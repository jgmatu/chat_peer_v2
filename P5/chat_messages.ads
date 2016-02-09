-- Francisco JAvier Gutierrez-Maturana Sanchez
with Lower_Layer_UDP;
with Ada.Command_Line;
with Ada.Strings.Unbounded;
	
package Chat_Messages is
	
	package LLU renames Lower_Layer_UDP;
	package ACL renames Ada.Command_Line;
	package ASU renames Ada.Strings.Unbounded;	

	type Seq_N_T is mod Integer'Last;

	type Message_Type is (Init, Reject , Confirm , Writer , Logout , Ack , S_Req , S_Rep , S_Den , Hello , Update ,Bye);

	type Mess_Id_T is record 
		EP  : LLU.End_point_Type;
		Seq : Seq_N_T;
	end record;	
		
	type Destination_T is record 
		EP : LLU.End_Point_Type := Null;
		Retries : Natural := 0;
	end record;
	
	type Destinations_T is array (1..10) of Destination_T;

	type Buffer_A_T is access LLU.Buffer_Type;
	
	type Value_T is record
		EP_H_Creat : LLU.End_Point_Type;
		Seq_N      : Seq_N_T;
		P_Buffer   : Buffer_A_T;
	end record;
	
	Max_Neighbors : constant := 10;

	type Neighbor_T is record 
		EP   : LLU.End_Point_Type;
		Nick :ASU.Unbounded_String;
	end record; 
	
	type Neighbors_T is array (1 .. Max_Neighbors) of Neighbor_T;

	P_Buffer_Main : Buffer_A_T;
	P_Buffer_Handler : Buffer_A_T;	

	Plazo_Retransmision : Duration;
	Max_Retrans  : Natural;
	Plazo_Reject : Duration;

end Chat_Messages;
