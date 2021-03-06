with Basic;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Pantalla;
with Debug;

package S_nodo is

	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;

	function "=" (Nick1 : ASU.Unbounded_String ; Nick2 : ASU.Unbounded_String) return Boolean;
	function "<" (Nick1 : ASU.Unbounded_String ; Nick2 : ASU.Unbounded_String) return Boolean;
	function ASU_String (Nick : ASU.Unbounded_String) return String;
	procedure Create_EP (EP : out LLU.End_Point_Type);

	procedure Proc_Req (To : LLU.End_Point_Type ; P_Buffer : access LLU.Buffer_Type);
 	
	procedure Proc_Logout (To : LLU.End_Point_Type ; P_Buffer : access LLU.Buffer_Type);	

	procedure Interfaz;
	
end S_Nodo;
