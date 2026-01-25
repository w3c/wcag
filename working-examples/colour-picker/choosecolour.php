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

// Set new colour if form submitted
if ($_POST)
{
	// Get posted colours
	$strBackcolour = $_POST["bcolour"];
	$strForecolour = $_POST["fcolour"];

	// Set cookies
	setcookie("backcolour", $strBackcolour, time() + (3600 * 24 * 365), "/");
	setcookie("forecolour", $strForecolour, time() + (3600 * 24 * 365), "/");
}
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"> 
<html lang="en">
<head>
	<title>Colour Picker - Choose Colour</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<link href="style.css" rel="stylesheet" type="text/css">
<?php
// Set style block
echo "\t<style type=\"text/css\">body, legend, a{ color: " . htmlspecialchars($strForecolour) . "; background: " . htmlspecialchars($strBackcolour) . ";}</style>\n";
?>
</head>
<body>
<h1>Colour Picker - Choose Colour</h1>
<p>
<a href="index.php">Back to the colour picker</a>.
</p>
<form id="pickerform" method="post" action="choosecolour.php">
<h2 id="foreground">Foreground Colour</h2>
<?php
// Build a grid of radio buttons with foreground colour choices
$iCounter=0;
echo "<div class=\"row\">\n";
for ($iInnerRed=0; $iInnerRed<16; $iInnerRed+=3)
{
	for ($iInnerGreen=0; $iInnerGreen<16; $iInnerGreen+=3)
	{
		for ($iInnerBlue=0; $iInnerBlue<16; $iInnerBlue+=3)
		{
			$iCounter++;
			$strColour = strtoupper("#". dechex($iInnerRed) . dechex($iInnerGreen) . dechex($iInnerBlue));
			$strID = "fc" . substr($strColour, -3);
			echo "\t<div class=\"col\">";
			if ($strColour == strtoupper($strForecolour))
				echo "<input type=\"radio\" name=\"fcolour\" id=\"$strID\" value=\"$strColour\" checked=\"checked\"> ";
			else
				echo "<input type=\"radio\" name=\"fcolour\" id=\"$strID\" value=\"$strColour\"> ";
			echo "<label for=\"$strID\"><span class=\"colour\" style=\"background-color: $strColour\">&#160;</span> $strColour</label></div>\n";
			if (($iCounter%8) === 0)
			{
				echo "</div>\n";
				if ($iCounter < 216)
					echo "<div class=\"row\">\n";
			}
		}
	}
}

?>
<h2 id="background">Background Colour</h2>
<?php
// Build a grid of radio buttons with background colour choices
$iCounter=0;
echo "<div class=\"row\">\n";
for ($iInnerRed=0; $iInnerRed<16; $iInnerRed+=3)
{
	for ($iInnerGreen=0; $iInnerGreen<16; $iInnerGreen+=3)
	{
		for ($iInnerBlue=0; $iInnerBlue<16; $iInnerBlue+=3)
		{
			$iCounter++;
			$strColour = strtoupper("#". dechex($iInnerRed) . dechex($iInnerGreen) . dechex($iInnerBlue));
			$strID = "bc" . substr($strColour, -3);
			echo "\t<div class=\"col\">";
			if ($strColour == strtoupper($strBackcolour))
			{
				echo "<input type=\"radio\" name=\"bcolour\" id=\"$strID\" value=\"$strColour\" checked=\"checked\"> ";
			}
			else
			{
				echo "<input type=\"radio\" name=\"bcolour\" id=\"$strID\" value=\"$strColour\"> ";
			}
			echo "<label for=\"$strID\"><span class=\"colour\" style=\"background-color: $strColour\">&#160;</span> $strColour</label></div>\n";
			if (($iCounter%8) === 0)
			{
				echo "</div>\n";
				if ($iCounter < 216)
					echo "<div class=\"row\">\n";
			}
		}
	}
}

?>
<div class="submit">
	<input type="submit" value="Change Colours">
</div>

</form>
<p>
<a href="index.php">Back to the colour picker</a>.
</p>

</body>
</html>
