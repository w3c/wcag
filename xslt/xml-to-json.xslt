<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:wcag="https://www.w3.org/WAI/GL/"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:include href="base.xslt"/>
	
	<xsl:output method="text"/>
	
	<xsl:variable name="ids" select="document('ids.xml')"/>
	<xsl:variable name="associations" select="document('../techniques/technique-associations.xml')"/>
	<xsl:variable name="techniques" select="document('../techniques/techniques.xml')"/>
	
	<xsl:function name="wcag:json-string" as="xs:string">
		<xsl:param name="val"/>
		<xsl:variable name="string">
			<xsl:choose>
				<xsl:when test="string($val) = $val">
					<xsl:copy-of select="$val"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="$val"/>					
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="replace(normalize-space($string), '&quot;', '\\&quot;')"/>
	</xsl:function>
	
	<xsl:template name="versions">
		<xsl:choose>
			<xsl:when test="version = 'WCAG20'">["2.0", "2.1", "2.2"]</xsl:when>
			<xsl:when test="version = 'WCAG21'">["2.1", "2.2"]</xsl:when>
			<xsl:when test="version = 'WCAG22'">["2.2"]</xsl:when>
			<xsl:otherwise>[]</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="altid">
		<xsl:for-each select="$ids//id[. = current()/@id]/following-sibling::altid">"<xsl:value-of select="."/>"<xsl:if test="position() != last()">, </xsl:if></xsl:for-each>
	</xsl:template>
	
	<xsl:template match="/">
		<xsl:message>Process sufficientNotes whatever they are</xsl:message>
		{
			"principles": [
			<xsl:apply-templates select="//principle"/>
			]
		}
	</xsl:template>
	
	<xsl:template match="principle">
		{
			"id": "WCAG2:<xsl:value-of select="@id"/>",
			"num": "<xsl:value-of select="num"/>",
			"versions": <xsl:call-template name="versions"/>,
			"handle": "<xsl:value-of select="normalize-space(name)"/>",
			"title": "<xsl:value-of select="normalize-space(content/html:p[1])"/>",
			"guidelines": [
				<xsl:apply-templates select="guideline"/>
			]
		}<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="guideline">
		{
			"id": "WCAG2:<xsl:value-of select="@id"/>",
			"alt_id": [<xsl:call-template name="altid"/>],
			"num": "<xsl:value-of select="num"/>",
			"versions": <xsl:call-template name="versions"/>,
			"handle": "<xsl:value-of select="normalize-space(name)"/>",
			"title": "<xsl:value-of select="normalize-space(content/html:p[1])"/>",
			"successcriteria": [
				<xsl:apply-templates select="success-criterion"/>
			],
			"techniques": [<xsl:apply-templates select="$associations//guideline[@id = current()/@id]" mode="techniques"/>]
		}<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="success-criterion">
		{
			"id": "WCAG2:<xsl:value-of select="@id"/>",
			"alt_id": [<xsl:call-template name="altid"/>],
			"num": "<xsl:value-of select="num"/>",
			"versions": <xsl:call-template name="versions"/>,
			"level": "<xsl:value-of select="level"/>",
			"handle": "<xsl:value-of select="normalize-space(name)"/>",
			"title": "<xsl:value-of select="wcag:json-string(content/html:p[1])"/>",
		<xsl:if test="content/html:dl">
			"details": [{
				"type": "ulist",
				"items": [
					<xsl:apply-templates select="content/html:dl/html:dt"/>
				]
			}],
		</xsl:if>
		<xsl:if test="content/html:*[@class = 'note']">
			<xsl:message>Still gotta process SC notes</xsl:message>
		</xsl:if>
		<xsl:if test="content/html:*[not(@class = 'note')]">
			<xsl:message>Still gotta process more "details" thingys</xsl:message>
		</xsl:if>
			"techniques": [<xsl:apply-templates select="$associations//success-criterion[@id = current()/@id]" mode="techniques"/>]
		}<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="guideline | success-criterion" mode="techniques">
		<xsl:apply-templates select="sufficient | advisory | failure"/>
	</xsl:template>
	
	<xsl:template match="html:dt">
		{
			"handle": "<xsl:value-of select="wcag:json-string(.)"/>",
			"text": "<xsl:value-of select="wcag:json-string(following-sibling::html:dd[1])"/>"
		}<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="sufficient | advisory | failure">
		{"<xsl:value-of select="name()"/>": [
		<xsl:if test="situation">
			{"situations": [
			<xsl:apply-templates select="situation"/>
			]}
		</xsl:if>
		<xsl:if test="technique or ./and">
			<xsl:apply-templates select="technique | ./and"/>
		</xsl:if>
		]}<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="situation">
		{"title": "<xsl:value-of select="wcag:json-string(title)"/>",
		"techniques": [
			<xsl:apply-templates select="technique | ./and"/>
		]}<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="technique">
		{
		"id":
		<xsl:choose>
			<xsl:when test="@id">"TECH:<xsl:value-of select="@id"/>"</xsl:when>
			<xsl:otherwise>"TECH:future-<xsl:value-of select="ancestor::element()[name() = 'success-criterion' or name() = 'guideline'][1]/@id"/>-<xsl:value-of select="count(preceding::technique[ancestor::element()/@id = current()/@id]) + 1"/>"</xsl:otherwise>
		</xsl:choose>
		,
		"title": 
		<xsl:choose>
			<xsl:when test="@id">"<xsl:value-of select="wcag:json-string($techniques//technique[@id = current()/@id]/title)"/>"</xsl:when>
			<xsl:otherwise>"<xsl:value-of select="wcag:json-string(title)"/>"</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="using">
			,<xsl:apply-templates select="using"/>
		</xsl:if>
		}
		<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="and">
		{"and": [
		<xsl:apply-templates select="technique"/>
		]}
		<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="using">
		"using": [
		<xsl:apply-templates select="technique | ./and"/>
		]
	</xsl:template>
	
</xsl:stylesheet>