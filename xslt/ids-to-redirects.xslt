<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:wcag="https://www.w3.org/WAI/GL/"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="#all"
	version="3.0">
	
	<xsl:template match="/">
		<xsl:text>RewriteEngine On
RewriteBase /TR/UNDERSTANDING-WCAG20/
</xsl:text>
		<xsl:apply-templates select="//idset"/>
	</xsl:template>
	
	<xsl:template match="idset">
		<xsl:text>RewriteRule ^</xsl:text>
		<xsl:value-of select="altid"/>
		<xsl:text>(\..*)? https://www.w3.org/WAI/WCAG20/Understanding/</xsl:text>
		<xsl:value-of select="id"/>
		<xsl:text> [R=permanent,L]
</xsl:text>
	</xsl:template>
	
</xsl:stylesheet>