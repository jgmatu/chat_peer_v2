with Ada.Command_Line;
with Ada.Text_IO;
with debug;
with pantalla;
with Chat_Messages;
with Ada.Strings.Unbounded;

package body Check_Parameters is
	
	package ACL renames Ada.Command_Line;
	package CM  renames Chat_Messages;	
	package ASU renames Ada.Strings.UnboundeD;


	function Neccesary_Parameters return Boolean is
	begin
		return ACL.Argument_Count < Min_Parameters;
	end Neccesary_Parameters;

	function Neighbors_Check return Boolean is
	begin
		return ACL.Argument_Count rem 2 /= 1;
	end Neighbors_Check;
	
	function Delays return Boolean is
	begin
		return Integer'Value(ACL.Argument(3)) > Integer'Value(ACL.Argument(4));
	exception
		when Constraint_Error =>
			debug.Put_Line("Delay min y delay max must be integer numbers" , pantalla.rojo);
			raise;
	end Delays;

	function Fault_PCT return Boolean is
	begin
		return Integer'Value(ACL.Argument(5)) < 0 or Integer'Value(ACL.Argument(5)) > 100; 
	exception 
		when Constraint_Error =>
			debug.Put_Line("Fault_PCT must be a number between 0 and 100" , pantalla.rojo);
			raise;
	end Fault_PCT;

	function isS_Node return Boolean is
	begin
		return ACL.Argument_Count = 7 and Integer'Value(ACL.Argument(7)) = 0;
	exception 
		when Constraint_Error =>
			return False; 
	end isS_Node;

	function Check_S_Node return Boolean is
	begin
		if isS_Node then
			return Integer'Value(ACL.Argument(4)) > 1024;
		else
			return False;
		end if;
	exception
		when Constraint_Error =>
			debug.Put_Line("Me has pasado mal el numero de puerto del Super Nodo");
			raise;
	end Check_S_Node;

	procedure CheckParameters (S_Node : out Boolean) is 
	begin
		if isS_Node then
			s_Node := True;
		else
			if Neccesary_Parameters then
				raise Neccesary_Parameters_Error;
			end if;

			if Neighbors_Check then
				raise Neighbors_Check_Error;
			end if;

			if Delays  then
				raise Delays_Error;
			end if;
		
			if Fault_PCT then
				raise Error_Fault_PCT;
			end if;
			S_Node := False;
		end if;	
	end CheckParameters;

	procedure Bad_Parameters is
	begin		
		Debug.Put_Line("You have me passed bad the parameters : ./chat_peer port nickname min_delay max_delay" & 
										     " fault_pct [N1] [N2]" , Pantalla.Rojo);
	end Bad_Parameters;

	procedure Config_P5 is
		Min_Delay : Integer;
		Max_Delay : Integer;
		Fault_PCT : Integer;	
	begin	
		Min_Delay := Integer'Value(ACL.Argument(3));
		Max_Delay := Integer'Value(ACL.Argument(4));
		Fault_PCT := Integer'Value(ACL.Argument(5));

		LLU.Set_Faults_Percent(Fault_PCT);
		LLU.Set_random_propagation_delay(Min_Delay , Max_Delay);
		
		CM.Plazo_Retransmision := 2 * Duration(Max_Delay) / 1000;
		CM.Max_Retrans := 10 + (Fault_PCT/10)**2;
		CM.Plazo_Reject := 0.5 + (6 * Duration(Max_Delay)/1000);
	end Config_P5;

	procedure Create_S_Nodo (EP_S_Nodo : out LLU.End_Point_Type) is
		Machine_S : ASU.Unbounded_String;
		Port      : Integer;	
		IP   	  : ASU.Unbounded_String;
	begin
		Machine_S := ASU.To_Unbounded_String(ACL.Argument(3));
		Port := Integer'Value(ACL.Argument(4));
			
		IP := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Machine_S)));		

		EP_S_Nodo := LLU.Build(ASU.To_String(IP) , Port);				
	
	end Create_S_Nodo;

	procedure Config_P5_S_Nodo (EP_S_Nodo : out LLU.End_Point_Type) is	
		Min_Delay : Integer;
		Max_Delay : Integer;
		Fault_PCT : Integer;	
	begin
		Min_Delay := Integer'Value(ACL.Argument(5));
		Max_Delay := Integer'Value(ACL.Argument(6));
		Fault_PCT := Integer'Value(ACL.Argument(7));

		LLU.Set_Faults_Percent(Fault_PCT);
		LLU.Set_random_propagation_delay(Min_Delay , Max_Delay);
		
		CM.Plazo_Retransmision := 2 * Duration(Max_Delay) / 1000;
		CM.Max_Retrans := 10 + (Fault_PCT/10)**2;
		CM.Plazo_Reject := 0.5 + (6 * Duration(Max_Delay)/1000);

		Create_S_Nodo(EP_S_Nodo);
	end Config_P5_S_Nodo;

end Check_Parameters;
