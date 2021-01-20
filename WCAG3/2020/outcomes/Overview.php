<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" dir="ltr">
	<head>
		<?php $title="Outcome"; include "../_head.phi"; ?>
	</head>
	<body>
		<?php include "../_header.phi"; ?>
		<?php
			/* not working on W3C server for some reason, works fine on mine
			$base = "/WAI/GL/WCAG3/2020/outcomes/";
			$page = preg_replace("/.*\/([\w-_]+)(\.\w*)?$/", "$1", $_SERVER['REQUEST_URI']);
			if ($page == $base) print ("<p>Available WCAG 3 outcomes are in the navigation menu labeled <q>Other Pages in this Resource</q> with the first item <q>WCAG 3 Outcomes</q>.</p>");
			else include ($page . ".html");
			*/
		?>
		<p>Available WCAG 3 outcomes are in the navigation menu labeled <q>Other Pages in this Resource</q> with the first item <q>WCAG 3 Outcomes</q>.</p>
		<?php include "../_footer.phi"; ?>
	</body>
</html>