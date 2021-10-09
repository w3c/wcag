<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:wcag="https://www.w3.org/WAI/GL/"
	xmlns:func="http://www.w3.org/2005/xpath-functions"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:include href="base.xslt"/>
	
	<xsl:param name="documentset.name" required="yes"/>
	
	<xsl:template match="/"><xsl:apply-templates/></xsl:template>
	
	<xsl:template match="html:body">
		<xsl:call-template name="header">
			<xsl:with-param name="documentset.name" select="$documentset.name"/>
		</xsl:call-template>
		<xsl:apply-templates/>
		<xsl:call-template name="wai-site-footer"/>
		<xsl:call-template name="site-footer"/>
	</xsl:template>
	
</xsl:stylesheet>