-- Francisco Javier Gutierrez-Maturana Sanchez

with Ada.Text_IO;
With Ada.Strings.Unbounded;
with Maps_G;
with Lower_Layer_UDP;

procedure Maps_Test is
   package ASU  renames Ada.Strings.Unbounded;
   package ATIO renames Ada.Text_IO;
   package LLU  renames Lower_Layer_UDP;

   type Seq_N_T is mod Integer'Last;

   package Maps is new Maps_G (Key_Type   => LLU.End_Point_Type,
                               Value_Type => Seq_N_T,
 			       Null_Key   =>  Null,
   			       Null_Value => 0,
   			       Max_Length => 10,
                               "="        => LLU."=",
                               Key_To_String  => LLU.Image,
                               Value_To_String  => Seq_N_T'Image);


--   Value   : Seq_N_T;
   Success : Boolean;

   A_Map     : Maps.Map;

   package A_Map is new Maps_Protector_G (Maps);

   EP_Client_1 : LLU.End_Point_Type := LLU.Build("192.168.1.10" , 62000);
   EP_Client_2 : LLU.End_Point_Type := LLU.Build("10.0.211.237" , 2100); 
   EP_Client_3 : LLU.End_Point_Type := LLU.Build("172.0.211.9" , 8342);
   EP_Client_4 : LLU.End_Point_Type := LLU.Build("8.8.8.8" , 8342); 
--   Keys   : Maps.Keys_Array_Type;
--   Values : Maps.Values_Array_Type; 
begin

       ATIO.New_Line;
       ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                        Integer'Image(Maps.Map_Length(A_Map)));
       Maps.Print_Map (A_Map);

       Maps.Put (A_Map , EP_Client_1 , 1 , Success);

	
       ATIO.New_Line;
       ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                        Integer'Image(Maps.Map_Length(A_Map)));
       Maps.Print_Map(A_Map);


       ATIO.New_Line;
--       Maps.Get (A_Map, EP_Client_2, Value, Success);
--       if Success then
--          ATIO.Put_Line ("El Numero de Mensaje es " &
--                      		Seq_N_T'Image(Value));
--       else
--		Ada.Text_IO.Put_Line("No hay un numero de mensaje con esa Key");
--     end if;

      Maps.Put (A_Map, EP_Client_2, 1 , Success);

      ATIO.New_Line;
      ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                        Integer'Image(Maps.Map_Length(A_Map)));
      Maps.Print_Map(A_Map);

      Maps.Put (A_Map,EP_Client_3, 1 , Success);

     ATIO.New_Line;
     ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                      Integer'Image(Maps.Map_Length(A_Map)));
     Maps.Print_Map(A_Map);
 
     ATIO.New_Line;
--        Ada.Text_IO.Put_Line("=== Mostrar claves de la tabla de simbolos ===");

	  ATIO.New_Line;   
	  Maps.Put (A_Map,EP_Client_4, 1 , Success);
--        Keys := Maps.Get_Keys(A_Map);
--        for i in Maps.Keys_Array_Type'Range loop
--           if not LLU.is_Null(Keys(i)) then
--		Ada.Text_IO.Put_Line(LLU.Image(Keys(i)));
--	   else
--	 	Ada.Text_IO.Put_Line("***Fila Vacia***");
--	   end if;    
--        end loop;

 --  Maps.Put (A_Map,
 --             ASU.To_Unbounded_String ("facebook.com"),
 --             ASU.To_Unbounded_String ("69.63.189.11"));

      ATIO.New_Line;
      ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                       Integer'Image(Maps.Map_Length(A_Map)));
      Maps.Print_Map(A_Map);

 --  ATIO.New_Line;
 --  Maps.Get (A_Map, ASU.To_Unbounded_String ("www.urjc.es"), Value, Success);
 --  if Success then
 --    ATIO.Put_Line ("Get: Dirección IP de www.urjc.es: " &
 --                      ASU.To_String(Value));
 --  else
 --     ATIO.Put_Line ("Get: NO hay una entrada para la clave www.urjc.es");
 --  end if;

 --  ATIO.New_Line;
 --  Maps.Delete (A_Map, ASU.To_Unbounded_String("google.com"), Success);
 --  if Success then
 --     ATIO.Put_Line ("Delete: BORRADO google.com");
 --  else
 --     ATIO.Put_Line ("Delete: google.com no encontrado");
 --  end if;

 --  ATIO.New_Line;
 --  ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
 --                   Integer'Image(Maps.Map_Length(A_Map)));
 --  Maps.Print_Map(A_Map);

 --  ATIO.New_Line;
 -- Maps.Delete (A_Map, ASU.To_Unbounded_String("www.urjc.es"), Success);
 --  if Success then
 --    ATIO.Put_Line ("Delete: BORRADO www.urjc.es");
 --  else
 --     ATIO.Put_Line ("Delete: www.urjc.es no encontrado");
 --  end if;

 --  ATIO.New_Line;
 --  ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
 --                   Integer'Image(Maps.Map_Length(A_Map)));
 --  Maps.Print_Map (A_Map);

 --  ATIO.New_Line;
 --  Maps.Delete (A_Map, ASU.To_Unbounded_String("bbb.bbb.bbb"), Success);
 --  if Success then
 --    ATIO.Put_Line ("Delete: BORRADO bbb.bbb.bbb");
 --  else
 --     ATIO.Put_Line ("Delete: bbb.bbb.bbb no encontrado");
 --  end if;

 --  ATIO.New_Line;
 --  ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
 --                   Integer'Image(Maps.Map_Length(A_Map)));
 --  Maps.Print_Map (A_Map);



end Maps_Test;
