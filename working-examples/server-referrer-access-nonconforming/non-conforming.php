<?php 
// if the request comes from a file that contains the string "conforming.php" then render the page
	if(stristr($_SERVER['HTTP_REFERER'], "conforming.php")) {
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Non-Conforming Content</title>
</head>
<body>
  <h1>This is a non-conforming page</h1>
  <p>Because you came from <?php echo htmlspecialchars($_SERVER['HTTP_REFERER']); ?>, you are able to view the content on this page. </p>
</body>
</html>
<?php
}
// if the referring page is not conforming.php, then redirect the user to the conforming version
else  {
	header("Location: conforming.php");
}
?>
