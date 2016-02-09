with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ordered_Maps_G;
with Ordered_Maps_Protector_G;
with Pantalla;
with debug;
with Ada.Exceptions;

procedure Ordered_Maps_Test2 is
	
	package ASU renames Ada.Strings.Unbounded;
	
	use type ASU.Unbounded_String;

	URL1  : ASU.Unbounded_String := ASU.To_Unbounded_String("nbc.com");
	URL2  : ASU.Unbounded_String := ASU.To_Unbounded_String("facebook.com");
	URL3  : ASU.Unbounded_String := ASU.To_Unbounded_String("yelp.com");
	URL4  : ASU.Unbounded_String := ASU.To_Unbounded_String("google.com");
	URL5  : ASU.Unbounded_String := ASU.To_Unbounded_String("bbva.com");
	URL6  : ASU.Unbounded_String := ASU.To_Unbounded_String("viacom.com");
	URL7  : ASU.Unbounded_String := ASU.To_Unbounded_String("zappos.com");
	URL8  : ASU.Unbounded_String := ASU.To_Unbounded_String("cbs.com");
	URL9  : ASU.Unbounded_String := ASU.To_Unbounded_String("ucla.edu");
	URL10 : ASU.Unbounded_String := ASU.To_Unbounded_String("xing.com");
	URL11 : ASU.Unbounded_String := ASU.To_Unbounded_String("edi.com");
	URL12 : ASU.Unbounded_String := ASU.To_Unbounded_String("wings.com");
	URL13 : ASU.Unbounded_String := ASU.To_Unbounded_String("wongs.com");
	URL14 : ASU.Unbounded_String := ASU.To_Unbounded_String("aa.com");
	URL15 : ASU.Unbounded_String := ASU.To_Unbounded_String("albaca.com");


	IP1    : ASU.Unbounded_String := ASU.To_Unbounded_String("66.77.124.26");
	IP2    : ASU.Unbounded_String := ASU.To_Unbounded_String("69.63.181.12");
	IP3    : ASU.Unbounded_String := ASU.To_Unbounded_String("63.251.52.110");
	IP4    : ASU.Unbounded_String := ASU.To_Unbounded_String("69.63.186.16");
	IP5    : ASU.Unbounded_String := ASU.To_Unbounded_String("195.76.187.83");
	IP6    : ASU.Unbounded_String := ASU.To_Unbounded_String("206.220.43.92");
	IP7    : ASU.Unbounded_String := ASU.To_Unbounded_String("66.209.92.150");
	IP8    : ASU.Unbounded_String := ASU.To_Unbounded_String("198.99.118.37");
	IP9    : ASU.Unbounded_String := ASU.To_Unbounded_String("169.232.55.22");
	IP10   : ASU.Unbounded_String := ASU.To_Unbounded_String("213.238.60.19");
	IP11   : ASU.Unbounded_String := ASU.To_Unbounded_String("192.86.2.98");
	IP12   : ASU.Unbounded_String := ASU.To_Unbounded_String("12.155.29.35");
	IP13   : ASU.Unbounded_String := ASU.To_Unbounded_String("111.155.29.35");
	IP14   : ASU.Unbounded_String := ASU.To_Unbounded_String("41.155.29.35");


	package NP_URLs is new Ordered_Maps_G (ASU.Unbounded_String , ASU.Unbounded_STring , ASU."=" , 
										ASU.">", ASU.To_String , ASU.To_String);
	package URLs is new Ordered_Maps_Protector_G (NP_URLs);

	Tree_URL : URLs.Prot_Map;
	Success  : Boolean := False;
	
	Total : Natural := 0;
begin

	URLs.Put(Tree_URL , URL1 , IP1);
	URLs.Put(Tree_URL , URL2 , IP2);
	URLs.Put(Tree_URL , URL3 , IP3);
	URLs.Put(Tree_URL , URL4 , IP4);
	URLs.Put(Tree_URL , URL5 , IP5);
	URLs.Put(Tree_URL , URL6 , IP6);
	URLs.Put(Tree_URL , URL7 , IP7);
	URLs.Put(Tree_URL , URL8 , IP8);
	URLs.Put(Tree_URL , URL9 , IP9);
	URLs.Put(Tree_URL , URL10 , IP10);
	URLs.Put(Tree_URL , URL11 , IP11);
	URLs.Put(Tree_URL , URL12 , IP12);


        URLs.Print_Map(Tree_URL);

        Total := URLs.Map_Length(Tree_URL);
Ada.Text_IO.Put_Line("Total de elementos : " & Integer'Image(Total));

	URLs.Delete(Tree_URL , URL2 , Success);
Ada.Text_IO.Put_Line("****************************");	

       URLs.Print_Map(Tree_URL);

        Total := URLs.Map_Length(Tree_URL);
Ada.Text_IO.Put_Line("Total de elementos : " & Integer'Image(Total));
exception 
	when Except:others =>
		Ada.Text_IO.Put_Line("Exception Imprevista : " & Ada.Exceptions.Exception_Name(Except) & " en : " &
		Ada.Exceptions.Exception_Message(Except));
end Ordered_Maps_test2;
