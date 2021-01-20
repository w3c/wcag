<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" dir="ltr">
	<head>
		<?php $title="Font characteristics contrast"; include "../../_head.phi"; ?>
		<link rel="stylesheet" type="text/css" href="apca.css"/>
	</head>
	<body>
		<?php include "../../_header.phi"; ?>
		<h1>Method: <?php print ($title); ?></h1>
		<div class="tabs" aria-label="Method">
			<?php include "../_tabs.phi"; ?>
			<div role="tabpanel" id="intro" tabindex="0" aria-labelledby="intro-button">
				<?php include "intro.html"; ?>
			</div>
			<div role="tabpanel" id="description" tabindex="0" aria-labelledby="description-button" class="is-hidden">
				<?php include "description.html"; ?>
			</div>
			<div role="tabpanel" id="examples" tabindex="0" aria-labelledby="examples-button" class="is-hidden">
				<?php include "examples.html"; ?>
			</div>
			<div role="tabpanel" id="tests" tabindex="0" aria-labelledby="tests-button" class="is-hidden">
				<?php include "tests.html"; ?>
			</div>
			<div role="tabpanel" id="resources" tabindex="0" aria-labelledby="resources-button" class="is-hidden">
				<?php include "resources.html"; ?>
			</div>
		</div>
		<?php include "footer.html"; ?>
		<?php include "../../_footer.phi"; ?>
	</body>
</html>