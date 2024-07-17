<?php
	$iErrorCount = 0;
	$bSubmitted = false;
	$bRegion = 0;
	$strError = "<ul>\n";

	$strSuggestion = $strOptional = $strRating = $strJibberish = $strForename = $strAge = $strEmail = ""; 

	if ($_POST)
	{
		if (isset($_POST['suggestion'])) $strSuggestion = $_POST["suggestion"];
		if (isset($_POST['optemail'])) $strOptional = $_POST["optemail"];
		if (isset($_POST['rating'])) $strRating = $_POST["rating"];
		if (isset($_POST['jibberish'])) $strJibberish = $_POST["jibberish"];
		if (isset($_POST['forename'])) $strForename = $_POST["forename"];
		if (isset($_POST['age'])) $strAge = $_POST["age"];
		if (isset($_POST['email'])) $strEmail = $_POST["email"];

		if (isset($_POST['signup']) && strlen($_POST["signup"]) > 0)
		{
			$bSubmitted = true;

			if (strlen($strForename) < 2 || is_numeric($strForename))
			{
				$iErrorCount++;
				$strError .= "<li><a href=\"#forename\">Please enter your forename</a></li>\n";
			}

			if (!is_numeric($strAge))
			{
				$iErrorCount++;
				$strError .= "<li><a href=\"#age\">Please enter your age</a></li>\n";
			}

			if (!preg_match("/^[\w\-\.\']{1,}\@([\da-zA-Z\-]{1,}\.){1,}[\da-zA-Z\-]{2,}$/", $strEmail))
			{
				$iErrorCount++;
				$strError .= "<li><a href=\"#email\">Please enter your email address</a></li>\n";
			}
		}
		else if (strlen($_POST["submit"]) > 0)
		{
			$bRegion = 1;
			$bSubmitted = true;

			if (strlen($strSuggestion) < 2 || is_numeric($strSuggestion))
			{
				$iErrorCount++;
				$strError .= "<li><a href=\"#suggestion\">Enter a suggestion</a></li>\n";
			}

			if (strlen($strOptional) > 0 && !preg_match("/^[\w\-\.\']{1,}\@([\da-zA-Z\-]{1,}\.){1,}[\da-zA-Z\-]{2,}$/", $strOptional))
			{
				$iErrorCount++;
				$strError .= "<li><a href=\"#optemail\">Please enter your email address (optional)</a></li>\n";
			}

			if (!is_numeric($strRating))
			{
				$iErrorCount++;
				$strError .= "<li><a href=\"#rating\">Please rate this suggestion</a></li>\n";
			}
		}

		$strError .= "</ul>\n";

		if ($iErrorCount > 0)
			$strError = "<h2>$iErrorCount Errors in Submission</h2>\n" . $strError;
	}
?>
<!DOCTYPE HTML>
<html lang="en">
<head>
	<meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">	
	<title>Form Validation</title>
	<link href="css/validate.css" rel="stylesheet">
	<script src="scripts/validate.js"></script>
</head>
<body>

<h1>Form Validation</h1>
<p>
The following form is validated before being submitted if scripting is available, otherwise the form is validated on the server. All fields are required, except those marked optional. If errors are found in the submission, the form is cancelled and a list of errors is displayed at the top of the form.</p>
<p>The<a href="validation.zip"> source code for this example (zip)</a> is available.</p>
<p>&nbsp;</p>
<?php if ($bSubmitted == true && $iErrorCount == 0) { ?>
<h1 id="focuspoint">Successful Submission</h1>
<p>
When it comes to filling out web forms, you rock!
</p>
<?php
	}
	else if ($iErrorCount > 0 && $bRegion == 0)
		echo $strError;

	if ($bSubmitted == false || ($bSubmitted == true && $iErrorCount != 0)) {
?>


<p>
Please enter your details below.
</p>

<h2>Validating Form</h2>
<form id="personalform" method="post" action="index.php">
<div class="validationerrors"></div>
<fieldset>
<legend>Personal Details</legend>
<div>
<label for="forename">Please enter your forename</label>
<input autocomplete="given-name" type="text" size="20" name="forename" id="forename" class="string" value="<?php echo htmlspecialchars($strForename); ?>">
</div>
<div>
<label for="age">Please enter your age</label> 
<input type="text" size="20" name="age" id="age" class="number" value="<?php echo htmlspecialchars($strAge); ?>">
</div>
<div>
<label for="email">Please enter your email address</label> 
<input autocomplete="email" type="text" size="20" name="email" id="email" class="email" value="<?php echo htmlspecialchars($strEmail); ?>">
</div>
</fieldset>
<div>
<input type="submit" name="signup" value="Sign up">
</div>
</form>
<?php
	}
	if ($iErrorCount > 0 && $bRegion == 1)
		echo $strError;

	if ($bSubmitted == false || ($bSubmitted == true && $iErrorCount != 0)) {

?>
<h2>Second Form</h2>
<form id="secondform" method="post" action="index.php#focuspoint">
<div class="validationerrors"></div>
<fieldset>
<legend>Second Form Details</legend>
<div>
<label for="suggestion">Enter a suggestion</label>
<input type="text" size="20" name="suggestion" id="suggestion" class="string" value="<?php echo htmlspecialchars($strSuggestion); ?>">
</div>
<div>
<label for="optemail">Please enter your email address (optional)</label>
<input autocomplete="email" type="text" size="20" name="optemail" id="optemail" class="optional email" value="<?php echo htmlspecialchars($strOptional); ?>">
</div>
<div>
<label for="rating">Please rate this suggestion</label> 
<input type="text" size="20" name="rating" id="rating" class="number" value="<?php echo htmlspecialchars($strRating); ?>">
</div>
<div>
<label for="jibberish">Enter some jibberish (optional)</label>
<input type="text" size="20" name="jibberish" id="jibberish" value="<?php echo htmlspecialchars($strJibberish); ?>">
</div>
</fieldset>
<div>
<input type="submit" name="submit" value="Add Suggestion">
</div>
</form>
<?php } ?>
</body>
</html>
