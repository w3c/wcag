<?php
// Get the foreground colour
if (isset($_COOKIE["forecolour"]) && strlen($_COOKIE["forecolour"]) == 4)
{
	$strForecolour = $_COOKIE["forecolour"];
}
else
{
	$strForecolour = "#000";
}

// Get the background colour
if (isset($_COOKIE["backcolour"]) && strlen($_COOKIE["backcolour"]) == 4)
{
	$strBackcolour = $_COOKIE["backcolour"];
}
else
{
	$strBackcolour = "#FFF";
}

// If colours sent through form (no JavaScript), set the
// colours
if ($_POST)
{
	// Get posted colours
	if (isset($_POST["background"])) $strBackcolour = $_POST["background"];
	if (isset($_POST["foreground"])) $strForecolour = $_POST["foreground"];

	// Set cookies
	setcookie("backcolour", $strBackcolour, time() + (3600 * 24 * 365), "/");
	setcookie("forecolour", $strForecolour, time() + (3600 * 24 * 365), "/");
}
?><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"> 
<html lang="en">
<head>
	<title>Colour Picker</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<script type="text/javascript" src="colourpicker.js"></script>
	<link href="style.css" rel="stylesheet" type="text/css">
<?php
// Set style block
echo "\t<style type=\"text/css\">body, legend, a{ color: " . htmlspecialchars($strForecolour) . "; background: " . htmlspecialchars($strBackcolour) . ";}</style>\n";
?>
</head>
<body>
<h1>Colour Picker</h1>
<form id="colourpicker" method="post" action="index.php">
<fieldset>
<legend>Colours</legend>
<div>
	<label for="foreground">Foregound: <a href="choosecolour.php#foreground" id="forelink">pick<span class="context"> a foreground colour</span></a></label>
	<input type="text" value="<?php echo htmlspecialchars($strForecolour); ?>" id="foreground" name="foreground">
</div>
<div>
	<label for="background">Backgound: <a href="choosecolour.php#background" id="backlink">pick<span class="context"> a foreground colour</span></a></label>
	<input type="text" value="<?php echo htmlspecialchars($strBackcolour); ?>" id="background" name="background">
</div>
</fieldset>
<div>
	<input type="submit" value="Change colours" id="changecolour">
</div>
</form>
<h2>Random Text</h2>
<p>
<a href="persist.php">Demonstrate persistence on another page</a>.</p>
<p><a href="Colourpicker.zip">Source code for this  example (zip)</a></p>
<p>
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Praesent at velit non massa semper suscipit. Quisque dapibus, urna vel lacinia ullamcorper, velit nulla porttitor eros, eget tincidunt velit purus id nunc. Maecenas magna. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In turpis lorem, rutrum vel, semper feugiat, ultricies et, urna. Nam vel nunc id ligula ultricies porta. Nullam non lorem. Pellentesque sit amet augue. Phasellus leo turpis, aliquam posuere, facilisis dapibus, bibendum et, ante. Praesent ipsum tortor, hendrerit eget, tempus in, porta vel, turpis. Phasellus urna lacus, laoreet vel, volutpat eget, tincidunt sagittis, ipsum.
</p>
<p>
Maecenas id leo. Donec massa enim, auctor at, aliquam sed, convallis sed, diam. Duis mattis sodales nisl. Integer nunc. Maecenas et quam. Quisque non sem quis purus faucibus tempor. Curabitur ipsum elit, dapibus sed, lobortis non, ornare at, arcu. Vivamus facilisis pharetra metus. Integer a dui sit amet nisl consectetuer ultrices. Praesent sed erat a velit interdum euismod. Curabitur laoreet. Suspendisse potenti. Vestibulum ut pede ac nibh sollicitudin cursus. Morbi eu est. Nulla eros metus, egestas at, interdum vel, ultrices eget, est. Nullam tempor, arcu sed tincidunt iaculis, ipsum ligula egestas lacus, at aliquam ligula sapien at nunc. Sed ligula.
</p>
<p>
Fusce eget quam. Nulla facilisi. Donec quis diam ut metus aliquet mattis. Vestibulum eu libero. Aenean porttitor felis vel nunc. Proin volutpat euismod velit. Proin porttitor enim eu libero. Sed tortor ipsum, dignissim eu, consequat elementum, pellentesque eu, elit. Morbi laoreet risus nec quam. Pellentesque pellentesque lacus in sapien egestas blandit. Vestibulum at metus nec lectus eleifend commodo.
</p>
<p>
In aliquam euismod mauris. Morbi ac diam. Phasellus bibendum odio vel lacus. Morbi justo libero, pellentesque iaculis, gravida pretium, condimentum vel, massa. Nunc nunc nisl, scelerisque eget, laoreet non, iaculis hendrerit, nisi. Etiam ut ligula a lorem adipiscing euismod. Vivamus ligula leo, bibendum quis, congue molestie, pulvinar eu, velit. Proin molestie, libero quis pellentesque tincidunt, enim felis dapibus eros, eget faucibus massa ante elementum metus. Suspendisse potenti. Nunc quis ligula non augue commodo semper. Cras mollis aliquam magna. Cras eu tortor id ipsum consectetuer tempor. Donec ac massa sit amet ante tincidunt laoreet. Sed nisi sem, scelerisque a, dignissim in, rhoncus eget, nibh. Nunc ac orci quis magna pharetra aliquet. Fusce lectus. In massa felis, volutpat eget, iaculis sed, iaculis eu, lorem. Cras sapien. Pellentesque libero nunc, luctus in, adipiscing non, molestie in, dolor.
</p>
<p>
Quisque lobortis accumsan orci. Nullam arcu. Pellentesque a eros. Sed dapibus urna. Curabitur in enim. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce quis purus. Praesent iaculis commodo risus. Pellentesque ipsum nulla, ullamcorper et, vehicula vitae, malesuada a, diam. Cras nec neque eget mauris posuere commodo. Fusce rhoncus elementum tortor. Etiam eget pede. Cras et est. Morbi et est. Vestibulum ut orci id mauris ullamcorper lacinia. Nunc eleifend mollis eros. Suspendisse velit ligula, vulputate eget, vulputate ut, ultricies vel, risus. Donec vulputate est eu tellus. Donec magna dui, adipiscing in, mattis ac, lobortis et, purus. 
</p>

</body>
</html>
