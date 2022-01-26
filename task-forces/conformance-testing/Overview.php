<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<?php include "../../_head.phi"; ?>
		<title>WCAG Accessibility Conformance Testing (ACT) Task Force</title>
	</head>
	<body>
		<?php include "../../_header.phi"; ?>
		<h1>Accessibility Conformance Testing (ACT) Task Force<br />
			<span class="subhead">of the <a href="https://www.w3.org/WAI/GL/">AG WG</a></span></h1>
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
      $group = "ACTTF";
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
			<section id="weekly">
				<h3>Weekly Teleconferences</h3>
				<p>ACT TF meets weekly on <strong><a href="https://www.timeanddate.com/worldclock/fixedtime.html?msg=ACT+TF+Weekly+Teleconference&iso=20180405T13&p1=%3A&ah=1">Thursdays from 13:00 to 14:00 <abbr title="Coordinated Universal Time">UTC</abbr></a></strong>:</p>
				<ul>
					<li>Meeting materials <ul>
							<li><a href="https://www.w3.org/WAI/GL/task-forces/conformance-testing/wiki/Meeting_Minutes">Meeting minutes</a></li>
							<li><a href="https://www.w3.org/2002/09/wbs/93339/availability/">Availability for ACT TF Teleconferences</a></li>
							<li><a href="https://www.w3.org/WAI/GL/task-forces/conformance-testing/wiki/Scribe_Rotation_List">Scribe rotation list</a></li>
						</ul>
					</li>
					<li>Calling options <ul>
							<li><a href="https://www.w3.org/2017/08/telecon-info_act">Teleconference details</a> (use your W3C login)</li>
						</ul>
					</li>
					<li>IRC options <ul>
							<li><a href="http://irc.w3.org/?channels=#wcag-act">Join IRC channel</a> (online using your browser)</li>
							<li>Server: irc.w3.org; Port 6665, 6667, 21, or 994; Channel: #wcag-act</li>
						</ul>
					</li>
				</ul>
			</section>
			<section id="minutes">
				<h3>Meeting Minutes</h3>
				<p><a href="minutes">Minutes from previous meetings</a> are available.</p>
			</section>
			<section id="email">
				<h3>Mailing Lists</h3>
				<p>The ACT TF uses the public-wcag-act@w3.org mailing list (<a href="http://lists.w3.org/Archives/Public/public-wcag-act/">mailing list archives</a>) for email discussion. Participants are automatically added to the mailing list when they become a participant of the Task Force.</p>
			</section>
			<section id="tools">
				<h3>Tools and Information</h3>
				<ul>
					<li><a href="work-statement">ACT TF Work Statement</a>
					<li><a href="https://www.w3.org/WAI/GL/task-forces/conformance-testing/wiki/">Wiki main page</a>
						<ul>
                            <li><a href="https://www.w3.org/WAI/GL/task-forces/conformance-testing/wiki/ACT_Overview_-_What_is_ACT">ACT Overview</a></li>
							<li><a href="https://www.w3.org/WAI/GL/task-forces/conformance-testing/wiki/Meeting_Minutes">Meeting minutes</a></li>
							<li><a href="https://www.w3.org/2002/09/wbs/93339/availability/">Availability for ACT TF Teleconferences</a></li>
						</ul>
					</li>
					<li><a href="http://lists.w3.org/Archives/Public/public-wcag-act/">Mailing list archive</a></li>
					<li><a href="https://www.w3.org/WAI/GL/task-forces/conformance-testing/wiki/Teleconference_Logistics">Teleconference logistics</a>
						<ul>
							<li><a href="https://www.w3.org/WAI/GL/task-forces/conformance-testing/wiki/Zoom_and_IRC_Setup">Zoom and IRC setup</a></li>
							<li><a href="https://www.w3.org/WAI/GL/task-forces/conformance-testing/wiki/Scribing_Instructions">Scribing instructions</a></li>
							<li><a href="https://www.w3.org/WAI/GL/task-forces/conformance-testing/wiki/Scribe_Rotation_List">Scribe rotation list</a></li>
						</ul>
					</li>
					<li><a href="https://www.w3.org/WAI/GL/task-forces/conformance-testing/wiki/Face-to-Face_Meetings">Face-to-face meetings</a></li>
					<li>GitHub repositories
                        <ul>
                            <li><a href="https://github.com/w3c/wcag-act/">ACT Spec (main)</a></li>
                            <li><a href="https://github.com/w3c/wcag-act-rules/">ACT Rules</a></li>
                        </ul>
                    </li>
					<li><a href="https://www.w3.org/2002/09/wbs/93339/">Web-based surveys (WBS)</a></li>
				</ul>
			</section>
		</section>
		<section id="work">
			<h2>Current Work</h2>
			<p>See the <a href="https://www.w3.org/WAI/GL/task-forces/conformance-testing/wiki/">wiki for current planning and draft documents</a>.</p>
		</section>
		<section id="publications">
			<h2>Publications</h2>
            <dl>
              <dt><strong>Accessibility Conformance Testing (ACT) Rules Format 1.0</strong></dt>
              <dd><ul>
                <li>W3C Standard: <a href="https://www.w3.org/TR/act-rules-format/">https://www.w3.org/TR/act-rules-format/</a></li>
                <li>Errata: <a href="https://www.w3.org/WAI/GL/task-forces/conformance-testing/errata">https://www.w3.org/WAI/GL/task-forces/conformance-testing/errata</a></li>
                <li>Editor draft: <a href="https://w3c.github.io/wcag-act/act-rules-format.html">https://w3c.github.io/wcag-act/act-rules-format.html</a></li>
              </ul></dd>
              <dt><strong>Accessibility Conformance Testing (ACT) Rules Repository</strong></dt>
              <dd><ul>
                <li>Published rules: <a href="https://www.w3.org/WAI/standards-guidelines/act/#act-rules-repository">https://www.w3.org/WAI/standards-guidelines/act/#act-rules-repository</a></li>
                <li>GitHub repository: <a href="https://github.com/w3c/wcag-act-rules/">https://github.com/w3c/wcag-act-rules/</a></li>
              </ul></dd>
            </dl>
		</section>
		<section id="contribute">
			<h2>How to Comment, Contribute, and Participate</h2>
			<p>To join the ACT TF, individuals must be participants of the AG WG. Participants are expected to <a href="work-statement#participation">actively contribute</a> to the work of the Task Force. If you are interested in participating in the ACT TF, please send e-mail to: <a href="mailto:shadi@w3.org?subject=ACT%20TF%20Enquiry">Shadi Abou-Zahra</a> and include a little bit about what you're interested in and how you think that you may be able to contribute to the Task Force. Then follow the <a href="../../participation">AG Working Group participation</a> procedures to join the Working Group, and once you have joined ask <a href="mailto:shadi@w3.org">Shadi Abou-Zahra</a> to add you to the task force.</p>
			<p>To contribute without joining the task force, see the <a href="../../contribute">AG Working Group contribute page</a> for general instructions. To contribute to documents under development, see <a href="https://github.com/w3c/wcag-act/">GitHub repository</a> directly.</p>
			<p><a href="https://www.w3.org/2000/09/dbwg/details?group=93339&amp;public=1">Current participants in the ACT TF</a>.</p>
		</section>
		<section id="administrative">
			<h2>Administrative Information</h2>
			<p>The WCAG Accessibility Conformance Testing (ACT) Task Force (ACT) is a Task Force of the <a href="http://www.w3.org/WAI/GL/">Accessibility Guidelines (AG) Working Group</a>. It assists the AG WG to produce specific deliverables as specified in the <a href="work-statement">work statement</a>.</p>
			<h3 id="facilitator">Facilitator and Contacts</h3>
			<ul>
				<li><strong>Task Force co-facilitators:</strong>
                	<ul>
                		<li>Wilco Fiers, Deque Systems</li>
                        <li>Mary Jo Mueller, IBM Corporation</li>
                    </ul>
                </li>
				<li><strong>Staff Contact: </strong><a href="http://www.w3.org/People/shadi/">Shadi Abou-Zahra</a></li>
			</ul>
			<h3 id="work-statement">Work Statement</h3>
			<p>The <a href="work-statement">Accessibility Conformance Testing (ACT) Task Force Work Statement</a> defines the initial objective, scope, approach, and participation of the Task Force.</p>
		</section>
		
		<?php include "../../_footer.phi"; ?>
	</body>
</html>