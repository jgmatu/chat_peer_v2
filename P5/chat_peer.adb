with Ada.Command_Line;
with Debug;
with Pantalla;
with Lower_Layer_UDP;
with Chat_Handlers;
with Body_Peer;
with Help;
with Ada.Exceptions;
with Check_Parameters;
with Timed_Handlers;

procedure Chat_Peer is

	package ACL renames Ada.Command_Line;
	package LLU renames Lower_Layer_UDP;
	package BP  renames Body_Peer;
	package CH  renames Chat_Handlers;
	package CP  renames Check_Parameters;

	Error_Parameters : Exception;

	Port 		 : Integer := 0;

	EP_S_Nodo        : LLU.End_Point_Type;
	S_Node		 : Boolean := False;
	Success	         : Boolean := False;
	EP_Receive       : LLU.End_Point_Type;
	EP_H_Create      : LLU.End_Point_Type;
	Quit		 : Boolean := False;

begin
	--We send the starting parameters 
	CP.CheckParameters(S_Node);		
	
	-- Config P5
	if not S_Node then
		debug.Put_Line("You are Configurate without Super Node");
		CP.Config_P5;
	else
		CP.Config_P5_S_Nodo(EP_S_Nodo);
		debug.Put_Line("You are Configurate with Super Node");
	end if;	

   	Port := Integer'Value(ACL.Argument(1));

	BP.Create_EP(EP_H_Create,  Port);	

	-- we tie to the Admission End Point in the EP_Receive
	LLU.Bind_Any(EP_Receive);

	-- we create the running threath as to receive messages
	LLU.Bind(EP_H_Create , CH.Peer_Handler'Access);
	
	BP.Start_Peer (EP_H_Create , EP_Receive , Port , Quit , EP_S_Nodo , S_Node);	

	BP.Screen_Writer(EP_H_Create , EP_Receive , Quit , S_Node , EP_S_Nodo);

	LLU.Finalize;
	Timed_Handlers.Finalize;

exception

	when Error_Parameters =>
		CP.Bad_Parameters;
		LLU.Finalize;
		Timed_Handlers.Finalize;	

	when Constraint_Error =>
		CP.Bad_Parameters;				
		LLU.Finalize;
		Timed_Handlers.Finalize;

	when CP.Neccesary_Parameters_Error => 
		debug.Put_Line("You must pass five parameters of way obligatory" , pantalla.rojo);	
		CP.Bad_Parameters;
		LLU.Finalize;
		Timed_Handlers.Finalize;

	when CP.Neighbors_Check_Error =>
		debug.Put_Line("Ya are passing bad the neighbors" , pantalla.rojo);
		CP.Bad_Parameters;	
		LLU.Finalize;
		Timed_Handlers.Finalize;

	when CP.Delays_Error =>
		debug.Put_Line("delays min debe ser mayor que delay_max" , pantalla.rojo);
		CP.Bad_Parameters;
		LLU.Finalize;
		Timed_Handlers.Finalize;

	when CP.Error_Fault_PCT =>
		debug.Put_Line("Fault_PCT debe ser un numero entre 0 y 100" , pantalla.rojo);
		CP.Bad_Parameters;
		LLU.Finalize;
		Timed_Handlers.Finalize;

	when Except:others =>
		Debug.Put_Line("Imprevist Exception  : " & 
		Ada.Exceptions.Exception_Name (Except) & " en : " & Ada.Exceptions.Exception_Message(Except));
end Chat_Peer; 
