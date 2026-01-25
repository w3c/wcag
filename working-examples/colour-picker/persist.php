<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"> 
<html lang="en">
<head>
	<title>Colour picker persistence</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<link href="style.css" rel="stylesheet" type="text/css">
<?php
// Get the foreground colour
if (strlen($_COOKIE["forecolour"]) == 4)
{
	$strForecolour = $_COOKIE["forecolour"];
}
else
{
	$strForecolour = "#000";
}

// Get the background colour
if (strlen($_COOKIE["backcolour"]) == 4)
{
	$strBackcolour = $_COOKIE["backcolour"];
}
else
{
	$strBackcolour = "#FFF";
}

// Set style block
echo "\t<style type=\"text/css\">body, legend, a{ color: " . htmlspecialchars($strForecolour) . "; background: " . htmlspecialchars($strBackcolour) . ";}</style>\n";
?>
</head>
<body>
<h1>Colour picker persistence</h1>
<p>
Cookies are set with JavaScript when the colour picker is used, and then used to persist the styles on other pages. If JavaScript isn't available, the server-side colour picker would set the cookies. The following is an example of how the <code>style</code> element could be written into the <code>head</code> on the fly with PHP, but the principle is the same for all server-side languages.
</p>
<pre><code>&lt;?php
if (isset($_COOKIE["forecolour"]) &amp;&amp; strlen($_COOKIE["forecolour"]) == 4)
{
    $strForecolour = $_COOKIE["forecolour"];
}
else
{
    $strForecolour = "#000";
}

if (isset($_COOKIE["backcolour"]) &amp;&amp; strlen($_COOKIE["backcolour"]) == 4)
{
    $strBackcolour = $_COOKIE["backcolour"];
}
else
{
    $strBackcolour = "#FFF";
}

echo "\t&lt;style type=\"text/css\"&gt;body, legend, a{ color: " . htmlspecialchars($strForecolour) . "; background: " . htmlspecialchars($strBackcolour) . ";}&lt;/style&gt;\n";
?&gt;</code></pre>
<p>
<a href="index.php">Back to the colour picker</a>.
</p>

</body>
</html>
