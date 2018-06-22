<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml" 
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:import href="../slices-techniques.xsl"/>
	
	<xsl:output method="html" omit-xml-declaration="yes" doctype-system="" doctype-public=""/>
	
	<xsl:template match="/">
		<xsl:text disable-output-escaping="yes"><![CDATA[<!DOCTYPE html>
]]></xsl:text>
		<html>
			<head>
				<title>User Agent Support Notes for WCAG Techniques</title>
			</head>
			<body>
				<h1>User Agent Support Notes for WCAG Techniques</h1>
				<p>This resource contains documented user agent issues from <a href="http://www.w3.org/TR/WCAG20-TECHS/">WCAG 2.0 Techniques</a>. There is a separate page for each technology. For some technology, user agent issues are primarily documented in overall technology notes that introduce the technology and are repeated in the technology page here.</p>
				<ul class="toc">
					<xsl:apply-templates select="//body/div1[descendant::ua-issues/*]" mode="toc"/>
				</ul>
				<xsl:apply-templates select="//body/div1[descendant::ua-issues/*]"/>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="div1" mode="toc">
		<li class="toc">
			<a href="{@id}"><xsl:apply-templates select="head" mode="text"/></a>
		</li>
	</xsl:template>
	<xsl:template match="div1">
		<xsl:result-document href="{@id}.html" omit-xml-declaration="yes" method="html" doctype-public="" doctype-system="">
			<xsl:text disable-output-escaping="yes"><![CDATA[<!DOCTYPE html>
]]></xsl:text>
			<html>
				<head>
					<title>User Agent Support Notes for for <xsl:apply-templates select="head" mode="text"/></title>
				</head>
				<body>
					<h1>User Agent Support Notes for <xsl:apply-templates select="head" mode="text"/></h1>
					<p>This page documents user agent support notes for <a href="/TR/WCAG20-TECHS/{@id}"><xsl:apply-templates select="head" mode="text"/></a>.</p>
					<ul class="toc">
						<xsl:apply-templates select="technique[descendant::ua-issues/*]" mode="toc"/>
					</ul>
					<xsl:apply-templates select="div2"/>
					<xsl:apply-templates select="technique[ua-issues/*]"/>
				</body>
			</html>
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="div2">
		<section id="{@id}"><xsl:apply-templates/></section>
	</xsl:template>
	
	<xsl:template match="technique" mode="toc">
		<li class="toc">
			<a href="{@id}"><xsl:apply-templates select="short-name" mode="text"/></a>
		</li>
	</xsl:template>
	<xsl:template match="technique">
		<section id="{@id}">
			<h2>
				<a>
					<xsl:attribute name="href">
						<xsl:call-template name="href.target"><xsl:with-param name="target" select="."/></xsl:call-template>
					</xsl:attribute>
					<xsl:value-of select="@id"/>
				</a>
				<xsl:text>: </xsl:text>
				<xsl:apply-templates select="short-name" mode="text"/>
			</h2>
			<xsl:choose>
				<xsl:when test="ua-issues/*">
					<xsl:apply-templates select="ua-issues/*"/>
				</xsl:when>
				<xsl:otherwise>
					<p><em>No user agent support notes have been documented for technique <xsl:value-of select="@id"/>.</em></p>
				</xsl:otherwise>
			</xsl:choose>
		</section>
	</xsl:template>
	
	<!-- Override href.target to force absolute URI -->
	<xsl:template name="href.target">
		<xsl:param name="target" select="."/>
		<xsl:variable name="slice" select="($target/ancestor-or-self::div1[not(@diff = 'del')] | 
			$target/ancestor-or-self::inform-div1[not(@diff = 'del')]  | $target/ancestor-or-self::technique[not(@diff = 'del')] | $target/ancestor-or-self::div2[not(@diff = 'del')][ancestor::body]  | $target/ancestor-or-self::spec)[last()]"/>
		<xsl:value-of select="//latestloc/loc"/> <!-- this is the only inserted line -->
		<xsl:apply-templates select="$slice" mode="slice-techniques-filename"/>
		<xsl:if test="$target != $slice">
			<xsl:text>#</xsl:text>
			<xsl:choose>
				<xsl:when test="$target/@id">
					<xsl:value-of select="$target/@id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="yes">Generating ID for <xsl:value-of select="."/></xsl:message>
					<xsl:value-of select="generate-id($target)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>