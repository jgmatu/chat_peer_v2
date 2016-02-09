with Ada.Text_IO;
with List_Nodes;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Debug;
with Pantalla;
with Ada.Exceptions;

procedure test_list is

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;

	EP_1 : LLU.End_Point_Type := LLU.Build("124.14.2.4" , 1344);
	EP_2 : LLU.End_Point_Type := LLU.Build("127.123.4.2" , 2343);
	EP_3 : LLU.End_Point_Type := LLU.Build("124.153.4.2" , 3243);
	EP_4 : LLU.End_Point_Type := LLU.Build("127.123.4.2" , 2343);
	EP_5 : LLU.End_Point_Type := LLU.Build("127.123.4.2" , 2343);
	N1   : ASU.Unbounded_String := ASU.To_Unbounded_String("Carlos");
	N2   : ASU.Unbounded_String := ASU.To_Unbounded_String("Javi");
	N3   : ASU.Unbounded_String := ASU.To_Unbounded_String("Tomas");
	N4   : ASU.Unbounded_String := ASU.To_Unbounded_String("Job");
	N5   : ASU.Unbounded_String := ASU.To_Unbounded_String("Elena");

	List    : List_Nodes.List_Type;
	Success : Boolean;

begin

	Ada.Text_IO.Put_Line("Testeo Lista");

	List_Nodes.Put(List , N1 , EP_1);

	List_Nodes.Put(List , N2 , EP_2);

	List_Nodes.Put(List , N3 , EP_3);

	List_Nodes.Put(List , N4 , EP_4);

	List_Nodes.Put(List , N5 , EP_5);

	List_Nodes.Delete (List , N5 , Success);


	Ada.Text_IO.Put_Line(List_Nodes.Image(List));

	LLU.Finalize;
exception

	when List_Nodes.List_Empty =>
		Ada.Text_IO.Put_Line("Lista Vacia");

	when Except:others =>
		Debug.Put_Line("Imprevist Exception  : " & 
		Ada.Exceptions.Exception_Name (Except) & " en : " & Ada.Exceptions.Exception_Message(Except));
end test_list;
