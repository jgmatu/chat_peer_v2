with Ada.Command_Line;
with Ada.TexT_IO;
with S_Handler;
with Chat_Messages;
with List_Nodes;
with Basic;
with Body_Peer;

package body S_nodo is

	package ACL renames Ada.Command_Line;	
	package SH  renames S_Handler;
	package CM  renames Chat_Messages;
	package BP  renames Body_Peer;

	use type LLU.End_Point_Type;


	function "=" (Nick1 : ASU.Unbounded_String ; Nick2 : ASU.Unbounded_String) return Boolean is
	begin
		return ASU.To_String(Nick1) = ASU.To_String(Nick2);
	end "=";
	
	function "<" (Nick1 : ASU.Unbounded_String ; Nick2 : ASU.Unbounded_String) return Boolean is
	begin
		return ASU.To_String(Nick1) < ASU.To_String(Nick2);
	end "<";
	
	function ASU_String (Nick : ASU.Unbounded_String) return String is
	begin
		return ASU.To_String(Nick);
	end ASU_String;

	procedure Get_Port (Port : out Integer) is
	begin
		if ACL.Argument_Count = 1 then
			Port := Integer'Value(ACL.Argument(1));
			if Port < 1024 then
				debug.Put_line("El puerto debe ser un numero mayor de 1024" , pantalla.rojo);
				raise Constraint_Error;
			end if;
		else
			debug.Put_Line("ME has pasado mal el numero de parámetros en la entrada [Puerto]"  , pantalla.rojo);
			raise Constraint_Error;
		end if;
	exception
		when Constraint_Error =>
			debug.Put("Me has pasado mal el numero de puerto" , pantalla.rojo);
			raise;		
	end Get_Port;

	procedure Create_EP (EP : out LLU.End_Point_Type) is
		Port	     : Integer := 0;	
		Name_Machine : ASU.Unbounded_String;
		IP	     : ASU.Unbounded_String;
	begin
		Get_Port(Port);
		Name_Machine := ASU.To_Unbounded_String(LLU.Get_Host_Name);
		IP := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Name_Machine)));
		EP := LLU.Build(ASU.To_String(IP) , Port);				
	end Create_EP;


	function isLeave (Remark : ASU.Unbounded_String) return Boolean is
	begin
		return ASU.To_String(Remark) = ".quit";
	end isLeave;

	function isShowList (Remark : ASU.Unbounded_String) return Boolean is
	begin
		return ASU.To_String(Remark) = ".list";
	end isShowList;

	function isCommand (Remark : ASU.Unbounded_String) return Boolean is
	begin
		return isLeave(Remark) or isShowList(Remark);
	end isCommand;
	
	procedure leave_s_nodo (Remark : ASU.Unbounded_String ; Quit : out Boolean) is
	begin
		if isLeave(Remark) then
			Quit := True;
		end if;
	end leave_s_nodo;

	procedure Show_List (Remark : ASU.Unbounded_String) is
	begin	
		if isShowList(Remark) then
			debug.Put_Line("List Nodes" , pantalla.rojo);
			debug.Put_Line("==========", pantalla.rojo);
			debug.Put_Line(List_Nodes.Image(SH.List) , pantalla.rojo);
		end if;
	end Show_List;

	procedure Main_Command (Remark : ASU.Unbounded_String ; Quit : out Boolean) is
	begin
		show_list(Remark);
		leave_s_nodo(Remark , Quit);
	end Main_Command;

	procedure ShowListCommands is
	begin
		debug.Put_Line("        Commandas Super Node" , pantalla.rojo);
		debug.Put_Line("====================================" , pantalla.rojo);
		debug.Put_Line("    Status                  Command" , pantalla.rojo);
		debug.Put_Line("Show List Nick EP           .list" , pantalla.rojo);
		debug.Put_Line("Leave Super Node            .quit" , pantalla.rojo);
	end ShowListCommands;

	procedure Interfaz is
		Remark : ASU.Unbounded_String;	
		Quit   : Boolean := False;
	begin
		while not Quit loop
			Remark := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);		
			if isCommand(Remark) then
				Main_Command(Remark , Quit);
			else
				ShowListCommands;				
			end if;
		end loop;
	end Interfaz;

	-- Code Receive Handler

	procedure RCV_Req (P_Buffer : access LLU.Buffer_Type ; EP_H_Create : out LLU.End_Point_Type ; 
					EP_Receive : out  LLU.End_Point_Type ;  Nick : out ASU.Unbounded_String) is
	begin
		EP_H_Create := LLU.End_Point_Type'Input(P_Buffer);
		EP_Receive := LLU.End_Point_Type'Input(P_Buffer);
		Nick := ASU.Unbounded_String'Input(P_Buffer);
	end RCV_Req;	

	procedure Send_Deny (EP_Receive : LLU.End_Point_Type ; To : LLU.End_Point_Type) is
		Mess : CM.Message_Type := CM.S_Den;	
		Buffer : aliased LLU.Buffer_Type(1024);
	begin
		Ada.Text_IO.Put_Line("Deny Client to Chat...");
		CM.Message_Type'Output(Buffer'Access, Mess);
		LLU.End_Point_Type'Output(Buffer'Access , To);
		
		LLU.Send (EP_Receive , Buffer'Access);

	end Send_Deny;

	procedure Send_Empty (EP_Receive : LLU.End_Point_Type) is
		Buffer : aliased LLU.Buffer_Type (1024);
		Mess   : CM.Message_Type := CM.S_Rep;
		Num    : Integer := 0;
	begin
		Ada.Text_IO.Put_Line("Sending Message Neighbors Empty");
		LLU.Reset(Buffer);
		CM.Message_Type'Output(Buffer'Access , Mess);
		Integer'Output(Buffer'Access , Num);
		LLU.Send (EP_Receive , Buffer'Access);
	end Send_Empty;
	
	procedure Send_Neigh (EP_H_Create : LLU.End_Point_Type ; EP_Receive : LLU.End_Point_Type ; Nick : ASU.Unbounded_String) is
		Neighbors : List_Nodes.Last_Neighbors_T;
		Mess	  : CM.Message_Type := CM.S_Rep;	
		Buffer	  : aliased LLU.Buffer_Type(1024);
		Num : Integer;
		Pos : Integer;
	begin
		Neighbors := List_Nodes.Get_Latest_Neighbors(SH.List);
		Num := 0;
		if List_Nodes.Length(SH.List) = 0 then
			Ada.Text_IO.Put_Line("We have Empty List");
			Num := 0;
		elsif List_Nodes.Length(SH.List) = 1 then
			Ada.Text_IO.Put_Line("We have a Neighbor");
			Num := 1;
		else
			Ada.Text_IO.Put_Line("Go!! to Bring Neighbors!! =)");
			Num := 2;
		end if;
		-- Input Header Message
		CM.Message_Type'Output(Buffer'Access , Mess);
		Integer'Output(Buffer'Access , Num);
		Pos := 0;
		while Pos /= Num loop
			LLU.End_Point_Type'Output(Buffer'Access , Neighbors(Pos).EP);
			ASU.Unbounded_String'Output(Buffer'Access , Neighbors(Pos).Nick);
			Pos := Pos + 1;
		end loop;	 
		LLU.Send (EP_Receive , Buffer'Access);
		LLU.Reset(Buffer);

		-- We add Finally the EP to the List
		Ada.Text_IO.Put_Line("Add to List..." & ASU.To_String(Nick) & " " & Basic.EP_Image(EP_H_Create));
		List_Nodes.Put(SH.List , Nick , EP_H_Create);
	exception
		when List_Nodes.List_Empty =>
			Ada.Text_IO.Put_Line("List Empty!");
			Send_Empty(EP_Receive);
			Ada.Text_IO.Put_Line("Add to List..." & ASU.To_String(Nick) & " " & Basic.EP_Image(EP_H_Create));
			List_Nodes.Put(SH.List , Nick , EP_H_Create);
	end Send_Neigh;

	procedure Proc_Name (Nick : ASU.UnboundeD_string ; EP_H_Create : LLU.End_Point_Type ; 
								EP_Receive : LLU.End_Point_Type ; To : LLU.End_PoinT_Type) is
		Success : Boolean := False;	
		Neighbors : List_Nodes.Last_Neighbors_T;
		EP : LLU.End_Point_Type;
	begin
		List_Nodes.Get (SH.List , Nick , EP , Success);
--Ada.Text_IO.Put_Line("He encontrado el nodo en la lista de Nodos" & Boolean'Image(Success));
		if Success and List_Nodes.Length(SH.List) /= 0 then
			Send_Deny (EP_Receive , To);
		else 	
			Send_Neigh (EP_H_Create , EP_Receive , Nick);
		end if;
	end Proc_Name;

	procedure Proc_Req (To : LLU.End_Point_Type ; P_Buffer : access LLU.Buffer_Type) is
		Nick        : ASU.Unbounded_String;
		EP_Receive  : LLU.End_Point_Type;
		EP_H_Create : LLU.End_Point_Type;
	begin
		RCV_Req(P_Buffer , EP_H_Create , EP_Receive, Nick);
		Proc_Name(Nick , EP_H_Create ,  EP_Receive , To);
	end Proc_Req; 


	procedure Proc_Logout (To : LLU.End_Point_Type ; P_Buffer : access LLU.Buffer_Type) is	
		EP_H_Create  : LLU.End_Point_Type;
		Seq_N	     : CM.Seq_N_T := 0;
		EP_Rsnd      : LLU.End_Point_Type;
		Nick	     : ASU.Unbounded_String;
		Confirm_Send : Boolean := False;
		Success	     : Boolean := False;
	begin		
		BP.RCV_Logout(P_Buffer, EP_H_Create , Seq_N , EP_Rsnd , Nick , Confirm_Send);
		List_Nodes.Delete (SH.List , Nick , Success);
	
		if Success then
			Ada.Text_IO.Put_Line("Se ha borrado de forma satisfacoria el EP de la Lista");
		else
			Ada.TexT_IO.Put_Line("No se ha encontrado el EP en la lista");
		end if;
				
	end Proc_Logout;

end S_nodo;
