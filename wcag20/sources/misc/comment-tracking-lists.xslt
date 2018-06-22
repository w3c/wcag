<?xml version="1.0" encoding="UTF-8"?>
<!-- NOTE: This file should be named using the format "{$day}-mapping.html" where $day = the publication day of the draft to which it corresponds -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="iso-8859-1" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="yes" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
	<xsl:param name="techniques.file">../wcag20-merged-techs.xml</xsl:param>
  <!-- create some variables to allow for extracting headings from various techniques documents -->
  <xsl:variable name="techs-src" select="document($techniques.file)"/>
  <xsl:variable name="draftDate">
    <xsl:value-of select="//pubdate/day"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="//pubdate/month"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="//pubdate/year"/>
  </xsl:variable>
  <xsl:variable name="thisversion">
    <xsl:value-of select="//publoc/loc[@href]"/>
  </xsl:variable>
  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>ID/Heading Listing (Experimental)</title>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>
      </head>
      <body xml:lang="en">
        <h1>ID/Heading Listing for Issue Tracking</h1>
        <p>This XSLT generates various lists and combinations of gudideline id's  and headings headings/etc for comment tracking database. This list was generated from the 
					 <a href="{$thisversion}">
            <xsl:value-of select="$draftDate"/> Working Draft</a>. </p>
        <h2>WCAG 2.0 Guidelines headings and ids</h2>
        <ul>
          <xsl:for-each select="//spec/front/div1[@id='intro'] | //spec/front/div1[@id='intro']/div2">
            <li><xsl:value-of select="head"></xsl:value-of> (intro.html#<xsl:value-of select="@id"/>)</li>
          </xsl:for-each>
                    <xsl:for-each select="//spec/front/div1[@id='conformance'] | //spec/front/div1[@id='conformance']/div2">
            <li><xsl:value-of select="head"></xsl:value-of> (conformance.html#<xsl:value-of select="@id"/>)</li>
          </xsl:for-each>
          <xsl:for-each select="//div3[@role='group1'] | //div3[@role='group2']">
            <li>
              <xsl:variable name="anchor">
                <xsl:value-of select="@id"/>
              </xsl:variable>
              Guideline <xsl:number level="multiple" count="div2 | div3" format="1.1"/><xsl:text> </xsl:text>(guidelines.html#<xsl:value-of select="@id"/>)
								
            </li>
            <xsl:for-each select="./div4[@role='req']/div5 | ./div4[@role='bp']/div5 | ./div4[@role='additional']/div5">
              <li>Success Criterion <xsl:call-template name="sc-number"/> (guidelines.html#<xsl:value-of select="@id"/>)
										
              </li>
            </xsl:for-each>
          </xsl:for-each>
          <xsl:for-each select="//spec/back/div1 | //spec/back/inform-div1">
          <xsl:variable name="appendixnumber">
<xsl:number count="div1 | inform-div1" format="A"/>          
          </xsl:variable>
            <li>Appendix <xsl:value-of select="$appendixnumber"></xsl:value-of>: <xsl:value-of select="head"></xsl:value-of> (appendix<xsl:value-of select="$appendixnumber"></xsl:value-of>.html#<xsl:value-of select="@id"/>)</li>
          </xsl:for-each>
        </ul>
        
        <h2>Understanding Item Number</h2>
       <ul>
<li>Introduction to Understanding WCAG 2.0 (intro)</li>
						<xsl:for-each select="//div3[@role='group1'] | //div3[@role='group2']">
							<li>Understanding Guideline <xsl:number level="multiple" count="div2 | div3" format="1.1 "/> (<xsl:value-of select="@id"/>)</li>
						
						<xsl:for-each select="./div4[@role='req']/div5 | ./div4[@role='bp']/div5 | ./div4[@role='additional']/div5">
							<li>How to Meet Success Criterion <xsl:call-template name="sc-number"/> (<xsl:value-of select="@id"/>)</li></xsl:for-each>
	</xsl:for-each>
     </ul>
     
     
     
        <h2>Techniques Item Number</h2>
        <ul>
          
				<xsl:for-each select="$techs-src//spec/body/div1">
              <xsl:variable name="head">
                <xsl:value-of select="head"/>
              </xsl:variable>
              <li><xsl:value-of select="head"></xsl:value-of></li>
                <xsl:for-each select="technique">
										<li><xsl:value-of select="@id"/>: <xsl:value-of select="substring(short-name, 1, 85)"/>...</li></xsl:for-each>
            </xsl:for-each>
        </ul>
        <hr/>
        </body>
        </html>
        </xsl:template>
  <xsl:template name="sc-number">
    <xsl:choose>
      <xsl:when test="ancestor::div4[@role='bp']">
        <xsl:variable name="sc" select="count(ancestor::div3/div4[@role='req']/div5) + 1"/>
        <xsl:value-of select="concat(count(ancestor::div2/preceding-sibling::div2) + 1, '.', count(ancestor::div3/preceding-sibling::div3) + 1, '.', count(preceding-sibling::div5) + $sc)"/>
      </xsl:when>
      <xsl:when test="ancestor::div4[@role='additional']">
        <xsl:variable name="sc" select="count(ancestor::div3/div4[@role='req']/div5) + count(ancestor::div3/div4[@role='bp']/div5) + 1"/>
        <xsl:value-of select="concat(count(ancestor::div2/preceding-sibling::div2) + 1, '.', count(ancestor::div3/preceding-sibling::div3) + 1, '.', count(preceding-sibling::div5) + $sc)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(count(ancestor::div2/preceding-sibling::div2) + 1, '.', count(ancestor::div3/preceding-sibling::div3) + 1, '.', count(preceding-sibling::div5) + 1)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  
</xsl:stylesheet>
