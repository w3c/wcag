<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:wcag="https://www.w3.org/WAI/GL/"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:include href="base.xslt"/>
	
	<xsl:param name="techniques.dir">techniques/</xsl:param>
	<xsl:param name="output.dir">output/</xsl:param>
	<xsl:param name="associations.file">technique-assocations.xml</xsl:param>
	<xsl:param name="guidelines.meta.file">../guidelines/wcag.xml</xsl:param>
	<xsl:param name="loc.guidelines">https://www.w3.org/TR/WCAG21/</xsl:param>
	<xsl:param name="loc.understanding">https://www.w3.org/WAI/WCAG21/Understanding/</xsl:param>
	<xsl:param name="loc.techniques">https://www.w3.org/WAI/WCAG21/Techniques/</xsl:param>
	
	<xsl:variable name="associations.doc" select="document($associations.file)"/>
	<xsl:variable name="guidelines.meta.doc" select="document($guidelines.meta.file)"/>
	
	<xsl:template name="navigation">
		<xsl:param name="meta" tunnel="yes"/>
		<nav>
		<ul id="navigation">
			<li><a href="{$loc.techniques}#techniques" title="Table of Contents">Contents</a></li>
			<li><a href="{$loc.techniques}#introduction" title="Introduction to Techniques">Intro</a></li>
			<xsl:choose>
				<xsl:when test="$meta/preceding-sibling::technique">
					<li><a href="{$meta/preceding-sibling::technique[1]/@id}">Previous Technique: <xsl:value-of select="$meta/preceding-sibling::technique[1]/@id"/></a></li>
				</xsl:when>
				<xsl:when test="$meta/parent::technology/preceding-sibling::technology">
					<li><a href="../{$meta/parent::technology/preceding-sibling::technology[1]/@name}/{$meta/parent::technology/preceding-sibling::technology[1]/technique[last()]/@id}">Previous Technique: <xsl:value-of select="$meta/parent::technology/preceding-sibling::technology[1]/technique[last()]/@id"/></a></li>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="$meta/following-sibling::technique">
					<li><a href="{$meta/following-sibling::technique[1]/@id}">Next Technique: <xsl:value-of select="$meta/following-sibling::technique[1]/@id"/></a></li>
				</xsl:when>
				<xsl:when test="$meta/parent::technology/following-sibling::technology">
					<li><a href="../{$meta/parent::technology/following-sibling::technology[1]/@name}/{$meta/parent::technology/following-sibling::technology[1]/technique[1]/@id}">Next Technique: <xsl:value-of select="$meta/parent::technology/following-sibling::technology[1]/technique[1]/@id"/></a></li>
				</xsl:when>
			</xsl:choose>
		</ul>
		</nav>
	</xsl:template>
	
	<xsl:template name="navtoc">
		<xsl:param name="meta" tunnel="yes"/>
		<nav class="navtoc">
			<p>On this page:</p>
			<ul id="navbar">
				<li><a href="#important-information">Important Information about Techniques</a></li>
				<li><a href="#applicability">Applicability</a></li>
				<li><a href="#description">Description</a></li>
				<li><a href="#examples">Examples</a></li>
				<li><a href="#resources">Related Resources</a></li>
				<li><a href="#related">Related Techniques</a></li>
				<li><a href="#tests">Tests</a></li>
			</ul>
		</nav>
	</xsl:template>
	
	<xsl:template name="technique-link">
		<xsl:param name="technique" select="."/>
		<xsl:choose>
			<xsl:when test="$technique"><a href="../{$technique/parent::technology/@name}/{$technique/@id}"><xsl:value-of select="$technique/@id"/>: <xsl:value-of select="$technique/title"/></a></xsl:when>
			<xsl:otherwise>an unwritten technique</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template name="understanding-link">
		<xsl:param name="understanding-id" select="@id"/>
		<xsl:variable name="guidelines.meta" select="$guidelines.meta.doc//*[@id = $understanding-id]"/>
		<a href="{$loc.understanding}{$guidelines.meta/@id}">
			<xsl:choose>
				<xsl:when test="$guidelines.meta/self::success-criterion">Success Criterion</xsl:when>
				<xsl:when test="$guidelines.meta/self::guideline">Guideline</xsl:when>
			</xsl:choose>
			<xsl:text> </xsl:text>
			<xsl:value-of select="$guidelines.meta/num"/>
			<xsl:text>: </xsl:text>
			<xsl:value-of select="$guidelines.meta/name"/>
		</a>
	</xsl:template>
	
	<xsl:template name="technique-sufficiency">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:choose>
			<xsl:when test="ancestor::sufficient">Sufficient</xsl:when>
			<xsl:when test="ancestor::advisory">Advisory</xsl:when>
			<xsl:when test="ancestor::failure">Failure</xsl:when>
		</xsl:choose>
		<xsl:if test="parent::and">
			<xsl:text>, together with </xsl:text>
			<xsl:for-each select="parent::and/technique[not(@id = current()/@id)]">
				<xsl:call-template name="technique-link">
					<xsl:with-param name="technique" select="$meta/ancestor::techniques//technique[@id = current()/@id]"/>
				</xsl:call-template>
				<xsl:if test="position() != last()"> and </xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="using">
			<xsl:text> using a more specific technique</xsl:text>
		</xsl:if>
		<xsl:if test="ancestor::using">
			<xsl:text> as a way to meet </xsl:text>
			<xsl:call-template name="technique-link">
				<xsl:with-param name="technique" select="$meta/ancestor::techniques//technique[@id = current()/ancestor::using[1]/parent::technique/@id]"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="/techniques">
		<xsl:variable name="techniques-sorted">
			<xsl:apply-templates select="technology" mode="sorting">
				<xsl:sort select="@name"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:apply-templates select="$techniques-sorted//technique"/>
	</xsl:template>
	
	<xsl:template match="technology" mode="sorting">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="technique" mode="sorting">
				<xsl:sort select="wcag:number-in-id(@id)" data-type="number"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template> 
	
	<xsl:template match="technique" mode="sorting">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="technique">
		<xsl:variable name="technology" select="parent::technology/@name"/>
		<xsl:result-document href="{$output.dir}/{$technology}/{@id}.html" encoding="utf-8" exclude-result-prefixes="#all" indent="yes" method="xml" omit-xml-declaration="yes">
			<xsl:apply-templates select="document(resolve-uri(concat($technology, '/', @id, '.html'), $techniques.dir))">
				<xsl:with-param name="meta" select="." tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:html">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:variable name="lang" select="$meta/ancestor::guidelines/@lang"/>
		<xsl:text disable-output-escaping="yes"><![CDATA[<!DOCTYPE html>
]]></xsl:text>
		<html lang="{$lang}" xml:lang="{$lang}">
			<head>
				<meta charset="UTF-8" />
				<xsl:apply-templates select="//html:title"/>
				<link rel="stylesheet" type="text/css" href="http://www.w3.org/StyleSheets/TR/2016/base" />
				<link rel="stylesheet" type="text/css" href="../techniques.css" />
				<link rel="stylesheet" type="text/css" href="../slicenav.css" />
			</head>
			<body>
				<xsl:call-template name="navigation"/>
				<xsl:call-template name="navtoc"/>
				<xsl:apply-templates select="//html:h1"/>
				<section id="important-information">
					<h2>Important Information about Techniques</h2>
					<p>See <a href="{$loc.understanding}understanding-techniques">Understanding Techniques for WCAG Success Criteria</a> for important information about the usage of these informative techniques and how they relate to the normative WCAG 2.0 success criteria. The Applicability section explains the scope of the technique, and the presence of techniques for a specific technology does not imply that the technology can be used in all situations to create content that meets WCAG 2.0.</p>
				</section>
				<main>
					<xsl:call-template name="applicability"/>
					<xsl:call-template name="description"/>
					<xsl:call-template name="examples"/>
					<xsl:call-template name="resources"/>
					<xsl:call-template name="related"/>
					<xsl:call-template name="tests"/>
				</main>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="html:title">
		<xsl:param name="meta" tunnel="yes"/>
		<title><xsl:value-of select="$meta/@id"/>: <xsl:value-of select="//html:h1"/></title>
	</xsl:template>
	
	<xsl:template match="html:h1">
		<h1><xsl:apply-templates select="node()"/></h1>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'meta']"/>
	
	<xsl:template name="applicability">
		<xsl:param name="meta" tunnel="yes"/>
		<section id="applicability">
			<h2>Applicability</h2>
			<xsl:call-template name="section-if-exists">
				<xsl:with-param name="section" select="//html:section[@id = 'applicability']"></xsl:with-param>
				<xsl:with-param name="name">applicability</xsl:with-param>
			</xsl:call-template>
			<!-- This has gotten really hairy, would like to find a more elegant way to sort the associations -->
			<xsl:variable name="associations" select="$associations.doc//technique[@id = $meta/@id]"/>
			<xsl:variable name="association-links">
				<xsl:for-each select="$associations">
					<span>
						<xsl:call-template name="understanding-link">
							<xsl:with-param name="understanding-id">
								<xsl:choose>
									<xsl:when test="ancestor::success-criterion"><xsl:value-of select="ancestor::success-criterion/@id"/></xsl:when>
									<xsl:when test="ancestor::guideline"><xsl:value-of select="ancestor::guideline/@id"/></xsl:when>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
						<xsl:text> (</xsl:text>
						<xsl:call-template name="technique-sufficiency"/>
						<xsl:text>)</xsl:text>
					</span>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="association-links-filtered">
				<xsl:for-each select="$association-links/html:span">
					<xsl:if test="not(preceding-sibling::html:span[. = current()])">
						<xsl:copy-of select="."/>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="count($association-links-filtered/html:span) &gt; 1">
					<p>This technique relates to:</p>
					<ul>
						<xsl:for-each select="$association-links-filtered/html:span">
							<li><xsl:copy-of select="node()"/></li>
						</xsl:for-each>
					</ul>
				</xsl:when>
				<xsl:when test="count($association-links-filtered/html:span) = 1">
					<p>This technique relates to <xsl:copy-of select="$association-links-filtered/node()"/>.</p>
				</xsl:when>
				<xsl:otherwise><p>This technique is not referenced from any Understanding document.</p></xsl:otherwise>
			</xsl:choose>
		</section>
	</xsl:template>
	
	<xsl:template name="description">
		<xsl:param name="meta" tunnel="yes"/>
		<section id="description">
			<h2>Description</h2>
			<xsl:call-template name="section-if-exists">
				<xsl:with-param name="section" select="//html:section[@id = 'description']"></xsl:with-param>
				<xsl:with-param name="name">description</xsl:with-param>
			</xsl:call-template>
		</section>
	</xsl:template>
	
	<xsl:template name="examples">
		<xsl:param name="meta" tunnel="yes"/>
		<section id="examples">
			<h2>Examples</h2>
			<xsl:call-template name="section-if-exists">
				<xsl:with-param name="section" select="//html:section[@id = 'examples']"></xsl:with-param>
				<xsl:with-param name="name">examples</xsl:with-param>
			</xsl:call-template>
		</section>
	</xsl:template>
	
	<xsl:template name="resources">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:variable name="resources" select="//html:section[@id = 'resources']"/>
		<section id="resources">
			<h2>Resources</h2>
			<p>Resources are for information purposes only, no endorsement implied.</p>
			<xsl:call-template name="section-if-exists">
				<xsl:with-param name="section" select="//html:section[@id = 'resources']"></xsl:with-param>
				<xsl:with-param name="name">resources</xsl:with-param>
			</xsl:call-template>
		</section>
		
	</xsl:template>
	
	<xsl:template name="related">
		<xsl:param name="meta" tunnel="yes"/>
		<section id="related">
			<h2>Related Techniques</h2>
			<xsl:call-template name="section-if-exists">
				<xsl:with-param name="section" select="//html:section[@id = 'related']"></xsl:with-param>
				<xsl:with-param name="name">related techniques</xsl:with-param>
			</xsl:call-template>
		</section>
	</xsl:template>
	
	<xsl:template name="tests">
		<xsl:param name="meta" tunnel="yes"/>
		<section id="tests">
			<h2>Tests</h2>
			<xsl:call-template name="section-if-exists">
				<xsl:with-param name="section" select="//html:section[@id = 'tests']"></xsl:with-param>
				<xsl:with-param name="name">tests</xsl:with-param>
			</xsl:call-template>
		</section>
	</xsl:template>
	
	<xsl:template name="section-if-exists">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:param name="section"/>
		<xsl:param name="name"/>
		<xsl:choose>
			<xsl:when test="$section and $section/html:*[not(wcag:isheading(.))]">
				<xsl:apply-templates select="$section/html:*[not(wcag:isheading(.))]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>No <xsl:value-of select="$name"/> section in <xsl:value-of select="$meta/@id"/></xsl:message>
				<p>No <xsl:value-of select="$name"/>.</p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="html:section[@class='test-procedure']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<h2>Procedure</h2>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@class='test-results']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<h2>Expected Results</h2>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@class='example']">
		<xsl:variable name="heading" select="wcag:find-heading(.)"/>
		<xsl:variable name="heading-text">
			<xsl:text>Example </xsl:text>
			<xsl:value-of select="count(preceding-sibling::html:section[@class='example']) + 1"/>
			<xsl:if test="normalize-space($heading) != ''">
				<xsl:text>: </xsl:text>
				<xsl:apply-templates select="$heading/node()"/>
			</xsl:if>
		</xsl:variable>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="id" select="wcag:generate-id($heading-text)"/>
			<h3><xsl:copy-of select="$heading-text"/></h3>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="id">
				<xsl:choose>
					<xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="wcag:generate-id(wcag:find-heading(.))"/></xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:h2 | html:h3 | html:h4 | html:h5 | html:h6">
		<xsl:variable name="level" select="count(ancestor::html:section) + 1"/>
		<xsl:element name="h{$level}">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="html:a[not(node()) and starts-with(@href, 'https://www.w3.org/WAI/WCAG21/Techniques/')]">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:value-of select="replace(@href, '^.*/([\w\d]*)$', '$1')"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:a[not(@href)]">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:variable name="dfn" select="lower-case(.)"/>
		<a href="{$loc.guidelines}#{$meta/ancestor::guidelines/term[name = $dfn]/id}" target="terms"><xsl:value-of select="."/></a>
	</xsl:template>
	
	<xsl:template match="html:*[@class = 'instructions']"/>
	
</xsl:stylesheet>