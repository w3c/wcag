<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:wcag="https://www.w3.org/WAI/GL/"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:import href="base.xslt"/>
	<xsl:import href="flatten-document.xslt"/>
	
	<xsl:param name="base.dir">understanding/</xsl:param>
	<xsl:param name="output.dir">input/understanding/</xsl:param>
	
	<xsl:template match="guidelines">
		<xsl:apply-templates select="//understanding | //guideline | //success-criterion"/>
	</xsl:template>

	<xsl:template match="understanding | guideline | success-criterion">
		<xsl:variable name="subpath" select="concat(max($versions.doc//id[@id = current()/@id]/parent::version/@name), '/')"/>
		<xsl:variable name="input.uri" select="resolve-uri(concat(file/@href, '.html'), concat($base.dir, $subpath))"/>
		<xsl:variable name="input.doc" select="document($input.uri)"/>
		<xsl:result-document href="{resolve-uri(concat(file/@href, '.html'), concat($output.dir, $subpath))}" encoding="utf-8" exclude-result-prefixes="#all" include-content-type="no" indent="yes" method="xhtml" omit-xml-declaration="yes">
			<xsl:apply-templates select="$input.doc//html:html"/>
		</xsl:result-document>
	</xsl:template>
	
</xsl:stylesheet>