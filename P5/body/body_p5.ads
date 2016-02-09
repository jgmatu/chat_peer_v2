with Chat_Messages;

package Body_P5 is
	
	package CM renames Chat_Messages;

	function "=" (Mess_ID1 : CM.Mess_ID_T ; Mess_ID2 : CM.Mess_ID_T) return Boolean;

	function "<" (Mess_ID1 : CM.Mess_ID_T ; Mess_ID2 : CM.Mess_ID_T) return Boolean;

	function Mess_ID_String (Mess_ID : CM.Mess_ID_T) return String;

	function Destinations_String (Destinations : CM.Destinations_T) return String;

	function String_Value (Value : CM.Value_T) return String;

	function Null_Neighbors return CM.Neighbors_T;

	function Neighbors_String (Neighbors : CM.Neighbors_T) return String;

end Body_P5;
