with Lower_Layer_UDP;

package Check_Parameters is
	
	package LLU renames Lower_Layer_UDP;
	
	Min_Parameters : constant := 5;

	Neccesary_Parameters_Error : Exception;
	Neighbors_Check_Error      : Exception;
	Delays_Error	           : Exception;
	Error_Fault_PCT		   : Exception;
	
	procedure CheckParameters (S_Node : out Boolean);

	procedure Bad_Parameters;

	procedure Config_P5;

	procedure Config_P5_S_Nodo (EP_S_Nodo : out LLU.End_Point_Type);

end Check_Parameters;
