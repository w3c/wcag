<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:param name="base.dir">file:///C:/Documents/code/GitHub/w3c/wcag/guidelines/</xsl:param>
	
	<xsl:output method="xhtml" indent="yes" encoding="UTF-8" include-content-type="no" omit-xml-declaration="yes"/>
	
	<xsl:template match="html:html">
		<xsl:text disable-output-escaping="yes"><![CDATA[<!DOCTYPE html>
]]></xsl:text>
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="element()[@data-include]">
		<xsl:choose>
			<xsl:when test="@data-include-replace = 'true'"><xsl:value-of select="unparsed-text(resolve-uri(@data-include, document-uri(ancestor::document-node())))" disable-output-escaping="yes"/></xsl:when>
			<xsl:otherwise>
				<xsl:copy><xsl:apply-templates select="@*[not(name() = 'data-include')]"/><xsl:value-of select="unparsed-text(resolve-uri(@data-include, document-uri(ancestor::document-node())))" disable-output-escaping="yes"/></xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>