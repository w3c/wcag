<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:template match="guidelines">
		<xsl:result-document href="toc.html">
			<ul>
				<xsl:apply-templates/>
			</ul>
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="principle | understanding | guideline | success-criterion">
		<li>
			<xsl:choose>
				<xsl:when test="name() != 'principle'"><a href="{file/@href}"><xsl:value-of select="name"/></a></xsl:when>
				<xsl:otherwise><xsl:value-of select="name"/></xsl:otherwise>				
			</xsl:choose>
			<xsl:if test="understanding | guideline | success-criterion">
				<ul>
					<xsl:apply-templates select="understanding | guideline | success-criterion"/>
				</ul>
			</xsl:if>
		</li>
	</xsl:template>
		
</xsl:stylesheet>