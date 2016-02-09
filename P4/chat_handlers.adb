-- Francisco Javier Gutierrez-Maturana Sanchez

with Ada.Strings.Unbounded;
with Debug;
with Pantalla;
with Chat_Messages;
with Aux_Peer;
with Ada.Command_Line;

package body Chat_Handlers is

	package ASU renames Ada.Strings.Unbounded;
	package CM  renames Chat_Messages;
	package AP  renames Aux_Peer;
	package ACL renames Ada.Command_Line;

	use type ASU.Unbounded_String;
	use type LLU.End_Point_Type;

	-- Procedure threath's run by  Messages reception
	procedure Peer_Handler (From : in LLU.End_Point_Type; To : in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type) is
		Mess : CM.Message_Type;
	begin
		Mess := CM.Message_Type'Input(P_Buffer);
		case Mess is
			when CM.Init =>
				AP.RCV_Admision (P_Buffer , To);
			when CM.Confirm =>
				AP.RCV_Admision_End(P_Buffer , To);
			when CM.Writer =>
				AP.RCV_Writers(P_Buffer , To);
					
			when CM.Logout =>
 				AP.RCV_Logouts (P_Buffer , To);
			when others =>
				debug.Put_Line("****");
		end case;
	end Peer_Handler;

end Chat_Handlers;

