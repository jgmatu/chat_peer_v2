with Ada.Calendar;

package time_string is

	function Image_1 (T: Ada.Calendar.Time) return String;

   	function Image_2 (T: Ada.Calendar.Time) return String;

   	function Image_S (T : Ada.Calendar.Time) return String;

	function Null_Clock return Ada.Calendar.Time;

 	function "=" (T1 : Ada.Calendar.Time ; T2 : Ada.Calendar.Time) return Boolean;

 	function "<" (T1 : Ada.Calendar.Time ; T2 : Ada.Calendar.Time) return Boolean;


end time_string;
