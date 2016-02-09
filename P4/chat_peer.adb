with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Debug;
with Pantalla;
with Maps_G;
with Lower_Layer_UDP;
with chat_handlers;
with Aux_Peer;
with Help;
with Chat_Messages;
with Ada.Exceptions;

procedure Chat_Peer is

	package ACL renames Ada.Command_Line;
	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;
	package AP  renames Aux_Peer;
	package CH  renames Chat_Handlers;
	package CM  renames Chat_Messages;
	
	use type CH.Seq_N_T;

	Error_Parameters : Exception;

	Port 		 : Integer := 0;
	Success	         : Boolean := False;
	EP_Receive       : LLU.End_Point_Type;
	EP_H_Create      : LLU.End_Point_Type;
	Quit		 : Boolean := False;
begin

	--We send the starting parameters 
	if AP.CheckParameters then
		raise Error_Parameters;
	end if;
	
   	Port := Integer'Value(ACL.Argument(1));

	AP.Create_EP(EP_H_Create,  Port);	

	-- we tie to the Admission End Point in the EP_Receive
	LLU.Bind_Any(EP_Receive);

	-- we create the running threath as to receive messages
	LLU.Bind(EP_H_Create , CH.Peer_Handler'Access);

	if AP.Neighbors then
		AP.Create_Map_Neighbors(CH.Map_Neighbors , Success);
		-- Admission protocol started
		debug.Put_Line("Admission Protocol started ...");			
		AP.Admision_Protocol(EP_H_Create, EP_Receive , Quit);
	else
		debug.Put_Line("Not following admision protocol because we dont have initial initial contacts");	
	end if;

	AP.Screen_Writer(EP_H_Create , EP_Receive , Quit);
	LLU.Finalize;
exception
	when Error_Parameters =>
		Debug.Put_Line("Me has pasado mal los parametros : ./chat_peer port nickname [N1] [N2]" , Pantalla.Rojo);
		LLU.Finalize;
	when Constraint_Error =>
		Debug.Put_Line("Error en un numero de Puerto ./chat_peer port nickname [N1] [N2]" , pantalla.rojo);
		LLU.Finalize;
	when Except:others =>
		Debug.Put_Line("Exception Imprevista  : " & 
		Ada.Exceptions.Exception_Name (Except) & " en : " & Ada.Exceptions.Exception_Message(Except));
end Chat_Peer;
