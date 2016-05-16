<?xml version="1.0"?>

<!-- Version: $Id: diffspec-howto.xsl,v 1.15 2008/12/08 23:50:08 bcaldwel Exp $ -->

<!-- Stylesheet for @diff markup in XMLspec -->
<!-- Author: Norman Walsh (Norman.Walsh@East.Sun.COM) -->
<!-- Date Created: 2000.07.21 -->

<!-- This stylesheet is copyright (c) 2000 by its authors.  Free
     distribution and modification is permitted, including adding to
     the list of authors and copyright holders, as long as this
     copyright notice is maintained. -->

<!-- This stylesheet attempts to implement the XML Specification V2.1
     DTD.  Documents conforming to earlier DTDs may not be correctly
     transformed.

     This stylesheet supports the use of change-markup with the @diff
     attribute. If you use @diff, you should always use this stylesheet.
     If you want to turn off the highlighting of differences, use this
     stylesheet, but set show.diff.markup to 0.

     Using the original xmlspec stylesheet with @diff markup will cause
     @diff=del text to be presented.
-->

<!-- ChangeLog:
     25 Sep 2000: (Norman.Walsh@East.Sun.COM)
       - Use inline diff markup (as opposed to block) for name and
         affiliation
       - Handle @diff='del' correctly in bibl and other list-contexts.
     14 Aug 2000: (Norman.Walsh@East.Sun.COM)
       - Support additional.title param
     27 Jul 2000: (Norman.Walsh@East.Sun.COM)
       - Fix HTML markup problem with diff'd authors in authlist
     26 Jul 2000: (Norman.Walsh@East.Sun.COM)
       - Update pointer to latest xmlspec-stylesheet.
     21 Jul 2000: (Norman.Walsh@East.Sun.COM)
       - Initial version
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
		version="1.0">

<xsl:import href="xmlspec-wcag-howto.xsl"/>

<xsl:param name="show.diff.markup" select="1"/>

<xsl:param name="additional.css">
<xsl:if test="$show.diff.markup != 0">
    <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="diffs.css" />
</xsl:if>
    <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="additional.css" />
</xsl:param>

<xsl:param name="additional.title">
  <xsl:if test="$show.diff.markup != 0">
      <xsl:text>Diff-marked Version</xsl:text>
  </xsl:if>
</xsl:param>

<xsl:param name="called.by.diffspec" select="0"/>

<!-- ==================================================================== 
BBC: This is all called in a previous XSLT, so commented out here. -->

  <!-- spec: the specification itself 
  <xsl:template match="spec">
    <html>
      <xsl:if test="header/langusage/language">
        <xsl:attribute name="lang">
          <xsl:value-of select="header/langusage/language/@id"/>
        </xsl:attribute>
      </xsl:if>
      <head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title>
          <xsl:apply-templates select="header/title"/>
          <xsl:if test="header/version">
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="header/version"/>
          </xsl:if>
          <xsl:if test="$additional.title != ''">
            <xsl:text> -</xsl:text>
            <xsl:value-of select="$additional.title"/>
	  </xsl:if>
        </title>
        <xsl:call-template name="css"/>
      </head>
      <body>
        <xsl:if test="$show.diff.markup != 0">
          <div xmlns="http://www.w3.org/1999/xhtml">
            <p>The presentation of this document has been augmented to
            identify changes from a previous version. Three kinds of changes
            are highlighted: <span class="diff-add" xmlns="http://www.w3.org/1999/xhtml">[begin add] new, added text [end add]</span>,
            <span class="diff-chg" xmlns="http://www.w3.org/1999/xhtml">[begin change] changed text [end change]</span>, and
            <span class="diff-del" xmlns="http://www.w3.org/1999/xhtml">[begin delete] deleted text [end delete]</span>.</p>
            <hr/>
          </div>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:if test="//footnote[not(ancestor::table)]">
          <hr/>
          <div class="endnotes" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:text>&#10;</xsl:text>
            <h3>
              <xsl:call-template name="anchor">
                <xsl:with-param name="conditional" select="0"/>
                <xsl:with-param name="default.id" select="'endnotes'"/>
              </xsl:call-template>
              <xsl:text>End Notes</xsl:text>
            </h3>
            <dl>
              <xsl:apply-templates select="//footnote[not(ancestor::table)]"
                                   mode="notes"/>
            </dl>
          </div>
        </xsl:if>
      </body>
    </html>
  </xsl:template>-->

<!-- ==================================================================== -->

<xsl:template name="diff-markup">
  <xsl:param name="diff">off</xsl:param>
  <xsl:choose>
    <xsl:when test="ancestor::scrap">
      <!-- forget it, we can't add stuff inside tables -->
      <!-- handled in base stylesheet -->
      <xsl:apply-imports/>
    </xsl:when>
    <xsl:when test="self::gitem or self::bibl or self::item">
      <!-- forget it, we can't add stuff inside dls; handled below 
BBC: added "item" here to address problems with ordered lists-->
      <xsl:apply-imports/>
    </xsl:when>
    <xsl:when test="ancestor-or-self::phrase">
      <span class="diff-{$diff}" xmlns="http://www.w3.org/1999/xhtml"><span class="difftext">[begin <xsl:value-of select="$diff"/>]</span>
	<xsl:apply-imports/> <span class="difftext">[end <xsl:value-of select="$diff"/>]</span>
      </span>      
    </xsl:when>
    <xsl:when test="ancestor::p and not(self::p)">
      <span class="diff-{$diff}" xmlns="http://www.w3.org/1999/xhtml"><span class="difftext">[begin <xsl:value-of select="$diff"/>]</span>
	<xsl:apply-imports/> <span class="difftext">[end <xsl:value-of select="$diff"/>]</span>
      </span>   
    </xsl:when>
    <xsl:when test="ancestor-or-self::affiliation">
      <span class="diff-{$diff}" xmlns="http://www.w3.org/1999/xhtml"><span class="difftext">[begin <xsl:value-of select="$diff"/>]</span>
	<xsl:apply-imports/> <span class="difftext">[end <xsl:value-of select="$diff"/>]</span>
      </span>   
    </xsl:when>
    <xsl:when test="ancestor-or-self::name">
      <span class="diff-{$diff}" xmlns="http://www.w3.org/1999/xhtml"><span class="difftext">[begin <xsl:value-of select="$diff"/>]</span>
	<xsl:apply-imports/> <span class="difftext">[end <xsl:value-of select="$diff"/>]</span>
      </span>   
    </xsl:when>
    <xsl:otherwise>
      <div class="diff-{$diff}" xmlns="http://www.w3.org/1999/xhtml"><span class="difftext">[begin <xsl:value-of select="$diff"/>] </span>
	<xsl:apply-imports/> <span class="difftext">[end <xsl:value-of select="$diff"/>]</span>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*[@diff='chg']">
  <xsl:choose>
    <xsl:when test="$show.diff.markup != 0">
      <xsl:call-template name="diff-markup">
	<xsl:with-param name="diff">change</xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*[@diff='add']">
  <xsl:choose>
    <xsl:when test="$show.diff.markup != 0">
      <xsl:call-template name="diff-markup">
	<xsl:with-param name="diff">add</xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*[@diff='del']">
  <xsl:choose>
    <xsl:when test="$show.diff.markup != 0">
      <xsl:call-template name="diff-markup">
	<xsl:with-param name="diff">delete</xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <!-- suppress deleted markup -->
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*[@diff='off']">
  <xsl:choose>
    <xsl:when test="$show.diff.markup != 0">
      <xsl:call-template name="diff-markup">
	<xsl:with-param name="diff">off</xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ================================================================= -->

  <xsl:template match="bibl[@diff]" priority="1">
    <xsl:variable name="dt">
      <xsl:if test="@id">
	<a name="{@id}"/>
      </xsl:if>
      <xsl:choose>
	<xsl:when test="@key">
	  <xsl:value-of select="@key"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="@id"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="dd">
      <xsl:apply-templates/>
      <xsl:if test="@href">
        <xsl:text>  (See </xsl:text>
        <xsl:value-of select="@href"/>
        <xsl:text>.)</xsl:text>
      </xsl:if>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="@diff and $show.diff.markup != 0">
	<dt class="label" xmlns="http://www.w3.org/1999/xhtml">
	  <span class="diff-{@diff}" xmlns="http://www.w3.org/1999/xhtml">
	    <xsl:copy-of select="$dt"/>
	  </span>
	</dt>
	<dd xmlns="http://www.w3.org/1999/xhtml">
	  <div class="diff-{@diff}" xmlns="http://www.w3.org/1999/xhtml">
	    <xsl:copy-of select="$dd"/>
	  </div>
	</dd>
      </xsl:when>
      <xsl:when test="@diff='del' and $show.diff.markup = 0">
	<!-- suppressed -->
      </xsl:when>
      <xsl:otherwise>
	<dt class="label" xmlns="http://www.w3.org/1999/xhtml">
	  <xsl:copy-of select="$dt"/>
	</dt>
	<dd xmlns="http://www.w3.org/1999/xhtml">
	  <xsl:copy-of select="$dd"/>
	</dd>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="gitem/label">
    <xsl:variable name="diffval" select="ancestor-or-self::*/@diff"/>
    <xsl:choose>
      <xsl:when test="$diffval != '' and $show.diff.markup != 0">
	<dt class="label" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:call-template name="anchor">
				<xsl:with-param name="node" select=".."/>
			</xsl:call-template>
			<!--<xsl:call-template name="anchor"/>-->
	  <span class="diff-{ancestor-or-self::*/@diff}" xmlns="http://www.w3.org/1999/xhtml">
	    <xsl:apply-templates/>
	  </span>
	</dt>
      </xsl:when>
      <xsl:when test="$diffval='del' and $show.diff.markup = 0">
	<!-- suppressed -->
      </xsl:when>
      <xsl:otherwise>
	<dt class="label" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:call-template name="anchor">
				<xsl:with-param name="node" select=".."/>
			</xsl:call-template>
			<!--<xsl:call-template name="anchor"/>-->
	  <xsl:apply-templates/>
	</dt>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="gitem/def">
    <xsl:variable name="diffval" select="ancestor-or-self::*/@diff"/>
    <xsl:choose>
      <xsl:when test="$diffval != '' and $show.diff.markup != 0">
	<dd xmlns="http://www.w3.org/1999/xhtml">
	  <div class="diff-{ancestor-or-self::*/@diff}" xmlns="http://www.w3.org/1999/xhtml">
	    <xsl:apply-templates/>
	  </div>
	</dd>
      </xsl:when>
      <xsl:when test="$diffval='del' and $show.diff.markup = 0">
	<!-- suppressed -->
      </xsl:when>
      <xsl:otherwise>
	<dd xmlns="http://www.w3.org/1999/xhtml">
	  <xsl:apply-templates/>
	</dd>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="item[ancestor-or-self::*/@diff]" priority="1">
    <xsl:variable name="diffval" select="ancestor-or-self::*/@diff"/>
    <xsl:choose>
      <xsl:when test="$diffval != '' and $show.diff.markup != 0">
	<li xmlns="http://www.w3.org/1999/xhtml">
	  <div class="diff-{ancestor-or-self::*/@diff}" xmlns="http://www.w3.org/1999/xhtml">
	    <xsl:apply-templates/>
	  </div>
	</li>
      </xsl:when>
      <xsl:when test="$diffval='del' and $show.diff.markup = 0">
	<!-- suppressed -->
      </xsl:when>
      <xsl:otherwise>
	<li xmlns="http://www.w3.org/1999/xhtml">
	  <xsl:apply-templates/>
	</li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- authlist: list of authors (editors, really) -->
  <!-- called in enforced order from header's template, in <dl>
       context -->
  <xsl:template match="authlist[@diff]" priority="1">
    <xsl:choose>
      <xsl:when test="$show.diff.markup != 0">
	<dt>
	  <span class="diff-{ancestor-or-self::*/@diff}" xmlns="http://www.w3.org/1999/xhtml">
	    <xsl:text>Editor</xsl:text>
	    <xsl:if test="count(author) > 1">
	      <xsl:text>s</xsl:text>
	    </xsl:if>
	    <xsl:text>:</xsl:text>
	  </span>
	</dt>
      </xsl:when>
      <xsl:when test="@diff='del' and $show.diff.markup = 0">
	<!-- suppressed -->
      </xsl:when>
      <xsl:otherwise>
	<dt>
	  <xsl:text>Editor</xsl:text>
	  <xsl:if test="count(author) > 1">
	    <xsl:text>s</xsl:text>
	  </xsl:if>
	  <xsl:text>:</xsl:text>
	</dt>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
  </xsl:template>

  <!-- author: an editor of a spec -->
  <!-- only appears in authlist -->
  <!-- called in <dl> context -->
  <xsl:template match="author[@diff]" priority="1">
    <xsl:choose>
      <xsl:when test="@diff and $show.diff.markup != 0">
	<dd>
	  <span class="diff-{ancestor-or-self::*/@diff}" xmlns="http://www.w3.org/1999/xhtml">
	    <xsl:apply-templates/>
	    <xsl:if test="@role = '2e'">
	      <xsl:text> - Second Edition</xsl:text>
	    </xsl:if>
	  </span>
	</dd>
      </xsl:when>
      <xsl:when test="@diff='del' and $show.diff.markup = 0">
	<!-- suppressed -->
      </xsl:when>
      <xsl:otherwise>
	<dd>
	  <xsl:apply-templates/>
	  <xsl:if test="@role = '2e'">
	    <xsl:text> - Second Edition</xsl:text>
	  </xsl:if>
	</dd>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- unlink deleted text, as target likely to be deleted too -->
<xsl:template match="loc[ancestor-or-self::*[@diff='del']]" priority="1">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="termref[ancestor-or-self::*[@diff='del']] | specref[ancestor-or-self::*[@diff='del']]" priority="1">
	<xsl:value-of select="key('ids', @def)/label"/>
</xsl:template>

<!-- override sc-number-link so as to remove anchor if deleted -->
	<xsl:template name="sc-number-link">
		<xsl:param name="id" select="../@id"/>
		<xsl:param name="criterion" select="$gl-src//*[@id = $id]"/>
		<xsl:variable name="val"><xsl:call-template name="sc-number"><xsl:with-param name="id" select="$id"/><xsl:with-param name="criterion" select="$criterion"/></xsl:call-template></xsl:variable>
		<xsl:choose>
			<xsl:when test="ancestor-or-self::*[@diff='del']">
				<xsl:value-of select="$val"/>
			</xsl:when>
			<xsl:otherwise>
				<a href="{$glthisversion}#{$id}">
					<xsl:value-of select="$val"/>
				</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
