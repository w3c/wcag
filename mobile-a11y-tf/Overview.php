<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
   <head>
      <?php include "../_head.phi"; ?>
      <title>Mobile Accessibility Task Force</title>
   </head>
<body>
   <?php include "../_header.phi"; ?>


<section id="contents">
   <div id="skipwrapper"> <a id="skip">-</a></div>
   <h1>Mobile Accessibility Task Force (Mobile A11Y TF)<br /> <span class="subhead">of the AG WG</span></h1>
	<p>Some information on this page is also shown on, and may be more current in, the <a href="https://www.w3.org/groups/tf/mobile-a11y-tf">automatically generated Mobile Accessibility Task Force page</a>.</p>
	
      <h2>Page Contents</h2>
      <ul>
         <li><a href="#announcements">Announcements and Meetings</a></li>
         <li><a href="#communication">Meetings and Communication</a></li>
         <li><a href="#work">Current Work</a></li>
         <li><a href="#publications">Publications</a></li>
         <li><a href="#about">About Mobile Accessibility Task Force</a></li>
      </ul>
      <!-- end (page) contents (list)-->
   </section>
   <section id="announcements">
      <h2>Announcements and Meetings</h2>
   	<?php
$group = "mobile-a11y-tf";
require_once "../_db_connect.phi";
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

   <section id="communication">  
         <h2>Meetings and Communication</h2>
         <p>The Mobile Accessibility Task Force conducts its work using a variety of synchronous and asynchronous tools. Most work is done via email and issues as shown below, supplemented by occasional teleconferences.</p>
         <ul>
            <li><a href="#email">Email lists</a>;</li>
            <li><a href="wiki">wiki</a>;</li>
            <li><a href="track/">Tracker</a>;</li>
            <li>IRC discussion (server: <strong>irc.w3.org</strong>, port: <strong>6665,</strong> channel: <strong>#mobile-a11y</strong>) is used by some members during the teleconferences. Please type &quot;present+&quot; <em>your name</em> in the IRC channel when joining a meeting.;</li>
            <li><a href="/2002/09/wbs/66524/">Web-Based Surveys (WBS)</a>;</li>
         </ul>
         <p>These tools are used by participants of the Task Force. For ways non-participants can contribute, see how to <a href="../participation">participate in the Working Group</a> and <a href="../../WCAG20/comments/">file comments</a>.</p>
         
         <section id="teleconferences">
            <h3>Teleconferences</h3>
         	<ul>
               <li><a href="https://www.w3.org/2002/09/wbs/66524/telco/">Mobile Accessibility Task Force Meetings call-in informations</a> are available.</li>
         		<li>Mobile Accessibility Task Force Meetings are every Thursday, <strong>11:00 to 12:00pm</strong> <strong>EST, 16:00-17:00 UTC</strong>. To determine what time this is in your region, please consult the <a href="http://www.timeanddate.com/worldclock/meeting.html">world clock meeting planner</a>. Since <a href="http://webexhibits.org/daylightsaving/b.html">Daylight Saving Time changeovers</a> occur at different times in different countries, please check the times each week. </li>
         	</ul>
         </section>
         <section>
            <h3 id="minutes">Meeting Minutes</h3>
               <p><a href="minutes">Minutes from previous meetings</a> are available.</p>
         </section>

         <section id="email">
            <h3>Mailing Lists</h3>
            <ul>
               <li>The Mobile Accessibility Task Force uses the public-mobile-a11y-tf@w3.org mailing list for email discussion; members of the public can post to this list to send input to the task force. Mobile Accessibility Task Force <a href="http://lists.w3.org/Archives/Public/public-mobile-a11y-tf/">mailing list archives</a> are publicly available for the Mobile A11Y TF main mailing list.</li>
               <li>Participants are automatically added to the mailing list when the become a participant of the Task Force.</li>
            </ul>
         </section>
      </section>
      




   <section id="work">
   <h2 >Current Work</h2>
      <p>The <a href="http://w3c.github.io/Mobile-A11y-TF-Note/">editors' draft of Mobile Accessibility: How WCAG 2.0 and Other W3C/WAI Guidelines Apply to Mobile</a> is on Github. <a href="https://github.com/w3c/Mobile-A11y-TF-Note">Issues and pull requests</a> are welcome.</p>
      <p >The Task Force stores their current work and discussions in their <a href="https://www.w3.org/WAI/GL/mobile-a11y-tf/wiki/Main_Page">wiki</a>. You can also follow email discussion on the <a href="http://lists.w3.org/Archives/Public/public-mobile-a11y-tf/">email list archive</a>. </p>
      
      <ul>
         <li>Creating mobile techniques for WCAG using HTML5, ARIA, CSS and JavaScript
           <ul>
             <li>Editor's Draft: <a href="http://w3c.github.io/Mobile-A11y-TF-Note/">Mobile Accessibility: How WCAG 2.0 and UAAG 2.0 Apply to Mobile Devices</a></li>
             <li><a href="https://www.w3.org/WAI/GL/mobile-a11y-tf/wiki/Draft_WCAG_Techniques" title="Draft WCAG Techniques">Draft WCAG Techniques</a></li>
               <li><a href="https://www.w3.org/WAI/GL/mobile-a11y-tf/wiki/Draft_Understanding_WCAG_2.0" title="Draft Understanding WCAG 2.0">Draft Understanding WCAG 2.0</a></li>
           </ul>
         </li>
         <li> Developing design guidance or mobile web accessibility best practices
           <ul>
             <li><a href="https://www.w3.org/WAI/GL/mobile-a11y-tf/wiki/Discussion:_BBC_Mobile_Guidelines" title="Discussion: BBC Mobile Guidelines">Gap Analysis Discussion: BBC Mobile Guidelines</a></li>
               
             <li><a href="https://www.w3.org/WAI/GL/mobile-a11y-tf/wiki/Discussion:_BBC_Mobile_Guidelines" title="Discussion: BBC Mobile Guidelines">Gap Analysis </a><a href="https://www.w3.org/WAI/GL/mobile-a11y-tf/wiki/Discussion:_Funka_Nu_Mobile_Accessibility_Guidelines" title="Discussion: Funka Nu Mobile Accessibility Guidelines">Discussion: Funka Nu Mobile Accessibility Guidelines</a></li>
               <li><a href="https://www.w3.org/WAI/GL/mobile-a11y-tf/wiki/Discussion:_IBM" title="Discussion: IBM">Gap Analysis Discussion: IBM Accessibility Guidelines</a></li>
               <li><a href="https://www.w3.org/WAI/GL/mobile-a11y-tf/wiki/Responsive_Design">Accessibility Concerns in Responsive Design for Mobile</a></li>
           </ul>
         </li>
         <li> <a href="https://www.w3.org/WAI/GL/mobile-a11y-tf/wiki/Mobile_Resources">Reviewing existing resources</a>, including those outside of W3C </li>
      </ul>
   </section> 
   <section id="publications">
   <h2>Publications</h2>
   <ul>
      <li>Editor's Draft: <a href="http://w3c.github.io/Mobile-A11y-TF-Note/">Mobile Accessibility: How WCAG 2.0 and UAAG 2.0 Apply to Mobile Devices</a></li>
   </ul>
   	
   </section>
   <section id="about">
   <h2>About the Mobile Accessibility Task Force</h2>
   <p>The Mobile Accessibility Task Force (Mobile A11Y TF) is a Task Force of the <a href="http://www.w3.org/WAI/GL/">Accessibility Guidelines Working Group (AG WG)</a>. It assists this Working Group to produce techniques, understanding, and guidance documents, as well as updates to existing related W3C  material that addresses the mobile space.</p>
   <section>
   <h3 id="facilitator">Facilitator and Contacts</h3>
   <ul>
      <li> <strong>Task Force facilitators:</strong> <a href="mailto:Kim@redstartsystems.com">Kim Patch</a>, <a href="mailto:kathy@interactiveaccessibility.com">Kathy Wahlbin</a>.</li>
   	<li><strong>Staff Contact: </strong><a href="https://www.w3.org/People/Roy/">Roy Ran</a>.</li>
   </ul>
   </section>
   <section>
   <h3 id="work-statement">Work Statement</h3>
   <p><strong><a href="work-statement">Mobile Accessibility Task Force Work Statement</a></strong> defines the initial objective, scope, approach, and participation of the Task Force.</p>
   </section>
 
   
   <section>
      <h3 id="participation">Participation</h3>
   <p>To join the Mobile Accessibility Task Force, individuals must be participants of either the <a href="http://www.w3.org/WAI/GL/">Accessibility Guidelines Working Group (AG WG)</a>. Participants are expected to actively contribute to the work of the Task Force, including:</p>
   <ul>
      <li>Minimum 4 hours per week of Mobile A11Y TF work (this time also counts towards the individual's participation requirement in the sponsoring WG through which they have joined);</li>
      <li>Remain current on the Mobile Accessibility Task Force mailing list and respond in a timely manner to postings;</li>
      <li>Participate in Mobile Accessibility Task Force telephone meetings, or send regrets to the Task Force mailing list.</li>
   </ul>
   <p>If you are interested in participating in the Mobile Accessibility Task Force, please send e-mail to: <a href="mailto:Kim@redstartsystems.com">Kim Patch</a>, <a href="mailto:kathy@interactiveaccessibility.com">Kathy Wahlbin</a>, <a href="mailto:ran@w3.org">Roy Ran</a> and <a href="mailto:cooper@w3.org">Michael Cooper</a> include a little bit about what you’re interested in and how you think that you may be able to contribute to the Task Force.</p>
   <p><a href="https://www.w3.org/2000/09/dbwg/details?group=66524&amp;public=1">Participants in the Mobile Accessibility Task Force</a> lists current participants.</p>
   </section>
</section>

<?php include "../_footer.phi"; ?>
   <!-- end main -->


   <!-- end footer -->

</body>
</html>
