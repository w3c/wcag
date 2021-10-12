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
	
	<xsl:param name="base.dir">input/understanding/</xsl:param>
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
	
	<xsl:template name="prevnext">
		<xsl:param name="meta" tunnel="yes"/>
		<nav class="pager" aria-label="Previous/Next Page">
		<ul id="navigation">
			<xsl:choose>
				<xsl:when test="name($meta) = 'guideline'">
					<xsl:choose>
						<xsl:when test="$meta/preceding-sibling::guideline">
							<li class="pager--item previous">
								<a href="{$meta/preceding-sibling::guideline[1]/file/@href}">
									<xsl:call-template name="prevnext-previous"/>
									<span class="pager--item-text">
										<span class="pager--item-text-direction">Previous:</span>
										<span class="pager--item-text-target">Guideline: <xsl:value-of select="$meta/preceding-sibling::guideline[1]/name"/></span>
									</span>
								</a>
							</li>
						</xsl:when>
						<xsl:when test="$meta/parent::principle/preceding-sibling::principle">
							<li class="pager--item previous">
								<a href="{$meta/parent::principle/preceding-sibling::principle[1]/guideline[last()]/file/@href}">
									<xsl:call-template name="prevnext-previous"/>
									<span class="pager--item-text">
										<span class="pager--item-text-direction">Previous Guideline</span>: 
										<span class="pager--item-text-target"><xsl:value-of select="$meta/parent::principle/preceding-sibling::principle[1]/guideline[last()]/name"/></span>
									</span>
								</a>
							</li>
						</xsl:when>
						<xsl:when test="$meta/parent::principle/preceding-sibling::understanding">
							<li class="pager--item previous">
								<a href="{$meta/parent::principle/preceding-sibling::understanding[1]/file/@href}">
									<xsl:call-template name="prevnext-previous"/>
									<span class="pager--item-text">
										<span class="pager--item-text-target"><xsl:value-of select="$meta/parent::principle/preceding-sibling::understanding[1]/name"/></span>
									</span>
								</a>
							</li>
						</xsl:when>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="$meta/following-sibling::guideline">
							<li class="pager--item next">
								<a href="{$meta/following-sibling::guideline[1]/file/@href}">
									<xsl:call-template name="prevnext-next"/>
									<span class="pager--item-text">
									<span class="pager--item-text-direction">Next Guideline:</span> 
									<span class="pager--item-text-target"><xsl:value-of select="$meta/following-sibling::guideline[1]/name"/></span>
									</span>
								</a>
							</li>
						</xsl:when>
						<xsl:when test="$meta/parent::principle/following-sibling::principle">
							<li class="pager--item next">
								<a href="{$meta/parent::principle/following-sibling::principle[1]/guideline[1]/file/@href}">
									<xsl:call-template name="prevnext-next"/>
									<span class="pager--item-text">
										<span class="pager--item-text-direction">Next Guideline:</span> 
										<span class="pager--item-text-target"><xsl:value-of select="$meta/parent::principle/following-sibling::principle[1]/guideline[1]/name"/></span>
									</span>
								</a>
							</li>
						</xsl:when>
						<xsl:when test="$meta/parent::principle/following-sibling::understanding">
							<li class="pager--item next">
								<a href="{$meta/parent::principle/following-sibling::understanding[1]/file/@href}">
									<xsl:call-template name="prevnext-next"/>
									<span class="pager--item-text">
										<span class="pager--item-text-target">
											<xsl:value-of select="$meta/parent::principle/following-sibling::understanding[1]/name"/>
										</span>
									</span>
								</a>
							</li>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="name($meta) = 'success-criterion'">
					<li class="pager--item context"><a href="{$meta/parent::guideline[1]/file/@href}"><span class="pager--item-text"><span class="pager--item-text-direction"><abbr title="Guideline">Part of Guideline</abbr>:</span> <span class="pager--item-text-target"><xsl:value-of select="$meta/parent::guideline[1]/name"/></span></span></a></li>
					<xsl:choose>
						<xsl:when test="$meta/preceding-sibling::success-criterion">
							<li class="pager--item previous">
								<a href="{$meta/preceding-sibling::success-criterion[1]/file/@href}">
									<xsl:call-template name="prevnext-previous"/>
									<span class="pager--item-text">
										<span class="pager--item-text-direction">Previous <abbr title="Success Criterion">SC</abbr>:</span> 
										<span class="pager--item-text-target"><xsl:value-of select="$meta/preceding-sibling::success-criterion[1]/name"/></span>
									</span>
								</a>
							</li>
						</xsl:when>
						<xsl:when test="$meta/parent::guideline/preceding-sibling::guideline">
							<li class="pager--item previous">
								<a href="{$meta/parent::guideline/preceding-sibling::guideline[1]/success-criterion[last()]/file/@href}">
									<xsl:call-template name="prevnext-previous"/>
									<span class="pager--item-text">
										<span class="pager--item-text-direction">Previous <abbr title="Success Criterion">SC</abbr>:</span>
										<span class="pager--item-text-target"><xsl:value-of select="$meta/parent::guideline/preceding-sibling::guideline[1]/success-criterion[last()]/name"/></span>
									</span>
								</a>
							</li>
							<li class="pager--item previous">
								<a href="{$meta/parent::guideline/preceding-sibling::guideline[1]/success-criterion[last()]/file/@href}">
									<xsl:call-template name="prevnext-previous"/>
									<span class="pager--item-text">
										<span class="pager--item-text-direction">Previous <abbr title="Success Criterion">SC</abbr>:</span>
										<span class="pager--item-text-target"><xsl:value-of select="$meta/parent::guideline/preceding-sibling::guideline[1]/success-criterion[last()]/name"/></span>
									</span>
								</a>
							</li>
						</xsl:when>
						<xsl:when test="$meta/ancestor::principle/preceding-sibling::principle">
							<li class="pager--item previous"><a href="{$meta/ancestor::principle/preceding-sibling::principle[1]/guideline[last()]/success-criterion[last()]/file/@href}">	<xsl:call-template name="prevnext-previous"/><span class="pager--item-text"><span class="pager--item-text-direction">Previous <abbr title="Success Criterion">SC</abbr>:</span> <span class="pager--item-text-target"><xsl:value-of select="$meta/ancestor::principle/preceding-sibling::principle[1]/guideline[last()]/success-criterion[last()]/name"/></span></span></a></li>
						</xsl:when>
						<xsl:when test="$meta/ancestor::principle/preceding-sibling::understanding">
							<li class="pager--item previous"><a href="{$meta/ancestor::principle/preceding-sibling::understanding[1]/file/@href}"><xsl:call-template name="prevnext-previous"/><span class="pager--item-text"><span class="pager--item-text-direction">Previous: </span><span class="pager--item-text-target"><xsl:value-of select="$meta/ancestor::principle/preceding-sibling::understanding[1]/name"/></span></span></a></li>
						</xsl:when>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="$meta/following-sibling::success-criterion">
							<li class="pager--item next"><a href="{$meta/following-sibling::success-criterion[1]/file/@href}"><xsl:call-template name="prevnext-next"/><span class="pager--item-text"><span class="pager--item-text-direction">Next <abbr title="Success Criterion">SC</abbr>:</span> <span class="pager--item-text-target"><xsl:value-of select="$meta/following-sibling::success-criterion[1]/name"/></span></span></a></li>
						</xsl:when>
						<xsl:when test="$meta/parent::guideline/following-sibling::guideline">
							<li class="pager--item next"><a href="{$meta/parent::guideline/following-sibling::guideline[1]/success-criterion[1]/file/@href}"><xsl:call-template name="prevnext-next"/><span class="pager--item-text"><span class="pager--item-text-direction">Next <abbr title="Success Criterion">SC</abbr>:</span> <span class="pager--item-text-target"><xsl:value-of select="$meta/parent::guideline/following-sibling::guideline[1]/success-criterion[1]/name"/></span></span></a></li>
						</xsl:when>
						<xsl:when test="$meta/ancestor::principle/following-sibling::principle">
							<li class="pager--item next"><a href="{$meta/ancestor::principle/following-sibling::principle[1]/guideline[1]/success-criterion[1]/file/@href}">					<xsl:call-template name="prevnext-next"/><span class="pager--item-text"><span class="pager--item-text-direction">Next <abbr title="Success Criterion">SC</abbr>: </span><span class="pager--item-text-target"><xsl:value-of select="$meta/ancestor::principle/following-sibling::principle[1]/guideline[1]/success-criterion[1]/name"/></span></span></a></li>
						</xsl:when>
						<xsl:when test="$meta/ancestor::principle/following-sibling::understanding">
							<li class="pager--item next"><a href="{$meta/ancestor::principle/following-sibling::understanding[1]/file/@href}"><xsl:call-template name="prevnext-next"/><span class="pager--item-text"><span class="pager--item-text-direction">Next: </span><span class="pager--item-text-target"><xsl:value-of select="$meta/ancestor::principle/following-sibling::understanding[1]/name"/></span></span></a></li>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="name($meta) = 'understanding'">
					<xsl:if test="name($meta/preceding-sibling::element()[1]) = 'understanding'">
						<li class="pager--item previous"><a href="{$meta/preceding-sibling::understanding[1]/file/@href}"><xsl:call-template name="prevnext-previous"/><span class="pager--item-text"><span class="pager--item-text-direction">Previous: </span><span class="pager--item-text-target"><xsl:value-of select="$meta/preceding-sibling::understanding[1]/name"/></span></span></a></li>
					</xsl:if>
					<xsl:if test="name($meta/preceding-sibling::element()[1]) = 'principle'">
						<li class="pager--item previous"><a href="{$meta/preceding-sibling::principle[1]/guideline[last()]/file/@href}"><xsl:call-template name="prevnext-previous"/><span class="pager--item-text-direction"><span class="pager--item-text">Previous Guideline:</span> <span class="pager--item-text-target"><xsl:value-of select="$meta/preceding-sibling::principle[1]/guideline[last()]/name"/></span></span></a></li>
						<li class="pager--item previous"><a href="{$meta/preceding-sibling::principle[1]/guideline[last()]/success-criterion[last()]/file/@href}"><xsl:call-template name="prevnext-previous"/><span class="pager--item-text"><span class="pager--item-text-direction">Previous <abbr title="Success Criterion">SC</abbr>:</span> <span class="pager--item-text-target"><xsl:value-of select="$meta/preceding-sibling::principle[1]/guideline[last()]/success-criterion[last()]/name"/></span></span></a></li>
					</xsl:if>
					<xsl:if test="name($meta/following-sibling::element()[1]) = 'primaar nciple'">
						<li class="pager--item previous"><a href="{$meta/following-sibling::principle[1]/guideline[1]/file/@href}"><xsl:call-template name="prevnext-previous"/><span class="pager--item-text"><span class="pager--item-text-direction">First Guideline: </span><span class="pager--item-text-target"><xsl:value-of select="$meta/following-sibling::principle[1]/guideline[1]/name"/></span></span></a></li>
						<li class="pager--item next"><a href="{$meta/following-sibling::principle[1]/guideline[1]/success-criterion[1]/file/@href}"><xsl:call-template name="prevnext-previous"/><span class="pager--item-text"><span class="pager--item-text-direction">First <abbr title="Success Criterion">SC</abbr>: </span><span class="pager--item-text-target"><xsl:value-of select="$meta/following-sibling::principle[1]/guideline[1]/success-criterion[1]/name"/></span></span></a></li>
					</xsl:if>
					<xsl:if test="name($meta/following-sibling::element()[1]) = 'understanding'">
						<li class="pager--item next"><a href="{$meta/following-sibling::understanding[1]/file/@href}"><xsl:call-template name="prevnext-next"/><span class="pager--item-text"><span class="pager--item-text-direction">Next: </span><span class="pager--item-text-target"><xsl:value-of select="$meta/following-sibling::understanding[1]/name"/></span></span></a></li>
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
				<xsl:if test="name($meta) = 'success-criterion'">
					<li><a href="#intent">Intent</a></li>
					<li><a href="#benefits">Benefits</a></li>
					<xsl:if test="wcag:section-meaningfully-exists('examples', //html:section[@id = 'examples'])"><li><a href="#examples">Examples</a></li></xsl:if>
					<xsl:if test="wcag:section-meaningfully-exists('resources', //html:section[@id = 'resources'])"><li><a href="#resources">Related Resources</a></li></xsl:if>
					<li><a href="#techniques">Techniques</a></li>
					<xsl:if test="$act.doc//func:array[@key = 'successCriteria'][func:string = $meta/@id]">
						<li><a href="#test-rules">Test Rules</a></li>
					</xsl:if>
				</xsl:if>
				<xsl:if test="name($meta) = 'guideline'">
					<li><a href="#intent">Intent</a></li>
					<xsl:if test="wcag:section-meaningfully-exists('gladvisory', //html:section[@id = 'gladvisory'])"><li><a href="#advisory">Advisory Techniques</a></li></xsl:if>
					<li><a href="#success-criteria">Success Criteria</a></li>
				</xsl:if>
				<xsl:if test="name($meta) = 'understanding'">
					<xsl:for-each select="//html:body/html:section">
						<li>
							<a>
								<xsl:attribute name="href">
									<xsl:choose>
										<xsl:when test="@id">#<xsl:value-of select="@id"/></xsl:when>
										<xsl:otherwise>#<xsl:value-of select="wcag:generate-id(wcag:find-heading(.))"/></xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
								<xsl:value-of select="wcag:find-heading(.)"/>
							</a>
						</li>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="//html:a[not(@href)] | $meta/content/descendant::html:a[not(@href)]">
					<li><a href="#key-terms">Key Terms</a></li>
				</xsl:if>
			</ul>
		</nav>
	</xsl:template>
	

	<xsl:template name="prevnext-previous">
		<svg focusable="false" aria-hidden="true" class="icon-arrow-left pager--item-icon" viewBox="0 0 25 28">
			<path d="M24 14v2c0 1.062-0.703 2-1.828 2h-11l4.578 4.594c0.375 0.359 0.594 0.875 0.594 1.406s-0.219 1.047-0.594 1.406l-1.172 1.188c-0.359 0.359-0.875 0.578-1.406 0.578s-1.047-0.219-1.422-0.578l-10.172-10.187c-0.359-0.359-0.578-0.875-0.578-1.406s0.219-1.047 0.578-1.422l10.172-10.156c0.375-0.375 0.891-0.594 1.422-0.594s1.031 0.219 1.406 0.594l1.172 1.156c0.375 0.375 0.594 0.891 0.594 1.422s-0.219 1.047-0.594 1.422l-4.578 4.578h11c1.125 0 1.828 0.938 1.828 2z"/>
		</svg>
	</xsl:template>

	<xsl:template name="prevnext-next">
		<svg focusable="false" aria-hidden="true" class="icon-arrow-right pager--item-icon" viewBox="0 0 23 28">
			<path d="M23 15c0 0.531-0.203 1.047-0.578 1.422l-10.172 10.172c-0.375 0.359-0.891 0.578-1.422 0.578s-1.031-0.219-1.406-0.578l-1.172-1.172c-0.375-0.375-0.594-0.891-0.594-1.422s0.219-1.047 0.594-1.422l4.578-4.578h-11c-1.125 0-1.828-0.938-1.828-2v-2c0-1.062 0.703-2 1.828-2h11l-4.578-4.594c-0.375-0.359-0.594-0.875-0.594-1.406s0.219-1.047 0.594-1.406l1.172-1.172c0.375-0.375 0.875-0.594 1.406-0.594s1.047 0.219 1.422 0.594l10.172 10.172c0.375 0.359 0.578 0.875 0.578 1.406z"/>		
		</svg>
	</xsl:template>

	<xsl:template name="gl-sc">
		<xsl:param name="meta" tunnel="yes"/>
		<section id="success-criteria">
			<details>
			<summary><h2>Success Criteria for this Guideline</h2></summary>
			<ul>
				<xsl:for-each select="$meta/success-criterion">
					<li><a href="{file/@href}"><xsl:value-of select="num"/><xsl:text> </xsl:text><xsl:value-of select="name"/></a></li>
				</xsl:for-each>
			</ul>
			</details>
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
		<xsl:if test="//html:a[not(@href)] | $meta/content/descendant::html:a[not(@href)]">
			<xsl:variable name="termrefs">
				<xsl:sequence>
					<xsl:apply-templates select="//html:a[not(@href)] | $meta/content/descendant::html:a[not(@href)]" mode="find-key-terms"/>
				</xsl:sequence>
			</xsl:variable>
			<xsl:variable name="termids" as="node()*">
				<xsl:for-each select="distinct-values($termrefs/name)">
					<xsl:copy-of select="$meta/ancestor::guidelines/term[name = current()]"/>
				</xsl:for-each>
			</xsl:variable>
				<xsl:apply-templates select="$termids" mode="key-terms">
					<xsl:sort select="id"/>
				</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="act">
		<xsl:param name="meta" tunnel="yes"/>
		
		<xsl:if test="$act.doc//func:array[@key = 'successCriteria'][func:string = $meta/@id]">
			<section id="test-rules">
				<details>
				<summary><h2>Test Rules</h2></summary>
				<p>The following are Test Rules for certain aspects of this Success Criterion. It is not necessary to use these particular Test Rules to check for conformance with WCAG, but they are defined and approved test methods. For information on using Test Rules, see <a href="understanding-act-rules.html">Understanding Test Rules for WCAG Success Criteria</a>.</p>
				<ul>
					<xsl:for-each select="$act.doc//func:array[@key = 'successCriteria']/func:string[. = $meta/@id]">
						<li><a href="/WAI{ancestor::func:map/func:string[@key = 'permalink']}"><xsl:value-of select="ancestor::func:map/func:string[@key = 'title']"/></a></li>
					</xsl:for-each>
				</ul>
				</details>
			</section>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="html:a[not(@href)]" mode="find-key-terms" priority="1">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:param name="list-so-far"></xsl:param>
		<xsl:variable name="canonical-name" select="$meta/ancestor::guidelines/term[name = lower-case(normalize-space(current()))]/name[1]"/>
		<xsl:choose>
			<xsl:when test="empty($canonical-name)">
				<xsl:message>Unable to find term "<xsl:value-of select="."/>" in "<xsl:value-of select="$meta/name"/> (<xsl:value-of select="$meta/name()"/>)"; key terms list will be incomplete.</xsl:message>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence><xsl:copy-of select="$canonical-name"/></xsl:sequence>
				<xsl:if test="not(index-of($list-so-far, $canonical-name))">
					<xsl:apply-templates select="$meta/ancestor::guidelines/term[name = $canonical-name]//html:a[not(@href)]" mode="find-key-terms">
						<xsl:with-param name="list-so-far" select="($list-so-far, $canonical-name)"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="term" mode="key-terms">
		<dd id="{id}"><xsl:value-of select="name[1]"/></dd>
		<!-- <dd><xsl:apply-templates select="definition"/></dd> -->
	</xsl:template>
	
	<xsl:template match="guidelines">
		<!--<xsl:result-document href="wcag-act-rules.xml"><xsl:apply-templates select="$act.doc/*"/></xsl:result-document>-->
		<xsl:apply-templates select="//understanding | //guideline | //success-criterion"/>
	</xsl:template>
	
	<xsl:template match="understanding | guideline | success-criterion">
		<xsl:result-document href="{$output.dir}/{file/@href}.html" encoding="utf-8" exclude-result-prefixes="#all" include-content-type="no" indent="yes" method="xhtml" omit-xml-declaration="yes">
			<xsl:apply-templates select="document(resolve-uri(concat(file/@href, '.html'), concat($base.dir, max($versions.doc//id[@id = current()/@id]/parent::version/@name), '/')))">
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
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<title><xsl:apply-templates select="//html:title"/></title>
		    <link rel="stylesheet" href="https://w3.org/WAI/assets/css/style.css" />
				<link rel="stylesheet" href="base.css" />
			</head>
			<body dir="ltr">
				<xsl:call-template name="header">
					<xsl:with-param name="documentset.name">Understanding</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="navigation">
					<xsl:with-param name="documentset.name">Understanding</xsl:with-param>
				</xsl:call-template>
				<div class="default-grid">
					<main class="main-content">
						<h1><xsl:apply-templates select="//html:h1"/></h1>
						<xsl:choose>
							<xsl:when test="name($meta) = 'guideline' or name($meta) = 'success-criterion'">
								<blockquote class="scquote">
									<xsl:apply-templates select="$meta/content/html:p[1]" mode="sc-info">
										<xsl:with-param name="sc-info"><xsl:call-template name="sc-info"/></xsl:with-param>
									</xsl:apply-templates>
									<xsl:apply-templates select="$meta/content/html:*[position() &gt; 1]" mode="sc-info"/>
								</blockquote>
								<xsl:apply-templates select="//html:section[@id = 'status']"/>
								<xsl:apply-templates select="//html:section[@id = 'intent']"/>
								<xsl:apply-templates select="//html:section[@id = 'benefits']"/>
								<xsl:apply-templates select="//html:section[@id = 'examples']"/>
								<xsl:apply-templates select="//html:section[@id = 'resources']"/>
								<xsl:apply-templates select="//html:section[@id = 'techniques']"/>
								<xsl:if test="name($meta) = 'guideline'">
									<xsl:apply-templates select="//html:section[@id = 'advisory']" mode="gladvisory"/>
									<xsl:call-template name="gl-sc"/>
								</xsl:if>
							</xsl:when>
							<xsl:when test="name($meta) = 'understanding'">
								<div>
									<xsl:apply-templates select="descendant::html:body/node()[not(wcag:isheading(.))]"/>
									<xsl:call-template name="key-terms"/>
								</div>
							</xsl:when>
						</xsl:choose>
						<xsl:call-template name="prevnext"/>
						<xsl:call-template name="back-to-top"/>
					</main>
					<xsl:call-template name="sidebar"/>
					<xsl:call-template name="help-improve"/>
				</div>
				<xsl:call-template name="wai-site-footer"/>
				<xsl:call-template name="site-footer"/>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template name="sidebar">
		<xsl:param name="meta" tunnel="yes"/>
  	<aside class="your-report your-report--expanded sidebar" aria-labelledby="about-this-page">
			<h2 style="margin-top: 0" id="about-this-page">About this page</h2>
			<p><em>Understanding documents</em> explain intent, benefits, examples and key terms for WCAG success criteria.</p>
			<dl>
				<xsl:if test="string-length($meta/level) > 0">
				<dt>Level</dt>
				<dd><xsl:value-of select="$meta/level"/></dd>
				</xsl:if>
				<xsl:if test="//html:a[not(@href)] | $meta/content/descendant::html:a[not(@href)]">
					<dt>Key terms</dt>
					<xsl:call-template name="key-terms"/>
				</xsl:if>
			</dl>
		</aside>
	</xsl:template>

	<xsl:template match="html:title">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:if test="name($meta) != 'understanding'">Understanding </xsl:if><xsl:call-template name="name"/>
	</xsl:template>
	
	<xsl:template match="html:h1">
		<xsl:param name="meta" tunnel="yes"/>
		<xsl:if test="name($meta) != 'understanding'"><span class="standalone-resource__type-of-guidance">Understanding:</span> </xsl:if><xsl:call-template name="name"/>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'intent']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<details>
			<summary><h2>Intent</h2></summary>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.) or @id = 'benefits')]"/>
			</details>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'benefits']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<details>
			<summary><h2>Benefits</h2></summary>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
			</details>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'examples']">
		<xsl:if test="wcag:section-meaningfully-exists('examples', .)">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<details>
			<summary><h2>Examples</h2></summary>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
			</details>
		</xsl:copy>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'resources']">
		<xsl:if test="wcag:section-meaningfully-exists('resources', .)">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<details>
			<summary><h2>Related Resources</h2></summary>
			<p>Resources are for information purposes only, no endorsement implied.</p>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
			</details>
		</xsl:copy>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'techniques']">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<details>
			<summary><h2>Techniques</h2></summary>
			<p>Each numbered item in this section represents a technique or combination of techniques that the WCAG Working Group deems sufficient for meeting this Success Criterion. However, it is not necessary to use these particular techniques. For information on using other techniques, see <a href="understanding-techniques">Understanding Techniques for WCAG Success Criteria</a>, particularly the "Other Techniques" section.</p>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
			</details>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'sufficient']">
		<xsl:if test="wcag:section-meaningfully-exists('sufficient', .)">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<h3>Sufficient Techniques</h3>
			<xsl:if test="html:section[@class = 'situation']"><p>Select the situation below that matches your content. Each situation includes techniques or combinations of techniques that are known and documented to be sufficient for that situation. </p></xsl:if>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'advisory']">
		<xsl:if test="wcag:section-meaningfully-exists('advisory', .)">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<h3>Advisory Techniques</h3>
			<p>Although not required for conformance, the following additional techniques should be considered in order to make content more accessible. Not all techniques can be used or would be effective in all situations.</p>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'advisory']" mode="gladvisory">
		<xsl:if test="wcag:section-meaningfully-exists('gladvisory', .)">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<details>
			<summary><h2>Advisory Techniques</h2></summary>
			<p>Specific techniques for meeting each Success Criterion for this guideline are listed in the understanding sections for each Success Criterion (listed below). If there are techniques, however, for addressing this guideline that do not fall under any of the success criteria, they are listed here. These techniques are not required or sufficient for meeting any success criteria, but can make certain types of Web content more accessible to more people.</p>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
			</details>
		</xsl:copy>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'failure']">
		<xsl:if test="wcag:section-meaningfully-exists('failure', .)">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<h3>Failures</h3>
			<p>The following are common mistakes that are considered failures of this Success Criterion by the WCAG Working Group.</p>
			<xsl:apply-templates select="html:*[not(wcag:isheading(.))]"/>
		</xsl:copy>
		</xsl:if>
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
		<a href="#{$meta/ancestor::guidelines/term[name = $dfn]/id}"><xsl:value-of select="."/></a>
	</xsl:template>
	
	<xsl:template match="html:*[@class = 'instructions']"/>
	
</xsl:stylesheet>