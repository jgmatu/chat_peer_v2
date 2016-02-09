-- Francisco Javier Gutierrez-Maturana Sanchez

with Debug;
with Pantalla;
with Maps_G;
with Aux_Peer;
with Time_String;
with Ada.Text_IO;
with Chat_Messages;

package body help is

	package AP renames Aux_Peer;	
	package TS renames Time_String;	
	package CM renames Chat_Messages;

	function isHelp (Comentario : ASU.Unbounded_String) return Boolean is
	begin
		return ASU.To_String(Comentario) = ".h" or ASU.To_String(Comentario) = ".help";
	end isHelp;
	
	function isQuit (Comentario :ASU.Unbounded_String) return Boolean is
	begin
		return ASU.To_String(Comentario) = ".quit";
	end isQuit;

	function isPrompt (Comentario : ASU.Unbounded_String) return Boolean is
	begin
		return ASU.To_String(Comentario) = ".prompt";
	end isPrompt;

	function isWhoamI (Comentario : ASU.Unbounded_String) return Boolean is
	begin
		return ASU.To_String(Comentario) = ".wai" or ASU.To_String(Comentario) = ".whoami";
	end isWhoamI;
	
	function isDebug (Comentario : ASU.Unbounded_String) return Boolean is
	begin
		return ASU.To_String(Comentario) = ".debug";	
	end isDebug;
	
	function isShowLatest_Msgs (Comentario : ASU.Unbounded_String) return Boolean is
	begin
		return ASU.To_String(Comentario) = ".latest_msgs" or ASU.To_String(Comentario) = ".lm";
	end isShowLatest_Msgs;
			
	function isShowNeighbors (Comentario : ASU.Unbounded_String) return Boolean is
	begin
		return ASU.To_String(Comentario) = ".neighbors" or ASU.To_String(Comentario) = ".nb";
	end isShowNeighbors;

	function Patron (Comentario : ASU.Unbounded_String) return Boolean is
		Result : Boolean := False;	
	begin	
		Result := isHelp(Comentario);
		Result := Result or isQuit(Comentario) or isPrompt(Comentario) or isWhoamI(Comentario);
		Result := Result or isDebug(Comentario) or isShowLatest_Msgs(Comentario) or isShowNeighbors(Comentario);
		return Result;
	end Patron;

	procedure Show_Help (Remark : ASU.Unbounded_String) is
	begin	
		if isHelp(Remark) then
			debug.Put_Line("       Commands            Effect" , pantalla.rojo);
			debug.Put_Line("       ==============      ======" , pantalla.rojo);
			debug.Put_Line("       .nb .neigbors       Shows neighbors list" , pantalla.rojo );
			debug.Put_Line("       .lm .latest_msgs    Shows latest messages list" , pantalla.rojo);
			debug.Put_Line("       .debug              Toggles debug info" , pantalla.rojo);
			debug.Put_Line("       .wai .whoami        Shows: nick | EP_H | EP_R" , pantalla.rojo);
	
			debug.Put_Line("       .prompt             Toogles showing prompt" , pantalla.rojo);
			debug.Put_Line("       .h .help            Shows this help info" , pantalla.rojo);
			debug.Put_Line("       .quit               Quits program" , pantalla.rojo);
		end if;		
	end Show_Help;
	
	procedure Leave_Chat (Quit : out Boolean ; EP_H_Create : LLU.End_Point_Type ; Seq_N : CH.Seq_N_T ; 
								Nick : ASU.Unbounded_String ; Remark :ASU.Unbounded_String) is 
		Confirm_Send : Boolean := True;
		Mess	: CM.Message_Type := CM.Logout;
	begin
		if isQuit(Remark) then
			Quit := True;	
			AP.Flood(EP_H_Create , Seq_N , EP_H_Create , null, Nick , EP_H_Create , Mess , Confirm_Send);
		end if;
	end Leave_Chat;

	procedure Show_Neighbors (Remark : ASU.Unbounded_String) is
		Keys_Neigh         : CH.NP_Neighbors.Keys_Array_Type;
		Values_Neigh       : CH.NP_Neighbors.Values_Array_Type;
		Pos : Integer;
		Num_Neigh    	   : Integer;
		Success	     	   : Boolean;
	begin
  
		if not isShowNeighbors(Remark) then
			return;
		end if;

		debug.Put_Line("        Neighbors " , Pantalla.Rojo);
		debug.Put_Line("        --------------- " , Pantalla.Rojo);			

		Keys_Neigh := CH.Neighbors.Get_Keys(CH.Map_Neighbors);
		Num_Neigh := CH.Neighbors.Map_Length(CH.Map_Neighbors); 
		Pos := 1;				
		while  Num_Neigh /= 0 and Pos <= Num_Neigh loop
			debug.Put("        [ " , Pantalla.Rojo);
			CH.Neighbors.Get (CH.Map_Neighbors , Keys_Neigh(Pos) , Values_Neigh(Pos), Success);
			debug.Put("(" & AP.EP_Image(Keys_Neigh(Pos))  & ")" , Pantalla.Rojo);
			debug.Put(" , " & TS.Image_2(Values_Neigh(Pos)) , pantalla.Rojo);			
			debug.Put(" ]" , Pantalla.Rojo);
			Pos := Pos + 1;
			Ada.Text_IO.New_Line;
		end loop;	

	end Show_Neighbors;

	procedure Show_Latest_Messages (Remark : ASU.Unbounded_String) is	
		Keys_Latest_Msgs   : CH.NP_Latest_Msgs.Keys_Array_Type;
		Values_Latest_Msgs : CH.NP_Latest_Msgs.Values_Array_Type;
		Pos	     	   : Integer;
		Num_Latest_Msgs	   : Integer;
		Success	     	   : Boolean;
	begin

		if not isShowLatest_Msgs(Remark) then
			return;		
		end if;

		debug.Put_Line("        Latest Messages " , Pantalla.Rojo);
		debug.Put_Line("        --------------- " , Pantalla.Rojo);			
		
		Keys_Latest_Msgs := CH.Latest_Msgs.Get_Keys(CH.Map_Latest_Messages);
		Num_Latest_Msgs := CH.Latest_Msgs.Map_Length(CH.Map_Latest_Messages);
		Pos := 1;
		while  Num_Latest_Msgs /= 0 and Pos <= Num_Latest_Msgs loop
			debug.Put("        [ " , Pantalla.Rojo);
			CH.Latest_Msgs.Get (CH.Map_Latest_Messages , Keys_Latest_Msgs(Pos) , 	
										Values_Latest_Msgs(Pos), Success);
			debug.Put("(" & AP.EP_Image(Keys_Latest_Msgs(Pos))  & ")" , Pantalla.Rojo);
			debug.Put(" , " & CH.Seq_N_T'Image(Values_Latest_Msgs(Pos)) , pantalla.Rojo);			
			debug.Put(" ]" , Pantalla.Rojo);
			Pos := Pos + 1;
			Ada.Text_IO.New_Line;
		end loop;		
	end Show_Latest_Messages;
	

	procedure Who_Am_I (Nick : ASU.Unbounded_String ; EP_H_Create : LLU.End_Point_Type ; 
						EP_Receive : LLU.End_Point_Type ; Remark : ASU.Unbounded_String) is
	begin
		if isWhoamI (Remark) then
			debug.Put("Nick : " , pantalla.rojo);
			debug.Put(ASU.To_String(Nick) , pantalla.rojo);
			debug.Put( " | " & "EP_H : " , pantalla.rojo);
			debug.Put(AP.EP_Image(EP_H_Create) & " | " , pantalla.rojo); 
			debug.Put("EP_R : " & AP.EP_Image(EP_Receive) , pantalla.rojo);
			debug.Put_Line("" , pantalla.rojo);
		end if;
	
	end Who_Am_I;

	procedure Activate_Debug (Status : in out Boolean ; Remark : ASU.Unbounded_String) is
	begin
		if isDebug(Remark) then
			Status := not Status;
			if Status then debug.Put_Line("Debug info activated" , pantalla.rojo); 
			else debug.Put_Line("Debug info deactivated" , pantalla.rojo); end if;   			
			Debug.Set_Status(Status);
		end if; 		
	end Activate_Debug;
	
	procedure Activate_Prompt (Prompt : in out Boolean ; Remark : ASU.Unbounded_String) is
	begin
		if isPrompt(Remark) then
			Prompt := not Prompt;		
			if Prompt then debug.Put_Line("Prompt activated" , pantalla.rojo); 
			else debug.Put_Line("Prompt deactivated" , pantalla.rojo); end if;
   		end if;
	end Activate_Prompt;

	procedure Main_Help (Remark : ASU.Unbounded_String ; Quit : out Boolean ; EP_H_Create : LLU.End_Point_Type ; 
				EP_Receive : LLU.End_Point_Type  ; Nick : ASU.Unbounded_String ; 
				Seq_N : CH.Seq_N_T ; Status  : in out Boolean ; Prompt : in out Boolean) is

	begin
		Debug.Set_Status(True);
	
		Show_Help(Remark);		

		Who_Am_I (Nick ,EP_H_Create , EP_Receive , Remark);

		Show_Neighbors(Remark);		

		Show_Latest_Messages(Remark);		

		Activate_Debug(Status , Remark);
		
		Activate_Prompt(Prompt , Remark);

		Debug.Set_Status(Status);

		Leave_Chat(Quit , EP_H_Create , Seq_N , Nick , Remark);

	end Main_Help;


end help;
