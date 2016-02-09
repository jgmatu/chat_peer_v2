--
--  TAD genérico de una tabla de símbolos (map) implementada como una lista
--  enlazada no ordenada.
--

generic
   type Key_Type is private;
   type Value_Type is private;
   with function "=" (K1, K2: Key_Type) return Boolean;
   with function "<" (K1, K2: Key_Type) return Boolean;
   with function Key_To_String (K: Key_Type) return String;
   with function Value_To_String (K: Value_Type) return String;
package Ordered_Maps_G is

   type Map is limited private;

   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean);


   procedure Put (M     : in out Map;
                  Key   : Key_Type;
                  Value : Value_Type);

   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean);


   function Map_Length (M : Map) return Natural;

   procedure Print_Map (M : Map);


private

   type Tree_Node;
   type Map is access Tree_Node;
   type Tree_Node is record
      Key   : Key_Type;
      Value : Value_Type;
      Left  : Map;
      Right : Map;
   end record;
  

   type Type_Prev;
   type Prev_A is access Type_Prev;
   type Type_Prev is record
        P_Tree : Map;
	Next   : Prev_A;
   end record;

   type Type_List_Prev is record
        P_Stack : Prev_A := null;
   end record;

end Ordered_Maps_G;
