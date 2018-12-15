<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:output method="xhtml" indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>
	
	<xsl:template match="guidelines">
		<xsl:result-document href="toc.html" method="xhtml">
			<nav id="toc">
				<h2 class="introductory" id="understanding-pages">
					Understanding Pages
					<!-- <span class="permalink"><a href="#toc" aria-label="Permalink for Understanding Pages" title="Permalink for Understanding Pages"><span>§</span></a></span> -->
				</h2>
				<ol class="toc">
					<xsl:apply-templates select="principle | understanding | guideline | success-criterion"/>
				</ol>
			</nav>
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="principle | understanding | guideline | success-criterion">
		<li class="tocline">
			<xsl:choose>
				<xsl:when test="name() != 'principle'">
					<a href="{file/@href}" class="tocxref">
						<span class="secno"><xsl:value-of select="num"/><xsl:text> </xsl:text></span>
						<xsl:value-of select="name"/></a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="name"/>
				</xsl:otherwise>				
			</xsl:choose>
			<xsl:if test="understanding | guideline | success-criterion">
				<ol class="toc">
					<xsl:apply-templates select="understanding | guideline | success-criterion"/>
				</ol>
			</xsl:if>
		</li>
	</xsl:template>
		
</xsl:stylesheet>