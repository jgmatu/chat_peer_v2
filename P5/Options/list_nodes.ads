with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
	
package List_Nodes is

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;

	type List_Type is private;

	List_Empty : Exception;
	
	function Image (List : List_Type) return String;
	
	procedure Put (List : out List_Type ; Nick : ASU.Unbounded_String ; EP : LLU.End_Point_Type);

	procedure Delete (List : in out List_Type ; Nick : ASU.Unbounded_String ; Success : out Boolean);

	procedure Get (List : List_Type ; Nick : ASU.Unbounded_String ; EP : out LLU.End_Point_Type ; Success : out Boolean);

	function Length (List : List_Type) return Integer;

	Max_Neighbors : Constant := 2;
	
	type Last_Neighbor_T is record
		 EP   : LLU.End_Point_Type := null;
		 Nick : ASU.UnboundeD_String := ASU.Null_Unbounded_String;
	end record; 
		
	type Last_Neighbors_T is array (0 .. Max_Neighbors - 1) of Last_Neighbor_T;

	function Get_Latest_Neighbors (List : List_Type) return Last_Neighbors_T;

	private 

	type Cell;

   	type Cell_A is access Cell;

  	type Cell is record
  	    Nick     : ASU.Unbounded_String;
  	    EP       : LLU.End_Point_Type;
  	    Next     : Cell_A;
  	    Previous : Cell_A;
  	end record;

	type List_Type is record
		P_First : Cell_A;
		P_Last : Cell_A;
		Num      : Integer := 0;
	end record;

end List_Nodes;
