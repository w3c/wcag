<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:wcag="https://www.w3.org/WAI/GL/"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:import href="base.xslt"/>
	
	<xsl:output method="xml" indent="yes"/>
	
	<xsl:param name="techniques.dir">techniques/</xsl:param>
	<xsl:param name="understanding.dir">understanding/</xsl:param>
	
	<xsl:template match="guidelines">
		<techniques>
			<xsl:apply-templates select="//guideline | //success-criterion"/>
		</techniques>
	</xsl:template>
	
	<xsl:template match="guideline | success-criterion">
		<xsl:variable name="subpath">
			<xsl:choose>
				<xsl:when test="version = 'WCAG20'">20/</xsl:when>
				<xsl:when test="version = 'WCAG21'">21/</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:apply-templates select="document(resolve-uri(concat(file/@href, '.html'), concat($understanding.dir, $subpath)))">
			<xsl:with-param name="meta" select="." tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="html:html">
		<xsl:apply-templates select="descendant::html:section[@id = 'techniques']//html:a"/>
	</xsl:template>
	
	<xsl:template match="html:a[starts-with(@href, 'https://www.w3.org/WAI/WCAG21/Techniques/')]">
		<xsl:variable name="tech-technology" select="replace(@href, '^.*/([\w-]*)/[\w\d]*$', '$1')"/>
		<xsl:variable name="tech-id" select="replace(@href, '^.*/([\w\d]*)$', '$1')"/>
		<xsl:variable name="tech-path" select="concat('../techniques/', $tech-technology, '/', $tech-id, '.html')"/>
		<xsl:variable name="tech-doc" select="document(resolve-uri($tech-path, $techniques.dir))"/>
		<technique>
			<id><xsl:value-of select="$tech-id"/></id>
			<technology><xsl:value-of select="$tech-technology"/></technology>
			<type><xsl:choose><xsl:when test="$tech-technology = 'failures'">failure</xsl:when><xsl:otherwise>technique</xsl:otherwise></xsl:choose></type>
			<title><xsl:value-of select="normalize-space($tech-doc//html:h1)"/></title>
			<file href="{$tech-technology}/{$tech-id}"/>
		</technique>
	</xsl:template>
	
	<xsl:template match="html:a"/>
	
</xsl:stylesheet>