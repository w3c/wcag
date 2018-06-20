<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	exclude-result-prefixes="xs xlink"
	version="2.0">
	
	<xsl:output method="xml" indent="yes" cdata-section-elements="codeblock code" doctype-system="../xmlspec.dtd"/>
	<xsl:preserve-space elements="*"/>
	
	<xsl:template match="node()|@*"><xsl:copy><xsl:apply-templates select="node()|@*"/></xsl:copy></xsl:template>
	
	<xsl:template match="technique">
		<xi:include href="{ancestor::div1/@id}/{@id}.xml"/>
		<xsl:result-document href="{ancestor::div1/@id}/{@id}.xml" doctype-system="../../xmlspec.dtd" exclude-result-prefixes="xs xlink" indent="yes" cdata-section-elements="codeblock code">
			<xsl:copy><xsl:apply-templates select="node()|@*"/></xsl:copy>
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="@*[namespace-uri() = 'http://www.w3.org/1999/xlink' or local-name() = 'xlink']"/>
</xsl:stylesheet>