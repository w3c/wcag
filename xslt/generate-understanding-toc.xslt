<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:output method="xhtml" indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>
	
	<xsl:template match="guidelines">
		<xsl:result-document href="toc.html" method="xhtml" omit-xml-declaration="yes">
				<xsl:apply-templates select="principle | guideline | success-criterion"/>
				<h2>Other Understanding documents</h2>
				<ul class="toc-wcag-docs">
				<xsl:apply-templates select="understanding"/>
				</ul>
		</xsl:result-document>
	</xsl:template>

	<xsl:template match="principle">
		<section>
			<h2><xsl:value-of select="name"/></h2>
			<xsl:apply-templates select="guideline"/>
		</section>
	</xsl:template>
	
	<xsl:template match="guideline">
		<section>
			<h3>
				<a href="{file/@href}">
					<span class="secno"><xsl:value-of select="num"/><xsl:text> </xsl:text></span>
					<xsl:value-of select="name"/>
				</a>
			</h3>
			<ul>
			<xsl:apply-templates select="success-criterion"/>
			</ul>
		</section>
	</xsl:template>
	
	<xsl:template match="success-criterion">
		<li>
			<a href="{file/@href}">
				<span class="secno"><xsl:value-of select="num"/><xsl:text> </xsl:text></span>
				<xsl:value-of select="name"/>
			</a>
		</li>
	</xsl:template>
	
	<xsl:template match="understanding">
		<li><a href="{file/@href}"><xsl:value-of select="name"/></a></li>
	</xsl:template>
	
</xsl:stylesheet>