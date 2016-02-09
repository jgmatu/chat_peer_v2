with Ada.Text_IO;
with Aux_P5;
with Chat_Messages;
with Lower_Layer_UDP;
with Ordered_Maps_G;
with Ordered_Maps_Protector_G;	
with Chat_Handlers;
with Ada.Calendar;
with Time_String;
with Ada.Exceptions;

procedure Ordered_Maps_Test is
	package LLU renames Lower_Layer_UDP;
	package AP5 renames Aux_P5;
	package CM  renames Chat_Messages;	
	package CH  renames Chat_Handlers;
	package TS  renames Time_String;

	use type Ada.Calendar.Time;

	package NP_Sender_Dest is new Ordered_Maps_G (CM.Mess_ID_T, CM.Destinations_T, AP5."=", AP5."<", 
										AP5.Mess_ID_String , AP5.Destinations_String);

	package Sender_Dest is new Ordered_Maps_Protector_G (NP_Sender_Dest);

	package NP_Sender_Buffering is new Ordered_Maps_G (Ada.Calendar.Time , CM.Value_T , Ada.Calendar."=" , 
										Ada.Calendar."<", TS.Image_S , AP5.String_Value);

	package Sender_Buffering is new Ordered_Maps_Protector_G(NP_Sender_Buffering);

	Sender_Dest_Map  : Sender_Dest.Prot_Map; 
	Sender_Buffering_Map : Sender_Buffering.Prot_Map;
	

	EP_K1 : LLU.End_Point_Type := LLU.Build ("127.0.0.1" , 1024);
	EP_K2 : LLU.End_Point_Type := LLU.Build ("127.0.0.1" , 1023);
	EP_1  : LLU.End_Point_Type := LLU.Build ("193.39.14.9" , 2200);
	EP_2  : LLU.End_Point_Type := LLU.Build ("82.0.0.1"  , 9100);
	EP_3  : LLU.End_Point_Type := LLU.Build ("93.23.21.3" , 4900);
	Seq_N : CH.Seq_N_T := 0;

	Mess_ID1 : CM.Mess_ID_T;
	Mess_ID2 : CM.Mess_ID_T;

	Destinations : CM.Destinations_T;
	
	Time1  : Ada.Calendar.Time := Ada.Calendar.Clock;
	Time2  : Ada.Calendar.Time := Ada.Calendar.Clock + 60.0;

	Value   : CM.Value_T; 
	Success : Boolean;
begin
	Ada.Text_IO.Put_Line("Hola Mundo!! =) Vamos a probar el paquete Sender Buffering");

	-- Create Mess ID

	Mess_ID1.EP := EP_K1;
	Mess_ID1.Seq := 1;
	
	Mess_ID2.EP := EP_K2;
	Mess_ID2.Seq := 1;
	
	-- Create Destinations

	Destinations(1).EP := EP_1;
	Destinations(1).Retries := 7;
	Destinations(2).EP := EP_2		;	
	Destinations(2).Retries := 4;
	Destinations(3).EP := EP_3;
	Destinations(3).Retries := 8;
	
	-- Insert Destinations of Message Send	

	Sender_Dest.Put(Sender_Dest_Map , Mess_ID1 , Destinations);
	
	Destinations(2).EP := null;

	Sender_Dest.Put(Sender_Dest_Map , Mess_ID2 , Destinations);

	-- Show Symbol Table Sender Dest

	Sender_Dest.Print_Map(Sender_Dest_Map);


	-- Test Times Compare
	
	Ada.Text_IO.Put_Line("Mess_ID1 es menor que Mess_ID2 : " & Boolean'Image(AP5."<"(Mess_ID1, MESS_ID2)));

	Ada.Text_IO.Put_Line("Tiempo uno y dos son iguales :");

	Ada.Text_IO.Put_Line(Boolean'Image(TS."="(Time1 , Time2)));

	Ada.Text_IO.Put_Line("Tiempo 1 es menor que Tiempo 2 :" & Boolean'Image(TS."<"(Time1 , Time2)));

	-- Insert Value to Sender Buffering

	Value.EP_H_Creat := EP_1;
	Value.Seq_N := 2;
	Value.P_Buffer := new LLU.Buffer_Type(1024);
	Sender_Buffering.Put(Sender_Buffering_Map , Time1 , Value);
		
	Value.EP_H_Creat := EP_2;
	Value.Seq_N := 3;
	Value.P_Buffer := null;
	Sender_Buffering.Put(Sender_Buffering_Map , Time2 , Value);	
	
	-- Print Symbol Map Sender Buffering
	Sender_Buffering.Print_Map(Sender_Buffering_Map);

	--Prepare Get
	Ada.Text_IO.Put_Line("Para la Clave " & AP5.Mess_ID_String(Mess_ID1));
 
	Sender_Dest.Get(Sender_Dest_Map, Mess_ID1 , Destinations , Success);

	Ada.Text_IO.Put_Line("Comprobacion de Get : " & AP5.Destinations_String(Destinations) & Boolean'Image(Success));

	
	Sender_Dest.Delete(Sender_Dest_Map , Mess_ID1 , Success);
	

	Sender_Dest.Print_Map(Sender_Dest_Map);
	-- LLU Test Compare

	Ada.Text_IO.PuT_Line("Las claves K1 y K2 son iguales :" & Boolean'Image(AP5."="(Mess_ID1,Mess_ID2)));
	
	LLU.Finalize;
exception
	when Except:others =>
		Ada.Text_IO.Put_Line ("Exception imprevista : " & Ada.Exceptions.Exception_Name(Except) &
									 " en:" & Ada.Exceptions.Exception_Message(Except));
end Ordered_Maps_Test;
