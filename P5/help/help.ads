-- Francisco Javier Gutierrez-Maturana Sanchez

with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Chat_Messages;

package Help is
		
	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;	
	package CM  renames Chat_Messages;


	procedure Main_Help (Remark : ASU.Unbounded_String ; Quit : out Boolean ; EP_H_Create : LLU.End_Point_Type ;
				EP_Receive : LLU.End_Point_Type ; Nick : ASU.Unbounded_String ; 
				Seq_N : CM.Seq_N_T ; Status  : in out Boolean ; Prompt : in out Boolean ; 
				S_Node : Boolean ; EP_S_Nodo : LLU.End_Point_Type);

	function Patron (Remark	 : ASU.Unbounded_String) return Boolean;


	procedure Leave_Chat (Quit : out Boolean ; EP_H_Create : LLU.End_Point_Type ; Seq_N : CM.Seq_N_T ; 
							Nick : ASU.Unbounded_String ; Remark :ASU.Unbounded_String ; 
							S_Node : Boolean ; EP_S_Nodo : LLU.End_Point_Type);
end Help;
