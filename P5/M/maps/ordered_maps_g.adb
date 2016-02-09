with Ada.Text_IO;
with Ada.Unchecked_Deallocation;
with Pantalla;
with Debug;

package body Ordered_Maps_G is
   procedure Free is new Ada.Unchecked_Deallocation (Tree_Node, Map);
   
   procedure Print (K : Key_Type ; V : Value_Type) is
   begin
	Ada.Text_IO.Put_Line("Key : " & Key_To_String(K) & " Value :" & Value_To_String(V));
   end Print;

   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean) is
  	P_Tree : Map := null;
   begin
	P_Tree := M;

	if P_Tree = null then
		Success := False;
	end if;

	Success := False;
	while P_Tree /= null and then not Success loop
		if P_Tree.Key = Key then

			Success := True;
			Value := P_Tree.Value;

		elsif Key < P_Tree.Key then

			P_Tree := P_Tree.Left;
		else 

			P_Tree := P_Tree.Right;

		end if;

	end loop;
   end Get;


   procedure Put (M     : in out Map;
                  Key   : Key_Type;
                  Value : Value_Type) is
  	P_Tree : Map := null;
	P_Node : Map := null; 
	
	Success : Boolean;
   begin

         P_Node := new Tree_Node'(Key, Value, null, null);

	 P_Tree := M;
	 Success := False;

	 while P_Tree /= null and then not Success loop
		if P_Tree.Key = Key then

			 P_Tree.Value := P_Node.Value;
			 Success := True;
		
		elsif Key < P_Tree.Key then	

			if P_Tree.Left = null then
				P_Tree.Left  := P_Node;
				Success := True;
			else	
				P_Tree := P_Tree.Left;
			end if;

		else
			if P_Tree.Right = null then
				P_Tree.Right := P_Node;
				Success := True;
			else
				P_Tree := P_Tree.Right;
			end if;

		end if;

 	 end loop;

	 if M = null then
		M := P_Node;
	 end if;
   end Put;

   function Minimo (M : Map) return Map is
      P_Min : Map := Null; 
      Fin   : Boolean;
   begin
	if M = null then
		return null;
	end if;

	P_Min := M;
	Fin := False;
	while P_Min /= null and then not Fin loop
		if P_Min.Left = null then
			if P_Min.Right = null then
				Fin := True;
			else	
				P_Min := P_Min.Right;
			end if;
		else
			P_Min := P_Min.Left;
		end if;
	end loop;
	return P_Min;
   end Minimo;

   procedure Delete_Min (M : in out Map ; Key : Key_Type) is 
 	P_Free     : Map;
	P_Previous : Map;
	Fin        : Boolean;
   begin
	P_Free := M;
	P_Previous := M;
	Fin := False;
	while P_Free /= null and then not Fin loop
		if P_Free.Left = null then
			if P_Free.Right = null then
--Ada.Text_IO.Put("A NULL : ");
--Print(P_Previous.Right.Key , P_Previous.Right.Value);
				if P_Previous.Right.Key = Key then
					P_Previous.Right := null;
				else
					P_Previous.Left := null;
				end if;
--Ada.Text_IO.Put("Free : ");
--Print(P_Free.Key , P_Free.Value);
--Ada.Text_IO.Put("Previous : ");
--Print(P_Previous.Key , P_Previous.Value);
				Free(P_Free);	
				Fin := True;
			else	
				P_Previous := P_Free;
				P_Free := P_Free.Right;
			end if;
		else
			P_Previous := P_Free;	
			P_Free := P_Free.Left;
		end if;
	end loop;
   end Delete_Min;

   procedure Delete (M : in out Map ; Key : in Key_Type ; Success : out Boolean) is
      P_Min        : Map := null;
      P_Free       : Map := null;
      P_Previous   : Map := null;
   begin
	Success := False;
	P_Free := M;
	while P_Free /= null and then not Success loop
		if P_Free.Key = Key then				
			if P_Free.Left = null and P_Free.Right = null and not Success then
				Free(P_Free);
				Success := True;
			end if;
			
			if P_Free.Left /= null and P_Free.Right = null and not Success then
				if P_Previous.Right.Key = Key then
					P_Previous.Right := P_Free.Left;
				else
					P_Previous.Left := P_Free.Left;
				end if;
				Free(P_Free);
				Success := True;
			end if;
 
			if not Success and then (P_Free.Left = null and P_Free.Right /= null) then
				if P_Previous.Right.Key = Key then
					P_Previous.Right := P_Free.Right;
				else
					P_Previous.Left := P_Free.Right;
				end if;
				Free(P_Free);
				Success := True;
			end if;

			if not Success and then  (P_Free.Left /= null and P_Free.Right /= null) then
				P_Min := Minimo(P_Free);

				if P_Previous.Right.Key = Key then
					P_Previous.Right.Key := P_Min.Key;
					P_Previous.Right.Value := P_Min.Value;
				else
					P_Previous.Left.Key := P_Min.Key;
					P_Previous.Left.Value := P_Min.Value;
				end if;	
				Delete_Min(P_Free , P_Min.Key);
				Success := True;
				end if;

		elsif Key < P_Free.Key then
			P_Previous := P_Free;
			P_Free := P_Free.Left;
		else
			P_Previous := P_Free;	
			P_Free := P_Free.Right;
		end if;
	end loop;
   end Delete;


   -- Imprimir Tabla de Símbolos y contar elementos

   procedure print_prev (List_Prev : Type_List_Prev) is
        P_Node : Prev_A;
   begin
	P_Node := List_Prev.P_Stack;
	Ada.Text_IO.Put_Line("Pinto Previos!!");
	while P_Node /= null loop
		Print(P_Node.P_Tree.Key, P_Node.P_Tree.Value);
		P_Node := P_Node.Next; 
	end loop;
	Ada.Text_IO.Put_Line("*********************");
  end print_prev;

   procedure Push_Prev (List_Prev : in out Type_List_Prev ; Prev : Map) is
   	P_Element : Prev_A;
   begin

	P_Element := new Type_Prev'(Prev , null);

	if List_Prev.P_Stack = null then
		List_Prev.P_Stack := P_Element;
	else
		P_Element.Next := List_Prev.P_Stack;
		List_Prev.P_Stack := P_Element;
	end if;
   end Push_Prev;

   procedure Pop_Prev (List_Prev : out Type_List_Prev ; Prev : out Map) is
   	P_Node : Prev_A;
	procedure Free is new Ada.Unchecked_Deallocation (Type_Prev , Prev_A);
   begin
 	if List_Prev.P_Stack /= null then
		P_Node := List_Prev.P_Stack;
		Prev := P_Node.P_Tree;	
		if P_Node.Next /= null then
			List_Prev.P_Stack := P_Node.Next;
			Free(P_Node);
		else
			List_Prev.P_Stack := null;
		end if;
	end if;
   end Pop_Prev;

   procedure Print_Left (M : Map ; List_Prev : out Type_List_Prev ; Right : in out Natural) is
   	P_Tree  : Map;
	Printed : Boolean;
   begin
	P_Tree := M;
	Printed := False;
--Ada.Text_IO.Put("Estoy en : ");
--Print(P_Tree.Key , P_Tree.Value);
--print_prev(List_Prev);
	while P_Tree /= null and then not Printed loop
		if P_Tree.Left = null and P_Tree.Right = null then
			Print(P_Tree.Key , P_Tree.Value);
			Printed := True;	
		elsif P_Tree.Left = null and P_Tree.Right /= null then
Ada.Text_IO.Put("Estoy en : ");
Print(P_Tree.Key , P_Tree.Value);
			Print(P_Tree.Key , P_Tree.Value);
			Printed := True;	
--Ada.Text_IO.Put_Line("Right : " & Integer'Image(Right));
		elsif P_Tree.Left /= null and P_Tree.Right = null then
			Push_Prev(List_Prev , P_Tree);		
			P_Tree := P_Tree.Left;
			Right := Right + 1;	
		else	
--Ada.Text_IO.Put("Estoy en : ");
--Print(P_Tree.Key , P_Tree.Value);
			Push_Prev(List_Prev , P_Tree);
			P_Tree := P_Tree.Left;
		end if;	
	end loop; 
--print_prev(List_Prev);
--Ada.Text_IO.Put_Line("*******************************");
   end Print_Left;

   procedure Print_Tree (M : Map) is
   	P_Tree    : Map := null;
	List_Prev : Type_List_Prev;
	Right	  : Integer;
	Pos 	  : Integer;
	Fin	  : Boolean;
 begin

	P_Tree := M;
	while P_Tree /= null loop	
		Right := 0;
		Print_Left(P_Tree , List_Prev , Right);
--print_prev(List_Prev);
		if Right = 0 then
			Pop_Prev(List_Prev , P_Tree);
			Print (P_Tree.Key , P_Tree.Value);
		else 	
			Pos := 0;
			Fin := False;
			while Pos /= Right + 1 and then not Fin loop
				Pop_Prev(List_Prev , P_Tree);
				Print(P_Tree.Key , P_Tree.Value);
				if List_Prev.P_Stack = null then
					Fin := True;
				end if;
				Pos := Pos + 1;			
--Ada.Text_IO.Put_Line("*******************************");
			end loop;
		end if;
		P_Tree := P_Tree.Right;	
	end loop;
 
--	-- Ultimo de la Lista se queda en la pila
	if List_Prev.P_Stack /= null then
		Print(List_Prev.P_Stack.P_Tree.Key , List_Prev.P_Stack.P_Tree.Value);
 	end if;
 end Print_Tree;

--   procedure Print_Tree (M : Map) is
--  begin
--	if M /= null then
--		if M.Left /= null then
--			Print_Tree(M.Left);
--		end if;
		
--		Print (M.key , M.Value);
		
--		if M.Right /= null then
--			Print_Tree(M.Right);
--		end if;
--	end if;
--  end Print_Tree;

   procedure Print_Map (M : Map) is
   begin
      Ada.Text_Io.Put_Line ("Symbol Table");
      Ada.Text_Io.Put_Line ("============");

      Print_Tree (M);
   end Print_Map;

   
   procedure Count_Left  (M : Map ; List_Prev : out Type_List_Prev ; Right : in out Natural ; Total : in out Natural) is
   	P_Tree : Map;
	Fin : Boolean;
   begin
	P_Tree := M;
	Fin := False;
--Ada.Text_IO.Put("Estoy en : ");
--Print(P_Tree.Key , P_Tree.Value);
	while P_Tree /= null and then not Fin loop
		if P_Tree.Left = null and P_Tree.Right = null then
			Total := Total + 1;
			Fin := True;
		elsif P_Tree.Left = null and P_Tree.Right /= null then
--Ada.Text_IO.Put("Estoy en : ");
--Print(P_Tree.Key , P_Tree.Value);		
			Total := Total + 1;
			Fin := True;	
--Ada.Text_IO.Put_Line("Right : " & Integer'Image(Right));
		elsif P_Tree.Left /= null and P_Tree.Right = null then
			Push_Prev(List_Prev , P_Tree);		
			P_Tree := P_Tree.Left;
			Right := Right + 1;	
		else	
--Ada.Text_IO.Put("Estoy en : ");
--Print(P_Tree.Key , P_Tree.Value);
			Push_Prev(List_Prev , P_Tree);
--print_prev(List_Prev);
			P_Tree := P_Tree.Left;
		end if;
	end loop; 
--Ada.Text_IO.Put_Line("*******************************");
   end Count_Left;

   function Map_Length (M : Map) return Natural is
   	P_Tree    : Map := null;
	List_Prev : Type_List_Prev;
	Total : Natural;
	Right : Natural;
	Pos   : Natural;
	Fin   : Boolean;	
   begin
	P_Tree := M;
	Total := 0;
	while P_Tree /= null loop
		Right := 0;
		Count_Left(P_Tree , List_Prev , Right , Total);
		if Right = 0 then
			Pop_Prev(List_Prev , P_Tree);
			Total := Total + 1;		
		else 	
			Pos := 0;
			Fin := False;
			while Pos /= Right + 1 and then not Fin loop
				Pop_Prev(List_Prev , P_Tree);
				Total := Total + 1;
				if List_Prev.P_Stack = null then
					Fin := True;
				end if;
				Pos := Pos + 1;			
--Ada.Text_IO.Put_Line("*******************************");
			end loop;
		end if;
		P_Tree := P_Tree.Right;	
	end loop;
	-- Ultimo de la Lista se queda en la pila
	if List_Prev.P_Stack /= null then
		Print(List_Prev.P_Stack.P_Tree.Key , List_Prev.P_Stack.P_Tree.Value);
   	end if;
	return Total;
   end Map_Length;
end Ordered_Maps_G;
