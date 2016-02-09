-- Francisco Javier Gutierrez-Maturana Sanchez

with Lower_Layer_UDP;
with Maps_G;
with Ada.Calendar;
with Time_String;
with Maps_Protector_G;
with Ordered_Maps_G;
with Ordered_Maps_Protector_G;
with Chat_Messages;
with Body_P5;
with Basic;

package Chat_Handlers is
	package LLU renames Lower_Layer_UDP;
	package TS  renames Time_String;
	package CM  renames Chat_Messages;
	package BP5 renames Body_P5;
  
	package NP_Neighbors is new Maps_G (Key_Type  => LLU.End_Point_Type,
		Value_Type => Ada.Calendar.Time,
		Null_Key => null,
		Null_Value => TS.Null_Clock ,
		Max_Length => CM.Max_Neighbors,
		"="  => LLU."=" ,
		Key_To_String  => LLU.Image,
		Value_To_String  => time_string.image_1);


	package NP_Latest_Msgs is new Maps_G (Key_Type   => LLU.End_Point_Type,		
		Value_Type => CM.Seq_N_T,
		Null_Key => Null,
		Null_Value => 0,
		Max_Length => 50,
		"="        => LLU."=" ,
		Key_To_String  => LLU.Image,
		Value_To_String  => CM.Seq_N_T'Image);

	Handler_Call_Counter : Natural := 0;

	package Neighbors is new Maps_Protector_G (NP_Neighbors);

	package Latest_Msgs is new Maps_Protector_G (NP_Latest_Msgs);

	package NP_Sender_Dest is new Ordered_Maps_G (CM.Mess_ID_T, CM.Destinations_T, BP5."=", BP5."<", 
										BP5.Mess_ID_String,BP5.Destinations_String);

	package Sender_Dest is new Ordered_Maps_Protector_G (NP_Sender_Dest);

	package NP_Sender_Buffering is new Ordered_Maps_G (Ada.Calendar.Time , CM.Value_T , Ada.Calendar."=" , 
										Ada.Calendar."<", TS.Image_S , BP5.String_Value);

	package Sender_Buffering is new Ordered_Maps_Protector_G(NP_Sender_Buffering);


	package NP_Topology is new Maps_G (Key_Type   => LLU.End_Point_Type,		
		Value_Type => CM.Neighbors_T,
		Null_Key => Null,
		Null_Value => BP5.Null_Neighbors,
		Max_Length => 15,
		"="        => LLU."=" ,
		Key_To_String  => LLU.Image,
		Value_To_String  => BP5.Neighbors_String);

	package Topology is new Maps_Protector_G (NP_Topology);


	Map_Sender_Dest  : Sender_Dest.Prot_Map; 
	Map_Sender_Buffering : Sender_Buffering.Prot_Map;
	
	Map_Neighbors : Neighbors.Prot_Map; 
	Map_Latest_Messages : Latest_Msgs.Prot_Map;
	
	Map_Topology : Topology.Prot_Map; 


-- This procedure must NOT be called. It's called from LL
procedure Peer_Handler (From     : in     LLU.End_Point_Type; To : in LLU.End_Point_Type ;P_Buffer : access LLU.Buffer_Type);


end Chat_Handlers;
