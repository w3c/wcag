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
	<xsl:param name="versions.file">../guidelines/versions.xml</xsl:param>
	<xsl:param name="techniques.file">techniques.xml</xsl:param>
	-->
	<xsl:param name="associations.file">../techniques/technique-associations.xml</xsl:param>
	
	<!--
	<xsl:variable name="versions.doc" select="document($versions.file)"/>
	<xsl:variable name="techniques.doc" select="document($techniques.file)"/>
	-->
	<xsl:variable name="associations.doc" select="document($associations.file)"/>
	
	<xsl:function name="wcag:quote-string">
		<xsl:param name="str"/>
		<xsl:text>'</xsl:text><xsl:value-of select="$str"/><xsl:text>'</xsl:text>
	</xsl:function>
	
	<xsl:function name="wcag:escape-apos">
		<xsl:param name="str"/>
		<xsl:variable name="apos">&#39;</xsl:variable>
		<xsl:variable name="eapos">&#39;&#39;</xsl:variable>
		<xsl:value-of select="replace($str, $apos, $eapos)"/>
	</xsl:function>
	
	<xsl:template match="/">
		<xsl:text>insert into success_criteria (sc_id, principle, guideline, criterion, sc_num, level, handle, text, spec_source) values 
</xsl:text>
		<xsl:apply-templates select="//success-criterion" mode="success-criteria"/>
		
		<xsl:text>insert into techniques (technique_id, title, technology_id, test_procedure, expected_result) values 
</xsl:text>
		<xsl:apply-templates select="$techniques.doc//technique" mode="techniques"/>
		
		<xsl:text>insert into techniques_applicability (technique_id, sc_id, nature) values 
</xsl:text>
		<xsl:apply-templates select="$associations.doc//technique" mode="associations"/>
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
		<xsl:value-of select="wcag:quote-string(wcag:escape-apos(serialize(content/node())))"/><xsl:text>, </xsl:text>
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
	<xsl:template match="technique" mode="techniques">
		<xsl:variable name="technique-doc" select="document(concat('../techniques/', parent::technology/@name, '/', @id, '.html'))"/>
		<xsl:text>(</xsl:text>
		<xsl:value-of select="wcag:quote-string(@id)"/><xsl:text>, </xsl:text>
		<xsl:value-of select="wcag:quote-string(wcag:escape-apos(title))"/><xsl:text>, </xsl:text>
		<xsl:choose>
			<xsl:when test="parent::technology/@name = 'aria'">8</xsl:when>
			<xsl:when test="parent::technology/@name = 'client-side-script'">4</xsl:when>
			<xsl:when test="parent::technology/@name = 'css'">3</xsl:when>
			<xsl:when test="parent::technology/@name = 'failures'">null</xsl:when>
			<xsl:when test="parent::technology/@name = 'general'">1</xsl:when>
			<xsl:when test="parent::technology/@name = 'html'">2</xsl:when>
			<xsl:when test="parent::technology/@name = 'pdf'">10</xsl:when>
			<xsl:when test="parent::technology/@name = 'server-side-script'">5</xsl:when>
			<xsl:when test="parent::technology/@name = 'smil'">6</xsl:when>
			<xsl:when test="parent::technology/@name = 'text'">7</xsl:when>
		</xsl:choose><xsl:text>, </xsl:text>
		<xsl:value-of select="wcag:quote-string(wcag:escape-apos(serialize($technique-doc//html:section[@class='procedure']/html:ol)))"/><xsl:text>, </xsl:text>
		<xsl:value-of select="wcag:quote-string(wcag:escape-apos(serialize($technique-doc//html:section[@class='results']/html:ul)))"/>
		<xsl:text>)</xsl:text>
		<xsl:choose>
			<xsl:when test="position() = last()"><xsl:text>;</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>,</xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:text>
</xsl:text>
	</xsl:template>
	
	<!-- techniques-applicability -->
	<xsl:template match="technique" mode="associations">
		<xsl:text>(</xsl:text>
		<xsl:value-of select="wcag:quote-string(@id)"/><xsl:text>, </xsl:text>
		<xsl:value-of select="wcag:quote-string(ancestor::success-criterion/@id)"/><xsl:text>, </xsl:text>
		<xsl:value-of select="wcag:quote-string(name(ancestor::sufficient | ancestor::advisory | ancestor::failure))"/>
		<xsl:text>)</xsl:text>
		<xsl:choose>
			<xsl:when test="position() = last()"><xsl:text>;</xsl:text></xsl:when>
			<xsl:otherwise><xsl:text>,</xsl:text></xsl:otherwise>
		</xsl:choose>
		<xsl:text>
</xsl:text>
	</xsl:template>
</xsl:stylesheet>