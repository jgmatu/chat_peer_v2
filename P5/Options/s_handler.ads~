with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with S_nodo;
with Basic;
with List_Nodes;

package S_Handler is

	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;
		
	List : List_Nodes.List_Type;

	-- This procedure must NOT be called. It's called from LL
	procedure S_Node_Handler (From     : in     LLU.End_Point_Type; To : in LLU.End_Point_Type ;
												P_Buffer : access LLU.Buffer_Type);

end S_Handler;
