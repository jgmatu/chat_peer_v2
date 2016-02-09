-- Francisco Javier Gutierrez-Maturana Sanchez

with Lower_Layer_UDP;
with Maps_G;
with Ada.Calendar;
with Time_String;
with Maps_Protector_G;
with Ordered_Maps_G;
with Ordered_Maps_Protector;

package Chat_Handlers is
	package LLU renames Lower_Layer_UDP;
	package TS  renames Time_String;

	type Seq_N_T is mod Integer'Last;

	package NP_Neighbors is new Maps_G (Key_Type  => LLU.End_Point_Type,
		Value_Type => Ada.Calendar.Time,
		Null_Key => null,
		Null_Value => TS.Null_Clock ,
		Max_Length => 10,
		"="  => LLU."=" ,
		Key_To_String  => LLU.Image,
		Value_To_String  => time_string.image_1);


	package NP_Latest_Msgs is new Maps_G (Key_Type   => LLU.End_Point_Type,
		Value_Type => Seq_N_T,
		Null_Key => Null,
		Null_Value => 0,
		Max_Length => 10,
		"="        => LLU."=" ,
		Key_To_String  => LLU.Image,
		Value_To_String  => Seq_N_T'Image);
		Handler_Call_Counter : Natural := 0;

	package NP_Sender_Dest is new Ordered_Maps_G (CM.Mess_ID_T,CM.Destinations_T, AP."=" , AP."<" , 
							AP.Mess_ID_String , AP.Destinations_String);


	package NP_Sender_Buffering is new Ordered_Maps_G (Ada.Calendar.Time , CM.Value_T , Ada.Calendar."=" , 
									Ada.Calendar."<"  , TS.Image_2 , AP.String_Value);

	package Neighbors is new Maps_Protector_G (NP_Neighbors);

	package Latest_Msgs is new Maps_Protector_G (NP_Latest_Msgs);

	package Sender_Dest is new Ordered_Maps_Protector_G (NP_Sender_Dest);

	package Sender_Buffering is new Ordered_Maps_Protector_G(NP_Sender_Buffering);

	Map_Sender_Dest : Sender_Dest.Prot_Map; 
	Map_Sender_Buffering : Sender_Buffering.Prot_Map;
	Map_Neighbors : Neighbors.Prot_Map; 
	Map_Latest_Messages : Latest_Msgs.Prot_Map;
	Seq_N : Seq_N_T;


-- This procedure must NOT be called. It's called from LL
procedure Peer_Handler (From     : in     LLU.End_Point_Type; To : in LLU.End_Point_Type ;P_Buffer : access LLU.Buffer_Type);


end Chat_Handlers;
