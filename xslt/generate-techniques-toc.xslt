<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:wcag="https://www.w3.org/WAI/GL/"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:import href="base.xslt"/>
	
	<xsl:output method="xhtml" indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>
	
	<xsl:template match="techniques">
		<xsl:result-document href="toc.html" method="xhtml">
			<nav id="toc">
				<h2 class="introductory" id="techniques-pages">
					Techniques
					<!-- <span class="permalink"><a href="#toc" aria-label="Permalink for Techniques" title="Permalink for Techniques"><span>§</span></a></span> -->
				</h2>
				<xsl:apply-templates select="technology">
					<xsl:sort select="@name"/>
				</xsl:apply-templates>
			</nav>
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="technology">
		<xsl:variable name="technology-id" select="wcag:generate-id(@name)"/>
		<xsl:variable name="technology-title">
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
		</xsl:variable>
		<h3 id="{$technology-id}">
			<xsl:value-of select="$technology-title"/>
			<span class="permalink"><a href="#{$technology-id}" aria-label="Permalink for {$technology-title}" title="Permalink for {$technology-title}"><span>§</span></a></span>
		</h3>
		<ul>
			<xsl:apply-templates select="technique">
				<xsl:sort select="wcag:number-in-id(@id)" data-type="number"/>
			</xsl:apply-templates>
		</ul>
	</xsl:template>
	
	<xsl:template match="technique">
		<li>
			<a href="{parent::technology/@name}/{@id}"><xsl:value-of select="@id"/>: <xsl:value-of select="title"/></a>
		</li>
	</xsl:template>
		
</xsl:stylesheet>