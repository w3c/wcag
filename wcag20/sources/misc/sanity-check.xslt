<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" exclude-result-prefixes="xsl xs fn" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
	
	<xsl:param name="guidelines.file">../wcag2-src.xml</xsl:param>
	<xsl:param name="understanding.file">../guide-to-wcag2-src.xml</xsl:param>
	<xsl:param name="techniques.file">../wcag20-merged-techs.xml</xsl:param>
	
	<xsl:param name="guidelines.doc" select="/"/>
	<xsl:param name="understanding.doc" select="document($understanding.file)"/>
	<xsl:param name="techniques.doc" select="document($techniques.file)"/>
	
	<xsl:variable name="techs.general" select="$techniques.doc/id('general')"/>
	<xsl:variable name="techs.failures" select="$techniques.doc/id('failures')"/>
	<xsl:variable name="techs.html" select="$techniques.doc/id('html')"/>
	<xsl:variable name="techs.css" select="$techniques.doc/id('css')"/>
	<xsl:variable name="techs.script" select="$techniques.doc/id('client-side-script')"/>
	<xsl:variable name="techs.smil" select="$techniques.doc/id('smil')"/>
	<xsl:variable name="techs.server" select="$techniques.doc/id('server-side-script')"/>
	<xsl:variable name="techs.text" select="$techniques.doc/id('text')"/>
	<xsl:variable name="techs.aria" select="$techniques.doc/id('aria')"/>
	<xsl:variable name="techs.flash" select="$techniques.doc/id('flash')"/>
	<xsl:variable name="techs.pdf" select="$techniques.doc/id('pdf')"/>
	<xsl:variable name="techs.silverlight" select="$techniques.doc/id('silverlight')"/>
	
	<xsl:template match="/">
		<html>
			<head>
				<title>WCAG 2.0 Suite Sanity Check</title>
			</head>
			<body>
				<h1>WCAG 2.0 Suite Sanity Check</h1>
				<p>This document shows cross references of various types amongst the WCAG documents where the reference is not mirrored. The main purpose is to catch references that were deleted in one place but not another, but also enforces a principle that reference links should be mutual.</p>
				<h2>WCAG sections in Understanding referencing technique, but technique doesn't refer back</h2>
				<table border="1" cellspacing="0">
					<thead>
						<tr valign="top">
							<th>WCAG ID</th>
							<th>References tech, not referenced</th>
							<th>Referenced by tech, doesn't reference</th>
						</tr>
					</thead>
					<tbody>
						<xsl:apply-templates select="$understanding.doc//div1[@role = 'extsrc'][not(@diff = 'del')] | $understanding.doc//div2[@role = 'extsrc'][not(@diff = 'del')]" mode="tech-non-ref"/>
					</tbody>
				</table>
				<h2>Techniques that reference related techniques, but reference isn't mutual</h2>
				<table cellspacing="0" border="1">
					<thead>
						<tr>
							<th>Technique</th>
							<th>References technique</th>
						</tr>
					</thead>
					<tbody>
						<xsl:apply-templates select="$techniques.doc//technique[not(ancestor-or-self::*/@diff = 'del')]" mode="relatedtechs"/>
					</tbody>
				</table>
				<!-- 
				<h2>List of failure techniques and their SC</h2>
				<table border="1" cellspacing="0">
					<thead>
						<tr>
							<th>ID</th>
							<th>Title</th>
							<th>SC References</th>
						</tr>
					</thead>
					<tbody>
						<xsl:apply-templates select="$techs.failures//technique[not(ancestor-or-self::*/@diff = 'del')]" mode="failures"/>
					</tbody>
				</table>
				-->
				<div>
					<h2>Cross references by ID to nonexistent targets</h2>
					<h3>WCAG</h3>
					<xsl:call-template name="missingloc"><xsl:with-param name="doc" select="$guidelines.doc"/></xsl:call-template>
					<h3>Understanding</h3>
					<xsl:call-template name="missingloc"><xsl:with-param name="doc" select="$understanding.doc"/></xsl:call-template>
					<h3>General</h3>
					<xsl:call-template name="missingloc"><xsl:with-param name="doc" select="$techs.general"/></xsl:call-template>
					<h3>Failures</h3>
					<xsl:call-template name="missingloc"><xsl:with-param name="doc" select="$techs.failures"/></xsl:call-template>
					<h3>HTML</h3>
					<xsl:call-template name="missingloc"><xsl:with-param name="doc" select="$techs.html"/></xsl:call-template>
					<h3>CSS</h3>
					<xsl:call-template name="missingloc"><xsl:with-param name="doc" select="$techs.css"/></xsl:call-template>
					<h3>Script</h3>
					<xsl:call-template name="missingloc"><xsl:with-param name="doc" select="$techs.script"/></xsl:call-template>
					<h3>SMIL</h3>
					<xsl:call-template name="missingloc"><xsl:with-param name="doc" select="$techs.smil"/></xsl:call-template>
					<h3>Server</h3>
					<xsl:call-template name="missingloc"><xsl:with-param name="doc" select="$techs.server"/></xsl:call-template>
					<h3>Text</h3>
					<xsl:call-template name="missingloc"><xsl:with-param name="doc" select="$techs.text"/></xsl:call-template>
					<h3>ARIA</h3>
					<xsl:call-template name="missingloc"><xsl:with-param name="doc" select="$techs.aria"/></xsl:call-template>
					<h3>Flash</h3>
					<xsl:call-template name="missingloc"><xsl:with-param name="doc" select="$techs.flash"/></xsl:call-template>
					<h3>PDF</h3>
					<xsl:call-template name="missingloc"><xsl:with-param name="doc" select="$techs.pdf"/></xsl:call-template>
					<h3>Silverlight</h3>
					<xsl:call-template name="missingloc"><xsl:with-param name="doc" select="$techs.silverlight"/></xsl:call-template>
				</div>
				<h2>Understanding and Technques documents lacking placeholder sections</h2>
				<p>Not implemented yet</p>
				<h2>Understanding docs lacking at least one sufficient technique per SC or per situation</h2>
				<p>Not implemented yet</p>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="body//div1[@role = 'extsrc'] | body//div2[@role = 'extsrc']" mode="tech-non-ref">
		<xsl:variable name="id" select="@id"/>
		<tr valign="top">
			<td><xsl:value-of select="@id"/></td>
			<td>
				<xsl:variable name="missing"><xsl:apply-templates select="*[@role = 'techniques']//loc[not(ancestor-or-self::*/@diff = 'del')]" mode="tech-non-ref"><xsl:with-param name="sc-id" select="$id"></xsl:with-param></xsl:apply-templates></xsl:variable>
				<xsl:choose>
					<xsl:when test="$missing//html:li">
						<ul>
							<xsl:copy-of select="$missing"/>
						</ul>
					</xsl:when>
					<xsl:otherwise>&#160;</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:variable name="missing"><xsl:apply-templates select="$techniques.doc//technique[applies-to/*[@idref = $id]][not(ancestor-or-self::*/@diff = 'del')]" mode="tech-non-ref"><xsl:with-param name="item" select="."/></xsl:apply-templates></xsl:variable>
				<xsl:choose>
					<xsl:when test="$missing//html:li">
						<ul>
							<xsl:copy-of select="$missing"/>
						</ul>
					</xsl:when>
					<xsl:otherwise>&#160;</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="loc" mode="tech-non-ref">
		<xsl:param name="sc-id"/>
		<xsl:variable name="tech-id" select="@href"/>
		<xsl:if test="not($techniques.doc//technique[@id = $tech-id]/applies-to/*[@idref = $sc-id])"><li><xsl:value-of select="$tech-id"/></li></xsl:if>
	</xsl:template>
	
	<xsl:template match="technique" mode="tech-non-ref">
		<xsl:param name="item"/>
		<xsl:variable name="tech-id" select="@id"/>
		<xsl:if test="not($item//*[@role = 'techniques']//loc[@href = $tech-id])"><li><xsl:value-of select="$tech-id"/></li></xsl:if>
	</xsl:template>
	
	<xsl:template match="technique" mode="relatedtechs">
		<xsl:variable name="missing"><xsl:apply-templates select="descendant::relatedtech[not(ancestor-or-self::*/@diff = 'del')]" mode="relatedtechs"><xsl:with-param name="id" select="@id"/></xsl:apply-templates></xsl:variable>
		<xsl:if test="$missing//html:li">
			<tr valign="top">
				<td><xsl:value-of select="@id"/></td>
				<td>
					<xsl:copy-of select="$missing"/>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="relatedtech" mode="relatedtechs">
		<xsl:param name="id" required="yes"/>
		<xsl:variable name="referenced" select="@idref"/>
		<xsl:if test="not($techniques.doc//technique[@id = $referenced][not(ancestor-or-self::*/@diff = 'del')]//relatedtech[@idref = $id])">
			<li><xsl:value-of select="$referenced"/></li>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="technique" mode="failures">
		<tr>
			<td><xsl:value-of select="@id"/></td>
			<td><xsl:value-of select="short-name"/></td>
			<td>
				<ul>
					<xsl:apply-templates select="applies-to/*[not(ancestor-or-self::*/@diff = 'del')]" mode="failures"></xsl:apply-templates>
				</ul>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template mode="failures" match="success-criterion">
		<li><xsl:call-template name="sc-number"><xsl:with-param name="id" select="@idref"></xsl:with-param></xsl:call-template></li>
	</xsl:template>
	
	<xsl:template match="guideline | conformance-criterion" mode="failures">
		<li><xsl:value-of select="@idref"></xsl:value-of></li>
	</xsl:template>
	
	<xsl:template name="missingloc">
		<xsl:param name="doc"/>
		<xsl:variable name="return"><xsl:apply-templates select="$doc//loc[@linktype][not(ancestor-or-self::*/@diff = 'del')]" mode="missingloc"/></xsl:variable>
		<xsl:choose>
			<xsl:when test="$return//html:tr">
				<table border="1" cellspacing="0">
					<thead>
						<tr>
							<th>HREF</th>
							<th>linktype</th>
						</tr>
					</thead>
					<tbody>
						<xsl:copy-of select="$return"/>
					</tbody>
				</table>
			</xsl:when>
			<xsl:otherwise><p>No problems found</p></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="loc" mode="missingloc">
		<xsl:variable name="target">
			<xsl:choose>
				<xsl:when test="starts-with(@href, '#')"><xsl:value-of select="substring-before(@href, '#')"></xsl:value-of></xsl:when>
				<xsl:otherwise><xsl:value-of select="@href"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="@linktype = 'general'"><xsl:if test="not($techs.general//*[@id = $target])"><xsl:call-template name="missinglocinfo"/></xsl:if></xsl:when>
			<xsl:when test="@linktype = 'html'"><xsl:if test="not($techs.html//*[@id = $target])"><xsl:call-template name="missinglocinfo"/></xsl:if></xsl:when>
			<xsl:when test="@linktype = 'guideline'"><xsl:if test="not($guidelines.doc//*[@id = $target])"><xsl:call-template name="missinglocinfo"/></xsl:if></xsl:when>
			<xsl:when test="@linktype = 'glossary'"><xsl:if test="not($guidelines.doc//*[@id = $target])"><xsl:call-template name="missinglocinfo"/></xsl:if></xsl:when>
			<xsl:when test="@linktype = 'understanding'"><xsl:if test="not($understanding.doc//*[@id = $target])"><xsl:call-template name="missinglocinfo"/></xsl:if></xsl:when>
			<xsl:when test="@linktype = 'techniques'"><xsl:if test="not($techniques.doc//*[@id = $target])"><xsl:call-template name="missinglocinfo"/></xsl:if></xsl:when>
			<xsl:when test="@linktype = 'text'"><xsl:if test="not($techs.text//*[@id = $target])"><xsl:call-template name="missinglocinfo"/></xsl:if></xsl:when>
			<xsl:when test="@linktype = 'css'"><xsl:if test="not($techs.css//*[@id = $target])"><xsl:call-template name="missinglocinfo"/></xsl:if></xsl:when>
			<xsl:when test="@linktype = 'script'"><xsl:if test="not($techs.script//*[@id = $target])"><xsl:call-template name="missinglocinfo"/></xsl:if></xsl:when>
			<xsl:when test="@linktype = 'aria'"><xsl:if test="not($techs.aria//*[@id = $target])"><xsl:call-template name="missinglocinfo"/></xsl:if></xsl:when>
			<xsl:when test="@linktype = 'failure'"><xsl:if test="not($techs.failures//*[@id = $target])"><xsl:call-template name="missinglocinfo"/></xsl:if></xsl:when>
			<xsl:when test="@linktype = 'smil'"><xsl:if test="not($techs.smil//*[@id = $target])"><xsl:call-template name="missinglocinfo"/></xsl:if></xsl:when>
			<xsl:when test="@linktype = 'server'"><xsl:if test="not($techs.server//*[@id = $target])"><xsl:call-template name="missinglocinfo"/></xsl:if></xsl:when>
			<xsl:when test="@linktype = 'flash'"><xsl:if test="not($techs.flash//*[@id = $target])"><xsl:call-template name="missinglocinfo"/></xsl:if></xsl:when>
			<xsl:when test="@linktype = 'pdf'"><xsl:if test="not($techs.pdf//*[@id = $target])"><xsl:call-template name="missinglocinfo"/></xsl:if></xsl:when>
			<xsl:when test="@linktype = 'silverlight'"><xsl:if test="not($techs.silverlight//*[@id = $target])"><xsl:call-template name="missinglocinfo"/></xsl:if></xsl:when>
			<xsl:when test="@linktype = 'examples'"/>
			<xsl:otherwise><xsl:message>linktype not recognized: <xsl:value-of select="@linktype"/></xsl:message></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="missinglocinfo">
		<tr>
			<td><xsl:value-of select="@href"/></td>
			<td><xsl:value-of select="@linktype"/></td>
		</tr>
	</xsl:template>

	<xsl:template name="sc-number">
		<xsl:param name="id" select="../@id"/>
		<xsl:param name="criterion" select="$guidelines.doc//*[@id = $id]"/>
		<xsl:choose>
			<xsl:when test="$criterion/ancestor::div4[@role='bp']">
				<xsl:variable name="sc" select="count($criterion/ancestor::div3/div4[@role='req']/div5) + 1"/>
				<xsl:value-of select="concat(count($criterion/ancestor::div2/preceding-sibling::div2) + 1, '.', count($criterion/ancestor::div3/preceding-sibling::div3) + 1, '.', count($criterion/ancestor-or-self::div5/preceding-sibling::div5) + $sc)"/>
			</xsl:when>
			<xsl:when test="$criterion/ancestor::div4[@role='additional']">
				<xsl:variable name="sc" select="count($criterion/ancestor::div3/div4[@role='req']/div5) + count($criterion/ancestor::div3/div4[@role='bp']/div5) + 1"/>
				<xsl:value-of select="concat(count($criterion/ancestor::div2/preceding-sibling::div2) + 1, '.', count($criterion/ancestor::div3/preceding-sibling::div3) + 1, '.', count($criterion/ancestor-or-self::div5/preceding-sibling::div5) + $sc)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(count($criterion/ancestor::div2/preceding-sibling::div2) + 1, '.', count($criterion/ancestor::div3/preceding-sibling::div3) + 1, '.', count($criterion/ancestor-or-self::div5/preceding-sibling::div5) + 1)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[@use-id]" priority="1" mode="#all">
		<xsl:apply-templates select="id(@use-id)" mode="#current"/>
	</xsl:template>
</xsl:stylesheet>
