<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
<?php include "_head.phi"; ?> 		
		<title>AG Communication</title>
	</head>
	<body>
<?php include "_header.phi"; ?>		
		<h1>AG Communication</h1>
		
		<p>The Accessibility Guidelines Working Group uses the following tools and procedures to perform its work.</p>
		
		<section id="telecon">
			<h2>Teleconferences</h2>

			<p>The AG WG and its task forces participate in the following teleconferences. Unless otherwise mentioned, times are given in Boston time because the UTC time floats with U.S. Daylight Savings Time changes. Follow the link to convert to local time. Meetings take place on <a href="https://www.w3.org/2006/tools/wiki/Category:WebEx">WebEx</a>, using the link given or by dial-in to +1-617-324-0000. If using the web interface to WebEx, the meeting password must be obtained in advance from the chair or staff contact. <a href="#irc">IRC</a> is used for text chat and <a href="http://dev.w3.org/cvsweb/~checkout~/2002/scribe/scribedoc.htm?content-type=text/html">minute taking</a>. It is not expected that participants will join all meetings; instead please strive to be a regular participant in the meeting(s) of greatest relevance to your work in the group.</p>
			<ul>
				<?php
					include "../../2017/01/telecon-info/filtered-telecon-list.phi";
					showTeleconList("ag-coga", "ag-extra", "ag-facilitators", "ag-ftf", "ag-lvtf", "ag-mobile", "ag-plan", "ag-silver-fri", "ag-silver-plan", "ag-silver-tue", "ag-tpac", "ag-wg", "ag-wg2", "coga-plan");
				?>
			</ul>
			<p><a href="minutes-history">Minutes of past teleconferences</a> are available.</p>
		</section>
		
		<section id="ftf">
			<h2>Face to Face Meetings</h2>
			<p>The Working Group holds occasional face-to-face meetings. These are usually listed in the <a href="wiki/Meetings">meetings wiki</a>.</p>
		</section>

		<section id="email">
			<h2>Email lists</h2>
			<ul>
				<li><strong><a href="mailto:w3c-wai-gl@w3.org">w3c-wai-gl@w3.org</a></strong> - Working Group discussion list; public archive (<a href="http://lists.w3.org/Archives/Public/w3c-wai-gl/">w3c-wai-gl archives</a>);</li> 
				<li><strong><a href="mailto:public-agwg-comments@w3.org">public-agwg-comments@w3.org</a></strong> - For WG to receive public comments on publications; public archive; anyone may post; only editors subscribe (<a href="https://lists.w3.org/Archives/Public/public-agwg-comments/">public-agwg-comments archives</a>);</li> 
				<li><strong><a href="mailto:group-ag-chairs@w3.org">group-ag-chairs@w3.org</a></strong> - for private input to the AG chairs from the public; anyone may post; only editors subscribe;</li>
				<li><strong><a href="mailto:group-ag-plan@w3.org">group-ag-plan@w3.org</a></strong> – for private input to AG leadership team; anyone may post; only  editors, staff contacts, and project manager subscribe;</li>
				<li><strong><a href="mailto:public-ag-admin@w3.irg">public-ag-admin@w3.org</a></strong> - Working Group consensus tracking list; public archive (<a href="http://lists.w3.org/Archives/Public/public-ag-admin/">public-ag-admin archives</a>).</li> 
			</ul>
			<p>The AG Admin list will be used to approve WCAG 3 issues. Proposed resolutions will be discussed in the relevant subgroup before coming to the group via email on this list. When proposed resolutions are brought to the list, the group will have 7 days to vote. </p>
			<ul>
				<li>If all responses are  +1, 0 or no response is provided then the issue will be resolved;</li>
				<li>If -1 responses can be quickly resolved via email, we will do so;</li>
				<li>If -1 responses require discussion they will be queued up for Tuesday meetings.</li>
			</ul>
		</section>
		
		<section id="repo">
			<h2>Source repository</h2>
			<p>Publications under development are maintained in the <a href="https://github.com/w3c/wcag/">WCAG 2.0 GitHub repository</a> and <a href="https://github.com/w3c/wcag21/">WCAG 2.1 GitHub repository</a>. This distributed source control system allows multiple people to edit simultaneously, public view of changes as they are committed, and "pull requests" to enable people without direct commit access to suggest contributions. Publication editors are designated by the WG chair and have direct commit access. Editors commit to execute the group consensus, request review of non-editorial changes, process conflicting input (from issues, pull requests, and discussions) in a neutral manner, and maintain document quality.</p>
			<!--<p><a href="editors/">Information for editors</a></p>-->
		</section>
		
		<section id="irc">
			<h2>IRC</h2>
			<p>W3C Working Groups use <a href="https://www.w3.org/wiki/IRC">IRC</a> for synchronous text chat and, with the aid of some IRC bots, to record minutes of teleconferences. The ARIA WG uses the following IRC channels. They are available at any time but are only routinely logged during teleconferences.</p>
			<ul>
				<li><a href="irc://irc.w3.org/aria">#ag</a> for the main Working Group.</li>
				<li><a href="irc://irc.w3.org/wcag-act">#wcag-act</a> for the Accessibility Conformance Testing Task Force.</li>
				<li><a href="irc://irc.w3.org/coga">#coga</a> for the Cognitive Accessibility Task Force.</li>
				<li><a href="irc://irc.w3.org/mobile-a11y">#mobile-a11y</a> for the Mobile Accessibility Task Force.</li>
				<li><a href="irc://irc.w3.org/lvtf">#lvtf</a> for the Low Vision Accessibility Task Force.</li>
				<li><a href="irc://irc.w3.org/silver">#silver</a> for the Silver Task Force.</li>
			</ul>
		</section>
		
		<section id="other">
			<h2>Other</h2>
			<p>The ARIA WG uses the following web-based resources as well:</p>
			<ul>
				<li><a href="wiki/">Wiki</a>, to develop or record content not immediately intended for formal publication. This is writeable by WG members and publicly readable.</li>
				<li><a href="http://www.w3.org/2002/09/wbs/35422/">Web-Based Surveys (WBS)</a>, to measure aggregate group opinion. These can be completed by WG members with publicly readable results.</li>
				<li><a href="track/">Issue Tracker</a>, to track issues and action items. This is maintainable by WG members and publicly readable.</li>
				<li><a href="https://github.com/w3c/wcag/issues">WCAG 2.0 GitHub Issues</a> and <a href="https://github.com/w3c/wcag21/issues">WCAG 2.1 GitHub Issues</a>, to track issues for publications maintained in the GitHub repository. Users with a <a href="https://github.com/">GitHub account</a> can file or comment on issues, and issues are publicly readable.</li>
			</ul>
		</section>

<?php include "_footer.phi"; ?> 		
	</body>
</html>