<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:param name="base.dir">file:///C:/Documents/code/GitHub/w3c/wcag21/guidelines/</xsl:param>
	
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="element()[@data-include]">
		<xsl:choose>
			<xsl:when test="@data-include-replace = 'true'"><xsl:value-of select="unparsed-text(resolve-uri(@data-include, $base.dir))" disable-output-escaping="yes"/></xsl:when>
			<xsl:otherwise>
				<xsl:copy><xsl:value-of select="unparsed-text(resolve-uri(@data-include, $base.dir))" disable-output-escaping="yes"/></xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>