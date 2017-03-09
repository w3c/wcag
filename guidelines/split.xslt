<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mc="https://www.w3.org/People/cooper/"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:output method="xhtml" indent="no"/>
    
    <xsl:function name="mc:create-filename">
        <xsl:param name="string"/>
        <xsl:variable name="lowercased" select="lower-case($string)"/>
        <xsl:variable name="hyphenated" select="replace($lowercased, ' ', '-')"/>
        <xsl:variable name="nopunct" select="replace($hyphenated, '[(),]', '')"/>
        <xsl:value-of select="$nopunct"/>
    </xsl:function>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="html:section[matches(@class, 'sc')][html:p[@class='change']]">
        <xsl:variable name="filename" select="mc:create-filename(html:h4)"/>
        <section data-include="sc/{$filename}.html" data-include-replace="true"/>
        <xsl:result-document href="sc/{$filename}.html" exclude-result-prefixes="#all" method="html" indent="true" xpath-default-namespace="http://www.w3.org/1999/xhtml">
            <xsl:copy-of select="."/>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="html:dt[@class='new' or @class='proposed']">
        <xsl:variable name="filename" select="mc:create-filename(html:dfn)"/>
        <dt data-include="terms/{$filename}.html" data-include-replace="true"/>
        <xsl:result-document href="terms/{$filename}.html" exclude-result-prefixes="#all" method="html" indent="true" xpath-default-namespace="http://www.w3.org/1999/xhtml">
            <xsl:copy-of select="."/>
            <xsl:copy-of select="./following-sibling::html:dd[1]"/>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="html:dd[@class='new' or @class='proposed']"/>
</xsl:stylesheet>