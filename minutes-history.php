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
	<?php
	$channel = array("ag", "wai-wcag");
	include "../../2022/01/minutes/default-view.phi";
	?>
</body>
</html>
