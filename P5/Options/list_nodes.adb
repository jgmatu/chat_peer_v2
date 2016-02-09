with Ada.Text_IO;
with Basic;
with Ada.Unchecked_Deallocation;

package body List_Nodes is

	use type ASU.Unbounded_String;
	
	procedure Put (List : out List_Type ; Nick : ASU.Unbounded_String ; EP : LLU.End_Point_Type) is
		P_Node : Cell_A;
	begin
		-- Create Element
		P_Node := new Cell;
		P_Node.all.Nick := Nick;
		P_Node.all.EP := EP;

		-- Create circular List
		if List.P_First = null then
			List.P_First := P_Node;
			List.P_Last := P_Node;

			P_Node.Next := List.P_Last;
			P_Node.Previous := List.P_First;

		elsif List.Num = 1 then

			P_Node.Next := List.P_Last;
			P_Node.Previous := List.P_First;

			List.P_First.Next := P_Node;
			List.P_First.Previous := P_Node;

			List.P_Last := P_Node;
 
		else	
			P_Node.Previous := List.P_Last;
			P_Node.Next := List.P_First;

			List.P_First.Previous := P_Node;
			List.P_Last.Next := P_Node;

			List.P_Last := P_Node;
		
		end if;
		List.Num := List.Num + 1; 
		P_Node := Null;
	end Put;

	procedure Get (List : List_Type ; Nick : ASU.Unbounded_String ; EP : out LLU.End_Point_Type ; Success : out Boolean) is
		P_Node : Cell_A;	
		Pos : Integer;	
	begin
		Pos := 0;
		Success := False;
		P_Node := List.P_First;
		while Pos /= List.Num and then not Success loop
			if P_Node.all.Nick = Nick then
				Success := True;
				EP := P_Node.all.EP;
			else
				Pos := Pos + 1;
				P_Node := P_Node.Next;
			end if;
		end loop;
	end Get;

	procedure Delete (List : in out List_Type ; Nick : ASU.Unbounded_String ; Success : out Boolean) is
		procedure Free is new Ada.Unchecked_Deallocation (Cell , Cell_A);
		Delete : Boolean := False;
		P_Node : Cell_A;
		Pos    : Integer := 0;
	begin	
		if List.P_First = null then
			raise List_Empty;
		end if;	

		if List.Num /= 1 then
			Success := False;
			Pos := 0;
			P_Node := List.P_First;
			while Pos /= List.Num and then not Success loop
				if P_Node.all.Nick = Nick then
					Success := True;		
					P_Node.Next.Previous := P_Node.Previous;
					P_Node.Previous.Next := P_Node.Next;
					if List.P_First = P_Node then	
						List.P_First := P_Node.Next;
					end if;
					if List.P_Last = P_Node then
						List.P_Last := P_Node.Previous;
					end if;
					List.Num := List.Num - 1;
				else
					Pos := Pos + 1;
					P_Node := P_Node.Next;
				end if;
			end loop;
			Free(P_Node);	
		else
			Success := True;
			Free(List.P_First);
			List.P_Last := null;
			List.Num := 0;
		end if;

--Ada.Text_IO.Put_Line("Siguiente ELemento : " & ASU.To_STring(P_Node.Previous.all.Nick));
--Ada.Text_IO.Put_Line("Previo Elemento : " & ASU.To_STring(P_Node.Next.all.Nick));

	end Delete;


	function Image (List : List_Type) return String is
		P_Node     : Cell_A;
		Pos        : Integer;
		Image_List : ASU.Unbounded_String := ASU.Null_Unbounded_String;
	begin
		if List.Num = 0 then
			raise List_Empty;
		end if;

		Pos := 0;
		P_Node := List.P_First;
		while Pos /= List.Num loop
			Image_List := Image_List & P_Node.all.Nick & " , " & Basic.EP_Image(P_Node.all.EP) & ASCII.LF;	
			Pos := Pos + 1;		
			P_Node := P_Node.Next;
		end loop;
		return ASU.To_String(Image_List);
	end Image;

	function Length (List : List_Type) return Integer is
	begin
		return List.Num;
	end Length;

	function Get_Latest_Neighbors (List : List_Type) return Last_Neighbors_T is
		Last_Neighbors : Last_Neighbors_T;	
		P_Node : Cell_A;
		Pos : Integer;
	begin
		if List.Num = 0 then
			raise List_Empty;
		end if;		

		P_Node := List.P_Last;
		Pos := 0;
		while Pos /= Max_Neighbors and List.Num >= Max_Neighbors loop
			Last_Neighbors(Pos).EP := P_Node.all.EP;
			Last_Neighbors(Pos).Nick := P_Node.all.Nick;
			P_Node := P_Node.Previous;
			Pos := Pos + 1;	
		end loop;
		if List.Num = 1 then
			Last_Neighbors(0).EP := P_Node.all.EP;
			Last_Neighbors(0).Nick := P_Node.all.Nick;
		end if;
		return Last_Neighbors;
	end Get_Latest_Neighbors; 

end List_Nodes;
