with Ada.Calendar;

package time_string is

	function Image_1 (T: Ada.Calendar.Time) return String;

   	function Image_2 (T: Ada.Calendar.Time) return String;

	function Null_Clock return Ada.Calendar.Time;

end time_string;
