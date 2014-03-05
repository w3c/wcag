<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:wcag="http://www.w3.org/WAI/GL/"
	version="2.0">
	
	<xsl:output method="text"/>
	
	<xsl:param name="understanding.file">../guide-to-wcag2-src.xml</xsl:param>
	<xsl:param name="techniques.file">../wcag2-merged-techs.xml</xsl:param>
	
	<xsl:param name="understanding.doc" select="document($understanding.file)"/>
	<xsl:param name="techniques.doc" select="document($techniques.file)"/>
	
	<xsl:param name="guidelines.specId">@@guidelines</xsl:param>
	<xsl:param name="understanding.specId">@@understanding</xsl:param>
	<xsl:param name="techniques.specId">@@techniques</xsl:param>
	
	<xsl:template match="/">
/* These SQL statements input the sections of WCAG specs under review into the W3C comment tracker. Apply these statements to the 'misc' database. If params weren't set in the XSLT, search and replace the document ID (starting with @@) first. The proper ID is usually the final path segment of the dated TR URI. 

/* GUIDELINES */
REPLACE INTO specSections (id, title, specId, rank) VALUES 
<xsl:apply-templates select="//front/div1 | //front/div1/div2 | //div2[@role='principle'] | //div3[@role='group1'] | //div3[@role='group2'] | //div4[@role='req']/div5 | //div4[@role='bp']/div5 | //div4[@role='additional']/div5 | //div1[@role = 'normative'] | //back//gitem" mode="guidelines"/>

/* UNDERSTANDING */
REPLACE INTO specSections (id, title, specId, rank) VALUES 
		<xsl:apply-templates select="$understanding.doc//front/div1, //div3[@role='group1'] | //div3[@role='group2'] | //div4[@role='req']/div5 | //div4[@role='bp']/div5 | //div4[@role='additional']/div5 | //div1[@role = 'normative'] | $understanding.doc//back/inform-div1" mode="understanding"></xsl:apply-templates>
<xsl:apply-templates select="$understanding.doc" mode="understanding"/>

/* TECHNIQUES */
REPLACE INTO specSections (id, title, specId, rank) VALUES 
<xsl:apply-templates select="$techniques.doc//front/div1 | $techniques.doc//body/div1/div2 | $techniques.doc//technique" mode="techniques"/>
	</xsl:template>
	
	<xsl:template match="*" mode="#all"/>
	
	<xsl:function name="wcag:elide" as="xs:string">
		<xsl:param name="val"/>
		<xsl:choose>
			<xsl:when test="string-length($val) > 80"><xsl:value-of select="concat(substring($val, 0, 75), '...')"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$val"/></xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="wcag:sql-escape" as="xs:string">
		<xsl:param name="val"/>
		<xsl:value-of select='replace($val, "&apos;", "\\&apos;")'/>
	</xsl:function>
	
	<xsl:template name="sql.fragment">
		<xsl:param name="title" required="yes" as="item()*"/>
		<xsl:param name="spec" required="yes"/>
('<xsl:value-of select="@id"/>', '<xsl:value-of select="wcag:sql-escape(wcag:elide(normalize-space($title)))" />', '<xsl:value-of select="$spec"/>', <xsl:value-of select="position()"/>)<xsl:if test="position() &lt; last()">,
</xsl:if></xsl:template>
	
	<!-- == GUIDELINES == -->
	<xsl:template match="front/div1 | front/div1/div2" mode="guidelines">
		<xsl:call-template name="sql.fragment">
			<xsl:with-param name="title" select="head"/>
			<xsl:with-param name="spec" select="$guidelines.specId"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="div2[@role='principle']" mode="guidelines">
		<xsl:call-template name="sql.fragment">
			<xsl:with-param name="title"><xsl:value-of select="count(preceding-sibling::div2) + 1"/>: <xsl:value-of select="head"/></xsl:with-param>
			<xsl:with-param name="spec" select="$guidelines.specId"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="div3[@role='group1'] | div3[@role='group2']" mode="guidelines">
		<xsl:call-template name="sql.fragment">
			<xsl:with-param name="title">Guideline <xsl:value-of select="count(parent::div2/preceding-sibling::div2) + 1"/>.<xsl:value-of select="count(preceding-sibling::div3) + 1"/>: <xsl:value-of select="head"/></xsl:with-param>
			<xsl:with-param name="spec" select="$guidelines.specId"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="div4[@role='req']/div5 | div4[@role='bp']/div5 | div4[@role='additional']/div5" mode="guidelines">
		<xsl:call-template name="sql.fragment">
			<xsl:with-param name="title">Success Criterion <xsl:value-of select="count(ancestor::div2/preceding-sibling::div2) + 1"/>.<xsl:value-of select="count(ancestor::div3/preceding-sibling::div3) + 1"/>.<xsl:value-of select="count(preceding-sibling::div5) + 1"/>: <xsl:value-of select="head"/></xsl:with-param>
			<xsl:with-param name="spec" select="$guidelines.specId"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="div1[@role = 'normative']" mode="guidelines">
		<xsl:call-template name="sql.fragment">
			<xsl:with-param name="title"><xsl:value-of select="head"/></xsl:with-param>
			<xsl:with-param name="spec" select="$guidelines.specId"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="back//gitem" mode="guidelines">
		<xsl:call-template name="sql.fragment">
			<xsl:with-param name="title"><xsl:value-of select="label"/></xsl:with-param>
			<xsl:with-param name="spec" select="$guidelines.specId"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- == UNDERSTANDING == -->

	<xsl:template match="div3[@role='group1'] | div3[@role='group2']" mode="understanding">
		<xsl:call-template name="sql.fragment">
			<xsl:with-param name="title">Understanding Guideline <xsl:value-of select="count(parent::div2/preceding-sibling::div2) + 1"/>.<xsl:value-of select="count(preceding-sibling::div3) + 1"/>: <xsl:value-of select="head"/></xsl:with-param>
			<xsl:with-param name="spec" select="$understanding.specId"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="div4[@role='req']/div5 | div4[@role='bp']/div5 | div4[@role='additional']/div5" mode="understanding">
		<xsl:call-template name="sql.fragment">
			<xsl:with-param name="title"><xsl:value-of select="head"/>: Understanding Success Criterion <xsl:value-of select="count(ancestor::div2/preceding-sibling::div2) + 1"/>.<xsl:value-of select="count(ancestor::div3/preceding-sibling::div3) + 1"/>.<xsl:value-of select="count(preceding-sibling::div5) + 1"/></xsl:with-param>
			<xsl:with-param name="spec" select="$understanding.specId"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="front/div1" mode="understanding">
		<xsl:call-template name="sql.fragment">
			<xsl:with-param name="title"><xsl:value-of select="head"/></xsl:with-param>
			<xsl:with-param name="spec" select="$understanding.specId"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="div1[@role = 'normative']" mode="understanding">
		<xsl:call-template name="sql.fragment">
			<xsl:with-param name="title">Understanding <xsl:value-of select="head"/></xsl:with-param>
			<xsl:with-param name="spec" select="$understanding.specId"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="inform-div1" mode="understanding">
		<xsl:call-template name="sql.fragment">
			<xsl:with-param name="title">Appendix <xsl:number value="count(preceding-sibling::inform-div1) + 1" format="A"></xsl:number>: <xsl:value-of select="head"/></xsl:with-param>
			<xsl:with-param name="spec" select="$understanding.specId"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- == TECHNIQUES == -->
	
	<xsl:template match="front/div1[@id = 'intro'] | body/div1/div2" mode="techniques">
		<xsl:call-template name="sql.fragment">
			<xsl:with-param name="title" select="head"/>
			<xsl:with-param name="spec" select="$techniques.specId"/>
		</xsl:call-template>
	</xsl:template> 

	<xsl:template match="technique" mode="techniques">
		<xsl:call-template name="sql.fragment">
			<xsl:with-param name="title"><xsl:value-of select="@id"/>: <xsl:value-of select="short-name"/></xsl:with-param>
			<xsl:with-param name="spec" select="$techniques.specId"/>
		</xsl:call-template>
	</xsl:template> 
</xsl:stylesheet>