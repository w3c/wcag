<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:wcag="https://www.w3.org/WAI/GL/"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:include href="base.xslt"/>
	
	<xsl:param name="base.dir">understanding/</xsl:param>
	<xsl:param name="output.dir">output/</xsl:param>
	
	<xsl:template name="name">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:variable name="type">
			<xsl:choose>
				<xsl:when test="name($meta) = 'guideline'">Guideline</xsl:when>
				<xsl:when test="name($meta) = 'success-criterion'">Success Criterion</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$type != ''"><xsl:value-of select="$type"/><xsl:text> </xsl:text><xsl:value-of select="$meta/num"/><xsl:text>: </xsl:text></xsl:if><xsl:value-of select="$meta/name"/>
	</xsl:template>
	
	<xsl:template name="navigation">
		<xsl:param name="meta" tunnel="yes"/>
		<nav>
		<ul id="navigation">
			<li><a href="." title="Table of Contents">Contents</a></li>
			<xsl:choose>
				<xsl:when test="name($meta) = 'guideline'">
					<xsl:choose>
						<xsl:when test="$meta/preceding-sibling::guideline">
							<li><a href="{$meta/preceding-sibling::guideline[1]/file/@href}">Previous <abbr title="Guideline">GL</abbr>: <xsl:value-of select="$meta/preceding-sibling::guideline[1]/name"/></a></li>
						</xsl:when>
						<xsl:when test="$meta/parent::principle/preceding-sibling::principle">
							<li><a href="{$meta/parent::principle/preceding-sibling::principle[1]/guideline[last()]/file/@href}">Previous <abbr title="Guideline">GL</abbr>: <xsl:value-of select="$meta/parent::principle/preceding-sibling::principle[1]/guideline[last()]/name"/></a></li>
						</xsl:when>
						<xsl:when test="$meta/parent::principle/preceding-sibling::understanding">
							<li><a href="{$meta/parent::principle/preceding-sibling::understanding[1]/file/@href}"><xsl:value-of select="$meta/parent::principle/preceding-sibling::understanding[1]/name"/></a></li>
						</xsl:when>
					</xsl:choose>
					<li><a href="{$meta/success-criterion[1]/file/@href}">First <abbr title="Success Criterion">SC</abbr>: <xsl:value-of select="$meta/success-criterion[1]/name"/></a></li>
					<xsl:choose>
						<xsl:when test="$meta/following-sibling::guideline">
							<li><a href="{$meta/following-sibling::guideline[1]/file/@href}">Next <abbr title="Guideline">GL</abbr>: <xsl:value-of select="$meta/following-sibling::guideline[1]/name"/></a></li>
						</xsl:when>
						<xsl:when test="$meta/parent::principle/following-sibling::principle">
							<li><a href="{$meta/parent::principle/following-sibling::principle[1]/guideline[1]/file/@href}">Next <abbr title="Guideline">GL</abbr>: <xsl:value-of select="$meta/parent::principle/following-sibling::principle[1]/guideline[1]/name"/></a></li>
						</xsl:when>
						<xsl:when test="$meta/parent::principle/following-sibling::understanding">
							<li><a href="{$meta/parent::principle/following-sibling::understanding[1]/file/@href}"><xsl:value-of select="$meta/parent::principle/following-sibling::understanding[1]/name"/></a></li>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="name($meta) = 'success-criterion'">
					<li><a href="{$meta/parent::guideline[1]/file/@href}"><abbr title="Guideline">GL</abbr>: <xsl:value-of select="$meta/parent::guideline[1]/name"/></a></li>
					<xsl:choose>
						<xsl:when test="$meta/preceding-sibling::success-criterion">
							<li><a href="{$meta/preceding-sibling::success-criterion[1]/file/@href}">Previous <abbr title="Success Criterion">SC</abbr>: <xsl:value-of select="$meta/preceding-sibling::success-criterion[1]/name"/></a></li>
						</xsl:when>
						<xsl:when test="$meta/parent::guideline/preceding-sibling::guideline">
							<li><a href="{$meta/parent::guideline/preceding-sibling::guideline[1]/success-criterion[1]/file/@href}">Previous <abbr title="Success Criterion">SC</abbr>: <xsl:value-of select="$meta/ancestor::principle/preceding-sibling::principle[1]/guideline[1]/success-criterion[1]/name"/></a></li>
						</xsl:when>
						<xsl:when test="$meta/ancestor::principle/preceding-sibling::principle">
							<li><a href="{$meta/ancestor::principle/preceding-sibling::principle[1]/guideline[last()]/success-criterion[last()]/file/@href}">Previous <abbr title="Success Criterion">SC</abbr>: <xsl:value-of select="$meta/ancestor::principle/preceding-sibling::principle[1]/guideline[last()]/success-criterion[last()]/name"/></a></li>
						</xsl:when>
						<xsl:when test="$meta/ancestor::principle/preceding-sibling::understanding">
							<li><a href="{$meta/ancestor::principle/preceding-sibling::understanding[1]/file/@href}">Previous: <xsl:value-of select="$meta/ancestor::principle/preceding-sibling::understanding[1]/name"/></a></li>
						</xsl:when>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="$meta/following-sibling::success-criterion">
							<li><a href="{$meta/following-sibling::success-criterion[1]/file/@href}">Next <abbr title="Success Criterion">SC</abbr>: <xsl:value-of select="$meta/following-sibling::success-criterion[1]/name"/></a></li>
						</xsl:when>
						<xsl:when test="$meta/parent::guideline/following-sibling::guideline">
							<li><a href="{$meta/parent::guideline/following-sibling::guideline[1]/success-criterion[1]/file/@href}">Next <abbr title="Success Criterion">SC</abbr>: <xsl:value-of select="$meta/parent::guideline/following-sibling::guideline[1]/success-criterion[1]/name"/></a></li>
						</xsl:when>
						<xsl:when test="$meta/ancestor::principle/following-sibling::principle">
							<li><a href="{$meta/ancestor::principle/following-sibling::principle[1]/guideline[1]/success-criterion[1]/file/@href}">Next <abbr title="Success Criterion">SC</abbr>: <xsl:value-of select="$meta/ancestor::principle/following-sibling::principle[1]/guideline[1]/success-criterion[1]/name"/></a></li>
						</xsl:when>
						<xsl:when test="$meta/ancestor::principle/following-sibling::understanding">
							<li><a href="{$meta/ancestor::principle/following-sibling::understanding[1]/file/@href}">Next: <xsl:value-of select="$meta/ancestor::principle/following-sibling::understanding[1]/name"/></a></li>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="name($meta) = 'understanding'">
					<xsl:if test="name($meta/preceding-sibling::element()[1]) = 'understanding'">
						<li><a href="{$meta/preceding-sibling::understanding[1]/file/@href}">Previous: <xsl:value-of select="$meta/preceding-sibling::understanding[1]/name"/></a></li>
					</xsl:if>
					<xsl:if test="name($meta/preceding-sibling::element()[1]) = 'principle'">
						<li><a href="{$meta/preceding-sibling::principle[1]/guideline[last()]/success-criterion[last()]/file/@href}">Previous <abbr title="Guideline">GL</abbr>: <xsl:value-of select="$meta/preceding-sibling::principle[1]/guideline[last()]/name"/></a></li>
						<li><a href="{$meta/preceding-sibling::principle[1]/guideline[last()]/file/@href}">Previous <abbr title="Success Criterion">SC</abbr>: <xsl:value-of select="$meta/preceding-sibling::principle[1]/guideline[last()]/success-criterion[last()]/name"/></a></li>
					</xsl:if>
					<xsl:if test="name($meta/following-sibling::element()[1]) = 'principle'">
						<li><a href="{$meta/following-sibling::principle[1]/guideline[1]/file/@href}">First <abbr title="Guideline">GL</abbr>: <xsl:value-of select="$meta/following-sibling::principle[1]/guideline[1]/name"/></a></li>
						<li><a href="{$meta/following-sibling::principle[1]/guideline[1]/success-criterion[1]/file/@href}">First <abbr title="Success Criterion">SC</abbr>: <xsl:value-of select="$meta/following-sibling::principle[1]/guideline[1]/success-criterion[1]/name"/></a></li>
					</xsl:if>
					<xsl:if test="name($meta/following-sibling::element()[1]) = 'understanding'">
						<li><a href="{$meta/following-sibling::understanding[1]/file/@href}">Next: <xsl:value-of select="$meta/following-sibling::understanding[1]/name"/></a></li>
					</xsl:if>
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
				<li><a href="#intent">Intent</a></li>
				<xsl:if test="name($meta) = 'success-criterion'">
					<li><a href="#benefits">Benefits</a></li>
					<li><a href="#examples">Examples</a></li>
					<li><a href="#resources">Related Resources</a></li>
					<li><a href="#techniques">Techniques</a></li>
				</xsl:if>
				<xsl:if test="name($meta) = 'guideline'">
					<li><a href="#advisory">Advisory Techniques</a></li>
					<li><a href="#success-criteria">Success Criteria</a></li>
				</xsl:if>
				<xsl:if test="//html:a[not(@href)] | $meta/content/descendant::html:a[not(@href)]">
					<li><a href="#key-terms">Key Terms</a></li>
				</xsl:if>
			</ul>
		</nav>
	</xsl:template>
	
	<xsl:template name="gl-sc">
		<xsl:param name="meta" tunnel="yes"/>
		<section id="success-criteria">
			<h2>Success Criteria for this Guideline</h2>
			<ul>
				<xsl:for-each select="$meta/success-criterion">
					<li><a href="{file/@href}"><xsl:value-of select="num"/><xsl:text> </xsl:text><xsl:value-of select="name"/></a></li>
				</xsl:for-each>
			</ul>
		</section>
	</xsl:template>
	
	<xsl:template name="sc-info">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:choose>
			<xsl:when test="name($meta) = 'guideline'">Guideline </xsl:when>
			<xsl:when test="name($meta) = 'success-criterion'">Success Criterion </xsl:when>
		</xsl:choose>
		<a href="{$loc.guidelines}#{$meta/@id}" style="font-weight: bold;">
			<xsl:value-of select="$meta/num"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="$meta/name"/>
		</a>
		<xsl:if test="name($meta) = 'success-criterion'"> (Level <xsl:value-of select="$meta/level"/>)</xsl:if>
		<xsl:text>: </xsl:text>
	</xsl:template>
	
	<xsl:template match="html:p" mode="sc-info">
		<xsl:param name="sc-info"/>
		<p><xsl:apply-templates select="@*"/><xsl:apply-templates select="$sc-info"/><xsl:apply-templates mode="sc-info"/></p>
	</xsl:template>
	
	<xsl:template match="html:a[starts-with(@href, '#')]" mode="sc-info">
		<a href="{$loc.guidelines}{@href}"><xsl:apply-templates mode="sc-info"/></a>
	</xsl:template>
	
	<xsl:template name="key-terms">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:variable name="termrefs" select="//html:a[not(@href)] | $meta/content/descendant::html:a[not(@href)]"/>
		<xsl:if test="$termrefs">
			<xsl:variable name="termrefs-canonical">
				<xsl:for-each select="$termrefs">
					<xsl:copy-of select="$meta/ancestor::guidelines/term[name = lower-case(normalize-space(current()))]/name[1]"/>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="termids" as="node()*">
				<xsl:for-each select="distinct-values($termrefs-canonical/name)">
					<xsl:copy-of select="$meta/ancestor::guidelines/term[name = current()]"/>
				</xsl:for-each>
			</xsl:variable>
			<section id="key-terms">
				<h2>Key Terms</h2>
				<xsl:apply-templates select="$termids" mode="key-terms">
					<xsl:sort select="id"/>
				</xsl:apply-templates>
			</section>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="term" mode="key-terms">
		<dt id="{id}"><xsl:value-of select="name[1]"/></dt>
		<dd><xsl:apply-templates select="definition"/></dd>
	</xsl:template>
	
	<xsl:template match="guidelines">
		<xsl:apply-templates select="//understanding | //guideline | //success-criterion"/>
	</xsl:template>
	
	<xsl:template match="understanding | guideline | success-criterion">
		<xsl:variable name="subpath" select="concat('WCAG', $versions.doc//id[@id = current()/@id]/parent::version/@name)"/>
		<xsl:result-document href="{$output.dir}/{file/@href}.html" encoding="utf-8" exclude-result-prefixes="#all" include-content-type="no" indent="yes" method="xhtml" omit-xml-declaration="yes">
			<xsl:apply-templates select="document(resolve-uri(concat(file/@href, '.html'), concat($base.dir, $subpath)))">
				<xsl:with-param name="meta" select="." tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="node()|@*" mode="#all">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*" mode="#current"/>
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
				<title><xsl:apply-templates select="//html:h1"/></title>
				<link rel="stylesheet" type="text/css" href="https://www.w3.org/StyleSheets/TR/2016/base" />
				<link rel="stylesheet" type="text/css" href="understanding.css" />
				<link rel="stylesheet" type="text/css" href="slicenav.css" />
			</head>
			<body>
				<xsl:call-template name="navigation"/>
				<xsl:call-template name="navtoc"/>
				<h1><xsl:apply-templates select="//html:h1"/></h1>
				<xsl:choose>
					<xsl:when test="name($meta) = 'guideline' or name($meta) = 'success-criterion'">
						<blockquote class="scquote">
							<xsl:apply-templates select="$meta/content/html:p[1]" mode="sc-info">
								<xsl:with-param name="sc-info"><xsl:call-template name="sc-info"/></xsl:with-param>
							</xsl:apply-templates>
							<xsl:apply-templates select="$meta/content/html:*[position() &gt; 1]" mode="sc-info"/>
						</blockquote>
						<main>
							<xsl:apply-templates select="//html:section[@id = 'intent']"/>
							<xsl:apply-templates select="//html:section[@id = 'benefits']"/>
							<xsl:apply-templates select="//html:section[@id = 'examples']"/>
							<xsl:apply-templates select="//html:section[@id = 'resources']"/>
							<xsl:apply-templates select="//html:section[@id = 'techniques']"/>
							<xsl:if test="name($meta) = 'guideline'">
								<xsl:apply-templates select="//html:section[@id = 'advisory']" mode="gladvisory"/>
								<xsl:call-template name="gl-sc"/>
							</xsl:if>
							<xsl:call-template name="key-terms"/>
						</main>
					</xsl:when>
					<xsl:when test="name($meta) = 'understanding'">
						<main>
							<xsl:apply-templates select="descendant::html:body/node()[not(wcag:isheading(.))]"/>
						</main>
					</xsl:when>
				</xsl:choose>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="html:title | html:h1">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:if test="name($meta) != 'understanding'">Understanding </xsl:if><xsl:call-template name="name"/>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'intent']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<h2>Intent</h2>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.) or @id = 'benefits')]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'benefits']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<h2>Benefits</h2>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'examples']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<h2>Examples</h2>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'resources']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<h2>Related Resources</h2>
			<p>Resources are for information purposes only, no endorsement implied.</p>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'techniques']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<h2>Techniques</h2>
			<p>Each numbered item in this section represents a technique or combination of techniques that the WCAG Working Group deems sufficient for meeting this Success Criterion. However, it is not necessary to use these particular techniques. For information on using other techniques, see <a href="understanding-techniques">Understanding Techniques for WCAG Success Criteria</a>, particularly the "Other Techniques" section.</p>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'sufficient']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<h3>Sufficient Techniques</h3>
			<xsl:if test="html:section[@class = 'situation']"><p>Select the situation below that matches your content. Each situation includes techniques or combinations of techniques that are known and documented to be sufficient for that situation. </p></xsl:if>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'advisory']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<h3>Advisory Techniques</h3>
			<p>Although not required for conformance, the following additional techniques should be considered in order to make content more accessible. Not all techniques can be used or would be effective in all situations.</p>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'advisory']" mode="gladvisory">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<h2>Advisory Techniques</h2>
			<p>Specific techniques for meeting each Success Criterion for this guideline are listed in the understanding sections for each Success Criterion (listed below). If there are techniques, however, for addressing this guideline that do not fall under any of the success criteria, they are listed here. These techniques are not required or sufficient for meeting any success criteria, but can make certain types of Web content more accessible to more people.</p>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'failure']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<h3>Failures</h3>
			<p>The following are common mistakes that are considered failures of this Success Criterion by the WCAG Working Group.</p>
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
	
	<xsl:template match="html:a[not(@href)]" mode="#all">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:variable name="dfn" select="lower-case(.)"/>
		<a href="{$loc.guidelines}#{$meta/ancestor::guidelines/term[name = $dfn]/id}" target="terms"><xsl:value-of select="."/></a>
	</xsl:template>
	
	<xsl:template match="html:*[@class = 'instructions']"/>
	
</xsl:stylesheet>