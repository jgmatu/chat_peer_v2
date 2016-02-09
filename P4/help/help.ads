-- Francisco Javier Gutierrez-Maturana Sanchez

with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Chat_Handlers;

package Help is
		
	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;	
	package CH  renames Chat_Handlers;


	procedure Main_Help (Remark : ASU.Unbounded_String ; Quit : out Boolean ; EP_H_Create : LLU.End_Point_Type ;
					EP_Receive : LLU.End_Point_Type ; Nick : ASU.Unbounded_String ; 
					Seq_N : CH.Seq_N_T ; Status  : in out Boolean ; Prompt : in out Boolean);

	function Patron (Comentario : ASU.Unbounded_String) return Boolean;

end Help;
