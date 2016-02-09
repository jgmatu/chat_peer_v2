--Francisco Javier Gutierrez-Maturana Sanchez

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Chat_Handlers;
with Chat_Messages;

package Aux_Peer is
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CH renames Chat_Handlers;	
	package CM renames Chat_Messages;

	
	type Type_Neighbor is record
		Host : ASU.Unbounded_String;
		Port : Integer;
	end record;	

	type Type_Neighbors is array (0 .. 2) of Type_Neighbor;

	function CheckParameters return Boolean;

	procedure Create_EP (EP_Handler : out LLU.End_Point_Type; Port : in Integer);

	function Neighbors return Boolean;

	procedure Create_Map_Neighbors (Map_Neighbors : out CH.Neighbors.Prot_Map ; Success : out Boolean);	

	procedure Admision_Protocol (EP_H_Create : LLU.End_Point_Type ; EP_Receive : LLU.End_Point_Type ; Quit : out Boolean);


	procedure Flood (EP_H_Create : LLU.End_Point_Type ; Seq_N : in  CH.Seq_N_T ; EP_Rsnd : LLU.End_Point_Type ; EP_Receive : 						LLU.End_Point_Type := null ; Nick : ASU.Unbounded_String ; EP_Not_Send : 						LLU.End_Point_Type ; Mess : CM.Message_Type ; Confirm_Send : Boolean := False ;
					Remark : ASU.Unbounded_String := ASU.Null_Unbounded_String);

	function EP_Image (EP : LLU.End_Point_Type) return String;

	procedure Screen_Writer (EP_H_Create : LLU.End_Point_Type ; EP_Receive : LLU.End_Point_Type ; Quit : in out Boolean);

	procedure RCV_Admision (P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type);

	procedure RCV_Admision_End(P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type);

	procedure RCV_Writers (P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type);
	
	procedure RCV_Logouts (P_Buffer : access LLU.Buffer_Type ; To : LLU.End_Point_Type);
end Aux_Peer;
