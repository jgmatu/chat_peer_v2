with Timed_Handlers;
with Ada.Calendar;
with Ada.Text_IO;
with Chat_Handlers;
with Lower_Layer_UDP;
with Chat_Messages;
with Basic;
with Debug;
with Pantalla;
with Ada.Unchecked_Deallocation;
with Body_P5;

Package body Example_Handlers is

   package CH  renames Chat_Handlers;
   package LLU renames Lower_Layer_UDP;
   package CM  renames Chat_Messages;
   package BP5 renames Body_P5; 

   use type Ada.Calendar.Time;
   use type LLU.End_Point_Type;

   procedure Retransmision (Time: in Ada.Calendar.Time) is
	Success      : Boolean;
	Value        : CM.Value_T;
	New_Time     : Ada.Calendar.Time := Ada.Calendar.Clock + CM.Plazo_Retransmision;
	Mess_ID      : CM.Mess_ID_T;
	Destinations : CM.Destinations_T;
	Senders      : Natural := 0;
	procedure Free is new Ada.Unchecked_Deallocation (LLU.Buffer_Type , CM.Buffer_A_T);
   begin
	
      -- Get the menssage to the retransmision
      CH.Sender_Buffering.Get(CH.Map_Sender_Buffering , Time , Value , Success);


      -- Delete Message for the retransmission no valid hour
      CH.Sender_Buffering.Delete(CH.Map_Sender_Buffering , Time , Success);
 
      -- Create Key Mess_ID 
      Mess_ID.EP := Value.EP_H_Creat; 
      Mess_ID.Seq := Value.Seq_N;

      -- Check if we have to retransmision the message
      CH.Sender_Dest.Get (CH.Map_Sender_Dest , Mess_ID , Destinations , Success);
      
      -- We have to Retransmit the message to some Destination
      if Success then

	   debug.Put ("RETRANSMIT OF MESSAGE : " , pantalla.amarillo);

	   for i in CM.Destinations_T'Range loop
		if Destinations(i).EP /= null and Destinations(i).Retries /= CM.Max_Retrans then
			Senders := Senders + 1;
			LLU.Send(Destinations(i).EP , Value.P_Buffer);
			Destinations(i).Retries := Destinations(i).Retries + 1;	
		end if;
		-- Max Retransmisions we desist to Send the Message
		if Destinations(i).Retries = CM.Max_Retrans then
			Debug.Put_Line("Max Retransmision lacked" , pantalla.rojo);
			Destinations(i).EP := null;
		end if;

	   end loop;

	   CH.Sender_Buffering.Put(CH.Map_Sender_Buffering , New_Time , Value);
	   CH.Sender_Dest.Put(CH.Map_Sender_Dest , Mess_ID , Destinations);
           Timed_Handlers.Set_Timed_Handler (New_Time, Retransmision'Access);
	   CH.Sender_Dest.Get(CH.Map_Sender_Dest , Mess_ID , Destinations , Success);

--Ada.Text_IO.Put_Line("Sender and Success : " & Natural'Image(Senders) & " " & Boolean'Image(Success));
--Ada.Text_IO.Put_Line("Mess_ID : " & BP5.Mess_ID_String(Mess_ID));

	   -- Are all the Destinations Sended
     	   if Senders = 0 and Success then
	        CH.Sender_Dest.Delete(CH.Map_Sender_Dest , Mess_ID , Success);
		Debug.Put_Line("Message Transmited to all Destinations" , pantalla.azul);
		if Success then 
			Free(Value.P_Buffer);
		end if;
	   else
	       -- Message to Retransmit	
	       debug.Put_Line (Basic.EP_Image(Value.EP_H_Creat) & CM.Seq_N_T'Image(Value.Seq_N) , pantalla.verde);
	   end if;
	
	end if;
  
   end Retransmision;


   procedure H2 (Time: in Ada.Calendar.Time) is
   begin
      Ada.Text_Io.Put_Line ("****************** pong: " & Ada.Calendar.Seconds(Time)'Img);
     Timed_Handlers.Set_Timed_Handler (Ada.Calendar.Clock + 4.0, H2'Access);
   end H2;


end Example_Handlers;
