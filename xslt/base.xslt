<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:wcag="https://www.w3.org/WAI/GL/"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="#all"
	version="3.0">
	
	<xsl:param name="guidelines.version"/>
	
	<xsl:param name="loc.guidelines">/guidelines/</xsl:param>
	<xsl:param name="loc.understanding">/understanding/</xsl:param>
	<xsl:param name="loc.techniques">/techniques/</xsl:param>
	
	<xsl:param name="techniques.file">../techniques/techniques.xml</xsl:param>
	<xsl:variable name="techniques.doc" select="document($techniques.file)"/>
	
	<xsl:param name="versions.file">../guidelines/versions.xml</xsl:param>
	<xsl:variable name="versions.doc" select="document($versions.file)"/>
	
	<xsl:param name="act.file">../guidelines/act-mapping.json</xsl:param>
	<xsl:variable name="act.doc" select="json-to-xml(unparsed-text($act.file))"/>
	
	<xsl:function name="wcag:isheading" as="xs:boolean">
		<xsl:param name="el"/>
		<xsl:choose>
			<xsl:when test="name($el) = 'h1' or name($el) = 'h2' or name($el) = 'h3' or name($el) = 'h4' or name($el) = 'h5' or name($el) = 'h6'">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="wcag:generate-id">
		<xsl:param name="title"/>
		<xsl:value-of select="lower-case(replace(replace($title, ' ', '-'), '[,():]', ''))"/>
	</xsl:function>
	
	<xsl:function name="wcag:find-heading">
		<xsl:param name="el"/>
		<xsl:copy-of select="$el/html:h1[1] | $el/html:h2[1]| $el/html:h3[1] | $el/html:h4[1] | $el/html:h5[1] | $el/html:h6[1]"/>
	</xsl:function>
	
	<xsl:function name="wcag:number-in-id">
		<xsl:param name="value"/>
		<xsl:analyze-string select="$value" regex="\d+">
			<xsl:matching-substring>
				<xsl:value-of select="."/>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:function>
	
	<xsl:function name="wcag:is-technique-link" as="xs:boolean">
		<xsl:param name="link"/>
		<xsl:choose>
			<!--
			<xsl:when test="$link/@class and index-of(('aria', 'client-side-script', 'css', 'failure', 'failures', 'flash', 'general', 'html', 'pdf', 'server-side-script', 'silverlight', 'smil', 'text', 'technqiues'), $link/@class)"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="starts-with($link/@href, 'https://www.w3.org/WAI/WCAG21/Techniques/')"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="starts-with($link/@href, 'https://w3c.github.io/techniques/')"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="starts-with($link/@href, 'https://rawgit.com/w3c/wcag/') and contains($link/@href, '/techniques/')"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="starts-with($link/@href, '../') and contains($link/@href, '/techniques/')"><xsl:value-of select="true()"/></xsl:when>
			-->
			<xsl:when test="(starts-with($link/@href, 'https://www.w3.org/WAI/WCAG21/Techniques/') or starts-with($link/@href, 'https://w3c.github.io/techniques/') or starts-with($link/@href, 'https://rawgit.com/w3c/wcag/') or starts-with($link/@href, '../')) and matches($link/@href, '[A-Z]+\d+(.html)?$')"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="matches($link/@href, '^([a-z\-]+/)?[A-Z]+\d+(.html)?$')"><xsl:value-of select="true()"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="wcag:section-meaningfully-exists" as="xs:boolean">
		<xsl:param name="id"/>
		<xsl:param name="section"/>
		<xsl:choose>
			<xsl:when test="$id = 'applicability'"><xsl:value-of select="$section and ($section/html:p[not(@class = 'instructions')] or $section/html:ol or $section/html:ul)"/></xsl:when>
			<xsl:when test="$id = 'description'"><xsl:value-of select="$section and $section/html:p[not(@class = 'instructions')]"/></xsl:when>
			<xsl:when test="$id = 'examples'"><xsl:value-of select="$section and ($section/html:p[not(@class = 'instructions')] or $section/html:ol or $section/html:ul or $section/html:section[@class = 'example'])"/></xsl:when>
			<xsl:when test="$id = 'resources'"><xsl:value-of select="$section and ($section/html:p[not(@class = 'instructions')] or $section//html:li[not(. = 'Resource')] or $section//html:a[@href])"/></xsl:when>
			<xsl:when test="$id = 'related'"><xsl:value-of select="$section and $section//html:li//html:a[@href]"/></xsl:when>
			<xsl:when test="$id = 'tests'"><xsl:value-of select="$section and $section//html:section[@class = 'test-procedure' or @class = 'procedure']//html:li and $section//html:section[@class = 'test-results' or @class = 'results']"/></xsl:when>
			<xsl:when test="$id = 'sufficient' or $id = 'advisory' or $id = 'gladvisory' or $id = 'failure'"><xsl:value-of select="$section and ($section/html:*[not(@class = 'instructions')]//html:li)"/></xsl:when>
		</xsl:choose>
	</xsl:function>
	
	<xsl:template match="node()|@*" priority="-1">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:a[wcag:is-technique-link(.)]">
		<xsl:variable name="technique-id" select="replace(@href, '^.*/([\w\d]*)(\.html)?$', '$1')"/>
		<xsl:choose>
			<xsl:when test="$technique-id">
				<xsl:variable name="technique" select="$techniques.doc//technique[@id = $technique-id]"/>
				<xsl:copy>
					<xsl:apply-templates select="@*[not(name() = 'href')]"/>
					<xsl:attribute name="href">
						<xsl:value-of select="$loc.techniques"/>
						<xsl:value-of select="$technique/parent::technology/@name"/>
						<xsl:text>/</xsl:text>
						<xsl:value-of select="$technique-id"/>
					</xsl:attribute>
					<xsl:value-of select="$technique-id"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="$technique/title"/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<xsl:text>IN DEVELOPMENT: </xsl:text>
					<xsl:apply-templates/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="html:p[@class = 'note'] | html:div[@class = 'note']">
		<div class="note">
			<div role="heading" class="note-title marker" aria-level="{count(ancestor::html:section) + 2}">Note</div>
			<xsl:copy><xsl:apply-templates select="@*[not(name() = 'class')]|node()"/></xsl:copy>
		</div>
	</xsl:template>
	
	<xsl:template match="html:li[@class = 'note']">
		<xsl:copy>
			<xsl:apply-templates select="@*[not(name() = 'class')]"/>
			<div class="note">
				<div role="heading" class="note-title marker" aria-level="{count(ancestor::html:section) + 2}">Note</div>
				<xsl:apply-templates/>
			</div>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:*[@class = 'generate-date']">
		<xsl:value-of select="format-date(current-date(), '[D] [MNn] [Y]')"/>
	</xsl:template>
	
	<xsl:template match="html:*[@class = 'generate-year']">
		<xsl:value-of select="format-date(current-date(), '[Y]')"/>
	</xsl:template>
	
	<xsl:template match="html:link[@href][contains(@href, 'css/editors.css')]"/>
	
	<xsl:template match="html:figure">
		<xsl:if test="not(@id)">
			<xsl:message terminate="yes">ID is required on figure: src=<xsl:value-of select="html:img/@src"/> in <xsl:value-of select="base-uri()"/></xsl:message>
		</xsl:if>
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:figcaption">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:text>Figure </xsl:text>
			<xsl:value-of select="count(parent::html:figure/preceding::html:figure) + 1"/>
			<xsl:text> </xsl:text>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:p[@class = 'change']"/>
	
	<xsl:template match="element()[@data-include]">
		<xsl:choose>
			<xsl:when test="@data-include-replace = 'true'"><xsl:value-of select="unparsed-text(resolve-uri(@data-include, document-uri(ancestor::document-node())))" disable-output-escaping="yes"/></xsl:when>
			<xsl:otherwise>
				<xsl:copy><xsl:apply-templates select="@*[not(name() = 'data-include')]"/><xsl:value-of select="unparsed-text(resolve-uri(@data-include, document-uri(ancestor::document-node())))" disable-output-escaping="yes"/></xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="html:*[starts-with(@class, 'wcag')]">
		<xsl:if test="not($guidelines.version)">
			<xsl:message terminate="yes">Guidelines version not provided</xsl:message>
		</xsl:if>
		<xsl:variable name="version" select="substring-after(@class, 'wcag')"/>
		<xsl:choose>
			<xsl:when test="$version &lt; $guidelines.version">
				<xsl:copy>
					<xsl:apply-templates select="node()|@*"/>
				</xsl:copy>
			</xsl:when>
			<xsl:when test="$version = $guidelines.version">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<xsl:text> </xsl:text><span class="new-version">New in WCAG <xsl:value-of select="$guidelines.version"/>: </span>
					<xsl:apply-templates/>
				</xsl:copy>
			</xsl:when>
			<xsl:when test="$version &gt; $guidelines.version"><!-- don't output --></xsl:when>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>