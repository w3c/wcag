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
	
	<xsl:output method="text"/>
	
	<!--
	<xsl:param name="versions.file">technique-assocations.xml</xsl:param>
	<xsl:param name="techniques.file">technique-assocations.xml</xsl:param>
	-->
	<xsl:param name="associations.file">technique-assocations.xml</xsl:param>
	
	<!--
	<xsl:variable name="versions.doc" select="document($versions.file)"/>
	<xsl:variable name="techniques.doc" select="document($techniques.file)"/>
	-->
	<xsl:variable name="associations.doc" select="document($associations.file)"/>
	
	<xsl:function name="wcag:quote-string">
		<xsl:param name="str"/>
		<xsl:text>'</xsl:text><xsl:value-of select="$str"/><xsl:text>'</xsl:text>
	</xsl:function>
	
	<xsl:template match="/">
		<xsl:text>insert into success_criteria (sc_id, principle, guideline, criterion, sc_num, level, handle, text, spec_source) values 
</xsl:text>
		<xsl:apply-templates select="//success-criterion" mode="success-criteria"/>
	</xsl:template>
	
	<!-- success-criteria -->
	<xsl:template match="success-criterion" mode="success-criteria">
		<xsl:variable name="num-split" select="tokenize(num, '\.')"/>
		<xsl:text>(</xsl:text>
		<xsl:value-of select="wcag:quote-string(@id)"/><xsl:text>, </xsl:text>
		<xsl:value-of select="subsequence($num-split, 1, 1)"/><xsl:text>, </xsl:text>
		<xsl:value-of select="subsequence($num-split, 2, 1)"/><xsl:text>, </xsl:text>
		<xsl:value-of select="subsequence($num-split, 3, 1)"/><xsl:text>, </xsl:text>
		<xsl:value-of select="wcag:quote-string(num)"/><xsl:text>, </xsl:text>
		<xsl:value-of select="wcag:quote-string(level)"/><xsl:text>, </xsl:text>
		<xsl:value-of select="wcag:quote-string(name)"/><xsl:text>, </xsl:text>
		<xsl:value-of select="wcag:quote-string(replace(serialize(content/node()), '\&#39;', &#39;'))"/><xsl:text>, </xsl:text>
		<xsl:value-of select="wcag:quote-string(concat('WCAG', $versions.doc//id[@id = current()/@id]/parent::version/@name))"/>
		<xsl:text>)</xsl:text>
		<xsl:choose>
			<xsl:when test="position() = last()"><xsl:text>;</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>,</xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:text>

</xsl:text>
	</xsl:template>
	
	<!-- techniques -->
	
	<!-- techniques-applicability -->
	
</xsl:stylesheet>