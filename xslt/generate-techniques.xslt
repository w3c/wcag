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
	
	<xsl:variable name="associations.doc" select="document($associations.file)"/>
	<xsl:variable name="guidelines.meta.doc" select="document($guidelines.meta.file)"/>
	
	<xsl:template name="navigation">

		<xsl:param name="meta" tunnel="yes"/>

		<nav class="nav" aria-label="Meta navigation">
				<ul>
						<li class="nav__item">
							<a href="{$loc.techniques}#introduction">About Techniques</a>
						</li>
						<li class="nav__item">
								<a href="{$loc.techniques}#techniques">All Techniques</a>
						</li>
						<li class="nav__item">
								<a href="alt-index.html">All WCAG 2 Guidance 
									<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" height="24" width="24">
										<path xmlns="http://www.w3.org/2000/svg" fill-rule="evenodd" clip-rule="evenodd" d="M14 5C13.4477 5 13 4.55228 13 4C13 3.44772 13.4477 3 14 3H20C20.2652 3 20.5196 3.10536 20.7071 3.29289C20.8946 3.48043 21 3.73478 21 4L21 10C21 10.5523 20.5523 11 20 11C19.4477 11 19 10.5523 19 10L19 6.41422L9.70711 15.7071C9.31658 16.0976 8.68342 16.0976 8.29289 15.7071C7.90237 15.3166 7.90237 14.6834 8.29289 14.2929L17.5858 5H14ZM3 7C3 5.89543 3.89543 5 5 5H10C10.5523 5 11 5.44772 11 6C11 6.55228 10.5523 7 10 7H5V19H17V14C17 13.4477 17.4477 13 18 13C18.5523 13 19 13.4477 19 14V19C19 20.1046 18.1046 21 17 21H5C3.89543 21 3 20.1046 3 19V7Z" fill="#282828"></path>
									</svg>
								</a>
								<div id="explain-supporting-documents" hidden="">
										<p>WCAG comes with a number of supporting documents, like Techniques and Understanding documents.</p>
										<p>See also: <a href="https://www.w3.org/WAI/standards-guidelines/wcag/#whatis2">What is in the WCAG 2 Documents</a></p>
								</div>
						</li>
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
				<xsl:if test="wcag:section-meaningfully-exists('examples', //html:section[@id = 'examples'])"><li><a href="#examples">Examples</a></li></xsl:if>
				<xsl:if test="wcag:section-meaningfully-exists('resources', //html:section[@id = 'resources'])"><li><a href="#resources">Related Resources</a></li></xsl:if>
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
			<xsl:when test="ancestor::sufficient">Sufficient to meet </xsl:when>
			<xsl:when test="ancestor::advisory">Advisory</xsl:when>
			<xsl:when test="ancestor::failure">Failure</xsl:when>
		</xsl:choose>
		<xsl:if test="parent::and">
			<xsl:text>, if combined with </xsl:text>
			<xsl:for-each select="parent::and/technique[not(@id = current()/@id)]">
				<xsl:call-template name="technique-link">
					<xsl:with-param name="technique" select="$meta/ancestor::techniques//technique[@id = current()/@id]"/>
				</xsl:call-template>
				<xsl:if test="position() != last()"> and </xsl:if>
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="using">
			<xsl:text> using a more specific technique </xsl:text>
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
			<xsl:copy>
				<xsl:apply-templates select="technology" mode="sorting">
					<xsl:sort select="@name"/>
				</xsl:apply-templates>
			</xsl:copy>
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
		<xsl:result-document href="{$output.dir}/{$technology}/{@id}.html" encoding="utf-8" exclude-result-prefixes="#all" include-content-type="no" indent="yes" method="xhtml" omit-xml-declaration="yes">
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
		    <link rel="stylesheet" href="https://w3.org/WAI/assets/css/style.css?1573220675560713000" />
				<link rel="stylesheet" type="text/css" href="../base.css" />
			</head>
			<body>
				<xsl:call-template name="header" />
				<main>
					<div class="default-grid leftcol">
						<xsl:call-template name="navigation" />
						<section class="main-content">
							<xsl:apply-templates select="//html:h1"/>
							<xsl:call-template name="most-important-meta" />
							<xsl:call-template name="description"/>
							<xsl:call-template name="examples"/>
							<xsl:call-template name="resources"/>
							<xsl:call-template name="tests"/>
						</section>
						<xsl:call-template name="sidebar" />
					</div>
				</main>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="most-important-meta">
		<aside class="box">
				<header class="box-h  box-h-icon">
					[icon] Sufficient
				</header>
				<div class="box-i">
						<xsl:call-template name="applicability"/>
				</div>
		</aside>
	</xsl:template>

	<xsl:template name="header">
    <header id="site-header" class="default-grid with-gap">
        <div class="tool-header">
            <span class="tool-header-name"><a href="../">WCAG 2.1: Techniques</a></span>
            <div class="tool-header-logo">
                <a href="http://w3.org/">
                    <img alt="W3C" src="https://w3.org/WAI/atag/report-tool/images/w3c.svg" width="92" height="44" />
                </a>
                <a href="http://w3.org/WAI/">
                    <img alt="Web Accessibility Initiative" src="https://w3.org//WAI/atag/report-tool/images/wai.svg" />
                </a>
            </div>
        </div>
    </header>
	</xsl:template>
	
	<xsl:template match="html:title">
		<xsl:param name="meta" tunnel="yes"/>
		<title><xsl:value-of select="$meta/@id"/>: <xsl:value-of select="//html:h1"/></title>
	</xsl:template>
	
	<xsl:template match="html:h1">
		<h1><xsl:apply-templates select="node()"/></h1>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'meta']"/>
	
	<xsl:template name="sidebar">
  	<aside class="your-report your-report--expanded sidebar" tabindex="-1">
			<h2 style="margin-top: 0">About this page</h2>
			<p><em>Techniques</em> are examples of ways to meet a WCAG success criterion.</p>
			<dl>
				<dt>Type of technique 
					<button style="display: inline" type="button" data-tooltip-content="#explain-types-of-techniques">
						<span class="visuallyhidden">Explain types of techniques</span>
						<span aria-hidden="true" class="more-info__icon">
							<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 450" style="width: 1em">
							<path fill="currentColor" d="M256 344v-40c0-4.5-3.5-8-8-8h-24v-128c0-4.5-3.5-8-8-8h-80c-4.5 0-8 3.5-8 8v40c0 4.5 3.5 8 8 8h24v80h-24c-4.5 0-8 3.5-8 8v40c0 4.5 3.5 8 8 8h112c4.5 0 8-3.5 8-8zM224 120v-40c0-4.5-3.5-8-8-8h-48c-4.5 0-8 3.5-8 8v40c0 4.5 3.5 8 8 8h48c4.5 0 8-3.5 8-8zM384 224c0 106-86 192-192 192s-192-86-192-192 86-192 192-192 192 86 192 192z"></path>
						</svg>
						</span>	
					</button>
					<div id="explain-types-of-techniques" hidden="true">
						<p>There are different types of techniques:</p>
						<ul>
							<li>Sufficient - reliable ways to meet a WCAG Criterion</li>
							<li>Advisory - suggested ways to improve accessibility</li>
							<li>Failure - things that cause accessibility barriers and fail specific success criteria</li>
						</ul>
						<p>Note: all techniques are “informative”, that is, you do not have to use them.</p>
					</div>
        </dt>
                    <dd>Sufficient</dd>
                    <dt>Sufficient to meet</dt>
                    <dd><a href="https://www.w3.org/WAI/WCAG21/quickref/?versions=2.1#info-and-relationships">1.3.1 Info and relationships</a></dd>
										<xsl:call-template name="related"/>
                </dl>
                <h3>Other sources</h3>
                <p style="margin-top: -.5em; margin-bottom: 1.5em;"><em><small>No endorsement implied.</small></em></p>
                <ul>

                    <li>HTML 4.01 <a href="https://www.w3.org/TR/html4/struct/lists.html#h-10.2">Unordered lists (UL), ordered lists (OL), and list items (LI)</a>

                    </li>

                    <li>HTML 4.01 <a href="https://www.w3.org/TR/html4/struct/lists.html#h-10.3">Definition lists: the DL, DT, and DD elements</a>

                    </li>

                </ul>
            </aside>

	</xsl:template>

	<xsl:template name="applicability">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:variable name="technology" select="$meta/parent::technology/@name"/>
		<xsl:variable name="applicability" select="//html:section[@id = 'applicability']"/>
		<section id="applicability">
			<!-- Add links to the Understanding pages that reference this technique -->
			<!-- This has gotten really hairy, would like to find a more elegant way to sort the associations -->
			<xsl:variable name="associations" select="$associations.doc//technique[@id = $meta/@id]"/>
			<xsl:variable name="association-links">
				<xsl:for-each select="$associations">
					<span>
						<xsl:call-template name="technique-sufficiency"/>
						<xsl:call-template name="understanding-link">
							<xsl:with-param name="understanding-id">
								<xsl:choose>
									<xsl:when test="ancestor::success-criterion"><xsl:value-of select="ancestor::success-criterion/@id"/></xsl:when>
									<xsl:when test="ancestor::guideline"><xsl:value-of select="ancestor::guideline/@id"/></xsl:when>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
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
		<xsl:variable name="description" select="//html:section[@id = 'description']"/>
		<xsl:choose>
			<xsl:when test="wcag:section-meaningfully-exists('description', $description)">
				<section id="description">
					<h2>Description</h2>
					<xsl:apply-templates select="$description/html:*[not(wcag:isheading(.))]"/>
				</section>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>Missing or incomplete description section in <xsl:value-of select="$meta/@id"/></xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="examples">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:variable name="examples" select="//html:section[@id = 'examples']"/>
		<xsl:if test="wcag:section-meaningfully-exists('examples', $examples)">
			<section id="examples">
				<h2>Examples</h2>
				<xsl:apply-templates select="$examples/html:*[not(wcag:isheading(.))]"/>
			</section>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="resources">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:variable name="resources" select="//html:section[@id = 'resources']"/>
		<!-- put in resources section if present and not template -->
		<xsl:if test="wcag:section-meaningfully-exists('resources', $resources)">
			<section id="resources">
				<h2>Resources</h2>
				<p>Resources are for information purposes only, no endorsement implied.</p>
				<xsl:apply-templates select="$resources/html:*[not(wcag:isheading(.))]"/>
			</section>
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template name="related">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:variable name="related" select="//html:section[@id = 'related']"/>
		<!-- put in related techniques section if present and not template -->
		<xsl:if test="wcag:section-meaningfully-exists('related', $related)">
			<dt>Related Techniques</dt>
			<dd><xsl:apply-templates select="$related/html:*[not(wcag:isheading(.))]"/></dd>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="tests">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:variable name="tests" select="//html:section[@id = 'tests']"/>
		<xsl:choose>
			<xsl:when test="wcag:section-meaningfully-exists('tests', $tests)">
				<section id="tests">
					<h2>Tests</h2>
					<xsl:apply-templates select="$tests/html:*[not(wcag:isheading(.))]"/>
				</section>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>Missing or incomplete tests section in <xsl:value-of select="$meta/@id"/></xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="html:section[@class='test']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<h3><xsl:value-of select="html:*[wcag:isheading(.)][1]"/></h3>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@class='test-procedure']">
		<xsl:copy>
			<xsl:apply-templates select="@*[not(name(.) = 'id')]"/>
			<xsl:element name="h{count(ancestor::html:section[@class = 'test' or @id = 'tests']) + 2}">Procedure</xsl:element>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@class='test-results']">
		<xsl:copy>
			<xsl:apply-templates select="@*[not(name(.) = 'id')]"/>
			<xsl:element name="h{count(ancestor::html:section[@class = 'test' or @id = 'tests']) + 2}">Expected Results</xsl:element>
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
	
	<xsl:template match="html:a[not(@href)]" mode="#all">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:variable name="dfn" select="lower-case(.)"/>
		<a href="{$loc.guidelines}#{$meta/ancestor::guidelines/term[name = $dfn]/id}" target="terms"><xsl:value-of select="."/></a>
	</xsl:template>
	
	<xsl:template match="html:*[@class = 'instructions']"/>
	
</xsl:stylesheet>