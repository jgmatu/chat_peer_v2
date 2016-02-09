--Francisco Javier Gutierrez-Maturana Sanchez

with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

package body Maps_G is

   procedure Free is new Ada.Unchecked_Deallocation (Cell, Cell_A);

   -- Consulta a la tabla de simbolos por clave y devuelvo su valor
   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean) is
      P_Aux : Cell_A;
   begin
      P_Aux := M.P_First;
      Success := False;
      while not Success and P_Aux /= null Loop
         if P_Aux.Key = Key then
            Value := P_Aux.Value;
            Success := True;
         end if;
         P_Aux := P_Aux.Next;
      end loop;
   end Get;

   -- Add Nuevo Elemento a la lista
   procedure Add (M : in out Map ; Key : in Key_Type ; Value : in Value_Type) is
	P_Aux : Cell_A := null;
   begin
	-- Create the new element
	P_Aux := new Cell;
	P_Aux.all.Key := Key;
	P_Aux.all.Value := Value;
	-- We Have to see what is my List
	if M.P_First = null then
		M.P_First := P_Aux;
	else
		P_Aux.all.Next := M.P_First;
		M.P_First.all.Previous := P_Aux;
		M.P_First := P_Aux;
	end if;
   end Add;

   -- Meter un nuevo valor y clave a la tabla
   procedure Put (M     : in out Map ; Key : Key_Type ; Value : Value_Type ; Success : out Boolean) is
      P_Aux : Cell_A;
      Found : Boolean;
   begin
      -- Si la Lista esta llena no puedo añadir mas filas a la tabla
      if Max_Length > M.Length then
      	-- Si ya existe Key, cambiamos su Value
      	P_Aux := M.P_First;
      	Found := False;
      	while not Found and P_Aux /= null loop
      		if P_Aux.Key = Key then
      		P_Aux.Value := Value;
      		Found := True;
      		end if;
      		P_Aux := P_Aux.Next;
      	end loop;

      	-- Si no hemos encontrado Key añadimos al principio
      	if not Found then
      		M.Length := M.Length + 1;
		Add (M , Key , Value);
      	end if;
		Success := True;      	
	else
      		Success := False;
      	end if;
   end Put;


   -- Borrar Elemento del Mapa por 
   procedure Delete (M       : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean) is
      P_Current  : Cell_A;
      P_Previous : Cell_A;
   begin
      Success := False;
      P_Previous := null;
      P_Current  := M.P_First;
      while not Success and P_Current /= null  loop
         if P_Current.Key = Key then
            Success := True;
            M.Length := M.Length - 1;
            if P_Previous /= null then
               P_Previous.Next := P_Current.Next;
            end if;
            if M.P_First = P_Current then
               M.P_First := M.P_First.Next;
            end if;
            Free (P_Current);
         else
            P_Previous := P_Current;
            P_Current := P_Current.Next;
         end if;
      end loop;

   end Delete;

   -- Numero de Filas
   function Map_Length (M : Map) return Natural is
   begin
      return M.Length;
   end Map_Length;

   -- Pintar Mapa
   procedure Print_Map (M : Map) is
      P_Aux : Cell_A;
   begin
      P_Aux := M.P_First;

      Ada.Text_IO.Put_Line ("Map");
      Ada.Text_IO.Put_Line ("===");

      while P_Aux /= null loop
         Ada.Text_IO.Put_Line (Key_To_String(P_Aux.Key) & " " &
                                 VAlue_To_String(P_Aux.Value));
         P_Aux := P_Aux.Next;
      end loop;
   end Print_Map;

 

   function Get_Keys (M : Map) return Keys_Array_Type is
	Keys  : Keys_Array_Type;
	P_Aux : Cell_A;
   begin	
	P_Aux := M.P_First;
	for i in Keys_Array_Type'Range loop		
		-- Veo si tengo clave, si tengo clave la añado a mi array de claves si no inserto clave vacia
		if P_Aux /= null then
	        	Keys(i) := P_Aux.all.Key;
			P_Aux := P_Aux.all.Next;
		else
			Keys(i) := Null_Key;
		end if;
	end loop;
	return Keys;
   end Get_Keys;	


   function Get_Values (M : Map) return Values_Array_Type is
	Values : Values_Array_Type;
	P_Aux  : Cell_A;
   begin
	P_Aux := M.P_First;
	-- Recorro toda la Coleccion para insertarle los valores
	for i in Values_Array_Type'Range loop
		-- Si el map tiene valor se la añado si no empiezo a insertar Null_Value
		if P_Aux /= null then
			Values(i) := P_Aux.all.Value;
			P_Aux := P_Aux.all.Next;
		else
			Values(i) := Null_Value;		
		end if;
	end loop;
	return Values;
   end Get_Values;

end Maps_G;
