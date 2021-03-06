with Lower_Layer_UDP;
with Basic;
with Ada.Strings.Unbounded;

package body Body_P5 is

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;

	use type LLU.End_Point_Type;
	use type CM.Seq_N_T;
	use type ASU.Unbounded_String;
	use type CM.Buffer_A_T;
	-- Funcion de igualdad para la tabla de Simbolos de Destination
		
	function "=" (Mess_ID1 : CM.Mess_ID_T ; Mess_ID2 : CM.Mess_ID_T) return Boolean is
	begin
		return Mess_ID1.EP = Mess_ID2.EP and Mess_ID1.Seq = Mess_ID2.Seq;
	end "=";
		
	-- Funcion de comparacion menor para la tabla de simbolos de destination

	function "<" (Mess_ID1 : CM.Mess_ID_T ; Mess_ID2 : CM.Mess_ID_T) return Boolean is
	begin
		return LLU.Image(Mess_ID1.EP) < LLU.Image(Mess_ID2.EP) and Mess_ID1.Seq < Mess_ID2.Seq;
	end "<";
	
	function Mess_ID_String (Mess_ID : CM.Mess_ID_T) return String is
		EP    : LLU.End_Point_Type;
		Seq_N : CM.Seq_N_T;
	begin
		EP := Mess_ID.EP;
		Seq_N := Mess_ID.Seq;	
		return Basic.EP_Image(EP) & " " & CM.Seq_N_T'Image(Seq_N);
	end Mess_ID_String;
	
	function Destinations_String (Destinations : CM.Destinations_T) return String is
		EPs     : ASU.UnboundeD_String := ASU.Null_Unbounded_String;
		Retries : ASU.UnboundeD_String := ASU.Null_Unbounded_String;
		Destinations_String : ASU.UnboundeD_String := ASU.Null_Unbounded_String;
	begin
		for i in CM.Destinations_T'Range loop
			if not LLU.Is_Null(Destinations(i).EP) then
				EPs := ASU.To_Unbounded_String("EP" & Integer'Image(i) & ":" & 
									Basic.EP_Image(Destinations(i).EP) & " ");
				Retries := ASU.To_Unbounded_String ("Retries" & ": " &
									Integer'Image(Destinations(i).Retries));
				Destinations_String := Destinations_String & " " & Eps & Retries & ASCII.LF; 
			end if;
		end loop;
		return ASU.To_String(Destinations_String);
	end Destinations_String;
	
	function String_Value (Value : CM.Value_T) return String is
		EP_H_Create  : LLU.End_Point_Type;
		Seq_N	     : CM.Seq_N_T;
		P_Buffer     : CM.Buffer_A_T := null;
		Value_String : ASU.Unbounded_String;
	begin
		EP_H_Create := Value.EP_H_Creat;
		Seq_N       := Value.Seq_N;	
		P_Buffer    := Value.P_Buffer;

		Value_String := ASU.To_Unbounded_String(Basic.EP_Image(EP_H_Create)) & " " &	
				 ASU.To_Unbounded_String(CM.Seq_N_T'Image(Seq_N));

		if P_Buffer /= null then 
			Value_String := Value_String & " Buffer_Full";
		else 
			Value_String := Value_String & " Buffer_Empty";
		end if;

		Value_String := Value_String & ASCII.LF;

		return ASU.To_String(Value_String);
	end String_Value; 			

	
	function Null_Neighbors return CM.Neighbors_T is
		Neighbors : CM.Neighbors_T;		
	begin	
		for i in CM.Neighbors_T'Range loop
			Neighbors(i).Nick := ASU.Null_Unbounded_String;
			Neighbors(i).EP := null;
		end loop;
		return Neighbors;
	end Null_Neighbors;

	function Neighbors_String (Neighbors : CM.Neighbors_T) return String is
		S_Neighbors : ASU.Unbounded_String;	
	begin
		for i in CM.Neighbors_T'Range loop
			if Neighbors(i).EP /= null then
				S_Neighbors := S_Neighbors & Basic.EP_Image(Neighbors(i).EP) & " " & Neighbors(i).Nick & ASCII.LF;
			end if;
		end loop;
		return ASU.To_String(S_Neighbors);
	end Neighbors_String;

--	function Value_Null return CM.Value_T is
--		Value : CM.Value_T;
--	begin
--		Value.EP_H_Creat := null;
--		Value.Seq_N := 0;
--		Value.P_Buffer := null;
--		return Value;
--	end Value_Null;	

end Body_P5;
