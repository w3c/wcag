<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="#all" version="2.0">
	
	<xsl:output method="xml" encoding="UTF-8"></xsl:output>
	
	<xsl:template match="html:ul"><ulist><xsl:apply-templates select="node()|@*"/></ulist></xsl:template>
	
	<xsl:template match="html:ol"><olist><xsl:apply-templates select="node()|@*"/></olist></xsl:template>
	
	<xsl:template match="html:li">
		<item>
			<xsl:choose>
				<xsl:when test="normalize-space(node()[1][self::text()]) != ''"><p><xsl:apply-templates select="node()|@*"/></p></xsl:when>
				<xsl:when test="html:a or html:em or html:strong"><p><xsl:apply-templates select="node()|@*"/></p></xsl:when>
				<xsl:otherwise><xsl:apply-templates select="node()|@*"/></xsl:otherwise>
			</xsl:choose>
		</item>
	</xsl:template>
	
	<xsl:template match="html:h1 | html:h2 | html:h3 | html:h4 | html:h5 | html:h6"><head><xsl:apply-templates select="node()|@*"/></head></xsl:template>
	
	<xsl:template match="html:a"><loc><xsl:apply-templates select="node()|@*"/></loc></xsl:template>
	
	<xsl:template match="html:strong"><emph role="strong"><xsl:apply-templates select="node()|@*"/></emph></xsl:template>
	
	<xsl:template match="html:em"><emph><xsl:apply-templates select="node()|@*"/></emph></xsl:template>
	
	<xsl:template match="html:html"><spec><xsl:apply-templates select="node()|@*"/></spec></xsl:template>
	
	<xsl:template match="@longdesc | @rel | @shape | @title | @xml:space"/>
	
	<xsl:template match="html:pre"><code><xsl:apply-templates select="node()|@*"/></code></xsl:template>
	
	<xsl:template match="html:img"><image><img><xsl:apply-templates select="@src | @width | @height"/></img><alt><xsl:value-of select="@alt"/></alt></image></xsl:template>
	
	<xsl:template match="@src"><xsl:attribute name="source"><xsl:value-of select="."/></xsl:attribute></xsl:template>
	
	<xsl:template match="node()|@*"><xsl:copy><xsl:apply-templates select="node()|@*"/></xsl:copy></xsl:template>
	
</xsl:stylesheet>
