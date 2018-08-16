<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:wcag="https://www.w3.org/WAI/GL/"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:import href="base.xslt"/>
	
	<xsl:output method="html" indent="yes"/>
	
	<xsl:template match="techniques">
		<xsl:result-document href="toc.html">
			<ul>
				<xsl:apply-templates select="technology">
					<xsl:sort select="@name"/>
				</xsl:apply-templates>
			</ul>
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="technology">
		<li>
			<xsl:choose>
				<xsl:when test="@name = 'aria'">ARIA Techniques</xsl:when>
				<xsl:when test="@name = 'client-side-script'">Client-Side Script Techniques</xsl:when>
				<xsl:when test="@name = 'css'">CSS Techniques</xsl:when>
				<xsl:when test="@name = 'failures'">Common Failures</xsl:when>
				<xsl:when test="@name = 'flash'">Flash Techniques</xsl:when>
				<xsl:when test="@name = 'general'">General Techniques</xsl:when>
				<xsl:when test="@name = 'html'">HTML Techniques</xsl:when>
				<xsl:when test="@name = 'pdf'">PDF Techniques</xsl:when>
				<xsl:when test="@name = 'server-side-script'">Server-Side Script Techniques</xsl:when>
				<xsl:when test="@name = 'silverlight'">Silverlight Techniques</xsl:when>
				<xsl:when test="@name = 'smil'">SMIL Techniques</xsl:when>
				<xsl:when test="@name = 'text'">Plain-Text Techniques</xsl:when>
			</xsl:choose>
			<ul>
				<xsl:apply-templates select="technique">
					<xsl:sort select="wcag:number-in-id(@id)" data-type="number"/>
				</xsl:apply-templates>
			</ul>
		</li>
	</xsl:template>
	
	<xsl:template match="technique">
		<li>
			<a href="{parent::technology/@name}/{@id}"><xsl:value-of select="@id"/>: <xsl:value-of select="title"/></a>
		</li>
	</xsl:template>
		
</xsl:stylesheet>