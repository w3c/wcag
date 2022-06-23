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
	
	<xsl:param name="techniques.dir">techniques/</xsl:param>
	<xsl:param name="output.dir">output/</xsl:param>
	<xsl:param name="associations.file">technique-assocations.xml</xsl:param>
	<xsl:param name="guidelines.meta.file">../guidelines/wcag.xml</xsl:param>
	
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
				<xsl:if test="wcag:section-meaningfully-exists('examples', //html:section[@id = 'examples'])"><li><a href="#examples">Examples</a></li></xsl:if>
				<xsl:if test="wcag:section-meaningfully-exists('resources', //html:section[@id = 'resources'])"><li><a href="#resources">Related Resources</a></li></xsl:if>
				<xsl:if test="wcag:section-meaningfully-exists('related', //html:section[@id = 'related'])"><li><a href="#related">Related Techniques</a></li></xsl:if>
				<li><a href="#tests">Tests</a></li>
				<xsl:if test="$act.doc//func:array[@key = 'wcagTechniques'][func:string = $meta/@id]">
					<li><a href="#test-rules">Test Rules</a></li>
				</xsl:if>
			</ul>
		</nav>
	</xsl:template>
	
	<xsl:template name="technique-link">
		<xsl:param name="technique"/>
		<xsl:choose>
			<xsl:when test="$technique"><a href="../{$technique/parent::technology/@name}/{$technique/@id}"><xsl:value-of select="$technique/@id"/>: <xsl:value-of select="$technique/title"/></a></xsl:when>
			<xsl:when test="not($technique)"><xsl:value-of select="ancestor::using/parent::technique/title"/></xsl:when>
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
				<link rel="stylesheet" type="text/css" href="https://www.w3.org/StyleSheets/TR/2016/base" />
				<link rel="stylesheet" type="text/css" href="base.css" />
				<link rel="stylesheet" type="text/css" href="../techniques.css" />
				<link rel="stylesheet" type="text/css" href="../slicenav.css" />
			</head>
			<body>
				<xsl:call-template name="navigation"/>
				<xsl:call-template name="navtoc"/>
				<xsl:apply-templates select="//html:h1"/>
				<section id="important-information">
					<h2>Important Information about Techniques</h2>
					<p>See <a href="{$loc.understanding}understanding-techniques">Understanding Techniques for WCAG Success Criteria</a> for important information about the usage of these informative techniques and how they relate to the normative WCAG <xsl:value-of select="$guidelines.version.decimal"/> success criteria. The Applicability section explains the scope of the technique, and the presence of techniques for a specific technology does not imply that the technology can be used in all situations to create content that meets WCAG <xsl:value-of select="$guidelines.version.decimal"/>.</p>
				</section>
				<main>
					<xsl:call-template name="applicability"/>
					<xsl:call-template name="description"/>
					<xsl:call-template name="examples"/>
					<xsl:call-template name="resources"/>
					<xsl:call-template name="related"/>
					<xsl:call-template name="tests"/>
					<xsl:call-template name="act"/>
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
		<xsl:variable name="technology" select="$meta/parent::technology/@name"/>
		<xsl:variable name="applicability" select="//html:section[@id = 'applicability']"/>
		<section id="applicability">
			<h2>Applicability</h2>
			
			<!-- Copy applicability if provided, otherwise put in a stock one for technology -->
			<xsl:choose>
				<xsl:when test="wcag:section-meaningfully-exists('applicability', $applicability)">
					<xsl:apply-templates select="$applicability/html:*[not(wcag:isheading(.))]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$technology = 'aria'">
							<p>Content using <a href="https://www.w3.org/TR/wai-aria/">Accessible Rich Internet Applications (WAI-ARIA)</a>.</p>
						</xsl:when>
						<xsl:when test="$technology = 'client-side-script'">
							<p>Content using client-side script (JavaScript, ECMAScript).</p>
						</xsl:when>
						<xsl:when test="$technology = 'css'">
							<p>Content using technologies that support <a href="https://www.w3.org/TR/CSS/">Cascading Style Sheets (CSS)</a>.</p>
						</xsl:when>
						<xsl:when test="$technology = 'failures'">
							<xsl:message>No failures applicability statement in <xsl:value-of select="$meta/@id"/></xsl:message>
						</xsl:when>
						<xsl:when test="$technology = 'flash'">
							<p>Content implemented in Adobe Flash.</p>
						</xsl:when>
						<xsl:when test="$technology = 'general'">
							<p>Content implemented in any technology.</p>
						</xsl:when>
						<xsl:when test="$technology = 'html'">
							<p>Content structured in <a href="https://www.w3.org/TR/html/">HyperText Markup Language (HTML)</a>.</p>
						</xsl:when>
						<xsl:when test="$technology = 'pdf'">
							<p>Content implemented in Adobe Tagged PDF.</p>
						</xsl:when>
						<xsl:when test="$technology = 'server-side-script'">
							<p>Content modified by the server before being sent to the user.</p>
						</xsl:when>
						<xsl:when test="$technology = 'silverlight'">
							<p>Content implemented in Microsoft Silverlight.</p>
						</xsl:when>
						<xsl:when test="$technology = 'smil'">
							<p>Content implemented in <a href="https://www.w3.org/TR/SMIL/">Synchronized Multimedia Integration Language (SMIL)</a>.</p>
						</xsl:when>
						<xsl:when test="$technology = 'text'">
							<p>Content implemented in plain text, including Markdown and similar formats, without use of a structure technology.</p>
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- Put in deprecation warning for out-dated technologies -->
			<xsl:choose>
				<xsl:when test="$technology = 'flash'">
					<div class="note">
						<div role="heading" class="note-title marker" aria-level="3">Note</div>
						<p>Adobe has plans to stop updating and distributing the Flash Player at the end of 2020, and encourages authors interested in creating accessible web content to use HTML.</p>
					</div>
				</xsl:when>
				<xsl:when test="$technology = 'silverlight'">
					<div class="note">
						<div role="heading" class="note-title marker" aria-level="3">Note</div>
						<p>Microsoft has stopped updating and distributing Silverlight, and authors are encouraged to use HTML for accessible web content.</p>
					</div>
				</xsl:when>
			</xsl:choose>
			
			<!-- Add links to the Understanding pages that reference this technique -->
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
						<!-- sufficiency -->
						<xsl:text> (</xsl:text>
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
							<xsl:variable name="user" select="ancestor::using[1]/parent::technique"/>
							<xsl:text> when used with </xsl:text>
							<xsl:call-template name="technique-link">
								<xsl:with-param name="technique" select="$meta/ancestor::techniques//technique[@id = $user/@id]"/>
							</xsl:call-template>
						</xsl:if>
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
			<section id="related">
				<h2>Related Techniques</h2>
				<xsl:apply-templates select="$related/html:*[not(wcag:isheading(.))]"/>
			</section>
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
	
	<xsl:template name="act">
		<xsl:param name="meta" tunnel="yes"/>
		
		<xsl:if test="$act.doc//func:array[@key = 'wcagTechniques'][func:string = $meta/@id]">
			<section id="test-rules">
				<h2>Test Rules</h2>
				<p>The following are Test Rules related to this Technique. It is not necessary to use these particular Test Rules to check for conformance with WCAG, but they are defined and approved test methods. For information on using Test Rules, see <a href="{$loc.understanding}understanding-act-rules.html">Understanding Test Rules for WCAG Success Criteria</a>.</p>
				<ul>
					<xsl:for-each select="$act.doc//func:array[@key = 'wcagTechniques']/func:string[. = $meta/@id]">
						<li><a href="/WAI{ancestor::func:map/func:string[@key = 'permalink']}"><xsl:value-of select="ancestor::func:map/func:string[@key = 'title']"/></a></li>
					</xsl:for-each>
				</ul>
			</section>
		</xsl:if>
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
		<a href="{$loc.guidelines}#{$meta-guidelines//term[name = $dfn]/id}" target="terms"><xsl:value-of select="."/></a>
	</xsl:template>
	
	<xsl:template match="html:*[@class = 'instructions']"/>
	
</xsl:stylesheet>
