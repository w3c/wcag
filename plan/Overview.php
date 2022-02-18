<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" dir="ltr">
	<head>
		<title>AG Plan</title>
		<?php include "../_head.phi"; ?>
	</head>
	<body>
		<?php include "../_header.phi"; ?>
		<h1>AG Plan</h1>
		<p>AG leadership use confidential planning channels:</p>
		<ul>
			<?php
					include "../../../2017/01/telecon-info/filtered-telecon-list.phi";
					showTeleconList("ag-plan", "ag-chairs");
				?>
		</ul>
		<p><a href="minutes">Minutes of past teleconferences</a> are available.</p>
		<?php include "../_footer.phi"; ?>
	</body>
</html>
