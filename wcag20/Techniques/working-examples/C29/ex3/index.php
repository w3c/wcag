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

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
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
