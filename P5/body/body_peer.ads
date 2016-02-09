--Francisco Javier Gutierrez-Maturana Sanchez

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Chat_Handlers;
with Chat_Messages;

package Body_Peer is

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CH renames Chat_Handlers;	
	package CM renames Chat_Messages;

	
	type Type_Neighbor is record
		Host : ASU.Unbounded_String;
		Port : Integer;
	end record;	

	type Type_Neighbors is array (0 .. 2) of Type_Neighbor;

	procedure Create_EP (EP_Handler : out LLU.End_Point_Type; Port : in Integer);

	function Neighbors return Boolean;	

	procedure Admision_Protocol (EP_H_Create : LLU.End_Point_Type ; EP_Receive : LLU.End_Point_Type ; Quit : out Boolean);
	
	function Neigh_Empty return CH.NP_Neighbors.Keys_Array_Type;

	procedure Flood (EP_H_Create : LLU.End_Point_Type ; Seq_N : in CM.Seq_N_T ; EP_Rsnd : 
						LLU.End_Point_Type; EP_Receive : LLU.End_Point_Type := null ; 
						Nick : 	ASU.Unbounded_String ; EP_Not_Send : LLU.End_Point_Type ; 
						Mess : CM.Message_Type; Resend : Boolean ;
						Confirm_Send : in Boolean := False ; 
						Remark : ASU.Unbounded_String := ASU.Null_Unbounded_String ;
						Keys_Neigh : CH.NP_Neighbors.Keys_Array_Type := Neigh_Empty);

	procedure Screen_Writer (EP_H_Create : LLU.End_Point_Type ; EP_Receive : LLU.End_Point_Type ; Quit : in out Boolean ; 									S_Node : Boolean := False ; EP_S_Node : LLU.End_Point_Type);

	procedure RCV_Admision (P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type);

	procedure RCV_Admision_End(P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type);

	procedure RCV_Writers (P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type);
	
	procedure RCV_Logouts (P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type);

	procedure RCV_ACKs (P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type);

	procedure RCV_Hellos (P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type);

	procedure RCV_Updates (P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type);

	procedure RCV_Byes (P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type);

	procedure Start_Peer (EP_H_Create : LLU.End_Point_Type ; EP_Receive : LLU.End_Point_Type ; Port : Integer ; 
						Quit : out Boolean ; EP_S_Node : LLU.End_Point_Type ; S_Node : Boolean);

	procedure Send_Bye (EP_H_Create : LLU.End_Point_Type ; Keys_Neigh : CH.Neighbors.Keys_Array_Type);

        -- To Logout S_Nodo
	procedure RCV_Logout (P_Buffer : access LLU.Buffer_Type ; EP_H_Create : out LLU.End_Point_Type ; 
					Seq_N : out CM.Seq_N_T ; EP_Rsnd : out LLU.End_Point_Type ; 
					Nick : out ASU.Unbounded_String ; Confirm_Send : out Boolean);
	procedure Logout  (EP_H_Create : LLU.End_Point_Type ; Seq_N : CM.Seq_N_T ; EP_Rsnd : LLU.End_Point_Type ; 
				Nick : ASU.Unbounded_String ; Confirm_Send : Boolean ; Resend : Boolean);

 
	--function Mess_ID_Null return CM.Mess_ID_T;

	--function Destinations_Null return CM.Destinations_T;

	--function Value_Null return CM.Value_T;

end Body_Peer;
