with Chat_Messages;
with Ada.TexT_IO;
with S_Nodo;

package body S_Handler is

	package CM renames Chat_Messages;

-- This procedure must NOT be called. It's called from LL
	procedure S_Node_Handler (From     : in     LLU.End_Point_Type; To : in LLU.End_Point_Type ;
											P_Buffer : access LLU.Buffer_Type) is
		Mess : CM.Message_Type;
	begin
			
		Mess := CM.Message_Type'Input(P_Buffer);
		
		case Mess is
			when CM.S_Req =>
				Ada.Text_IO.Put_Line("Message Req...");
				S_Nodo.Proc_Req(To , P_Buffer);		

			when CM.Logout =>	
				Ada.Text_IO.Put_Line ("Mensaje de Salida del Chat");
				S_Nodo.Proc_Logout(To , P_Buffer);
			when others =>
				Ada.Text_IO.Put_Line("Descarte del Mensaje ");
		end case;

	end S_Node_Handler;

end S_Handler;
