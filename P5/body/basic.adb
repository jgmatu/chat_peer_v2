with Ada.Strings.Unbounded;

package body basic is

	package ASU renames Ada.Strings.Unbounded;
	-- Show EP 
	function EP_Image (EP : LLU.End_Point_Type) return String is		
		Client         : ASU.Unbounded_String;	
		String_EP      : ASU.Unbounded_String;
		Indice         : Natural := 0;
		IP	       : ASU.Unbounded_String;
		Port           : ASU.Unbounded_String;
	begin
			-- Obtain an EP
			String_EP := ASU.To_Unbounded_String(LLU.Image(EP));

			-- Cut IP	        
			Indice := ASU.Index(String_EP , ":");
			ASU.Tail(String_EP , ASU.Length(String_EP) - Indice - 1);
			Indice := ASU.Index(String_EP , ",");		
			IP := ASU.Head(String_EP , Indice - 1);

			-- Cut Puerto
			Indice := ASU.Index(String_EP , ":");
			ASU.Tail(String_EP , ASU.Length(STring_EP) - Indice - 1);
			Port := ASU.Head(String_EP , ASU.Length(String_EP));

			-- Add to the EP an IP Port
			String_EP := ASU.To_Unbounded_String(ASU.To_String(IP) & ":" & ASU.To_String(Port));

		return ASU.To_String(String_EP);
	end EP_Image;


end basic;
