<?php
if (isset($_GET['set'])) $thestyle = $_GET['set']; 
else $thestyle = "style2";
if ($thestyle == "style1")
	{
	$thestyle = "style2";
	}
else
	{
	$thestyle = "style1";
	}
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
<title>Using PHP $_GET to apply a different external CSS file</title>
   

  <link rel="stylesheet" type="text/css" media="screen" href="<?php echo($thestyle);?>.css" >

</head>

<body>

<?php
if ($thestyle == "style1") {
	echo "<a href=\"index.php?set=style1\">Switch to Style Sheet Two</a>";
	}
else {
	echo "<a href=\"index.php?set=style2\">Switch to Style Sheet One</a>";
	}
?>
<div id="mainbody">
  <h1>Conference report</h1>
  <p>Last week's conference presented an impressive line-up of speakers...</p>
</div>
</body>
</html>
