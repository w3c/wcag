<?php
	$title = "Visual contrast of text";
	$guideline = "Provide sufficient contrast between foreground text and its background.";
?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" dir="ltr">
	<head>
		<?php include "../../_head.phi"; ?>
		<link rel="stylesheet" type="text/css" href="style/visual-contrast-of-text.css" />
	</head>
	<body>
		<?php include "../../_header.phi"; ?>
		<h1><?php print ($title); ?></h1>
		<p><?php print ($guideline); ?></p>
		<div class="tabs" aria-label="How-To">
			<?php include "../_tabs.phi"; ?>
			<div role="tabpanel" id="get-started" tabindex="0" aria-labelledby="get-started-button">
				<?php include "get-started.html"; ?>
			</div>
			<div role="tabpanel" id="plan" tabindex="0" aria-labelledby="plan-button" class="is-hidden">
				<?php include "plan.html"; ?>
			</div>
			<div role="tabpanel" id="design" tabindex="0" aria-labelledby="design-button" class="is-hidden">
				<?php include "design.html"; ?>
			</div>
			<div role="tabpanel" id="develop" tabindex="0" aria-labelledby="develop-button" class="is-hidden">
				<?php include "develop.html"; ?>
			</div>
			<div role="tabpanel" id="examples" tabindex="0" aria-labelledby="examples-button" class="is-hidden">
				<?php include "examples.html"; ?>
			</div>
			<div role="tabpanel" id="resources" tabindex="0" aria-labelledby="resources-button" class="is-hidden">
				<?php include "resources.html"; ?>
			</div>
		</div>
		<?php include "footer.html"; ?>
		<?php include "../../_footer.phi"; ?>
	</body>
</html>