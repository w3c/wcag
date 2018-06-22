<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:import href="../xmlspec-tech.xsl"/>
	
	<xsl:template match="/">
		<html>
			<head>
				<title>WCAG Techniques and their Success Criteria</title>
			</head>
			<body>
				<h1>WCAG Techniques and their Success Criteria</h1>
				<xsl:apply-templates select="//div1[@id = 'general' or @id = 'html' or @id = 'css' or @id = 'script']"/>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="div1">
		<div>
			<h2><xsl:value-of select="head"/></h2>
			<table border="1" cellspacing="0">
				<thead>
					<tr>
						<th>Technique</th>
						<th>Applies To</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="technique"/>
				</tbody>
			</table>
		</div>
	</xsl:template>
	
	<xsl:template match="technique">
		<tr valign="top">
			<td>
				<a>
					<xsl:attribute name="href">
						<xsl:value-of select="$techs-src//publoc/loc"/>
						<xsl:value-of select="@id"/>
					</xsl:attribute>
					<xsl:apply-templates select="." mode="divnum"/>
					<xsl:apply-templates select="short-name" mode="text"/>
				</a>
			</td>
			<td>
				<ul>
					<xsl:apply-templates select="applies-to/success-criterion | applies-to/conformance-criterion"/>
				</ul>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="success-criterion">
		<xsl:variable name="id" select="@idref"/>
		<xsl:variable name="filename"><xsl:apply-templates select="$guide-src//*[@id = $id]" mode="slice-understanding-filename"/></xsl:variable>
		<xsl:variable name="fragment"><xsl:if test="$id != substring-before($filename, '.')">#<xsl:value-of select="$id"/></xsl:if></xsl:variable>
		<li>
			<a href="{$guide-src//publoc/loc[@href]}{$filename}{fragment}">
				<xsl:call-template name="sc-number"><xsl:with-param name="id" select="$id"/></xsl:call-template><xsl:text> </xsl:text><xsl:call-template name="sc-handle"><xsl:with-param name="handleid" select="$id"/></xsl:call-template>
			</a>
			(<xsl:value-of select="@relationship"/>)
		</li>
	</xsl:template>
	
	<xsl:template match="conformance-criterion">
		<xsl:variable name="id" select="@idref"/>
		<xsl:variable name="filename"><xsl:apply-templates select="$guide-src//*[@id = $id]" mode="slice-understanding-filename"/></xsl:variable>
		<xsl:variable name="fragment"><xsl:if test="$id != substring-before($filename, '.')">#<xsl:value-of select="$id"/></xsl:if></xsl:variable>
		<li>
			<a href="{$guide-src//publoc/loc[@href]}#{$id}">
				CC<xsl:text> </xsl:text><xsl:call-template name="cc-number"/> <xsl:call-template name="sc-handle"><xsl:with-param name="handleid" select="@idref"/></xsl:call-template>
			</a>
			(<xsl:value-of select="@relationship"/>)
		</li>
	</xsl:template>
</xsl:stylesheet>