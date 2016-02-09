with Lower_Layer_UDP;

package basic is

	package LLU renames Lower_Layer_UDP;

	function EP_Image (EP : LLU.End_Point_Type) return String;

end basic;
