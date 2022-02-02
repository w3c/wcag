<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<?php include "../../_head.phi"; ?>
		<title>AG Silver Task Force</title>
	</head>
	<body>
		<?php include "../../_header.phi"; ?>
		<h1>Silver Task Force<br />
			<span class="subhead">of the <a href="https://www.w3.org/WAI/GL/">AG WG</a></span></h1>
		<p>Some information on this page is also shown on, and may be more current in, the <a href="https://www.w3.org/groups/tf/silver">automatically generated Silver Task Force page</a>.</p>
		<section id="contents">
			<h2>Page Contents</h2>
			<ul>
				<li><a href="#announcements">Announcements</a></li>
				<li><a href="#communication">Meetings and Communication</a></li>
				<li><a href="#work">Current Work</a></li>
				<li><a href="#publications">Publications</a></li>
				<li><a href="#contribute">How to Comment, Contribute, and Participate</a></li>
				<li><a href="#administrative">Administrative Information</a></li>
			</ul>
		</section>
		<section id="announcements">
			<h2>Announcements</h2>
			<?php 
      $group = "Silver";
      require_once "../../_db_connect.phi";
      $sth = $dbh->prepare("select * from announcements where `group` = :group and (date_start <= curdate() or date_start IS NULL) and (date_end >= curdate() or date_end is null) order by date_display, date_start, header;");
      $sth->bindValue(":group", $group, PDO::PARAM_STR);
      $sth->execute();
      if ($sth->rowCount() > 0) {
        while ($row = $sth->fetch()) {
          print("<p>");
          if ($row['date_display'] != null) print("<em>" . $row['date_display'] . "</em> - ");
          else if ($row['date_start'] != null) print("<em>" . $row['date_start'] . "</em> - ");
          if ($row['header'] != null) print("<strong>" . $row['header'] . "</strong>: ");
          print($row['text']);
          print("</p>");
        }
      } else {
        print("<p>No announcements at the moment.</p>");
      }
      ?>
		</section>
		
		<section id="communication">
			<h2>Meetings and Communication</h2>
			<p>The Silver TF conducts its work using a variety of synchronous and asynchronous tools. Most work is done via email and issues as shown below, supplemented by occasional teleconferences.</p>
			<ul>
				<li><a href="#email">Email lists</a>;</li>
				<li><a href="wiki/">wiki</a>;</li>
				<li><a href="https://github.com/w3c/silver/">Silver GitHub repository</a> and <a href="https://w3c.github.io/silver/">GitHub draft documents</a>;</li>
				<li><a href="track/">Tracker</a>;</li>
				<li>IRC discussion on the <a href="irc://irc.w3.org/silver">#silver</a> IRCchannel, used largely for minute-taking;</li>
				<li><a href="/2002/09/wbs/94845/">Web-Based Surveys (WBS)</a>;</li>
				<li>Teleconferences of the task force<!-- (also see <a href="minutes">meeting minutes</a>);--></li>
				<li>Face to face meetings;</li>
			</ul>
			<p>These tools are used by participants of the Task Force. For ways non-participants can contribute, see how to <a href="../../participation">participate in the Working Group</a> and <a href="../../../WCAG20/comments/">file comments</a>.</p>
			
			<section id="teleconferences">
				<h3>Teleconferences</h3>
			<ul>
				<?php
					include "../../../../2017/01/telecon-info/filtered-telecon-list.phi";
					showTeleconList("ag-silver-tue", "ag-silver-fri", "ag-silver-plan");
				?>
			</ul>
			</section>
			<section id="minutes">
				<h3>Meeting Minutes</h3>
				<p><a href="minutes">Minutes from previous meetings</a> are available.</p>
			</section>
			<section id="email">
				<h3>Mailing Lists</h3>
				<p>The Silver TF uses the public-silver@w3.org mailing list (<a href="http://lists.w3.org/Archives/Public/public-silver/">mailing list archives</a>) for email discussion; members of the public can post to this list to send input to the task force. The TF uses the public-silver-admin@w3.org mailing list <a href="http://lists.w3.org/Archives/Public/public-silver-admin/">mailing list archives</a> for adminstrative discussion that is specific to participants in the task force. Participants are automatically subscribed to these mailing lists when they become a participant of the Task Force.</p>
			</section>
		</section>
		
		<section id="work">
			<h2>Current Work</h2>
			<p><a href="wiki/">See the wiki for current planning and draft documents</a>.</p>
		</section>
		
		<section id="publications">
			<h2>Publications</h2>
			<ul>
				<li><a href="https://w3c.github.io/silver/explainer/">Explainer for W3C Accessibility Guidelines (WCAG) 3.0</a></li>
				<li><a href="https://w3c.github.io/silver/requirements/">Requirements for WCAG 3.0</a></li>
				<li><a href="https://w3c.github.io/silver/guidelines/">W3C Accessibility Guidelines (WCAG) 3.0</a></li>
			</ul>

		</section>
		
		<section id="contribute">
			<h2>How to Comment, Contribute, and Participate</h2>
			<p>To join the Silver TF, individuals must be participants of the Accessibility Guidelines Working Group. Participants are expected to <a href="work-statement#participation">actively contribute</a> to the work of the Task Force. If you are interested in participating in the Silver TF, please send e-mail to: <a href="mailto:jspellman@spellmanconsulting.com,lauriat@google.com?subject=Silver%20Task%20Force%20Enquiry">Jeanne Spellman and Shawn Lauriat</a> and include a little bit about what you’re interested in and how you think that you may be able to contribute to the Task Force. Then follow the <a href="../../participation">participation procedures of the Accessibility Guidelines Working Group</a>, and once you have joined ask <a href="mailto:cooper@w3.org">Michael Cooper</a> to add you to the task force.</p>
			<p><a href="https://www.w3.org/2000/09/dbwg/details?group=94845&amp;public=1">Current participants in the Silver TF</a>.</p>
			<p>In addition to the task force, the <a href="https://www.w3.org/community/silver/">Silver Community Group</a> provides a venue to participate in this work without joining the Accessibility Working Group. This is intended for people who do not represent W3C Member organizations and people who wish to be involved but cannot make the full time commitment expected of Task Force participants.</p>
		</section> 
		
		<section id="administrative">
			<h2>Administrative Information</h2>
			<p>The Silver TF is a Task Force of the <a href="http://www.w3.org/WAI/GL/">Accessible Guidelines Working Group (AG WG)</a>. It assists this Working Group with preliminary development of a new version of Accessibility Guidelines to address current technological and cultural web accessibility requirements and provide a base for continued evolution of the guidelines.</p>
			<section id="facilitator">
				<h3>Facilitator and Contacts</h3>
				<ul>
					<li><strong>Facilitators:</strong> Shawn Lauriat, Jeanne Spellman</li>
					<li><strong>Project Manager: Wilco Fiers</strong></li>
					<li><strong>Staff Contact:</strong> <a href="http://www.w3.org/People/cooper/">Michael Cooper</a></li>
				</ul>
				<p>Contact the task force leadership and working group chairs by email to <a href="mailto:group-ag-plan@w3.org">group-ag-plan@w3.org</a></p>
			</section>
			<section id="work-statement">
				<h3>Work Statement</h3>
				<p>The <a href="work-statement">Silver Task Force Work Statement</a> defines the initial objective, scope, approach, and participation of the Task Force.</p>
			</section>
		</section>
		
		<?php include "../../_footer.phi"; ?>
	</body>
</html>