<?php
// This file is the lead-in file for the quickref. It needs to be concatenated with the output of the following:
// java org.apache.xalan.xslt.Process -IN sources/wcag2-quickref.xml -XSL sources/quickref.xslt -OUT quickref.php
// like this:
// cat sources/quickref-leadin.php quickref-temp.php > ../../WCAG20/quickref/quickref-temp.php

   header("Expires: Sat, 01 Jan 2000 00:00:00 GMT");
   header("Last-Modified: ".gmdate("D, d M Y H:i:s")." GMT");
   header("Pragma: public");
   header("Expires: 0");
   header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
   header("Cache-Control: public");
   session_cache_limiter("must-revalidate");
   // set a variable for use in determining the source of requests 
   // (so that users don't get broken links if they've customized)
    $uaString = isset($_SERVER['HTTP_REFERER']) ? $_SERVER['HTTP_REFERER'] : "";
	
	if ($_POST)
	{
		if (isset($_POST["savesettings"]) && $_POST["savesettings"] == "Y")
		{
			$bCookies = true;
			setcookie("allowcookies", "Y", time()+365*24*60*60, "/");
		}
			else
			{
				$bCookies = false;
				if (isset($_COOKIE["allowcookies"]))
					setcookie("allowcookies", "N", time()-3600, "/");
			}

		if (isset($_POST["htmlopt"]) && $_POST["htmlopt"] == "Y")
		{
			$bHTML = true;
			if ($bCookies)
				setcookie("htmlopt", "Y", time()+365*24*60*60, "/");
		}
			else
			{
				$bHTML = false;
				if ($bCookies)
					setcookie("htmlopt", "N", time()+365*24*60*60, "/");
			}

		if (isset($_POST["cssopt"]) && $_POST["cssopt"] == "Y")
		{
			$bCSS = true;
			if ($bCookies)
				setcookie("cssopt", "Y", time()+365*24*60*60, "/");
		}
			else
			{
				$bCSS = false;
				if ($bCookies)
					setcookie("cssopt", "N", time()+365*24*60*60, "/");
			}

		if (isset($_POST["smilopt"]) && $_POST["smilopt"] == "Y")
		{
			if ($bCookies)
				setcookie("smilopt", "Y", time()+365*24*60*60, "/");
			$bSMIL = true;
		}
			else
			{
				$bSMIL = false;
				if ($bCookies)
					setcookie("smilopt", "N", time()+365*24*60*60, "/");
			}

		if (isset($_POST["scriptopt"]) && $_POST["scriptopt"] == "Y")
		{
			$bScript = true;
			if ($bCookies)
				setcookie("scriptopt", "Y", time()+365*24*60*60, "/");
		}
			else
			{
				$bScript = false;
				if ($bCookies)
					setcookie("scriptopt", "N", time()+365*24*60*60, "/");
			}
		
		if (isset($_POST["serversideopt"]) && $_POST["serversideopt"] == "Y")
		{
			$bServerSide = true;
			if ($bCookies)
				setcookie("serversideopt", "Y", time()+365*24*60*60, "/");
		}
			else
			{
				$bServerSide = false;
				if ($bCookies)
					setcookie("serversideopt", "N", time()+365*24*60*60, "/");
			}
		
			if (isset($_POST["flashopt"]) && $_POST["flashopt"] == "Y")
		{
			$bFlash = true;
			if ($bCookies)
				setcookie("flashopt", "Y", time()+365*24*60*60, "/");
		}
			else
			{
				$bFlash = false;
				if ($bCookies)
					setcookie("flashopt", "N", time()+365*24*60*60, "/");
			}
			
			if (isset($_POST["pdfopt"]) && $_POST["pdfopt"] == "Y")
		{
			$bPDF = true;
			if ($bCookies)
				setcookie("pdfopt", "Y", time()+365*24*60*60, "/");
		}
			else
			{
				$bPDF = false;
				if ($bCookies)
					setcookie("pdfopt", "N", time()+365*24*60*60, "/");
			}
			
			if (isset($_POST["silverlightopt"]) && $_POST["silverlightopt"] == "Y")
		{
			$bSilverlight = true;
			if ($bCookies)
				setcookie("silverlightopt", "Y", time()+365*24*60*60, "/");
		}
			else
			{
				$bSilverlight = false;
				if ($bCookies)
					setcookie("silverlightopt", "N", time()+365*24*60*60, "/");
			}
			
		if (isset($_POST["ariaopt"]) && $_POST["ariaopt"] == "Y")
		{
			$bARIA = true;
			if ($bCookies)
				setcookie("ariaopt", "Y", time()+365*24*60*60, "/");
		}
			else
			{
				$bARIA = false;
				if ($bCookies)
					setcookie("ariaopt", "N", time()+365*24*60*60, "/");
			}

		if (isset($_POST["level1opt"]) && $_POST["level1opt"] == "Y")
		{
			$bLevel1 = true;
			if ($bCookies)
				setcookie("level1opt", "Y", time()+365*24*60*60, "/");
		}
			else
			{
				$bLevel1 = false;
				if ($bCookies)
					setcookie("level1opt", "N", time()+365*24*60*60, "/");		
			}
		
		if (isset($_POST["level2opt"]) && $_POST["level2opt"] == "Y")
		{
			$bLevel2 = true;
			if ($bCookies)
				setcookie("level2opt", "Y", time()+365*24*60*60, "/");
		}
			else
			{
				$bLevel2 = false;
				if ($bCookies)
					setcookie("level2opt", "N", time()+365*24*60*60, "/");
			}

		if (isset($_POST["level3opt"]) && $_POST["level3opt"] == "Y")
		{
			$bLevel3 = true;
			if ($bCookies)
				setcookie("level3opt", "Y", time()+365*24*60*60, "/");
		}
			else
			{
				$bLevel3 = false;
				if ($bCookies)
					setcookie("level3opt", "N", time()+365*24*60*60, "/");
			}
		
		if (isset($_POST["introopt"]) && $_POST["introopt"] == "Y")
		{
			$bIntroduction = true;
			if ($bCookies)
				setcookie("introopt", "Y", time()+365*24*60*60, "/");
		}
			else
			{
				$bIntroduction = false;
				if ($bCookies)
					setcookie("introopt", "N", time()+365*24*60*60, "/");
			}		
		
		if (isset($_POST["confreqs"]) && $_POST["confreqs"] == "Y")
		{
			$bConformance = true;
			if ($bCookies)
				setcookie("confreqs", "Y", time()+365*24*60*60, "/");
		}
			else
			{
				$bConformance = false;
				if ($bCookies)
					setcookie("confreqs", "N", time()+365*24*60*60, "/");
			}		
		
		if (isset($_POST["advopt"]) && $_POST["advopt"] == "Y")
		{
			$bAdvisory = true;
			if ($bCookies)
				setcookie("advopt", "Y", time()+365*24*60*60, "/");
		}
			else
			{
				$bAdvisory = false;
				if ($bCookies)
					setcookie("advopt", "N", time()+365*24*60*60, "/");
			}
		
		if (isset($_POST["sufopt"]) && $_POST["sufopt"] == "Y")
		{
			$bSufficient = true;
			if ($bCookies)
				setcookie("sufopt", "Y", time()+365*24*60*60, "/");
		}
			else
			{
				$bSufficient = false;
				if ($bCookies)
					setcookie("sufopt", "N", time()+365*24*60*60, "/");
			}
    
	}
// handle POST settings above, other requests below	
	else
	{
	// If a request comes from a guidelines draft, ignore cookie settings entirely. This prevents situations where a user follows a how to meet link from a AAA SC, but has prefs set to hide AAA SC.
		if(stristr($uaString, "/TR/") || stristr($uaString, "WCAG20/WD-WCAG20") || stristr($uaString, "WCAG20/NOTE-WCAG20"))
			$bCookies = false;
		elseif (isset($_COOKIE["allowcookies"]) && $_COOKIE["allowcookies"] == "Y")
			$bCookies = true;
		else
			$bCookies = false;
		
		if ($bCookies && isset($_COOKIE["htmlopt"]))
		{
			if ($_COOKIE["htmlopt"] == "Y")
				$bHTML = true;
			else
				$bHTML = false;
		}
		else
			$bHTML = true;
			
		if ($bCookies && isset($_COOKIE["cssopt"]))
		{
			if ($_COOKIE["cssopt"] == "Y")
				$bCSS = true;
			else
				$bCSS = false;
		}
		else
			$bCSS = true;
			

		if ($bCookies && isset($_COOKIE["smilopt"]))
		{
			if ($_COOKIE["smilopt"] == "Y")
				$bSMIL = true;
			else
				$bSMIL = false;
		}
		else
			$bSMIL = true;


		if ($bCookies && isset($_COOKIE["scriptopt"]))
		{
			if ($_COOKIE["scriptopt"] == "Y")
				$bScript = true;
			else
				$bScript = false;
		}
		else
			$bScript = true;
			
		if ($bCookies && isset($_COOKIE["serversideopt"]))
		{
			if ($_COOKIE["scriptopt"] == "Y")
				$bServerSide = true;
			else
				$bServerSide = false;
		}
		else
			$bServerSide = true;
		
		
		if ($bCookies && isset($_COOKIE["flashopt"]))
		{
			if ($_COOKIE["flashopt"] == "Y")
				$bFlash = true;
			else
				$bFlash = false;
		}
		
		else
			$bFlash = true;

		if ($bCookies && isset($_COOKIE["pdfopt"]))
		{
			if ($_COOKIE["pdfopt"] == "Y")
				$bPDF = true;
			else
				$bPDF = false;
		}
		
		else
			$bPDF = true;

		if ($bCookies && isset($_COOKIE["silverlightopt"]))
		{
			if ($_COOKIE["silverlightopt"] == "Y")
				$bSilverlight = true;
			else
				$bSilverlight = false;
		}
		
		else
			$bSilverlight = true;

		if ($bCookies && isset($_COOKIE["ariaopt"]))
		{
			if ($_COOKIE["ariaopt"] == "Y")
				$bARIA = true;
			else
				$bARIA = false;
		}
		else
			$bARIA = true;

		if ($bCookies && isset($_COOKIE["level1opt"]))
		{
			if ($_COOKIE["level1opt"] == "Y")
				$bLevel1 = true;
			else
				$bLevel1 = false;
		}
		else
			$bLevel1 = true;

		if ($bCookies && isset($_COOKIE["level2opt"]))
		{
			if ($_COOKIE["level2opt"] == "Y")
				$bLevel2 = true;
			else
				$bLevel2 = false;
		}
		else
			$bLevel2 = true;

		if ($bCookies && isset($_COOKIE["level3opt"]))
		{
			if ($_COOKIE["level3opt"] == "Y")
				$bLevel3 = true;
			else
				$bLevel3 = false;
		}
		else
			$bLevel3 = true;
			
		if ($bCookies && isset($_COOKIE["advopt"]))
		{
			if ($_COOKIE["advopt"] == "Y")
				$bAdvisory = true;
			else
				$bAdvisory = false;
		}
		else
			$bAdvisory = true;
			
			
			
		if ($bCookies && isset($_COOKIE["sufopt"]))
		{
			if ($_COOKIE["sufopt"] == "Y")
				$bSufficient = true;
			else
				$bSufficient = false;
		}
		else
			$bSufficient = true;
			
		if ($bCookies && isset($_COOKIE["introopt"]))
		{
			if ($_COOKIE["introopt"] == "Y")
				$bIntroduction = true;
			 else 
			 	$bIntroduction = false;
				
		}
		else
			$bIntroduction = true;
			
		if ($bCookies && isset($_COOKIE["confreqs"]))
		{
			if ($_COOKIE["confreqs"] == "Y")
				$bConformance = true;
			 else 
			 	$bConformance = false;
				
		}
		else
			$bConformance = true;
					
	}
// These features allow show/hide configuration for the introduction and the conformance requrements.
// They are set independently from the form, but their state is saved when the quickref is customized.

	if (isset($_GET["introopt"]) && $_GET["introopt"] == "Y") { 
			$bIntroduction = true;
			setcookie("introopt", "Y", time()+365*24*60*60, "/");
			}
	if (isset($_GET["introopt"]) && $_GET["introopt"] == "N") {
			$bIntroduction = false;
			setcookie("introopt", "N", time()+365*24*60*60, "/");
			}	
			
	if (isset($_GET["confreqs"]) && $_GET["confreqs"] == "Y") { 
			$bConformance = true;
			setcookie("confreqs", "Y", time()+365*24*60*60, "/");
			}
	if (isset($_GET["confreqs"]) && $_GET["confreqs"] == "N") {
			$bConformance = false;
			setcookie("confreqs", "N", time()+365*24*60*60, "/");
			}	
	
?>
