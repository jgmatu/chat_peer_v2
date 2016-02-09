with Ada.Text_IO;
with S_nodo;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with S_Handler;
with debug;
with pantalla;
with Timed_Handlers;

procedure S_nodo_main is

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;

	EP_Handler : LLU.End_Point_Type;
begin

	Ada.TexT_IO.Put_Line("Hola Mundo!! :P");
	
	S_Nodo.Create_EP (EP_Handler);
	
	LLU.Bind(EP_Handler , S_Handler.S_Node_Handler'Access);

	S_Nodo.Interfaz;
	LLU.Finalize;
	Timed_Handlers.Finalize;

exception 
	when Constraint_Error =>
		debug.Put_Line(" ./S_Node [Puerto]" , pantalla.rojo);
		LLU.Finalize;
		Timed_Handlers.Finalize;
end S_nodo_main;
