<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:wcag="https://www.w3.org/WAI/GL/"
	xmlns:func="http://www.w3.org/2005/xpath-functions"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:import href="base.xslt"/>
	
	<xsl:param name="navigation.current" required="yes"/>
	
	<xsl:output method="xhtml" exclude-result-prefixes="#all" omit-xml-declaration="yes" indent="yes"/>
	
	<xsl:template match="/"><xsl:apply-templates/></xsl:template>
	
	<xsl:template match="html:html">
		<xsl:text disable-output-escaping="yes"><![CDATA[<!DOCTYPE html>
]]></xsl:text>
		<xsl:copy><xsl:apply-templates select="node()|@*"/></xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:body">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:call-template name="header"/>
			<xsl:call-template name="navigation">
				<xsl:with-param name="navigation.current" select="$navigation.current"/>
			</xsl:call-template>
			<xsl:apply-templates/>
			<xsl:call-template name="wai-site-footer"/>
			<xsl:call-template name="site-footer"/>
			<xsl:call-template name="waiscript"/>
		</xsl:copy>
	</xsl:template>
	
	<!--
	<xsl:template match="html:section[@id = 'acknowledgements']/html:section">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<details>
				<summary><h2><xsl:value-of select="wcag:find-heading(.)"/></h2></summary>
				<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
			</details>
		</xsl:copy>
	</xsl:template>
	-->
	
</xsl:stylesheet>