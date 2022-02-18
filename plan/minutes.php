<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" dir="ltr">
	<head>
		<title>AG Plan Minutes</title>
		<?php include "../_head.phi"; ?>
	</head>
	<body>
		<?php include "../_header.phi"; ?>
		<h1>AG Plan Minutes</h1>
		<?php
			$channel_id = array('ag-chairs', 'ag-plan', 'silver-plan', 'wcag-plan');
			
			include "../../../2022/01/minutes/default-view.phi";
		?>
		<?php include "../_footer.phi"; ?>
	</body>
</html>