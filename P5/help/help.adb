-- Francisco Javier Gutierrez-Maturana Sanchez

with Debug;
with Pantalla;
with Maps_G;
with Body_Peer;
with Time_String;
with Ada.Text_IO;
with Basic;
with Chat_Handlers;
with Body_P5;
with Ada.Exceptions;

package body help is

	package BP  renames Body_Peer;	
	package TS  renames Time_String;	
	package CH  renames Chat_Handlers;
	package BP5 renames Body_P5;
	
	use type LLU.End_Point_Type;
	
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
	
	function isShow_Sender_Buffering (Remark : ASU.Unbounded_String) return Boolean is
	begin
		return ASU.To_String(Remark) = ".sb";
	end isShow_Sender_Buffering;
	function isShow_Sender_Dest (Remark : ASU.Unbounded_String) return Boolean is
	begin
		return ASU.To_String(Remark) = ".sd";
	end isShow_Sender_Dest;	
	
	function isShow_Topology (Remark : ASU.UnboundeD_String) return Boolean is
	begin
		return ASU.To_String(Remark) = ".top" or ASU.To_String(Remark) = ".topology"; 
	end isShow_Topology;


	function Patron (Remark : ASU.Unbounded_String) return Boolean is
		Result : Boolean := False;	
	begin	
		Result := isHelp(Remark);
		Result := Result or isQuit(Remark) or isPrompt(Remark) or isWhoamI(Remark);
		Result := Result or isDebug(Remark) or isShowLatest_Msgs(Remark) or isShowNeighbors(Remark);
		Result := Result or isShow_Sender_Buffering(Remark) or isShow_Sender_Dest(Remark);
		Result := Result or isShow_Topology(Remark);
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
			debug.Put_Line("       .sb                 Show Buffering" , pantalla.rojo);
			debug.Put_Line("       .sd                 Show Destinations" , pantalla.rojo);
			debug.Put_Line("       .top .topolgy       Show Network Topolgy" , pantalla.rojo);
		end if;		
	end Show_Help;

	procedure Show_Neighbors (Remark : ASU.Unbounded_String) is
		Keys_Neigh         : CH.Neighbors.Keys_Array_Type;
		Values_Neigh       : CH.Neighbors.Values_Array_Type;
		Pos : Integer;
		Num_Neigh    	   : Integer;
		Success	     	   : Boolean;
	begin
  		if isShowNeighbors(Remark) then		
			debug.Put_Line("        Neighbors " , Pantalla.Rojo);
			debug.Put_Line("        --------------- " , Pantalla.Rojo);			

			Keys_Neigh := CH.Neighbors.Get_Keys(CH.Map_Neighbors);
			Num_Neigh := CH.Neighbors.Map_Length(CH.Map_Neighbors); 
			Pos := 1;				
			while  Num_Neigh /= 0 and Pos <= Num_Neigh loop
				debug.Put("        [ " , Pantalla.Rojo);
				CH.Neighbors.Get (CH.Map_Neighbors , Keys_Neigh(Pos) , Values_Neigh(Pos), Success);
				debug.Put("(" & Basic.EP_Image(Keys_Neigh(Pos))  & ")" , Pantalla.Rojo);
				debug.Put(" , " & TS.Image_2(Values_Neigh(Pos)) , pantalla.Rojo);			
				debug.Put(" ]" , Pantalla.Rojo);
				Pos := Pos + 1;
				Ada.Text_IO.New_Line;
			end loop;	

		end if;
	end Show_Neighbors;

	procedure Show_Latest_Messages (Remark : ASU.Unbounded_String) is	
		Keys_Latest_Msgs   : CH.Latest_Msgs.Keys_Array_Type;
		Values_Latest_Msgs : CH.Latest_Msgs.Values_Array_Type;
		Pos	     	   : Integer;
		Num_Latest_Msgs	   : Integer;
		Success	     	   : Boolean;
	begin
		if isShowLatest_Msgs(Remark) then		
			debug.Put_Line("        Latest Messages " , Pantalla.Rojo);
			debug.Put_Line("        --------------- " , Pantalla.Rojo);			
		
			Keys_Latest_Msgs := CH.Latest_Msgs.Get_Keys(CH.Map_Latest_Messages);
			Num_Latest_Msgs := CH.Latest_Msgs.Map_Length(CH.Map_Latest_Messages);
			Pos := 1;
			while  Num_Latest_Msgs /= 0 and Pos <= Num_Latest_Msgs loop
				debug.Put("        [ " , Pantalla.Rojo);
				CH.Latest_Msgs.Get (CH.Map_Latest_Messages , Keys_Latest_Msgs(Pos) , 										Values_Latest_Msgs(Pos), Success);
				debug.Put("(" & Basic.EP_Image(Keys_Latest_Msgs(Pos))  & ")" , Pantalla.Rojo);
				debug.Put(" , " & CM.Seq_N_T'Image(Values_Latest_Msgs(Pos)) , pantalla.Rojo);			
				debug.Put(" ]" , Pantalla.Rojo);
				Pos := Pos + 1;
				Ada.Text_IO.New_Line;
			end loop;		
		end if;
	end Show_Latest_Messages;

	procedure Show_Sender_Buffering (Remark : ASU.Unbounded_String) is
			
	begin
		if isShow_Sender_Buffering(Remark) then
			debug.Put_Line("Sender Buffering" , pantalla.rojo);
			debug.Put_Line("================" , pantalla.rojo);
			CH.Sender_Buffering.Print_Map(CH.Map_Sender_Buffering);
		end if;
	end Show_Sender_Buffering; 

	
	procedure Show_Sender_Dest (Remark : ASU.Unbounded_String) is
	begin
		if isShow_Sender_Dest(Remark) then
			debug.Put_Line("Sender Destination" , pantalla.rojo);
			debug.Put_Line("================" , pantalla.rojo);
			CH.Sender_Dest.Print_Map(CH.Map_Sender_Dest);
		end if;
	end Show_Sender_Dest;

	procedure Who_Am_I (Nick : ASU.Unbounded_String ; EP_H_Create : LLU.End_Point_Type ; 
						EP_Receive : LLU.End_Point_Type ; Remark : ASU.Unbounded_String) is
	begin
		if isWhoamI (Remark) then
			debug.Put("Nick : " , pantalla.rojo);
			debug.Put(ASU.To_String(Nick) , pantalla.rojo);
			debug.Put( " | " & "EP_H : " , pantalla.rojo);
			debug.Put(Basic.EP_Image(EP_H_Create) & " | " , pantalla.rojo); 
			debug.Put("EP_R : " & Basic.EP_Image(EP_Receive) , pantalla.rojo);
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

	procedure Show_Topology (Remark : ASU.Unbounded_String) is
		Keys_Topology   : CH.Topology.Keys_Array_Type;
		Values_Topology : CH.Topology.Values_Array_Type;
		Num_EPs	        : Integer := 0;	
		Pos	        : Integer := 0;
	begin
		if isShow_Topology(Remark) then
			
			debug.Put_Line("        Network Topology " , Pantalla.Rojo);
			debug.Put_Line("        --------------- " , Pantalla.Rojo);			

			Num_EPs := CH.Topology.Map_Length(CH.Map_Topology);
			Keys_Topology := CH.Topology.Get_Keys(CH.Map_Topology);
			Values_Topology := CH.Topology.Get_Values(CH.Map_Topology);
			Pos := 0;
			for i in CH.Topology.Keys_Array_Type'Range loop
				if Keys_Topology(i) /= null then	
					debug.Put("Machine  " & Basic.EP_Image(Keys_Topology(i)) , pantalla.rojo);
					debug.Put_Line(" connected to  " , pantalla.rojo);
					debug.Put_Line(BP5.Neighbors_String(Values_Topology(i)) , pantalla.rojo);
					Pos := Pos + 1;
				end if;
			end loop;		
		end if;
	exception
		when Except:others =>
			Debug.Put_Line("Imprevist Exception  : " & 
			Ada.Exceptions.Exception_Name (Except) & " en : " & Ada.Exceptions.Exception_Message(Except));
	end Show_Topology;

	procedure Leave_Chat (Quit : out Boolean ; EP_H_Create : LLU.End_Point_Type ; Seq_N : CM.Seq_N_T ; 
							Nick : ASU.Unbounded_String ; Remark :ASU.Unbounded_String ; 
							S_Node : Boolean ; EP_S_Nodo : LLU.End_Point_Type) is 
		Confirm_Send : Boolean := True;
		Resend	     : Boolean := False;
		Mess         : CM.Message_Type := CM.Logout;
	begin
		if isQuit(Remark) then
			Quit := True;	
			BP.Flood(EP_H_Create , Seq_N , EP_H_Create , null, Nick , EP_H_Create , Mess , Resend , Confirm_Send);
			if S_Node then
				BP.Logout(EP_H_Create, Seq_N , EP_H_Create , Nick , Confirm_Send , Resend);
				LLU.Send(EP_S_Nodo,CM.P_Buffer_Main);
			end if;

			BP.Send_Bye(EP_H_Create ,  CH.Neighbors.Get_Keys(CH.Map_Neighbors));
Ada.Text_IO.Put_Line("Delay de  : "  & Duration	'Image(CM.Max_Retrans * CM.Plazo_Retransmision));
			delay CM.Max_Retrans * CM.Plazo_Retransmision;
		else
			Quit := False;
		end if;
	end Leave_Chat;

	procedure Main_Help (Remark : ASU.Unbounded_String ; Quit : out Boolean ; EP_H_Create : LLU.End_Point_Type ; 
				EP_Receive : LLU.End_Point_Type  ; Nick : ASU.Unbounded_String ; 
				Seq_N : CM.Seq_N_T ; Status  : in out Boolean ; Prompt : in out Boolean ; 
				S_Node : Boolean ; EP_S_Nodo : LLU.End_Point_Type) is

	begin

		Debug.Set_Status(True);
	
		Show_Help(Remark);	

		Who_Am_I (Nick ,EP_H_Create , EP_Receive , Remark);

		Show_Neighbors(Remark);		

		Show_Latest_Messages(Remark);		

		Activate_Debug(Status , Remark);
		
		Activate_Prompt(Prompt , Remark);

		Debug.Set_Status(Status);

		Show_Sender_Dest (Remark);
 	
		Show_Sender_Buffering (Remark);

		Show_Topology (Remark);

		Leave_Chat(Quit , EP_H_Create , Seq_N , Nick , Remark , S_Node , EP_S_Nodo);	
	end Main_Help;


end help;
