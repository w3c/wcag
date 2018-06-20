<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns="http://www.w3.org/1999/xhtml" 
	exclude-result-prefixes="#all"
	version="2.0">

	<xsl:import href="xmlspec-wcag-howto.xsl"/>
	<xsl:param name="pubtarget">editors</xsl:param>
	<xsl:param name="expandable"></xsl:param>
	<xsl:param name="publoc.main">
		<xsl:value-of select="//html:dd[@id = 'publoc.tr']"/>
		<!--
		<xsl:choose>
			<xsl:when test="$pubtarget = 'tr'"><xsl:value-of select="//html:dd[@id = 'publoc.tr']"/></xsl:when>
			<xsl:when test="$pubtarget = 'editors'"><xsl:value-of select="//html:dd[@id  = 'publoc.editors']"/></xsl:when>
		</xsl:choose>
		-->
	</xsl:param>
	<xsl:param name="publoc.accordion">
		<xsl:value-of select="concat(//html:dd[@id = 'publoc.editors'], 'accordion')"/>
	</xsl:param>
	<xsl:variable name="expandable.bool" select="boolean($expandable)"/>
	<xsl:variable name="wcag2ict-doc" select="."/>
	
	<xsl:output method="xhtml" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
	
	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="html:head">
		<xsl:copy>
			<xsl:if test="$expandable.bool"><script type="text/javascript" src="/WAI/scripts/excol/excol.js"></script></xsl:if>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'wcag2ict_comments_principles-guidelines-sc']">
		<div>
			<xsl:apply-templates select="node()[not(name() = 'section')]|@*"/>
			<!-- Switch to processing off the guidelines, using the main doc just for data -->
			<xsl:choose>
				<xsl:when test="$expandable.bool">
					<div class="f_controls_accordion f_fileToLoad_accordionControls"></div>
					<div id="accordion" class="accordionWrapper">
						<xsl:apply-templates select="$gl-src//div2[@role='principle']"/>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="$gl-src//div2[@role='principle']"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>
	
	<!-- Main sections of the document -->
	<!-- section for principle -->
	<xsl:template match="div2[@role='principle']">
		<div id="{@id}" class="guideline">
			<h3><xsl:value-of select="substring-before(head, '-')"/></h3>
			<p>From <a href="{$gl-src//publoc/loc}#{@id}">Principle <xsl:number level="single" count="div2" format="1"/></a>:</p>
			<blockquote cite="{$gl-src//publoc/loc}#{@id}" class="principle">
				<p><xsl:value-of select="substring-after(head, '-')"/></p>
			</blockquote>
			<div class="wcag2ict" id="wcag2ict_{@id}">
				<xsl:variable name="wcag2ict" select="$wcag2ict-doc//html:section[@id = current()/@id]/html:*[not(name() = 'h2' or name() = 'section')]"/>
				<h4>Additional Guidance When Applying Principle <xsl:number level="multiple" count="div2" format="1"/> to Non-Web Documents and Software:</h4>
				<xsl:choose>
					<xsl:when test="count($wcag2ict) > 0"><xsl:apply-templates select="$wcag2ict"/></xsl:when>
					<xsl:otherwise><p> In WCAG 2.0, the Principles are provided for framing and understanding the success criteria under them but are not required for conformance to WCAG. Principle <xsl:number level="single" count="div2" format="1"/> applies directly as written.</p></xsl:otherwise>
				</xsl:choose>
			</div>
			<xsl:apply-templates select="div3"/>
		</div>
	</xsl:template>
	
	<!-- section for guideline -->
	<xsl:template match="div3">
		<div id="{@id}" class="principle">
			<h4><xsl:call-template name="gl-name"/></h4>
			<p>From <a href="{$gl-src//publoc/loc}#{@id}">Guideline <xsl:number level="multiple" count="div2 | div3" format="1.1"/></a>:</p>
			<blockquote cite="{$gl-src//publoc/loc}#{@id}" class="gl">
				<p><xsl:value-of select="head"/></p>
			</blockquote>
			<div class="wcag2ict" id="wcag2ict_{@id}">
				<xsl:variable name="wcag2ict" select="$wcag2ict-doc//html:section[@id = current()/@id]/html:*[not(name() = 'h3' or name() = 'section')]"/>
				<h5>Additional Guidance When Applying Guideline <xsl:number level="multiple" count="div2 | div3" format="1.1"/> to Non-Web Documents and Software:</h5>
				<xsl:choose>
					<xsl:when test="count($wcag2ict) > 0"><xsl:apply-templates select="$wcag2ict"/></xsl:when>
					<xsl:otherwise><p>In WCAG 2.0, the Guidelines are provided for framing and understanding the success criteria under them but are not required for conformance to WCAG. Guideline <xsl:number level="multiple" count="div2 | div3" format="1.1"/> applies directly as written.</p></xsl:otherwise>
				</xsl:choose>
			</div>
			<p>
				<xsl:if test="$expandable.bool">
					<xsl:attribute name="class">f_panelHead</xsl:attribute>
				</xsl:if>
				<xsl:text>Intent from </xsl:text>
				<a href="{$guide-src//publoc/loc}{@id}#{@id}-intent">Understanding Guideline <xsl:number level="multiple" count="div2 | div3" format="1.1"/> in Understanding WCAG 2.0</a>
				<xsl:text> (</xsl:text>
				<xsl:choose>
					<xsl:when test="$expandable.bool">
						<a>
							<xsl:attribute name="href"><xsl:value-of select="$publoc.main"/>#<xsl:value-of select="@id"/></xsl:attribute>
							<xsl:text>View full version of guidance for Guideline </xsl:text>
							<xsl:number level="multiple" count="div2 | div3" format="1.1"/>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<a>
							<xsl:attribute name="href"><xsl:value-of select="$publoc.accordion"/>#<xsl:value-of select="@id"/></xsl:attribute>
							<xsl:text>View collapsible version of guidance for Guideline </xsl:text>
							<xsl:number level="multiple" count="div2 | div3" format="1.1"/>
						</a>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>):</xsl:text>
			</p>
			<blockquote cite="{$guide-src//publoc/loc}{@id}#{@id}-intent" class="gl intent">
				<xsl:apply-templates select="$guide-src//div1[@id = current()/@id]/div2[@role = 'glintent']/*[not(name() = 'head')]"/>
			</blockquote>
				<xsl:apply-templates select="div4/div5[@role = 'sc']"/>
		</div>
	</xsl:template>
	
	<!-- section for success criterion -->
	<xsl:template match="div5[@role = 'sc']">
		<!-- Skip AAA SC -->
		<xsl:if test="../@role != 'additional'">
		<div id="{@id}" class="sc">
			<h5>
				<xsl:call-template name="sc-name"/>
			</h5>
			<div>
				<p>From <a href="{$gl-src//publoc/loc}#{@id}">Success Criterion <xsl:call-template name="sc-number"><xsl:with-param name="criterion" select="."/></xsl:call-template></a>:</p>
				<blockquote cite="{$gl-src//publoc/loc}#{@id}" class="sc">
					<xsl:apply-templates select="*[not(name() = 'head')]"/>
				</blockquote>
				<div class="wcag2ict" id="wcag2ict_{@id}">
					<xsl:variable name="wcag2ict" select="$wcag2ict-doc//html:section[@id = current()/@id]/html:*[not(name() = 'h4') or name() = 'section']"/>
					<h6>Additional Guidance When Applying Success Criterion <xsl:call-template name="sc-number"><xsl:with-param name="criterion" select="."/></xsl:call-template> to Non-Web Documents and Software:</h6>
					<xsl:choose>
						<!-- copy content through if it's been provided -->
						<xsl:when test="count($wcag2ict) > 0"><xsl:apply-templates select="$wcag2ict"/></xsl:when>
						<!-- AAA SC haven't been reviewed yet -->
						<xsl:when test="../@role = 'additional'"><p><em>The WCAG2ICT Task Force has not yet reviewed Level AAA Success Criteria including Success Criterion <xsl:call-template name="sc-number"><xsl:with-param name="criterion" select="."/></xsl:call-template>.</em></p></xsl:when>
						<!-- guidance for SC not provided yet -->
						<xsl:otherwise><p><em>The WCAG2ICT Task Force has not yet produced additional guidance for Success Criterion <xsl:call-template name="sc-number"><xsl:with-param name="criterion" select="."/></xsl:call-template>.</em></p></xsl:otherwise>
					</xsl:choose>
				</div>
				<p>
					<xsl:if test="$expandable.bool">
						<xsl:attribute name="class">f_panelHead</xsl:attribute>
					</xsl:if>
					<xsl:text>Intent from </xsl:text> 
					<a href="{$guide-src//publoc/loc}{@id}#{@id}-intent-head">Understanding Success Criterion <xsl:call-template name="sc-number"><xsl:with-param name="criterion" select="."/></xsl:call-template> in Understanding WCAG 2.0</a>
					<xsl:text> (</xsl:text>
					<xsl:choose>
						<xsl:when test="$expandable.bool">
							<a>
								<xsl:attribute name="href"><xsl:value-of select="$publoc.main"/>#<xsl:value-of select="@id"/></xsl:attribute>
								<xsl:text>View full version of guidance for Success Criterion </xsl:text>
								<xsl:call-template name="sc-number"><xsl:with-param name="criterion" select="."/></xsl:call-template>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<a>
								<xsl:attribute name="href"><xsl:value-of select="$publoc.accordion"/>#<xsl:value-of select="@id"/></xsl:attribute>
								<xsl:text>View collapsible version of guidance for Success Criterion </xsl:text>
								<xsl:call-template name="sc-number"><xsl:with-param name="criterion" select="."/></xsl:call-template>
							</a>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>):</xsl:text>
				</p>
				<blockquote cite="{$guide-src//publoc/loc}{@id}#{@id}-intent-head" class="sc intent">
					<xsl:apply-templates select="$guide-src//div2[@id = current()/@id]/div3[@role = 'intent']/*[not(name() = 'head')]"/>
				</blockquote>
			</div>
		</div>
		</xsl:if>
	</xsl:template>

	<!-- Glossary items with specific guidance -->
	<xsl:template match="html:section[@id = 'wcag2ict_comments_definitions_guidance']/html:section">
		<xsl:variable name="gitem" select="$gl-src//gitem[@id = current()/@id]"/>
		<div id="{@id}" class="glossary">
			<xsl:apply-templates select="@*"/>
			<h4><xsl:value-of select="$gitem/label"/></h4>
			<p>From the <a href="{$gl-src//publoc/loc}#{@id}">WCAG 2.0 definition for <xsl:value-of select="$gitem/label"/></a>:</p>
			<blockquote cite="{$gl-src//publoc/loc}#{@id}" class="gitem">
				<xsl:apply-templates select="$gitem/def/*"/>				
			</blockquote>
			<div class="wcag2ict" id="wcag2ict_{@id}">
				<h5>Additional Guidance When Applying the Definition of “<xsl:value-of select="$gitem/label"/>” to Non-Web Documents and Software:</h5>
				<xsl:apply-templates select="html:*[not(name() = 'h4')]"/>
			</div>
		</div>
	</xsl:template>
	
	<!-- Names for consistency across this doc -->
	<!-- name for guideline -->
	<xsl:template name="gl-name">
		Guideline <xsl:number level="multiple" count="div2 | div3" format="1.1"/>
		<xsl:text>: </xsl:text>
		<xsl:call-template name="sc-handle">
			<xsl:with-param name="handleid" select="@id"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- name for success criterion -->
	<xsl:template name="sc-name">
		<xsl:text>Success Criterion </xsl:text>
		<xsl:call-template name="sc-number"><xsl:with-param name="criterion" select="."/></xsl:call-template>
		<xsl:text>: </xsl:text>
		<xsl:value-of select="head"/>
		<xsl:text> (Level </xsl:text>
		<xsl:choose>
			<xsl:when test="../@role = 'req'">A</xsl:when>
			<xsl:when test="../@role = 'bp'">AA</xsl:when>
			<xsl:when test="../@role = 'additional'">AAA</xsl:when>
		</xsl:choose>
		<xsl:text>)</xsl:text>
	</xsl:template>
	
	
	<!-- TOC -->
	<xsl:template match="html:section[@id = 'toc']">
		<div id="toc">
			<h2 class="introductory">Table of Contents</h2>
			<ul class="toc">
				<xsl:apply-templates select="/html:html/html:body/html:section" mode="toc"/>
			</ul>
		</div>
	</xsl:template>
	
	<!-- TOC entry for section in guidance doc -->
	<xsl:template match="html:section" mode="toc">
		<li class="tocline">
			<xsl:if test="not(parent::html:section or @class = 'introductory')">
				<xsl:call-template name="secno"/>
			</xsl:if>
			<a href="#{@id}" class="tocxref">
				<xsl:apply-templates select="html:h1 | html:h2 | html:h3 | html:h4 | html:h5 | html:h6" mode="toc"/>
			</a>
			<xsl:variable name="subtoc">
				<xsl:choose>
					<xsl:when test="@id = 'wcag2ict_comments_principles-guidelines-sc'">
						<xsl:apply-templates select="$gl-src//div2[@role='principle']" mode="toc"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="html:section" mode="toc"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="$subtoc/html:li">
				<ul class="toc">
					<xsl:copy-of select="$subtoc"/>
				</ul>
			</xsl:if>
		</li>
	</xsl:template>
	
	<xsl:template match="html:section[@id = 'toc']" mode="toc"/>
	
	<xsl:template match="html:h1 | html:h2 | html:h3 | html:h4 | html:h5 | html:h6" mode="toc">
		<xsl:apply-templates mode="toc"/>
	</xsl:template>
	
	<xsl:template match="html:span[@class='secno']" mode="#all"/>
	
	<!-- TOC entry for principle -->
	<xsl:template match="div2[@role='principle']" mode="toc">
		<li class="tocline">
			<a href="#{@id}" class="tocxref"><xsl:value-of select="substring-before(head, '-')"/></a>
			<ul class="toc">
				<xsl:apply-templates select="div3" mode="toc"/>
			</ul>
		</li>
	</xsl:template>
	
	<!-- TOC entry for guideline -->
	<xsl:template match="div3" mode="toc">
		<li class="tocline">
			<a href="#{@id}" class="tocxref"><xsl:call-template name="gl-name"/></a>
			<ul class="toc">
				<xsl:apply-templates select="div4[not(@role = 'additional')]/div5[@role = 'sc']" mode="toc"></xsl:apply-templates>
			</ul>
		</li>
	</xsl:template>
	
	<!-- TOC entry for success criterion -->
	<xsl:template match="div5[@role = 'sc']" mode="toc">
		<li class="tocline">
			<a href="#{@id}" class="tocxref">
				<xsl:call-template name="sc-name"/>
			</a>
		</li>		
	</xsl:template>
	
 	<!-- override imported templates -->
	<xsl:template match="p[@role='i'] | p[@role='v']">
		<p><xsl:apply-templates/></p>
	</xsl:template>
	
	<xsl:template match="div3[@role = 'intent']/div4">
		<xsl:variable name="id">
			<xsl:choose>
				<xsl:when test="../@id"><xsl:value-of select="ancestor::div2/@id"/>-<xsl:value-of select="../@id"/>-head</xsl:when>
				<xsl:otherwise><xsl:value-of select="ancestor::div2/@id"/>-<xsl:value-of select="count(preceding::div4) +1"/>-head</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div id="{$id}">
			<xsl:if test="@role">
				<xsl:attribute name="class" select="@role"/>
			</xsl:if>
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	
	<xsl:template match="div3[@role = 'intent']/div4/head">
		<h6><xsl:apply-templates/></h6>
	</xsl:template>

	<xsl:template match="div3[@role = 'intent']/div4[@role = 'benefits']/head" priority=".6">
		<xsl:variable name="criteriontype"> 
			<xsl:choose>
				<xsl:when test="../../../@role='cc'">Conformance</xsl:when>
				<xsl:otherwise>Success</xsl:otherwise>
			</xsl:choose>
		</xsl:variable> 
		<h6>Specific Benefits of <xsl:value-of select="$criteriontype" /> Criterion <xsl:call-template name="sc-number"><xsl:with-param name="id" select="../../../@id"/></xsl:call-template></h6>
	</xsl:template>
	
	<!-- get bibref to point to right place -->
	<!--
	<xsl:template match="bibref">
		<a>
			<xsl:attribute name="href"><xsl:value-of select="concat(ancestor::spec/header/publoc/loc, 'appendixD')"/><xsl:call-template name="href.target"><xsl:with-param name="target" select="key('ids', @ref)"/></xsl:call-template></xsl:attribute>
			<xsl:text>[</xsl:text>
			<xsl:choose>
				<xsl:when test="key('ids', @ref)/@key">
					<xsl:value-of select="key('ids', @ref)/@key"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@ref"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>]</xsl:text>
		</a>
	</xsl:template>
	-->
	
	<!-- override href.target so cross references get an absolute URL for bibref and specref; modified from version in slices-understanding-common.xsl -->
	<xsl:template name="href.target">
		<xsl:param name="target" select="."/>
		<xsl:variable name="slice" select="($target/ancestor-or-self::div1 | $target/ancestor-or-self::inform-div1  | $target/ancestor-or-self::div2   | $target/ancestor-or-self::div3 | $target/ancestor-or-self::spec)[last()]"/>
		
		<xsl:choose>
			<xsl:when test="ancestor::spec/header/w3c-designation = 'WCAG20'">
				<xsl:value-of select="ancestor::spec/header/publoc/loc/@href"/>
				<xsl:text>#</xsl:text>
				<xsl:value-of select="$target/@id"/>
			</xsl:when>
			<xsl:when test="ancestor::spec/header/w3c-designation = 'UNDERSTANDING-WCAG20'">
				<xsl:value-of select="ancestor::spec/header/publoc/loc/@href"/>
				<xsl:apply-templates select="$slice" mode="slice-understanding-filename"/>
				<xsl:if test="$target != $slice">
					<xsl:text>#</xsl:text>
					<xsl:value-of select="$target/@id"/>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- make an absolute url for internal cross references created with loc -->
	<!-- this is fragile because sometimes div3 is the level for a file target, and sometimes div2 is; it differentiates by presence of @id which seems not to be present on levels we don't want to generate files from -->
	<xsl:template match="loc[starts-with(@href, '#')]">
		<a>
			<xsl:attribute name="href">
				<xsl:call-template name="href.target">
					<xsl:with-param name="target" select="(ancestor-or-self::div1 | ancestor-or-self::inform-div1  | ancestor-or-self::div2   | ancestor-or-self::div3 | ancestor-or-self::spec)[@id][last()]"></xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="@href"/>
			</xsl:attribute>
			<xsl:apply-templates/>
		</a>
	</xsl:template>
	
	<!-- make an absolute url for local references -->
	<!-- this really is special casing a link to relativeluminance.xml -->
	<!-- there's probably a more elegant way to handle this, but oh well -->
	<xsl:template match="loc[not(@linktype) and not(starts-with(@href, 'http:') or starts-with(@href, '/')) and ancestor::spec/header/w3c-designation = 'WCAG20']">
		<a>
			<xsl:attribute name="href">
				<xsl:value-of select="ancestor::spec/header/publoc/loc/@href"/>
				<xsl:value-of select="@href"/>
			</xsl:attribute>
			<xsl:apply-templates/>
		</a>
	</xsl:template>
	
	<!-- remove deleted content from quotes -->
	<xsl:template match="*[@diff = 'del']"/>

	<!-- copy content from main doc --> 
	<xsl:template match="html:*|@*"><xsl:copy><xsl:apply-templates select="node()|@*"/></xsl:copy></xsl:template>
	
	<xsl:template match="html:section">
		<div>
			<xsl:apply-templates select="@*"/>
			<!--<xsl:attribute name="class">accordionWrapper</xsl:attribute>-->
			<xsl:apply-templates select="html:h1 | html:h2 | html:h3 | html:h4 | html:h5 | html:h6"/>
			<!--<div>-->
				<xsl:apply-templates select="node()[not(name() = 'h1' or name() = 'h2' or name() = 'h3' or name() = 'h4' or name() = 'h5' or name() = 'h6')]"/>
			<!--</div>-->
		</div>
	</xsl:template>
	
	<xsl:template match="html:h1 | html:h2 | html:h3 | html:h4 | html:h5 | html:h6">
		<xsl:copy>
			<!--<xsl:attribute name="class">f_panelHead</xsl:attribute>-->
			<xsl:apply-templates select="@*"/>
			<xsl:if test="count(ancestor::html:section) &lt;= 2">
				<xsl:call-template name="secno">
					<xsl:with-param name="section" select="parent::html:section"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template name="secno">
		<xsl:param name="section" select="self::html:section"/>
		<xsl:if test="$section and not($section/@class = 'introductory')">
			<span class="secno">
				<xsl:choose>
					<xsl:when test="$section/ancestor-or-self::html:section[last()]/@class = 'appendix'">
						<xsl:text>Appendix </xsl:text>
						<xsl:number level="multiple" count="html:section[@class='appendix']" format="A.1. "/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:number level="multiple" count="html:section[not(@class = 'introductory')]" format="1.1. "/>
					</xsl:otherwise>
				</xsl:choose>
			</span>
		</xsl:if>
	</xsl:template>
	
	<!-- stick a cite element into term reference links -->
	<xsl:template match="html:a[@class = 'termref' or @class = 'wcag2ict_termref'][not(ancestor::html:blockquote)]">
		<xsl:copy>
			<xsl:apply-templates select="@href | @class"/>
			<xsl:attribute name="title">
				<xsl:choose>
					<xsl:when test="@class = 'termref'">WCAG Definition: </xsl:when>
					<xsl:when test="@class = 'wcag2ict_termref'">WCAG2ICT Definition: </xsl:when>
				</xsl:choose>
				<xsl:value-of select="."/>
			</xsl:attribute>
			<cite><xsl:apply-templates/></cite>
		</xsl:copy>
	</xsl:template>
	
	<!-- Set links to WCAG20 to go to dated URL -->
	<xsl:template match="@href[starts-with(., 'http://www.w3.org/WAI/GL/WCAG20/')]">
		<xsl:attribute name="href">
			<xsl:value-of select="$gl-src/spec/header/publoc/loc"/>
			<xsl:value-of select="substring-after(., 'http://www.w3.org/WAI/GL/WCAG20/')"/>
		</xsl:attribute>
	</xsl:template>
	
	<!-- Set links to Understanding to go to currently used dated URL -->
	<xsl:template match="@href[starts-with(., 'http://www.w3.org/WAI/GL/UNDERSTANDING-WCAG20/')]">
		<xsl:attribute name="href">
			<xsl:value-of select="$guide-src/spec/header/publoc/loc"/>
			<xsl:value-of select="substring-after(., 'http://www.w3.org/WAI/GL/UNDERSTANDING-WCAG20/')"/>
		</xsl:attribute>
	</xsl:template>
	
	<!-- Set links to Techniques to go to dated URL -->
	<xsl:template match="@href[starts-with(., 'http://www.w3.org/WAI/GL/WCAG20-TECHS/')]">
		<xsl:attribute name="href">
			<xsl:value-of select="$techs-src/spec/header/publoc/loc"/>
			<xsl:value-of select="substring-after(., 'http://www.w3.org/WAI/GL/WCAG20-TECHS/')"/>
		</xsl:attribute>
	</xsl:template>
	
	<!-- output elements appropriately to the current publication target -->
	<xsl:template match="html:*[starts-with(@class, 'pubtarget')]">
		<xsl:if test="substring-after(@class, '.') = $pubtarget"><xsl:copy><xsl:apply-templates select="node()|@*[not(name() = 'class')]"/></xsl:copy></xsl:if>
	</xsl:template>
	
	<xsl:template match="html:style/text()"><xsl:value-of select="." disable-output-escaping="yes"/></xsl:template>
	
</xsl:stylesheet>