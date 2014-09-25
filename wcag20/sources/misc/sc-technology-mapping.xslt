<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:import href="../xmlspec-wcag.xsl"/>
	<xsl:variable name="techs" select="document('../wcag20-merged-techs.xml')"/>
	
	<xsl:variable name="technologies" select="'general', 'html', 'css', 'client-side-script', 'server-side-script', 'smil', 'text', 'aria', 'flash', 'silverlight', 'pdf'"/>
	
	<xsl:template match="/">
		<html>
			<head>
				<title>Success criteria supported by various technologies</title>
			</head>
			<body>
				<h1>Success criteria supported by various technologies</h1>
				<table border="1" cellspacing="0">
					<thead>
						<tr>
							<th>Success Criterion</th>
							<xsl:for-each select="$technologies">
								<xsl:variable name="tech" select="."/>
								<th>
									<xsl:value-of select="$tech"/>
								</th>
							</xsl:for-each>
						</tr>
					</thead>
					<tbody>
						<xsl:apply-templates select="//div5[@role = 'sc']"/>
					</tbody>
				</table>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="div5[@role='sc']">
		<xsl:variable name="sc" select="@id"/>
		<tr>
			<td>
				<xsl:call-template name="sc-number">
					<xsl:with-param name="id" select="$sc"/>
				</xsl:call-template>
				<xsl:text>: </xsl:text>
				<xsl:call-template name="sc-handle">
					<xsl:with-param name="handleid" select="$sc"/>
				</xsl:call-template>
			</td>
			<xsl:for-each select="$technologies">
				<xsl:variable name="tech" select="."/>
				<td>
					<xsl:choose>
						<xsl:when test="$techs//div1[@id = $tech]//success-criterion[@idref = $sc and (@relationship = 'sufficient' or @relationship = 'cosufficient')]">X</xsl:when>
						<xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
					</xsl:choose>
				</td>
			</xsl:for-each>
		</tr>
	</xsl:template>
</xsl:stylesheet>