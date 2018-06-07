<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:wcag="https://www.w3.org/WAI/GL/"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:include href="base.xslt"/>
	
	<xsl:param name="base.dir">understanding/</xsl:param>
	<xsl:param name="understanding.dir">understanding/</xsl:param>
	
	<xsl:output method="text"/>
	
	<xsl:variable name="ids" select="document('ids.xml')"/>
	
	<xsl:template name="versions">
		<xsl:choose>
			<xsl:when test="version = 'WCAG20'">["2.0", "2.1"]</xsl:when>
			<xsl:when test="version = 'WCAG21'">["2.1"]</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="techniques">
		"techniques": [
		<xsl:variable name="subpath">
			<xsl:choose>
				<xsl:when test="version = 'WCAG20'">20/</xsl:when>
				<xsl:when test="version = 'WCAG21'">21/</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:apply-templates select="document(resolve-uri(concat(file/@href, '.html'), concat($base.dir, $subpath)))//html:section[@id = 'sufficient' or @id = 'advisory' or @id = 'failure']">
			<xsl:with-param name="meta" select="." tunnel="yes"/>
		</xsl:apply-templates>
		]
		
		{"sufficient": [
			{"situations": [
				{
					"title": "Situation A: If the content is prerecorded audio-only:",
					"techniques": [
						{
							"id": "TECH:G158",
							"title": "Providing an alternative for time-based media for audio-only content"
						},
						{
							"id": "TECH:SL17",
							"title": "Providing Static Alternative Content for Silverlight Media Playing in a MediaElement"
						}
					]
				},
				{
					"title": "Situation B: If the content is prerecorded video-only:",
					"techniques": [
						{
						"id": "TECH:G159",
						"title": "Providing an alternative for time-based media for video-only content"
						}
					]
				}
			]}
		]},
		{"advisory": [
				{
					"id": "TECH:H96",
					"title": "Using the track element to provide audio descriptions"
				},
				{
					"id": "TECH:future2",
					"title": "Providing a transcript of a live audio only presentation after the fact"
				}
		]},
		{"failure": [
			{
				"id": "TECH:F30",
				"title": "Failure of Success Criterion 1.1.1 and 1.2.1 due to using text alternatives that are not alternatives (e.g., filenames or placeholder text)"
			},
			{
				"id": "TECH:F67",
				"title": "Failure of Success Criterion 1.1.1 and 1.2.1 due to providing long descriptions for non-text content that does not serve the same purpose or does not present the same information"
			}
		]}
	</xsl:template>
	
	<xsl:template name="altid">
		<xsl:for-each select="$ids//id[. = current()/@id]/following-sibling::altid">"<xsl:value-of select="."/>"<xsl:if test="position() != last()">, </xsl:if></xsl:for-each>
	</xsl:template>
	
	<xsl:template match="/">
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
			"handle": "<xsl:value-of select="name"/>",
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
			"handle": "<xsl:value-of select="name"/>",
			"title": "<xsl:value-of select="normalize-space(content/html:p[1])"/>",
			"successcriteria": [
				<xsl:apply-templates select="success-criterion"/>
			],
			"techniques": {<xsl:apply-templates select="descendant::html:section[@id = 'advisory']"/>}
		}<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="success-criterion">
		{
			"id": "WCAG2:<xsl:value-of select="@id"/>",
			"alt_id": [<xsl:call-template name="altid"/>],
			"num": "<xsl:value-of select="num"/>",
			"versions": <xsl:call-template name="versions"/>,
			"level": "<xsl:value-of select="level"/>",
			"handle": "<xsl:value-of select="name"/>",
			"title": "<xsl:value-of select="normalize-space(content/html:p[1])"/>",
		<xsl:if test="content/html:dl">
			"details": [{
				"type": "ulist",
				"items": [
					<xsl:apply-templates select="content/html:dt"/>
				]
			}],
		</xsl:if>
			"techniques": {<xsl:apply-templates select="descendant::html:section[@id = 'sufficient' or @id = 'advisory' or @id = 'failure']"/>}
		}<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="html:dt">
		{
			"handle": "<xsl:value-of select="normalize-space(.)"/>",
			"text": "<xsl:value-of select="normalize-space(following-sibling::html:dd[1])"/>"
		}<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	
	
	
	
	
	<xsl:template match="html:section[@id = 'sufficient' or @id = 'advisory' or @id = 'failure']">
		{"<xsl:value-of select="@id"/>": [
			<xsl:apply-templates select="html:section[@class = 'situation'] | html:ul | html:ol" mode="techniques"/>	
		]}<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="html:section[@class = 'situation']" mode="techniques">
		<situation num="{count(preceding-sibling::html:section[@class = 'situation']) + 1}">
			<title><xsl:value-of select="html:h4"/></title>
			<xsl:apply-templates select="html:ul | html:ol" mode="techniques"/>
		</situation>
	</xsl:template>
	
	<xsl:template match="html:ul | html:ol" mode="techniques">
		<xsl:choose>
			<xsl:when test="count(html:li) &gt; 1">
				<or><xsl:apply-templates select="html:li" mode="techniques"/></or>
			</xsl:when>
			<xsl:otherwise><xsl:apply-templates select="html:li" mode="techniques"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="html:li" mode="techniques">
		<technique>
			<xsl:choose>
				<xsl:when test="count(html:a) &gt; 1">
					<and><xsl:apply-templates select="html:a" mode="techniques"/></and>
					<xsl:if test="html:ol or html:ul">
						<using><xsl:apply-templates select="html:ul | html:ol" mode="techniques"/></using>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="html:a" mode="techniques"/>
					<xsl:if test="html:ol or html:ul">
						<using><xsl:apply-templates select="html:ul | html:ol" mode="techniques"/></using>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</technique>
	</xsl:template>
	
	
</xsl:stylesheet>