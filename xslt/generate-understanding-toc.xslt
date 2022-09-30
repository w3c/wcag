<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:output method="xhtml" indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>
	
	<xsl:template match="guidelines">
		<xsl:result-document href="toc.html" method="xhtml" omit-xml-declaration="yes">
				<h2>Understanding Guidelines and Success Criteria</h2>
				<xsl:apply-templates select="principle | guideline | success-criterion"/>
				<h2>Other Understanding documents</h2>
				<ul class="toc-wcag-docs">
				<xsl:apply-templates select="understanding"/>
				</ul>
		</xsl:result-document>
	</xsl:template>

	<xsl:template match="understanding">
		<li><a href="{file/@href}" class="tocxref"><xsl:value-of select="name"/></a></li>
	</xsl:template>

	<xsl:template match="principle | guideline | success-criterion">
		<xsl:choose>
			<xsl:when test="name() != 'principle'">
			<li>
				<a href="{file/@href}" class="tocxref">
					<span class="secno"><xsl:value-of select="num"/><xsl:text> </xsl:text></span>
					<xsl:value-of select="name"/>
				</a>
			</li>
			</xsl:when>
			<xsl:otherwise>
				<h3><xsl:value-of select="name"/></h3>
			</xsl:otherwise>				
		</xsl:choose>
		<xsl:if test="guideline">
			<ol class="toc toc-wcag-docs toc-understanding-guideline">
				<xsl:apply-templates select="guideline"/>
			</ol>
		</xsl:if>
		<xsl:if test="success-criterion">
			<li>
				<ol class="toc toc-wcag-docs">
					<xsl:apply-templates select="success-criterion"/>
				</ol>
			</li>
		</xsl:if>
	</xsl:template>
		
</xsl:stylesheet>