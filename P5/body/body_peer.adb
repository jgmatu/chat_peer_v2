-- Francisco Javier Gutierrez-Maturana Sanchez

with Ada.Text_IO;
with Debug;
with Pantalla;	
with Ada.Calendar;
with Help;
with Ada.Command_Line;
with Ada.Exceptions;
with Basic;
with Timed_Handlers;
with Example_Handlers;
with Ada.Calendar;
with Time_String;
with Body_P5;

package body Body_Peer is

	use type CM.Seq_N_T;
	use type LLU.End_Point_Type;
	use type CM.Message_Type;
	use type ASU.Unbounded_String;
	use type CM.Buffer_A_T;
	use type Ada.Calendar.Time;
	use type CH.Neighbors.Keys_Array_Type;


	package ACL renames Ada.Command_Line;
	package TH  renames Timed_Handlers;	
	package TS  renames Time_String;
	package BP5 renames Body_P5;

	Min_Parameters : constant := 5;

	function MyName return ASU.Unbounded_String is
	begin
		return ASU.To_Unbounded_String(ACL.Argument(2));
	end MyName;

	procedure Create_EP (EP_Handler : out LLU.End_Point_Type; Port : in Integer) is
		Machine_Name : ASU.Unbounded_String;
		Machine_IP   : ASU.Unbounded_String;	
	begin
		-- See our computer IP  
		Machine_Name := ASU.To_Unbounded_String(LLU.Get_Host_Name);
		Machine_IP   := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Machine_Name)));

		--Create our two EP's
		EP_Handler := LLU.Build(ASU.To_String(Machine_IP) , Port);
		
	end Create_EP;
		
	function Neighbors return Boolean is
	begin
		return (ACL.Argument_Count - Min_Parameters)/2 /= 0;
	end Neighbors;

	function isNeighbor (EP_H_Create : LLU.End_PoinT_Type ; EP_Rsnd : LLU.End_Point_Type) return Boolean is
	begin
		return EP_H_Create = EP_Rsnd;
	end isNeighbor;


	-- Create neighbors from Console 
	procedure Create_Neighbors (Neighbors : out Type_Neighbors ; Num_Neighbors : Integer) is
		Parametro : Integer;	
	begin
		-- We crate the parameters for sending then by flood
		Parametro := Min_Parameters + 1;
		for i in 1 .. Num_Neighbors loop
			Neighbors(i).Host := ASU.To_Unbounded_String(ACL.Argument(Parametro));
			Parametro := Parametro + 1;

			-- Check if the port is not between 1 and 1024
			if Integer'Value(ACL.Argument(Parametro)) > 1024 then
				Neighbors(i).Port := Integer'Value(ACL.Argument(Parametro));
			else
				debug.Put_Line("you can't use a port less than 1024" , pantalla.rojo);
			end if;
			Parametro := Parametro + 1;
		end loop;	
	exception 
		when Constraint_Error =>
			debug.Put_Line(" the number port must be a integer number",pantalla.rojo);
		when Except:others =>
			debug.Put_Line("Imprevist Exception :" &
			Ada.Exceptions.Exception_Name (Except) & " in : " & 
			Ada.Exceptions.Exception_Message (Except));
	end Create_Neighbors;

	-- Write Neighbors
	procedure Write_Neighbors (Neighbors : in Type_Neighbors ; Num_Neighbors : Integer) is
	begin
		for i in 1 .. Num_Neighbors loop
			Ada.Text_IO.Put_Line("Vencino " & ASU.TO_String(Neighbors(i).Host) &
			"  " & Integer'Image(Neighbors(i).Port));
		end loop;
	end Write_Neighbors;

	procedure Initial_Node (EP_H_Create : LLU.End_Point_Type ; Success : out Boolean) is
		Seq_N : CM.Seq_N_T := 1;
	begin

		debug.Put_Line("Not following admision protocol because we dont have initial initial contacts");	
		-- Inicial Latest Messages because wheather i cant send logout		
		CH.Latest_Msgs.Put(CH.Map_Latest_Messages, EP_H_Create, Seq_N , Success);

	end Initial_Node; 

	-- Recive Reply from Super Node
	procedure RCV_Rep (P_Buffer : access LLU.Buffer_Type ; EP_H_Create : LLU.End_Point_Type ; 
			   Success : out Boolean ; Quit : out Boolean) is
		Mess      : CM.Message_Type;
		EP_S_Node : LLU.End_Point_Type;
		Num_Neigh : Integer;
		Neighbor  : LLU.End_Point_Type;
		Nick	  : ASU.Unbounded_String;
		Time      : Ada.Calendar.Time := Ada.Calendar.Clock;
	begin
		Mess := CM.Message_Type'Input(P_Buffer);
		case Mess is
			when CM.S_Rep =>
				Success := True;
				Num_Neigh := Integer'Input(P_Buffer);				
				--Extract Neighbors and To Map_Neighbors
				for i in 1 .. Num_Neigh loop 
					Neighbor := LLU.End_Point_Type'Input(P_Buffer);
					Nick := ASU.Unbounded_String'Input(P_Buffer);
					debug.Put_Line("You have Added to : " & ASU.To_String(Nick));
					CH.Neighbors.Put(CH.Map_Neighbors , Neighbor , Time , Success);
				end loop;	
				if Num_Neigh = 0 then
					debug.Put_Line("Super Node Without Neighbors in his List");
					Initial_Node(EP_H_Create , Success);
					Success := False;
				end if;
			when CM.S_Den => 
				Ada.Text_IO.Put("Deny From :");
				EP_S_Node := LLU.End_Point_Type'Input(P_Buffer);
				Ada.Text_IO.Put_Line(Basic.EP_Image(EP_S_Node));
				Success := False;
				Quit := True;
			when others =>
				Success := False;
				Ada.Text_IO.Put_Line("This message is not for me...");
		end case;
	end RCV_Rep;

	-- We create the map with  the initial neighbors 
	procedure Create_Map_Neighbors (Map_Neighbors : out CH.Neighbors.Prot_Map ; EP_H_Create : LLU.End_Point_Type ; 
				 	Success : out Boolean ; S_Node : Boolean ; 
					P_Buffer : access LLU.Buffer_Type ; Quit : out Boolean) is
		Num_Neighbors : Integer;
		Neighbors     : Type_Neighbors;
		Neighbor_IP   : ASU.Unbounded_String;
		Neighbor_EP   : LLU.End_Point_Type;
		Time	      : Ada.Calendar.Time := Ada.Calendar.Clock;
		Pos	      : Integer;
		Mess	      : CM.Message_Type := CM.S_Req;
	begin
		Pos := 1;
		Success := True;
		-- Create Neighbors without or with Super Node
		if not S_Node then
			-- we count the given number of neighbours receive like parameters 			
			Num_Neighbors := (ACL.Argument_Count - 5)/2;
			Create_Neighbors(Neighbors , Num_Neighbors);
			loop
				Neighbor_IP := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Neighbors(Pos).Host)));
				Neighbor_EP := LLU.Build(ASU.To_String(Neighbor_IP) , Neighbors(Pos).Port);
				-- Depuration Messages
				debug.Put_Line("Adding to Neighbors " & ASU.To_String(Neighbor_IP) & " : " 												& Integer'Image(Neighbors(Pos).Port));
				CH.Neighbors.Put(Map_Neighbors , Neighbor_EP , Time , Success);
				Pos := Pos + 1;
			exit when not Success or Pos > Num_Neighbors;	
			end loop;
			Ada.TexT_IO.New_Line;
			Ada.TexT_IO.New_Line;
		else
			RCV_Rep(P_Buffer , EP_H_Create , Success , Quit);
		end if;
	end Create_Map_Neighbors;

	-- Debug Messages
	procedure Debug_Msgs (EP_H_Create : in LLU.End_Point_Type ; Seq_N : in CM.Seq_N_T ; Nick : in ASU.Unbounded_String) is
	begin
		debug.Put(" " & Basic.EP_Image(EP_H_Create) & " " & CM.Seq_N_T'Image(Seq_N) & " ");
		debug.Put_line(" " & Basic.EP_Image(EP_H_Create) & " " & ASU.To_String(Nick) & " ");	
 	end Debug_Msgs;

	procedure Init (EP_H_Create : LLU.End_Point_Type ; Seq_N : CM.Seq_N_T ;  Nick : ASU.Unbounded_String ;
						EP_Rsnd : LLU.End_Point_Type ;EP_Receive : LLU.End_Point_Type ; 
						Resend : Boolean) is
		Mess : CM.Message_Type := CM.Init;
	begin
		-- Debug Init Message for Flooding
		debug.Put("FLOOD INIT " , pantalla.Amarillo);
		Debug_Msgs(EP_H_Create , Seq_N , Nick);
		Ada.Text_IO.New_Line;
		if Resend then
--Debug.Put_Line("Envio de Mensaje por Reenvio " , pantalla.azul);
--Ada.Text_IO.New_Line;

			CM.P_Buffer_Handler := new LLU.Buffer_Type(1024);
			-- Prepare Buffer or Encapsulate Message Init
			CM.Message_Type'Output(CM.P_Buffer_Handler , Mess);
			LLU.End_Point_Type'Output(CM.P_Buffer_Handler , EP_H_Create);
			CM.Seq_N_T'Output(CM.P_Buffer_Handler , Seq_N);
			LLU.End_Point_Type'Output(CM.P_Buffer_Handler , EP_Rsnd);
			LLU.End_Point_Type'Output(CM.P_Buffer_Handler , EP_Receive);
			ASU.Unbounded_String'Output(CM.P_Buffer_Handler , Nick);
		else
--Debug.Put_Line("Mensaje Creado en Esta maquina" , pantalla.azul);
--Ada.Text_IO.New_Line;
			CM.P_Buffer_Main := new LLU.Buffer_Type(1024);

			-- Prepare Buffer or Encapsulate Message Init
			CM.Message_Type'Output(CM.P_Buffer_Main , Mess);
			LLU.End_Point_Type'Output(CM.P_Buffer_Main , EP_H_Create);
			CM.Seq_N_T'Output(CM.P_Buffer_Main , Seq_N);
			LLU.End_Point_Type'Output(CM.P_Buffer_Main , EP_Rsnd);
			LLU.End_Point_Type'Output(CM.P_Buffer_Main , EP_Receive);
			ASU.Unbounded_String'Output(CM.P_Buffer_Main , Nick);
		end if;		
	end Init;

	procedure Confirm (EP_H_Create : LLU.End_Point_Type ; Seq_N : CM.Seq_N_T  ; EP_Rsnd : LLU.End_Point_Type ; 
							Nick : ASU.Unbounded_String ; Resend : Boolean) is
		Mess : CM.Message_Type := CM.Confirm;
	begin
		-- Debug Messages for Flooding Confirmation
		debug.Put("FLOOD Confirm " , pantalla.Amarillo);	
		Debug_Msgs(EP_H_Create , Seq_N , Nick);
	
		if Resend then 
--debug.Put_Line("Mensaje de Reevio " , pantalla.azul);

			-- Encapsulate Confirmation Message Resend
			CM.P_Buffer_Handler := new LLU.Buffer_Type(1024);

			CM.Message_Type'Output(CM.P_Buffer_Handler , Mess);
			LLU.End_Point_Type'Output(CM.P_Buffer_Handler , EP_H_Create);
			CM.Seq_N_T'Output(CM.P_Buffer_Handler , Seq_N);
			LLU.End_Point_Type'Output(CM.P_Buffer_Handler , EP_Rsnd);
			ASU.Unbounded_String'Output(CM.P_Buffer_Handler , Nick);
		else 
--debug.Put_Line("Mensaje Creado en esta Maquina" , pantalla.azul);

			-- Encapsulate Confirmation Message Main
			CM.P_Buffer_Main := new LLU.Buffer_Type(1024);

			CM.Message_Type'Output(CM.P_Buffer_Main , Mess);
			LLU.End_Point_Type'Output(CM.P_Buffer_Main , EP_H_Create);
			CM.Seq_N_T'Output(CM.P_Buffer_Main , Seq_N);
			LLU.End_Point_Type'Output(CM.P_Buffer_Main , EP_Rsnd);
			ASU.Unbounded_String'Output(CM.P_Buffer_Main , Nick);
		end if;
	end Confirm;
	
	procedure Writer(EP_H_Create : LLU.End_Point_Type ; Seq_N : CM.Seq_N_T ; EP_Rsnd : LLU.End_Point_Type ; 
							    Nick : ASU.Unbounded_String ; Remark : ASU.Unbounded_String ;
							    Resend : Boolean) is
		Mess : CM.Message_Type := CM.Writer;	
	begin
		--Debug the  Writer's Messages  
		debug.Put("FLOOD Writer " , pantalla.amarillo);
		Debug_Msgs(EP_H_Create , Seq_N , Nick);

		if Resend then
--debug.Put_Line("Mensaje de Reenvio" , pantalla.azul);

			-- Encapsulate Writer's Message
			CM.P_Buffer_Handler := new LLU.Buffer_Type(1024);

			CM.Message_Type'Output(CM.P_Buffer_Handler , Mess);
			LLU.End_Point_Type'Output(CM.P_Buffer_Handler , EP_H_Create);	
			CM.Seq_N_T'Output(CM.P_Buffer_Handler , Seq_N);
			LLU.End_Point_Type'Output(CM.P_Buffer_Handler , EP_Rsnd);
			ASU.Unbounded_String'Output(CM.P_Buffer_Handler , Nick);	
			ASU.Unbounded_String'Output(CM.P_Buffer_Handler , Remark);		
		else 		
--debug.Put_Line("Mensaje Creado en esta Maquina" , pantalla.azul);

			-- Encapsulate Writer's Message
			CM.P_Buffer_Main := new LLU.Buffer_Type(1024);

			CM.Message_Type'Output(CM.P_Buffer_Main , Mess);
			LLU.End_Point_Type'Output(CM.P_Buffer_Main , EP_H_Create);	
			CM.Seq_N_T'Output(CM.P_Buffer_Main , Seq_N);
			LLU.End_Point_Type'Output(CM.P_Buffer_Main , EP_Rsnd);
			ASU.Unbounded_String'Output(CM.P_Buffer_Main , Nick);	
			ASU.Unbounded_String'Output(CM.P_Buffer_Main , Remark);				
		end if;
	end Writer;


	procedure Logout  (EP_H_Create : LLU.End_Point_Type ; Seq_N : CM.Seq_N_T ; EP_Rsnd : LLU.End_Point_Type ; 
				Nick : ASU.Unbounded_String ; Confirm_Send : Boolean ; Resend : Boolean) is
		Mess : CM.Message_Type := CM.Logout;
	begin
		-- Debug Logout Messages
		debug.Put("FLOOD Logout " , pantalla.amarillo);
		Debug_Msgs(EP_H_Create , Seq_N , Nick);

		if Resend then
--debug.Put_Line("Mensaje de Reenvio", pantalla.azul);

			-- Encapsulate Logout Message Resend

			CM.P_Buffer_Handler := new LLU.Buffer_Type(1024);

			CM.Message_Type'Output(CM.P_Buffer_Handler , Mess);
			LLU.End_Point_Type'Output(CM.P_Buffer_Handler , EP_H_Create);
			CM.Seq_N_T'Output(CM.P_Buffer_Handler , Seq_N);
			LLU.End_Point_Type'Output(CM.P_Buffer_Handler , EP_Rsnd);
			ASU.Unbounded_String'Output(CM.P_Buffer_Handler , Nick);
			Boolean'Output(CM.P_Buffer_Handler , Confirm_Send);
		else
--debug.Put_Line("Mensaje Creado en esta maquina" , pantalla.azul);

			-- Encapsulate Logout Message Main
			CM.P_Buffer_Main := new LLU.Buffer_Type(1024);

			CM.Message_Type'Output(CM.P_Buffer_Main , Mess);
			LLU.End_Point_Type'Output(CM.P_Buffer_Main , EP_H_Create);
			CM.Seq_N_T'Output(CM.P_Buffer_Main , Seq_N);
			LLU.End_Point_Type'Output(CM.P_Buffer_Main , EP_Rsnd);
			ASU.Unbounded_String'Output(CM.P_Buffer_Main , Nick);
			Boolean'Output(CM.P_Buffer_Main , Confirm_Send);	
		end if;

	end Logout;

	procedure Hello (EP_H_Create : LLU.End_Point_Type ; Seq_N : CM.Seq_N_T ; EP_Rsnd : LLU.End_Point_Type ; 
								Nick : ASU.Unbounded_String ; Resend : Boolean ; 
								Keys_Neigh : CH.Neighbors.Keys_Array_Type) is
		Mess : CM.Message_Type := CM.Hello;	
	begin	

		debug.Put("FLOOD Hello " , pantalla.amarillo);
		Debug_Msgs(EP_H_Create , Seq_N , Nick);

		if Resend then
			CM.P_Buffer_Handler := new LLU.Buffer_Type(1024);
			CM.Message_Type'Output(CM.P_Buffer_Handler , Mess);
			LLU.End_Point_Type'Output(CM.P_Buffer_Handler , EP_H_Create);
			CM.Seq_N_T'Output(CM.P_Buffer_Handler , Seq_N);
			LLU.End_Point_Type'Output(CM.P_Buffer_Handler , EP_Rsnd);						
			ASU.Unbounded_String'Output(CM.P_Buffer_Handler , Nick);
			CH.Neighbors.Keys_Array_Type'Output(CM.P_Buffer_Handler , Keys_Neigh);
		else
			CM.P_Buffer_Main := new LLU.Buffer_Type(1024);
			CM.Message_Type'Output(CM.P_Buffer_Main , Mess);
			LLU.End_Point_Type'Output(CM.P_Buffer_Main , EP_H_Create);
			CM.Seq_N_T'Output(CM.P_Buffer_Main , Seq_N);
			LLU.End_Point_Type'Output(CM.P_Buffer_Main , EP_Rsnd);
			ASU.Unbounded_String'Output(CM.P_Buffer_Main , Nick);
			CH.Neighbors.Keys_Array_Type'Output(CM.P_Buffer_Main , Keys_Neigh);
		end if;

	end Hello;

	procedure UPDATE (EP_H_Create : LLU.End_Point_Type ; Seq_N : CM.Seq_N_T ;  EP_Rsnd : LLU.End_Point_Type ; 
							  Keys_Neigh : CH.Neighbors.Keys_Array_Type ; Resend : Boolean) is
		Mess : CM.Message_Type := CM.UPDATE;
	begin

		debug.Put("FLOOD UPDATE " , pantalla.amarillo);
		debug.Put_Line(" " & Basic.EP_Image(EP_H_Create) & " " & CM.Seq_N_T'Image(Seq_N) & " ");

		if Resend then
			CM.P_Buffer_Handler := new LLU.Buffer_Type(1024);
			CM.Message_Type'Output(CM.P_Buffer_Handler , Mess);
			LLU.End_Point_Type'Output(CM.P_Buffer_Handler , EP_H_Create);
			CM.Seq_N_T'Output(CM.P_Buffer_Handler , Seq_N);
			LLU.End_Point_Type'Output(CM.P_Buffer_Handler , EP_Rsnd);
			CH.Neighbors.Keys_Array_Type'Output(CM.P_Buffer_Handler , Keys_Neigh);
		else
			CM.P_Buffer_Main := new LLU.Buffer_Type(1024);
			CM.Message_Type'Output(CM.P_Buffer_Main , Mess);
			LLU.End_Point_Type'Output(CM.P_Buffer_Main , EP_H_Create);
			CM.Seq_N_T'Output(CM.P_Buffer_Main , Seq_N);
			LLU.End_Point_Type'Output(CM.P_Buffer_Main , EP_Rsnd);
			CH.Neighbors.Keys_Array_Type'Output(CM.P_Buffer_Main , Keys_Neigh);
		end if;

	end UPDATE;


	procedure BYE (EP_H_Create : LLU.End_Point_Type ; Seq_N : CM.Seq_N_T ; EP_Rsnd : LLU.End_Point_Type ; 
								Keys_Neigh : CH.Neighbors.Keys_Array_Type ; Resend : Boolean) is
		Mess : CM.Message_Type := CM.Bye;		
	begin

		debug.Put("FLOOD BYE " , pantalla.amarillo);
		debug.Put_Line(" " & Basic.EP_Image(EP_H_Create) & " " & CM.Seq_N_T'Image(Seq_N) & " ");

		if Resend then
			CM.P_Buffer_Handler := new LLU.Buffer_Type(1024);
			CM.Message_Type'Output(CM.P_Buffer_Handler , Mess);
			LLU.End_Point_Type'Output(CM.P_Buffer_Handler , EP_H_Create);
			CM.Seq_N_T'Output(CM.P_Buffer_Handler , Seq_N);
			LLU.End_Point_Type'Output(CM.P_Buffer_Handler , EP_Rsnd);
			CH.Neighbors.Keys_Array_Type'Output(CM.P_Buffer_Handler , Keys_Neigh);
		else
			CM.P_Buffer_Main := new LLU.Buffer_Type(1024);
			CM.Message_Type'Output(CM.P_Buffer_Main , Mess);
			LLU.End_Point_Type'Output(CM.P_Buffer_Main , EP_H_Create);
			CM.Seq_N_T'Output(CM.P_Buffer_Main , Seq_N);
			LLU.End_Point_Type'Output(CM.P_Buffer_Main , EP_Rsnd);
			CH.Neighbors.Keys_Array_Type'Output(CM.P_Buffer_Main , Keys_Neigh);
		end if;
	end BYE;

	function Out_Logout (Mess : CM.Message_Type ; Success : Boolean) return Boolean is
	begin
		return Mess = CM.Logout and not Success;
	end Out_Logout;

	function isLatestMsgs (Seq_N : CM.Seq_N_T ; Value : CM.Seq_N_T ; Success : Boolean) return Boolean is
	begin
		return (Seq_N <= Value and Success);
	end isLatestMsgs;

--	function Special_Logout (Seq_N : CM.Seq_N_T ; Mess : CM.Message_Type ; Confirm_Send : Boolean ; Success : Boolean)
--													      return Boolean is
--	begin
--		return Seq_N = 3 and Mess = CM.Logout and Confirm_Send = True and Success = False;
--	end Special_Logout; 

	-- Control Flood
	function noFlood (Seq_N : CM.Seq_N_T ; Value : CM.Seq_N_T ;EP_Not_Send : LLU.End_Point_Type ;  
				Success : Boolean ; Mess : CM.Message_Type ; Confirm_Send : Boolean := False) return Boolean is
		Result : Boolean := False;
	begin
		Result := isLatestMsgs(Seq_N , Value , Success) or Out_Logout(Mess , Success);
		--Result := Result and not special_Logout(Seq_N , Mess , Confirm_Send , Success);		
		return Result;
	end noFlood;

	function Destinations_Null return CM.Destinations_T is
		Destinations : CM.Destinations_T;	
	begin
		for i in CM.Destinations_T'Range loop
			Destinations(i).EP := null;
			Destinations(i).Retries := 0;
		end loop;
		return Destinations;
	end Destinations_Null;

	function Mess_ID_Null return CM.Mess_ID_T is
		Mess_ID : CM.Mess_ID_T;
	begin
		Mess_ID.EP := null;
		Mess_ID.Seq := 0;
		return Mess_ID;
	end Mess_ID_Null;
	
	-- Send Message To My Neighbors
	procedure Send_Message (Resend : Boolean ; EP_Not_Send : LLU.End_Point_Type ; EP_H_Create : LLU.End_Point_Type ;
													Seq_N : CM.Seq_N_T) is
		Neighbors    : CH.Neighbors.Keys_Array_Type;
		Num_Neigh    : Natural := 0; 	
		Destinations : CM.Destinations_T;
		Mess_ID	     : CM.Mess_ID_T; 
		Value 	     : CM.Value_T;
		Time	     : Ada.Calendar.Time := Ada.Calendar.Clock + CM.Plazo_Retransmision;
		Senders      : Natural := 0;
	begin		
		--Inicialize Simbol Tables
		Destinations := Destinations_Null;
		Mess_ID := Mess_ID_Null;

		-- Key Mess_ID
		Mess_ID.EP  := EP_H_Create;
		Mess_ID.Seq := Seq_N;
	
		-- Get the neighbors list
		Neighbors := CH.Neighbors.Get_Keys(CH.Map_Neighbors);
		Num_Neigh := CH.Neighbors.Map_Length(CH.Map_Neighbors);

		-- Send The Messages to the Neighbors except the client who sent the message
		for i in 1 .. Num_Neigh loop
			if Neighbors(i) /= EP_Not_Send then
				if Resend then		
					LLU.Send(Neighbors(i) , CM.P_Buffer_Handler);
				else
					LLU.Send(Neighbors(i) , CM.P_Buffer_Main); 
				end if;
				-- Select Destinations 
				Destinations(i).EP := Neighbors(i);
				Destinations(i).Retries := 0;
				Senders := Senders + 1;				
				debug.Put_Line("        send to : " & Basic.EP_Image(Neighbors(i)));
			else
				debug.Put_Line("NO FLOOD" , pantalla.amarillo);
			end if;
		end loop; 	

		if Resend then
			Value.P_Buffer := CM.P_Buffer_Handler;
		else
			Value.P_Buffer := CM.P_Buffer_Main;	
		end if;

		if Senders /= 0 then

			-- Add First Send_Destinations
			CH.Sender_Dest.Put(CH.Map_Sender_Dest , Mess_ID , Destinations);

			-- Add First Send_Buffering
			Value.EP_H_Creat := EP_H_Create;
			Value.Seq_N := Seq_N;
			CH.Sender_Buffering.Put(CH.Map_Sender_Buffering , Time , Value);
   			Timed_Handlers.Set_Timed_Handler (Time,	Example_Handlers.Retransmision'Access);
		end if;
	end Send_Message;

	-- Add To LAtest Messages
	procedure Add_Latest_Messages (EP_H_Create : LLU.End_Point_Type ; Seq_N : CM.Seq_N_T) is
		Success : Boolean := False;	
	begin
		-- Debug Messages by Adding it to the Latest Messages
		debug.Put("        Adding to Latest Messages " & Basic.EP_Image(EP_H_Create) & CM.Seq_N_T'Image(Seq_N));
		CH.Latest_Msgs.Put(CH.Map_Latest_Messages , EP_H_Create , Seq_N  , Success);
		if Success then debug.Put_Line(" OK"); else debug.Put_Line(" FAIL"); end if;
	end Add_Latest_Messages;

	function Neigh_Empty return CH.NP_Neighbors.Keys_Array_Type is
		Key_Neighs : CH.Neighbors.Keys_Array_Type;
	begin
		for i in CH.Neighbors.Keys_Array_Type'Range loop
			Key_Neighs(i) := null;
		end loop;
		return Key_Neighs;
	end Neigh_Empty;

	-- Send by Flooding
	procedure Flood (EP_H_Create : LLU.End_Point_Type ; Seq_N : in CM.Seq_N_T ; EP_Rsnd : 
						LLU.End_Point_Type; EP_Receive : LLU.End_Point_Type := null ; 
						Nick : 	ASU.Unbounded_String ; EP_Not_Send : LLU.End_Point_Type ; 
						Mess : CM.Message_Type; Resend : Boolean ; Confirm_Send : in Boolean := False ; 
						Remark : ASU.Unbounded_String := ASU.Null_Unbounded_String ;
						Keys_Neigh : CH.NP_Neighbors.Keys_Array_Type := Neigh_Empty) is
		Value	    : CM.Seq_N_T;
		Success	    : Boolean;	
	begin
		-- Show Latest_Messages EP_H_Create
   		CH.Latest_Msgs.Get (CH.Map_Latest_Messages, EP_H_Create, Value, Success);
		
		if not noFlood (Seq_N , Value , EP_Not_Send , Success , Mess , Confirm_Send) then

			Add_Latest_Messages(EP_H_Create , Seq_N);

			case Mess is

				when CM.Init =>

					Init(EP_H_Create, Seq_N , Nick , EP_Rsnd , EP_Receive , Resend);

				when CM.Confirm =>

					Confirm(EP_H_Create , Seq_N  , EP_Rsnd , Nick , Resend);

				when CM.Writer =>

					Writer(EP_H_Create , Seq_N , EP_Rsnd , Nick ,  Remark , Resend);

				when CM.Logout =>

					Logout(EP_H_Create , Seq_N , EP_Rsnd , Nick , Confirm_Send , Resend);

				when CM.Hello =>

					Hello(EP_H_Create , Seq_N , EP_Rsnd , Nick , Resend , Keys_Neigh);
	
				when CM.UPDATE =>

					UPDATE(EP_H_Create , Seq_N , EP_Rsnd , Keys_Neigh , Resend);
				
				when CM.Bye =>
						
					BYE (EP_H_Create , Seq_N , EP_Rsnd , Keys_Neigh , Resend);

				when others =>
					debug.Put_Line("This messages is not sended by flood" , pantalla.azul);
			end case;
			Send_Message(Resend , EP_Not_Send , EP_H_Create , Seq_N);
		else 
			debug.Put_Line("NO FLOOD" , pantalla.amarillo);	
		end if;
	end Flood;

	-- Wait a Message Reject
	function isReject (EP_Receive : LLU.End_Point_Type) return Boolean is
		Expired : Boolean := False;
		Buffer  : aliased LLU.Buffer_Type (1024);
	begin
		LLU.Reset(Buffer);
		-- Wait to receive Rejection message
		LLU.Receive(EP_Receive , Buffer'Access , CM.Plazo_Reject , Expired);
		if not Expired then debug.Put_Line("RCV Reject" , pantalla.amarillo); end if;
		-- If not Expired is because we have received a Reject Message
		return not Expired;
	end isReject;


	-- Send Message Reject
	procedure Reject (EP_H : LLU.End_Point_Type ; EP_Receive : LLU.End_Point_Type ; Nick : ASU.Unbounded_String) is
		Mess   : CM.Message_Type;	
	begin	
		CM.P_Buffer_Main := new LLU.Buffer_Type(1024);

		debug.Put("Send REJECT " , pantalla.amarillo);
		debug.Put(Basic.EP_Image(EP_Receive) & " " );
		debug.Put_Line(ASU.To_String(Nick) & "  ...");
		Mess := CM.Reject;

		-- Prepare Buffer
		CM.Message_Type'Output(CM.P_Buffer_Main , Mess);
		LLU.End_Point_Type'Output(CM.P_Buffer_Main , EP_H);
		ASU.Unbounded_String'Output(CM.P_Buffer_Main , Nick);
	
		-- Send Message
		LLU.Send(EP_Receive , CM.P_Buffer_Main);

	end Reject;

	procedure Update_Field_EP (EP_Rsnd : out LLU.End_Point_Type ; EP_Not_Send : out LLU.End_Point_Type ; 
						EP_Rsnd_New : LLU.End_Point_Type ; EP_Not_Send_New : LLU.End_Point_Type) is
	begin
		EP_Rsnd := EP_Rsnd_New;
		EP_Not_Send := EP_Not_Send_New;
	end Update_Field_EP;


	procedure Prepare_Logout_Creater (EP_H_Create : LLU.End_Point_Type ; Seq_N :  out CM.Seq_N_T ; 
		EP_Rsnd : out LLU.End_Point_Type ; EP_Not_Send : out LLU.End_Point_Type ; Mess :  out CM.Message_Type) is
	begin
		Seq_N := 3;
		Update_Field_EP(EP_Rsnd , EP_Not_Send , EP_H_Create , EP_H_Create);
		Mess	:= CM.Logout;
	end Prepare_Logout_Creater;	


	procedure Prepare_Confirm_Creater (EP_H_Create : LLU.End_Point_Type ; Seq_N :  out CM.Seq_N_T ; EP_Rsnd : out 					LLU.End_Point_Type ; EP_Not_Send : out LLU.End_Point_Type ; Mess :  out CM.Message_Type) is
	begin
		Seq_N := 2;
		Update_Field_EP(EP_Rsnd , EP_Not_Send , EP_H_Create , EP_H_Create);
		Mess	:= CM.Confirm;
	end Prepare_Confirm_Creater;	

	procedure Prepare_Hello (EP_H_Create : LLU.End_Point_Type ; Seq_N :  out CM.Seq_N_T ; EP_Rsnd : out   						LLU.End_Point_Type ; EP_Not_Send : out LLU.End_Point_Type ; 
					Keys_Neigh : out CH.Neighbors.Keys_Array_Type ; Mess :  out CM.Message_Type) is
	begin
		Keys_Neigh := CH.Neighbors.Get_Keys(CH.Map_Neighbors);
		Seq_N := 3;
		Update_Field_EP(EP_Rsnd , EP_Not_Send , EP_H_Create , EP_H_Create);
		Mess	:= CM.Hello;
	end Prepare_Hello;

	-- Protocol Admision
	procedure Admision_Protocol (EP_H_Create : LLU.End_Point_Type ; EP_Receive : LLU.End_Point_Type ; Quit : out Boolean) is
		Mess        : CM.Message_Type := CM.Init;
		Seq_N       : CM.Seq_N_T := 1;
		EP_Rsnd     : LLU.End_Point_Type;
		EP_Not_Send : LLU.End_Point_Type;	
		NickName    : ASU.Unbounded_String;
		Resend	    : Boolean := False;
		Success	    : Boolean := False;
		Keys_Neigh  : CH.NP_Neighbors.Keys_Array_Type;
	begin
		NickName := Myname;
		Update_Field_EP(EP_Rsnd , EP_Not_Send , EP_H_Create , EP_H_Create);		
		Flood(EP_H_Create , Seq_N , EP_Rsnd , EP_Receive , NickName , EP_Not_Send , Mess , Resend);
		if isReject(EP_Receive) then
			Prepare_Logout_Creater(EP_H_Create , Seq_N , EP_Rsnd, EP_Not_Send , Mess);
			Flood(EP_H_Create , Seq_N , EP_Rsnd , EP_Receive , NickName , EP_Not_Send , Mess , Resend);
			Quit := True;
			delay CM.Plazo_Retransmision;
		else	
			Prepare_Confirm_Creater(EP_H_Create , Seq_N , EP_Rsnd, EP_Not_Send , Mess);
			Flood(EP_H_Create , Seq_N , EP_Rsnd , EP_Receive , NickName , EP_Not_Send , Mess , Resend);
			delay 1.0;	
			Prepare_Hello (EP_H_Create , Seq_N , EP_Rsnd , EP_Not_Send, Keys_Neigh , Mess);
			Flood (EP_H_Create , SeQ_N , EP_Rsnd , EP_Receive , NickName , EP_Not_Send , Mess , Resend ,  
									False , ASU.Null_Unbounded_String , Keys_Neigh);
			Quit := False;
		end if;	
	end Admision_Protocol;
	
	function notShow(Seq_N : CM.Seq_N_T ; Value : CM.Seq_N_T ; Success : Boolean ; Mess : CM.Message_Type
									; Confirm_Send : Boolean := False) return Boolean is
		Result : Boolean;
	begin
		Result := (Seq_N <= Value and Success);
                Result := Result or Out_Logout(Mess, Success);
		--Result := Result and not special_Logout(Seq_N , Mess , Confirm_Send , Success);
		return Result;
	end notShow; 

	procedure Screen_Control (Map_Latest_Messages : in out CH.Latest_Msgs.Prot_Map ; EP_H_Create : LLU.End_Point_Type ; 
								Seq_N : CM.Seq_N_T ; Nick : ASU.Unbounded_String ;  									Mess : CM.Message_Type ; 
								Remark : ASU.Unbounded_String := ASU.Null_Unbounded_String) is
		Value  : CM.Seq_N_T := 0;
		Success   : Boolean := False;
	begin
		-- Control for a lot of neighbors
		CH.Latest_Msgs.Get(Map_Latest_Messages , EP_H_Create , Value , Success);		
		if not notShow(Seq_N , Value , Success , Mess) then
			case Mess is
				when CM.Confirm =>
					-- Show on the screen  who  is Joining the chat room
					Ada.Text_IO.Put_Line(ASU.To_String(Nick) & " joins to Chat");
				when CM.Writer =>
					-- Show the Remark on Screen 		
					Ada.Text_IO.Put_Line(ASU.To_String(Nick) & " :" & ASU.To_String(Remark));
				when CM.Logout =>
					--if Seq_N = 3 then Seq_N := 4 end if;
					Ada.Text_IO.Put_Line(ASU.To_String(Nick) & " leaves the chat");
				when others =>
					Ada.Text_IO.Put_Line("*****");				
			end case;	
		end if;
--Ada.Text_IO.Put_Line("No Mostrar!!");
	end Screen_Control;	

	procedure Screen_Writer (EP_H_Create : LLU.End_Point_Type ; EP_Receive : LLU.End_Point_Type ; Quit : in out Boolean ; 								S_Node : Boolean := False ; EP_S_Node : LLU.End_Point_Type) is
		Mess        : CM.Message_Type := CM.Writer;
		Seq_N       : CM.Seq_N_T := 0;
		Remark      : ASU.Unbounded_String;	
		EP_Rsnd     : LLU.End_Point_Type;
		EP_Not_Send : LLU.End_Point_Type;
		Status      : Boolean := True;
		Prompt 	    : Boolean := False;
		NickName    : ASU.Unbounded_String;
		Resend	    : Boolean := False;
		Success	    : Boolean := False;
	begin		

		-- Begin Chat
		if not Quit then
			Ada.Text_IO.Put_Line("Chat Peer v2.0");
			Ada.TexT_IO.Put_Line("=========");
			Ada.TexT_IO.Put_Line("Logging into chat with nick : " & ASU.TO_String(NickName));
			Ada.Text_IO.Put_Line(".h for help");
			-- All the Mess Messagers from this point are Writer
			Mess := CM.Writer;
			-- EP_Rsnd and EP_Not_Send and EP_H_Create are  the same field
			Update_Field_EP (EP_Rsnd , EP_Not_Send , EP_H_Create , EP_H_Create); 

			NickName := Myname;
		end if;

		-- Writer's Interface on the screen
		while not Quit loop			
			Remark := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);

			CH.Latest_Msgs.Get(CH.Map_Latest_Messages , EP_H_Create , Seq_N , Success);	
			Seq_N := Seq_N + 1;

			if Help.Patron(Remark) then
				Help.Main_Help(Remark , Quit , EP_H_Create , EP_Receive , NickName , Seq_N , Status,  
				Prompt , S_Node , EP_S_Node);
			else
				if ASU.TO_String(Remark) /= "" then
					Flood(EP_H_Create ,Seq_N , EP_Rsnd, null, NickName , EP_Not_Send , Mess, Resend , 
														False , Remark);
				end if;
			end if;

			if Prompt then
				Ada.Text_IO.Put(ASU.To_String(NickName) & " >> ");
			end if;

		end loop;
	end Screen_Writer;	

	-- Debug Messages by Adding to Neighbors and Add Neighbors			
	procedure Add_Neighbors (EP_H_Create : in LLU.End_Point_Type ; EP_Rsnd : in LLU.End_Point_Type) is
		Time_Value   : Ada.Calendar.Time;
		Success : Boolean := False;			
	begin		
		Time_Value := Ada.Calendar.Clock;		
		if isNeighbor(EP_H_Create , EP_Rsnd) then
			debug.Put("        Adding to Neighbors " & Basic.EP_Image(EP_H_Create));
			CH.Neighbors.Put(CH.Map_Neighbors , EP_H_Create , Time_Value , Success);
			if Success then debug.Put_Line(" OK"); else debug.Put_Line(" FAIL"); end if;
		end if;
	end Add_Neighbors;


	procedure Send_ACK (To : LLU.End_Point_Type ; EP_H_Create : LLU.End_Point_Type ; EP_Rsnd : LLU.End_Point_Type ; 
													Seq_N : CM.Seq_N_T) is
		Mess : CM.Message_Type := CM.ACK;
	begin
		Debug.Put("SEND ACK " , pantalla.amarillo);

		Debug.Put_Line(Basic.EP_Image(EP_Rsnd) &  " " & CM.Seq_N_T'Image(Seq_N) , pantalla.azul);	
		
		CM.P_Buffer_Main := new LLU.Buffer_Type(1024);

		CM.Message_Type'Output(CM.P_Buffer_Main , Mess);
		LLU.End_Point_Type'Output(CM.P_Buffer_Main , To);
		LLU.End_Point_TYpe'Output(CM.P_Buffer_Main , EP_H_Create);
		CM.Seq_N_T'Output(CM.P_Buffer_Main , Seq_N);
		
		LLU.Send(EP_Rsnd , CM.P_Buffer_Main);
	end Send_ACK;

	-- Functions of Ordered Messages

	function Next_Message (Value_Seq : CM.Seq_N_T ; Seq_N : CM.Seq_N_T ; Success : Boolean ; Mess : CM.Message_Type) 
														return Boolean is
	begin
		return Value_Seq + 1 = Seq_N or not Success;
	end Next_Message;
	
	function Old_Message (Value_Seq : CM.Seq_N_T ; Seq_N : CM.Seq_N_T ; Success : Boolean ; Mess : CM.Message_Type)
													        return Boolean is
	begin
		return (Seq_N <= Value_Seq and Success);
	end Old_Message;

	function Future_Message (Value_Seq : CM.Seq_N_T ; Seq_N : CM.Seq_N_T ; Success : Boolean ; Mess : CM.Message_Type) 
														return Boolean is
	begin
		return (Seq_N > Value_Seq + 1 and Success);
	end Future_Message;
	
	-- End Funcitions Ordered Messages

	-- RCV_INIT
	procedure RCV_Init (P_Buffer : access LLU.Buffer_Type ; EP_H_Create : out LLU.End_Point_Type ;
						Seq_N : out CM.Seq_N_T ; EP_Rsnd : out LLU.End_Point_Type ; 
						EP_R_Create : out LLU.End_Point_Type ; Nick : out ASU.Unbounded_String) is
	begin	
		debug.Put ("RCV Init  " , pantalla.Amarillo);
		EP_H_Create := LLU.End_Point_Type'Input(P_Buffer);
		Seq_N := CM.Seq_N_T'Input(P_Buffer);			
		EP_Rsnd := LLU.End_Point_Type'Input(P_Buffer);
		EP_R_Create := LLU.End_Point_Type'Input(P_Buffer);
		Nick	:= ASU.UnboundeD_String'Input(P_Buffer);	
	
		Debug_Msgs(EP_H_Create , Seq_N , Nick);
	end RCV_Init;


	function ValidName (Nick : ASU.Unbounded_String ; NickName : ASU.UNboundeD_String ; EP_H_Create : LLU.End_Point_Type ;
										To : LLU.End_Point_Type) return Boolean is
	begin
		return Nick /= NickName and EP_H_Create /= To; 
	end ValidName;

	-- Allow the Name in the ChatRoom	
	procedure Allow_Name (EP_H_Create : in LLU.End_Point_Type ; Seq_N : in CM.Seq_N_T ;
			      EP_R_Create : in LLU.End_Point_Type ;  To : in  LLU.End_Point_Type ; 
			      EP_Rsnd : in out LLU.End_Point_Type ; Nick : in ASU.Unbounded_String) is
		NickName    : ASU.Unbounded_String;
		Mess	    : CM.Message_Type;
		EP_Not_Send : LLU.End_Point_Type; 
		Resend	    : Boolean := True;
	begin
		NickName := MyName;
		if ValidName(Nick , NickName , EP_H_Create, To) then
			Mess := CM.Init;
			Update_Field_EP(EP_Rsnd , EP_Not_Send , To , EP_Rsnd);
			Flood(EP_H_Create , Seq_N , EP_Rsnd , EP_R_Create , Nick, EP_Not_Send , Mess , Resend);
		else
			Reject(To , EP_R_Create , Nick);
		end if;
	end Allow_Name;

	-- RCV Admision

	procedure RCV_Admision (P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type) is
		Mess 	    : CM.Message_Type := CM.Init;		
		EP_H_Create : LLU.End_Point_Type;
		Seq_N       : CM.Seq_N_T;
		EP_Rsnd     : LLU.End_Point_Type;
		EP_R_Create : LLU.End_Point_Type;
		Nick	    : ASU.Unbounded_String;			
		Value_Seq   : CM.Seq_N_T := 0;
		Success	    : Boolean;
	begin
		RCV_Init(P_Buffer, EP_H_Create ,Seq_N , EP_Rsnd , EP_R_Create , Nick);

		CH.Latest_Msgs.Get (CH.Map_Latest_Messages , EP_H_Create , Value_Seq , Success);

		if Next_Message(Value_Seq , Seq_N , Success , Mess) then
		
			debug.Put_Line (" Message Inmmediatly Conssecutive " , pantalla.rojo);
			Send_ACK (To , EP_H_Create ,EP_Rsnd , Seq_N);		
			ADD_Neighbors(EP_H_Create , EP_Rsnd);
			Allow_Name(EP_H_Create , Seq_N ,EP_R_Create , To , EP_Rsnd , Nick);

		elsif Old_Message(Value_Seq , Seq_N , Success , Mess) then

			debug.put_line (" Old Message" , pantalla.rojo);
			Send_ACK (To , EP_H_Create ,EP_Rsnd , Seq_N);		

		elsif Future_Message(Value_Seq , Seq_N , Success , Mess) then

			debug.Put_Line("---Future Message---" , pantalla.rojo);			

		end if;	
	end RCV_Admision;


	procedure RCV_Confirm (P_Buffer : access LLU.Buffer_Type ; EP_H_Create : out LLU.End_Point_Type ; 
							 Seq_N : out CM.Seq_N_T ; EP_Rsnd : out LLU.End_Point_Type ; 
							 Nick : out ASU.Unbounded_String) is
	begin
		debug.Put ("RCV Confirm  " , pantalla.Amarillo);

		-- Unencapsulate Message				
		EP_H_Create := LLU.End_Point_Type'Input(P_Buffer);
		Seq_N := CM.Seq_N_T'Input(P_Buffer);
		EP_Rsnd := LLU.End_Point_Type'Input(P_Buffer);
		Nick := ASU.Unbounded_String'Input(P_Buffer);

		debug_Msgs(EP_H_Create , Seq_N , Nick);
	end RCV_Confirm;


	procedure RCV_Admision_End (P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type) is
		Mess 	    : CM.Message_Type := CM.Confirm;		
		EP_H_Create : LLU.End_Point_Type;
		Seq_N       : CM.Seq_N_T;
		EP_Rsnd     : LLU.End_Point_Type;
		Nick	    : ASU.Unbounded_String;	
		EP_Not_Send : LLU.End_Point_Type;
		Resend      : Boolean := True;
		Value_Seq   : CM.Seq_N_T;
		Success     : Boolean;
	begin
		RCV_Confirm(P_Buffer , EP_H_Create, Seq_N , EP_Rsnd , Nick);

		CH.Latest_Msgs.Get (CH.Map_Latest_Messages , EP_H_Create , Value_Seq , Success);

		if Next_Message (Value_Seq , Seq_N , Success , Mess) then
			debug.Put_Line ("Message inmediatly conssecutive" , pantalla.rojo);
			
			Send_ACK(To , EP_H_Create ,EP_Rsnd , Seq_N);
			Screen_Control (CH.Map_Latest_Messages, EP_H_Create , Seq_N , Nick , Mess);

			-- Go to Flood
			Update_Field_EP(EP_Rsnd , EP_Not_Send , To , EP_Rsnd);	
			Flood(EP_H_Create , Seq_N , EP_Rsnd , null , Nick, EP_Not_Send , Mess , Resend);

		elsif Old_Message (Value_Seq , Seq_N , Success , Mess) then

			debug.Put_Line ("Old Message" , pantalla.rojo);
			Send_ACK(To , EP_H_Create , EP_Rsnd , Seq_N);

		elsif Future_Message (Value_Seq, Seq_N , Success , Mess) then

			debug.Put_Line ("Future Message" , pantalla.rojo);

		end if;
	end RCV_Admision_End;
	
	procedure RCV_Writer (P_Buffer : access LLU.Buffer_Type ; EP_H_Create : out LLU.End_Point_Type ; Seq_N : out 								CM.Seq_N_T ; EP_Rsnd : out LLU.End_Point_Type ; 							Nick : out ASU.Unbounded_String ; Remark : out ASU.Unbounded_String) is
	begin
		debug.Put("RCV Writer " , pantalla.amarillo);
				
		-- Unencapsulate  the Writer's Message
		EP_H_Create := LLU.End_Point_Type'Input(P_Buffer);
		Seq_N := CM.Seq_N_T'Input(P_Buffer);
		EP_Rsnd := LLU.End_Point_Type'Input(P_Buffer);
		Nick := ASU.Unbounded_String'Input(P_Buffer);
		Remark := ASU.Unbounded_String'Input(P_Buffer);

		Debug_Msgs(EP_H_Create , Seq_N , Nick);		

	end RCV_Writer;
	
	procedure RCV_Writers (P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type) is
		Mess 	    : CM.Message_Type := CM.Writer;				
		EP_H_Create : LLU.End_Point_Type;
		Seq_N       : CM.Seq_N_T;
		EP_Rsnd     : LLU.End_Point_Type;
		Nick	    : ASU.Unbounded_String;
		Remark      : ASU.Unbounded_String := ASU.Null_Unbounded_String;
		EP_Not_Send : LLU.End_Point_Type;	
		Resend	    : Boolean := True; 
		Value_Seq   : CM.Seq_N_T;
		Success	    : Boolean;
	begin
		RCV_Writer (P_Buffer , EP_H_Create , Seq_N , EP_Rsnd , Nick , Remark);

		CH.Latest_Msgs.Get (CH.Map_Latest_Messages , EP_H_Create , Value_Seq , Success);
	
		if Next_Message(Value_Seq , Seq_N , Success , Mess) then

			debug.Put_Line("  Message inmendiatly conssecutive " , pantalla.rojo);
			Send_ACK  (To , EP_H_Create , EP_Rsnd , Seq_N);
			Screen_Control (CH.Map_Latest_Messages, EP_H_Create , Seq_N , Nick ,  Mess , Remark);
			Update_Field_EP(EP_Rsnd , EP_Not_Send , To , EP_Rsnd);
			Flood (EP_H_Create ,Seq_N,EP_Rsnd , null , Nick , EP_Not_Send , Mess, Resend , False , Remark);		

		elsif Old_Message (Value_Seq , Seq_N , Success , Mess) then

			debug.Put_Line (" Old Message" , pantalla.rojo);
			Send_ACK (To , EP_H_Create , EP_Rsnd , Seq_N);

		elsif Future_Message (Value_Seq , Seq_N , Success , Mess) then

			debug.Put_Line("Future Message " , pantalla.rojo);
			
		end if; 
	end RCV_Writers;

	procedure RCV_Logout (P_Buffer : access LLU.Buffer_Type ; EP_H_Create : out LLU.End_Point_Type ; 
					Seq_N : out CM.Seq_N_T ; EP_Rsnd : out LLU.End_Point_Type ; 
					Nick : out ASU.Unbounded_String ; Confirm_Send : out Boolean) is
	begin
		debug.Put("RCV Logout" , Pantalla.Amarillo);
			
		-- Unencapsulate the logout  Message	
		EP_H_Create := LLU.End_Point_Type'Input(P_Buffer);
		Seq_N := CM.Seq_N_T'Input(P_Buffer);
		EP_Rsnd := LLU.End_Point_Type'Input(P_Buffer);
		Nick := ASU.Unbounded_String'Input(P_Buffer);				
		Confirm_Send := Boolean'Input(P_Buffer);
			
		Debug_Msgs(EP_H_Create , Seq_N , Nick);		

	end RCV_Logout;

	procedure Delete_Neighbor (EP_H_Create : LLU.End_Point_Type ; EP_Rsnd : LLU.End_Point_Type) is
		Success : Boolean := False;
	begin		
		-- Delete the Neighbor's end point
		if EP_H_Create = EP_Rsnd then
			debug.Put("Deleting Neighbor ...");	
			CH.Neighbors.Delete(CH.Map_Neighbors , EP_H_Create , Success);
			if Success then Debug.Put_Line(" OK"); else debug.Put_Line(" FAIL"); end if;	
		end if;
	end Delete_Neighbor;


	-- Show  that the user has left the chatroom
	procedure Show_Leave (Mess : CM.Message_Type ; EP_H_Create : LLU.End_Point_Type ; Seq_N : CM.Seq_N_T ; 
								Nick : ASU.Unbounded_String ; Confirm_Send : Boolean ) is
	begin
		if Confirm_Send then
			Screen_Control (CH.Map_Latest_Messages, EP_H_Create , Seq_N , Nick , Mess);
		end if;	
	end Show_Leave;

	procedure Delete_Ltst_Msgs (EP_H_Create : LLU.End_Point_Type) is
		Success : Boolean;
	begin
		-- Delete the Latest End Point Messages 
		debug.Put("Deleting Latest Messages ...");				
		CH.Latest_Msgs.Delete(CH.Map_Latest_Messages , EP_H_Create , Success);
		if Success then Debug.Put_Line(" OK"); else debug.Put_Line(" FAIL"); end if;

	end Delete_Ltst_Msgs;

	procedure RCV_Logouts (P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type) is
		Mess	     : CM.Message_Type := CM.Logout;			
		EP_H_Create  : LLU.End_Point_Type;
		Seq_N 	     : CM.Seq_N_T;
		EP_Rsnd	     : LLU.End_Point_Type;
		Nick	     : ASU.Unbounded_String;
		Confirm_Send : Boolean;		
		EP_Not_Send  : LLU.End_Point_Type;	
		Resend	     : Boolean := True;
		Value_Seq    : CM.Seq_N_T;
		Success	     : Boolean;
	begin
		RCV_Logout(P_Buffer, EP_H_Create , Seq_N , EP_Rsnd , Nick , Confirm_Send);
		
		CH.Latest_Msgs.Get (CH.Map_Latest_Messages , EP_H_Create , Value_Seq , Success);

		if Next_Message(Value_Seq , Seq_N , Success , Mess) then
			debug.Put_Line ("  Message inmediatly conssecutive " , pantalla.rojo);
			
			Send_ACK (To , EP_H_Create , EP_Rsnd , Seq_N);
			Delete_Neighbor (EP_H_Create , EP_Rsnd);

--Ada.Text_IO.Put_Line("Recivido LogOut , Muestro por patnalla : " & Boolean'Image(Confirm_Send));
			Show_Leave(Mess , EP_H_Create , Seq_N , Nick , Confirm_Send);

			Update_Field_EP(EP_Rsnd , EP_Not_Send , To , EP_Rsnd);
			Flood(EP_H_Create , Seq_N , EP_Rsnd , null , Nick, EP_Not_Send , Mess , Resend , Confirm_Send);

			Delete_Ltst_Msgs(EP_H_Create);		

		elsif  Old_Message(Value_Seq , Seq_N , Success , Mess) then
			debug.Put_Line (" Old Message" , pantalla.rojo);
		
			Send_ACK(To , EP_H_Create , EP_Rsnd , Seq_N);
	
		elsif	Future_Message(Value_Seq , Seq_N , Success , Mess) then
			Debug.Put_Line("Is a future message! =) LogOut" , pantalla.rojo);
		end if;

	end RCV_Logouts;
	
	procedure RCV_Hello (P_Buffer : access LLU.Buffer_Type ; EP_H_Create : out LLU.End_Point_Type ; 
			     Seq_N : out CM.Seq_N_T ; EP_Rsnd : out LLU.End_Point_Type ; Nick : out ASU.Unbounded_String ; 
			     Keys_Neigh : out CH.NP_Neighbors.Keys_Array_Type) is
	begin

		debug.Put("RCV HELLO " , Pantalla.Amarillo);

		EP_H_Create := LLU.End_Point_Type'Input(P_Buffer);
		Seq_N := CM.Seq_N_T'Input(P_Buffer);
		EP_Rsnd := LLU.End_Point_Type'Input(P_Buffer);
		Nick := ASU.Unbounded_String'Input(P_Buffer);
		Keys_Neigh := CH.NP_Neighbors.Keys_Array_Type'Input(P_Buffer);

		Debug_Msgs(EP_H_Create , Seq_N , Nick);		
	end RCV_Hello; 

	function Get_Neighbors (Keys_Neigh : CH.Neighbors.Keys_Array_Type) return CM.Neighbors_T is
		Neighbors : CM.Neighbors_T;	
	begin	
		for i  in Keys_Neigh'Range loop
			if Keys_Neigh(i) /= null then
				Neighbors(i).EP := Keys_Neigh(i);
				Neighbors(i).Nick := ASU.Null_Unbounded_String;
			end if;
		end loop;
		return Neighbors;
	end Get_Neighbors;

	procedure Put_Topology (EP_H_Create : LLU.End_Point_Type ; Keys_Neigh :  CH.Neighbors.Keys_Array_Type) is
		Success : Boolean := False;	
	begin 

		CH.Topology.Put(CH.Map_Topology , EP_H_Create , Get_Neighbors(Keys_Neigh) , Success);
		debug.Put("Map Topology UPDATED " , pantalla.amarillo);
		debug.Put(Basic.EP_Image(EP_H_Create) & " , " & BP5.Neighbors_String(Get_Neighbors(Keys_Neigh)));
		if Success then debug.Put_Line("Ok"); else debug.Put_Line("Fail" , pantalla.rojo); end if;

	end Put_Topology;

	-- Create Message UPDATE Topology
	procedure UPDATE_Topology (To : LLU.End_Point_Type) is
		Mess        : CM.Message_Type := CM.UPDATE;	
		Resend      : Boolean := False;
		Nick	    : ASU.Unbounded_String;
		Keys_Neigh  : CH.Neighbors.Keys_Array_Type;
		Seq_N	    : CM.Seq_N_T;
		Success	    : Boolean;
	begin
		debug.Put("SEND UPDATED " , pantalla.amarillo);
		CH.Latest_Msgs.Get(CH.Map_Latest_Messages , To , Seq_N , Success);
		Nick := MyName;	
		Keys_Neigh := CH.Neighbors.Get_Keys(CH.Map_Neighbors);
		Seq_N := Seq_N + 1;
		if Success then	
			Flood(To , Seq_N , To , null , Nick , To , Mess , Resend , False ,
											 ASU.Null_Unbounded_String , Keys_Neigh);
			debug.Put_Line("OK");
		else
			debug.Put_Line("Fail");
		end if;
	end UPDATE_Topology;			

	procedure RCV_Hellos (P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type) is
		Mess	    : CM.Message_Type := CM.Hello;		
		EP_H_Create : LLU.End_Point_Type;
		EP_Not_Send : LLU.End_Point_Type;
		Seq_N       : CM.Seq_N_T;
		EP_Rsnd     : LLU.End_Point_Type;		
		Nick	    : ASU.Unbounded_String;
		Keys_Neigh  : CH.Neighbors.Keys_Array_Type;
		Value_Seq   : CM.Seq_N_T;
		Success	    : Boolean := False;
		Resend	    : Boolean := True;
	begin
		RCV_Hello (P_Buffer , EP_H_Create , Seq_N , EP_Rsnd , Nick , Keys_Neigh);

		CH.Latest_Msgs.Get (CH.Map_Latest_Messages , EP_H_Create , Value_Seq , Success);

		if Next_Message(Value_Seq , Seq_N , Success , Mess) then

			debug.Put_Line ("  Message inmediatly conssecutive " , pantalla.rojo);			
			Put_Topology(EP_H_Create , Keys_Neigh);
			
			Send_ACK(To , EP_H_Create , EP_Rsnd , Seq_N);	

			Update_Field_EP(EP_Rsnd , EP_Not_Send , To , EP_Rsnd);
			Flood(EP_H_Create , Seq_N , EP_Rsnd , null , Nick , To , Mess , Resend , 											False , ASU.Null_Unbounded_String , Keys_Neigh);
			UPDATE_Topology (To);

		elsif  Old_Message(Value_Seq , Seq_N , Success , Mess) then

			debug.Put_Line (" Old Message" , pantalla.rojo);
			Send_ACK(To , EP_H_Create , EP_Rsnd , Seq_N);

		elsif	Future_Message(Value_Seq , Seq_N , Success , Mess) then

			Debug.Put_Line("Is a future message! =) Hello!" , pantalla.rojo);

		end if;
	end RCV_Hellos;

	procedure RCV_UPDATE (P_Buffer : access LLU.Buffer_Type ; EP_H_Create : out LLU.End_Point_Type ; Seq_N : out CM.Seq_N_T ; 					EP_Rsnd : out LLU.End_Point_Type ;  Keys_Neigh : out CH.NP_Neighbors.Keys_Array_Type) is
	begin
	
		debug.Put("RCV UPDATE " , Pantalla.Amarillo);

		EP_H_Create := LLU.End_Point_Type'Input(P_Buffer);
		Seq_N := CM.Seq_N_T'Input(P_Buffer);
		EP_Rsnd := LLU.End_Point_Type'Input(P_Buffer);
		Keys_Neigh := CH.NP_Neighbors.Keys_Array_Type'Input(P_Buffer);

		debug.Put_Line(Basic.EP_Image(EP_H_Create) & CM.Seq_N_T'Image(Seq_N));

	end RCV_UPDATE;



	procedure RCV_Updates (P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type) is
		Mess	    : CM.Message_Type := CM.Update;		
		EP_H_Create : LLU.End_Point_Type;
		EP_Not_Send : LLU.End_Point_Type;
		Seq_N       : CM.Seq_N_T;
		EP_Rsnd     : LLU.End_Point_Type;		
		Nick	    : ASU.Unbounded_String;
		Keys_Neigh  : CH.Neighbors.Keys_Array_Type;
		Value_Seq   : CM.Seq_N_T;
		Success	    : Boolean := False;
		Resend	    : Boolean := True;
	begin

		RCV_UPDATE (P_Buffer , EP_H_Create , Seq_N , EP_Rsnd , Keys_Neigh);

		CH.Latest_Msgs.Get (CH.Map_Latest_Messages , EP_H_Create , Value_Seq , Success);

		if Next_Message(Value_Seq , Seq_N , Success , Mess) then

			debug.Put_Line ("  Message inmediatly conssecutive " , pantalla.rojo);
		
			Put_Topology(EP_H_Create , Keys_Neigh);
			Send_ACK(To , EP_H_Create , EP_Rsnd , Seq_N);	

			Update_Field_EP(EP_Rsnd , EP_Not_Send , To , EP_Rsnd);
			Flood(EP_H_Create , Seq_N , EP_Rsnd , null , Nick , EP_Not_Send , Mess , Resend , 											False , ASU.Null_Unbounded_String , Keys_Neigh);
		elsif  Old_Message(Value_Seq , Seq_N , Success , Mess) then

			debug.Put_Line (" Old Message" , pantalla.rojo);
			Send_ACK(To , EP_H_Create , EP_Rsnd , Seq_N);	
			
		elsif	Future_Message(Value_Seq , Seq_N , Success , Mess) then

			Debug.Put_Line("Is a future message! =) UPDATE!" , pantalla.rojo);

		end if;
	end RCV_Updates;


	procedure Proc_ACK (EP_H_Create : LLU.End_Point_Type ; EP_H_ACKer : LLU.End_Point_Type ; Seq_N : CM.Seq_N_T) is
		Mess_ID : CM.Mess_ID_T;
		Destinations : CM.Destinations_T;	
		Success : Boolean;
	begin
		Mess_ID.EP := EP_H_Create;
		Mess_ID.Seq := Seq_N;
		CH.Sender_Dest.Get(CH.Map_Sender_Dest , Mess_ID , Destinations , Success);
		for i in CM.Destinations_T'Range loop
			if Destinations(i).EP = EP_H_ACKer then
				Destinations(i).EP := null;
			end if;
		end loop;
		CH.Sender_Dest.Put(CH.Map_Sender_Dest , Mess_ID , Destinations);
	end Proc_ACK;	

	procedure RCV_ACK (P_Buffer : access LLU.Buffer_Type ; EP_H_ACker : out LLU.End_Point_Type ; 
								EP_H_Create : out LLU.End_Point_Type ; Seq_N : out CM.Seq_N_T) is
	begin
		debug.Put("RCV ACK " , Pantalla.Amarillo);

		EP_H_ACKer := LLU.End_Point_Type'Input(P_Buffer);
		EP_H_Create := LLU.End_Point_Type'Input(P_Buffer);
		Seq_N := CM.Seq_N_T'Input(P_Buffer);	
		
		-- Debug Message ACK
		debug.Put_Line(" " & Basic.EP_Image(EP_H_Create) & " " & CM.Seq_N_T'Image(Seq_N) & " " , pantalla.azul);
	end RCV_ACK;


	procedure RCV_ACKs (P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type) is
		EP_H_ACker  : LLU.End_Point_Type;
		EP_H_Create : LLU.End_Point_Type;
		Seq_N	    : CM.Seq_N_T;	
		
	begin
		RCV_ACK(P_Buffer , EP_H_ACKer , EP_H_Create , Seq_N);
		Proc_ACK (EP_H_Create , EP_H_ACKer , Seq_N);		
	end RCV_ACKs;

	procedure Send_Super_Node (EP_H_Create : LLU.End_Point_Type ; EP_Receive : LLU.End_Point_Type ; EP_S_Node : LLU.End_Point_Type) is
		Nick   : ASU.UnboundeD_String := MyName;	
		Mess   : CM.Message_Type := CM.S_Req;
		Buffer : aliased LLU.Buffer_Type(1024);
	begin		
		LLU.Reset(Buffer);
		CM.Message_Type'Output(Buffer'Access , Mess);
		LLU.End_Point_Type'Output(Buffer'Access , EP_H_Create);
		LLU.End_Point_Type'Output(Buffer'Access , EP_Receive);
		ASU.Unbounded_String'Output(Buffer'Access , Nick);
		
		LLU.Send(EP_S_Node , Buffer'Access);
	end Send_Super_Node;


	procedure Start_Peer (EP_H_Create : LLU.End_Point_Type ; EP_Receive : LLU.End_Point_Type ; Port : Integer ; 
						Quit : out Boolean ; EP_S_Node : LLU.End_Point_Type ; S_Node : Boolean) is
		Success : Boolean := False;
		Expired : Boolean := False;
		Buffer  : aliased LLU.Buffer_Type(1024);
	begin
		if Neighbors and not S_Node then
			Create_Map_Neighbors(CH.Map_Neighbors , EP_H_Create , Success , S_Node , Buffer'Access , Quit);
			-- Admission protocol started
			debug.Put_Line("Admission Protocol started ...");			
			Admision_Protocol(EP_H_Create, EP_Receive , Quit);
		elsif S_Node then

			debug.Put_Line("Starting with Super Node ...");
			Send_Super_Node(EP_H_Create , EP_Receive , EP_S_Node);	
			LLU.Receive(EP_Receive , Buffer'Access , 4.0 , Expired);

			if Expired then
				debug.Put_Line("Super Node Out of Time...");
				Initial_Node(EP_H_Create , Success);
			else
				debug.Put_Line("Admission Protocol started with Super Node...");	
				Create_Map_Neighbors(CH.Map_Neighbors , EP_H_Create , Success , S_Node , Buffer'Access , Quit);
				if not Quit and Success then
					Admision_Protocol(EP_H_Create, EP_Receive , Quit);
				end if;		
			end if;
		else 
			Initial_Node(EP_H_Create , Success);
		end if;
	end Start_Peer;


	procedure Send_Bye (EP_H_Create : LLU.End_Point_Type ; Keys_Neigh : CH.Neighbors.Keys_Array_Type) is
		Resend	: Boolean := False;
		Mess    : CM.Message_Type := CM.Bye;
		Seq_N   : CM.Seq_N_T;
		Success : Boolean := False;
	begin
		CH.Latest_Msgs.Get(CH.Map_Latest_Messages , EP_H_Create , Seq_N , Success);
		Seq_N := Seq_N + 1;
		Flood(EP_H_Create , Seq_N , EP_H_Create , null , ASU.Null_UnboundeD_String , EP_H_Create , 
							Mess , Resend , False , ASU.Null_Unbounded_String , Keys_Neigh);
	end Send_Bye;


	procedure RCV_Bye (P_Buffer : access LLU.Buffer_Type ; EP_H_Create : out LLU.End_Point_Type ; Seq_N : out CM.Seq_N_T ; 
					EP_Rsnd : out LLU.End_Point_Type ; Keys_Neigh : out CH.Neighbors.Keys_Array_Type) is
	begin	

		debug.Put("RCV BYE " , Pantalla.Amarillo);

		EP_H_Create := LLU.End_Point_Type'Input(P_Buffer);
		Seq_N := CM.Seq_N_T'Input(P_Buffer);
		EP_Rsnd := LLU.End_Point_Type'Input(P_Buffer);
		Keys_Neigh := CH.NP_Neighbors.Keys_Array_Type'Input(P_Buffer);

		debug.Put_Line(Basic.EP_Image(EP_H_Create) & CM.Seq_N_T'Image(Seq_N));

	end RCV_Bye;

	procedure Proc_Bye (EP_H_Create : LLU.End_Point_Type ; Keys_Neigh  : CH.Neighbors.Keys_Array_Type) is
		Success     : Boolean;
		Neighbors   : CM.Neighbors_T;
		Total_Neigh : Integer := 0;
	begin
		debug.Put("Deleted Node ..." , pantalla.amarillo);
		CH.Topology.Delete(CH.Map_Topology , EP_H_Create , Success);
		if Success then debug.Put_Line("OK"); else debug.Put_Line("Fail" , pantalla.rojo); end if;

		for i in CH.Neighbors.Keys_Array_Type'Range loop
			CH.Topology.Get(CH.Map_Topology , Keys_Neigh(i) , Neighbors , Success);

			for i in CM.Neighbors_T'Range loop

				if Neighbors(i).EP = EP_H_Create then
					Neighbors(i).EP := null;
				end if;

				if Neighbors(i).EP /= null then
					Total_Neigh := Total_Neigh + 1;
				end if;

			end loop;

			if Total_Neigh = 0 then
				CH.Topology.Delete(CH.Map_Topology , Keys_Neigh(i) , Success);
			else
				CH.Topology.Put(CH.Map_Topology , Keys_Neigh(i) , Neighbors , Success);	
			end if;
	
		end loop;

	end Proc_Bye;


	procedure RCV_Byes (P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type) is
		Mess	    : CM.Message_Type := CM.Bye;		
		EP_H_Create : LLU.End_Point_Type;
		EP_Not_Send : LLU.End_Point_Type;
		Seq_N       : CM.Seq_N_T;
		EP_Rsnd     : LLU.End_Point_Type;		
		Nick	    : ASU.Unbounded_String;
		Keys_Neigh  : CH.Neighbors.Keys_Array_Type;
		Value_Seq   : CM.Seq_N_T;
		Success	    : Boolean := False;
		Resend	    : Boolean := True;
	begin

		RCV_Bye (P_Buffer , EP_H_Create , Seq_N , EP_Rsnd , Keys_Neigh);

		CH.Latest_Msgs.Get (CH.Map_Latest_Messages , EP_H_Create , Value_Seq , Success);

		if Next_Message(Value_Seq , Seq_N , Success , Mess) then

			debug.Put_Line ("  Message inmediatly conssecutive " , pantalla.rojo);

			Proc_Bye (EP_H_Create , Keys_Neigh);

			Send_ACK(To , EP_H_Create , EP_Rsnd , Seq_N);	

			Update_Field_EP(EP_Rsnd , EP_Not_Send , To , EP_Rsnd);
			Flood(EP_H_Create , Seq_N , EP_Rsnd , null , Nick , EP_Not_Send , Mess , Resend , 											False , ASU.Null_Unbounded_String , Keys_Neigh);
		elsif  Old_Message(Value_Seq , Seq_N , Success , Mess) then

			debug.Put_Line (" Old Message" , pantalla.rojo);
			Send_ACK(To , EP_H_Create , EP_Rsnd , Seq_N);	
			
		elsif	Future_Message(Value_Seq , Seq_N , Success , Mess) then

			Debug.Put_Line("Is a future message! =) UPDATE!" , pantalla.rojo);

		end if;
	end RCV_Byes;

end Body_Peer;

