<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<?php
list($hour, $minute, $second, $month, $day, $year) = 
                                  explode(':', date('h:i:s:m:d:Y'));
?>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Minutes from AG (formerly WCAG) WG meetings</title>
<meta name="GENERATOR" content="amaya 8.1b, see http://www.w3.org/Amaya/" />
<link rel="stylesheet" type="text/css" href="/StyleSheets/public" />
<link rel="stylesheet" type="text/css" href="/WAI/GL/2004/12/minute-history.css" />
</head>
<body>
<p><a title="W3C Home" href="/"><img alt="W3C logo" border="0"
src="/Icons/w3c_home" /></a> <a title="WAI Home" href="/WAI/"><img
alt="Web Accessibility Initiative logo" border="0" src="/Icons/wai" /></a> <a
href="/WAI/GL/">WCAG WG</a></p>
<h1>Minutes from AG (formerly WCAG) WG meetings</h1>
<p align="center">
<?php
$yc = $year;
while ($yc > 2004) {
	print ("<a href=\"Y$yc\">$yc</a> | \n");
	$yc--;
}
?><a href="minutes-archive.html">Archived Minutes (1998-2004)</a></p>
<div class="minute-finder">
  <h3>Meeting Minute Finder</h3>
  <p>If the meeting date you're looking for isn't listed on this page,  you can enter it in the form below and select submit to view the minutes. </p>
  <form name="form1" method="post" action="/WAI/GL/2004/12/goto.php">
    <label for="month"></label>
    <p>
      <label for="month"><strong>Month:</strong>
      <select name="month" id="month">
        <option value="01">January</option>
        <option value="02">February</option>
        <option value="03">March</option>
        <option value="04">April</option>
        <option value="05">May</option>
        <option value="06">June</option>
        <option value="07">July</option>
        <option value="08">August</option>
        <option value="09">September</option>
        <option value="10">October</option>
        <option value="11">November</option>
        <option value="12">December</option>
      </select>
      </label>
    </p>
    <p>
      <label for="day"><strong>Day:</strong> </label>
      <select name="day" id="day">
        <?php
// array(00, 01, 02, 03, 04, 05, 06, 07, 08, 09)
foreach (range(1, 9) as $number) {
   echo "<option value=\"0$number\">$number</option>";
}
// array(10, 11, 12)
foreach (range(10, 31) as $number2) {
   echo "<option value=\"$number2\">$number2</option>";
}
?>
      </select>
    </p>
    <p>
      <label for="year"><strong>Year:</strong></label>
      <select name="year" id="year"><?php
$yc = $year;
while ($yc > 2004) {
	print ("<option value=\"$yc\">$yc</option>\n");
	$yc--;
}
?>
      </select>
    </p>
    <p>
      <input name="submit" type="submit" value="submit" />
      <input name="clear" type="reset" value="clear" />
    </p>
  </form>
  <p><em>Note:</em> Minutes may not be available for all meeting dates. </p>
</div>
<?php 
error_reporting(0);
/*
// PHP to generate list of Thursday calls so far this year. 
		print "<hr /><a name=\"Y$year\"> </a><h2>Minutes from $year</h2> \n";
		print "<ul>";
		$dayofyear = date("z");
		// list calls so far this year
			for ($i = -1; $i < $dayofyear; ++$i) {
				$timestamp = mktime($hour, $minute, $second, 1, $dayofyear - $i, $year); 
				$dayofweek = date("l", $timestamp);
				if ($timestamp < mktime(0, 0, 0, 4, 30, 2013) && (preg_match ("/Thu/", $dayofweek)) || ($timestamp > mktime(0, 0, 0, 4, 30, 2013) && preg_match("/Tue/", $dayofweek))) {
					$dateformatted = date("d F, Y", $timestamp);          
					$dateuri = date("Y\/m\/d", $timestamp); 
					$path = '../../';
					datelist($dateformatted, $dateuri, $path); 
				}
			}
		print "</ul>";
*/

// Because we didn't start consistently minuting in IRC until 2004 and are only keeping a year or two worth of minutes available on the main minutes page,
// only generate link lists after this date.
				
$yc = $year;
while ($yc > 2004) {
	print "<hr /><a name=\"Y$yc\"> </a><h2>Minutes from $yc</h2> \n";
	print "<ul>";

// print out up the number of Thursday calls from a previous year "357" and "22" below may need to be adjusted to accommodate the first and last meetings of each year. 
			for ($i = 0; $i < 357; ++$i) {
				$timestamp = mktime(0, 0, 0, 12, 22 - $i, $yc); 
				if ($yc < 2006 || $timestamp > mktime(0,0,0,8,27,2010)) { 
					$path = '../../';
				}
				else {
					$path = null;
				}
				
			    if ($timestamp < mktime(0, 0, 0, 2, 1, 2017)) $channel = "wai-wcag";
			    else $channel = "ag";
				$dateformatted = date("d F, Y", $timestamp);         
				$dateuri = date("$yc\/m\/d", $timestamp); 
				datelist($dateformatted, $dateuri, $path, $channel); 
}
	print "</ul>";
	$yc--;
}

function datelist($dateformatted, $dateuri, $path, $channel)
{
	// determine if minutes are available  
	if (is_readable("$path$dateuri-$channel-minutes.html")) {
		print "<li><a href=\"$path$dateuri-$channel-minutes.html\">$dateformatted Minutes</a></li>\n";
	}
	// determine whether an IRC log exists   
	else if (is_readable("../../$dateuri-$channel-irc.html")) {
		print "<li><a href=\"../../$dateuri-$channel-irc.html\">$dateformatted IRC Log</a></li>\n";
	}
	else {
		// do nothing if there is not an IRC log
	}
}

?>
<hr />
<div class="headnav">
  <p>$Date: 2019/11/07 14:49:21 $ </p>
</div>
</body>
</html>
