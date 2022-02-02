<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" dir="ltr">
	<head>
<?php include "_head.phi"; ?>
		<title>Accessibility Guidelines Working Group</title>
	</head>
	<body>
<?php include "_header.phi"; ?>
		<h1>Accessibility Guidelines Working Group</h1>

		<p>The mission of the Accessibility Guidelines Working Group is to develop specifications to support making implementations of web technologies accessible for people with disabilities, and to develop and maintain implementation support materials.</p>
		
		<p>Some information on this page is also shown on, and may be more current in, the <a href="https://www.w3.org/groups/wg/ag">automatically generated Accessibility Guidelines Working Group page</a>.</p>

		<section id="announcements">
			<h2>Announcements</h2>
<?php
$group = "WCAG";
require_once "_db_connect.phi";
$sth = $dbh->prepare("select * from announcements where `group` = :group and (date_start <= curdate() or date_start IS NULL) and (date_end >= curdate() or date_end is null) order by date_display, date_start, header;");
$sth->bindValue(":group", $group, PDO::PARAM_STR);
$sth->execute();
if ($sth->rowCount() > 0) {
	while ($row = $sth->fetch()) {
		print("<p>");
		if ($row['date_display'] != null) print("<em>" . $row['date_display'] . "</em> - ");
		else if ($row['date_start'] != null) print("<em>" . $row['date_start'] . "</em> - ");
		if ($row['header'] != null) print("<strong>" . $row['header']  . "</strong>: ");
		print($row['text']);
		print("</p>");
	}
} else {
	print("<p>No announcements at the moment.</p>");
}
?>
		</section>

		<section id="work">
			<h2>Current Work</h2>
			<p>The Working Group maintains a comprehensive list of <a href="deliverables">publications and current timelines</a>.</p>
			<p>The <a href="https://www.w3.org/WAI/GL/wiki/Timelines">Project Plan</a> details intended timeline and milestones for this work. A <a href="https://www.w3.org/TR/tr-groups-all#tr_Web_Content_Accessibility_Guidelines_Working_Group">list of publications</a> on the W3C Technical Reports page includes completed deliverables that are no longer worked on by the Working Group.</p>


			<section>
				<h3>WCAG 3</h3>
				<p>Work on W3C Accessibility Guidelines 3 takes place in many task forces and subgroups of the Working Group. Information about projects and timelines is available on the <a href="https://github.com/w3c/silver/wiki">WCAG 3 Project Plan</a>.</p>
			</section>
			
			<section>
				<h3>WCAG 2.2</h3>
				<p>The Working Group is processing comments from wide review and preparing for Candidate Recommendation. Current work is shown in <a href="https://github.com/w3c/wcag/issues/">WCAG issues</a>.</p>
			</section>
		</section>

		<section id="taskforces">
			<h2>Task Forces</h2>
			<p>The AG WG uses <a href="task-forces">task forces</a> to focus work on specific projects in addition to the work above. Task Forces are described on the related page. Some task forces form sub-groups to further divide the work.</p>
		</section>

		<section id="contribute">
			<h2>How to Comment, Contribute, and Participate</h2>
			<p>The Accessibility Guidelines Working Group engages with stakeholders in a variety of ways. See the following resources for information on:</p>
			<ul>
				<li><a href="/WAI/WCAG20/comments/">How to contribute to the Working Group and file comments</a>;</li>
				<li><a href="https://github.com/w3c/wcag/">How to contribute to the source repository directly</a>;</li>
				<li><a href="participation">How to participate in (join) the Working Group</a>.</li>
			</ul>
		</section>

		<section id="communication">
			<h2>Meetings and Communication</h2>
			<p>The AG WG conducts its work using a variety of synchronous and asynchronous tools. The <a href="communication">communication</a> page provides details about:</p>
			<ul>
				<li>Teleconferences of the Working Group and its task forces (also see <a href="https://www.w3.org/WAI/GL/wiki/Upcoming_agendas">upcoming agendas</a>, <a href="minutes-history">meeting minutes</a>);</li>
				<li>Face to face meetings (also see face to face <a href="wiki/Meetings">meeting pages</a>);</li>
				<li>Email lists;</li>
				<li><a href="https://github.com/w3c/wcag/">WCAG 2.0 source repository</a> and <a href="https://github.com/w3c/wcag21/">WCAG 2.1 source repository</a>;</li>
				<li><a href="wiki/">Wiki</a>;</li>
				<li><a href="/2002/09/wbs/35422/">Web-Based Surveys (WBS)</a>;</li>
				<li><a href="https://github.com/w3c/wcag/issues">WCAG 2 source repository issue tracker</a>.</li>
			</ul>
			<p>These tools are used by participants of the Working Group. For ways non-participants can contribute, see <!--<a href="contribute">how to contribute to the Working Group and file comments</a>--><a href="/WAI/WCAG20/comments/">How to contribute to the Working Group and file comments</a>.</p>

		</section>

		<section id="administrative">
			<h2>Administrative Information</h2>
			<p> Work of the AG WG is in accordance with the <a href="http://www.w3.org/2015/Process-20150901/">W3C Process</a>. AG WG work is funded in part by the <a href="http://www.w3.org/WAI/Core2015/">WAI Core 2015 Project</a>. The work of this group does not necessarily reflect the views or policies of the funders.</p>
			<p>The chairs of the AG WG, responsible for overall leadership and management, are Chuck Adams, Alastair Campbell, and Rachael Montgomery. The staff contact, responsible for <a href="http://www.w3.org/Consortium/Process/">W3C Process</a> and general support, is <a href="http://www.w3.org/People/cooper/">Michael Cooper</a>. Administrative inquiries may be sent to <a href="mailto:group-ag-chairs@w3.org">group-ag-chairs@w3.org</a>.</p>
			<p>Work on WCAG 3 is additionally led by Shawn Lauriat and Jeanne Spellman, task force co-facilitators, and Wilco Fiers, WCAG 3 Project Manager. Inquiries about WCAG 3 should be sent to <a href="mailto:group-ag-plan@w3.org">group-ag-plan@w3.org</a> to reach these people as well as the chairs.</p>
			<p>The AG WG maintains the following operational resources:</p>
			<ul>
				<li><a href="decision-policy">Decision policy</a>;</li>
				<li><a href="wiki/Decisions">Record of decisions made by the WG</a>;</li>
				<!--<li><a href="archive">Archives of past activity</a>;</li>-->
				<li><a href="minutes-history">meeting minutes</a>.</li>
			</ul>
			<p>W3C maintains a <a href="http://www.w3.org/2004/01/pp-impl/35422/status">public list of any patent disclosures</a> made in connection with the deliverables of the group; that page also includes instructions for disclosing a patent.</p>
			<p><a href="https://www.w3.org/2000/09/dbwg/details?group=35422&amp;public=1">Current participants in the AG WG</a>.</p>

		</section>
<?php include "_footer.phi"; ?>
	</body>
</html>