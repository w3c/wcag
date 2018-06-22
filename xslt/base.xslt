<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:wcag="https://www.w3.org/WAI/GL/"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:function name="wcag:isheading" as="xs:boolean">
		<xsl:param name="el"/>
		<xsl:choose>
			<xsl:when test="name($el) = 'h1' or name($el) = 'h2' or name($el) = 'h3' or name($el) = 'h4' or name($el) = 'h5' or name($el) = 'h6'">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="wcag:generate-id">
		<xsl:param name="title"/>
		<xsl:value-of select="lower-case(replace(replace($title, ' ', '-'), '[,()]', ''))"/>
	</xsl:function>
	
	<xsl:function name="wcag:find-heading">
		<xsl:param name="el"/>
		<xsl:copy-of select="$el/html:h1[1] | $el/html:h2[1]| $el/html:h3[1] | $el/html:h4[1] | $el/html:h5[1] | $el/html:h6[1]"/>
	</xsl:function>
	
	
</xsl:stylesheet>