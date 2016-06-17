<?xml version="1.0" encoding="utf-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://icl.com/saxon" xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="saxon" version="1.0">
  <!--BBC: For non-visual diff-marked versions, change thefollowing back to xmlspec.xsl-->
  <xsl:import href="xmlspec.xsl"/>
  <xsl:param name="slices" select="0"/>
  <xsl:param name="bytech">0</xsl:param>
  <xsl:param name="guide" select="1"/>
  <xsl:param name="show.diff.markup" select="1"/>
  <xsl:param name="show.issue.links" select="1"/>
  <xsl:param name="quickref" select="0"/>
  <!-- create some variables to allow for extracting headings from various techniques documents -->
	<xsl:param name="guidelines.file">wcag2-src.xml</xsl:param>
	<xsl:param name="understanding.file">guide-to-wcag2-src.xml</xsl:param>
	<xsl:param name="techniques.file">wcag20-merged-techs.xml</xsl:param>
	<xsl:param name="quickref.file">wcag2-quickref.xml</xsl:param>
	<xsl:param name="refs.file">refs.xml</xsl:param>
  <xsl:param name="gl-src" select="document($guidelines.file)"/>
  <xsl:param name="guide-src" select="document($understanding.file)"/>
  <xsl:param name="techs-src" select="document($techniques.file)"/>
  <xsl:param name="quickref-src" select="document($quickref.file)"/>
  <!--define variables for various versions of guidelines and techniques documents used-->
  <xsl:param name="thisversion">
    <xsl:value-of select="//publoc/loc[@href]"/>
  </xsl:param>
  <xsl:param name="glthisversion">
      <xsl:value-of select="$gl-src//publoc/loc[@href]"/>
  </xsl:param>
  <xsl:param name="guidethisversion">
      <!--BBC change as needed based on whether the guidelines should point the latest version or not -->
    <xsl:value-of select="$guide-src//latestloc/loc[@href]"/>
  </xsl:param>
  <xsl:param name="techsthisversion">
    <xsl:value-of select="$techs-src//publoc/loc[@href]"/>
  </xsl:param>
    <xsl:param name="quickrefthisversion">http://www.w3.org/WAI/WCAG20/quickref/</xsl:param>
  <!-- BBC: added link to TOC -->
  <xsl:template match="header">
    <xsl:choose>
      <xsl:when test="$bytech= 1"></xsl:when>
     
      <xsl:otherwise>
    <div class="head">
      <xsl:if test="not(/spec/@role='editors-copy')">
        <p>
          <a href="http://www.w3.org/">
          	<img src="https://www.w3.org/StyleSheets/TR/2016/logos/W3C" alt="W3C" height="48" width="72"/>
          </a>
          <xsl:choose>
            <xsl:when test="/spec/@w3c-doctype='memsub'">
              <a href="http://www.w3.org/Submission/">
                <img alt="Member Submission" src="http://www.w3.org/Icons/member_subm"/>
              </a>
            </xsl:when>
            <xsl:when test="/spec/@w3c-doctype='teamsub'">
              <a href="http://www.w3.org/2003/06/TeamSubmission">
                <img alt="Team Submission" src="http://www.w3.org/Icons/team_subm"/>
              </a>
            </xsl:when>
          </xsl:choose>
        </p>
      </xsl:if>
      <xsl:text>
</xsl:text>
      <h1>
        <xsl:call-template name="anchor">
          <xsl:with-param name="node" select="title[1]"/>
          <xsl:with-param name="conditional" select="0"/>
          <xsl:with-param name="default.id" select="'title'"/>
        </xsl:call-template>
        <xsl:apply-templates select="title"/>
        <xsl:if test="version">
          <xsl:text> </xsl:text>
          <xsl:apply-templates select="version"/>
        </xsl:if>
      </h1>
      <xsl:if test="subtitle">
        <xsl:text>
</xsl:text>
        <h2>
          <xsl:call-template name="anchor">
            <xsl:with-param name="node" select="subtitle[1]"/>
            <xsl:with-param name="conditional" select="0"/>
            <xsl:with-param name="default.id" select="'subtitle'"/>
          </xsl:call-template>
          <xsl:apply-templates select="subtitle"/>
        </h2>
      </xsl:if>
      <xsl:text>
</xsl:text>
      <h2>
        <xsl:if test="/spec/@w3c-doctype='review'">
          <xsl:attribute name="class">sorethumb</xsl:attribute>
        </xsl:if>
        <xsl:call-template name="anchor">
          <xsl:with-param name="node" select="w3c-doctype[1]"/>
          <xsl:with-param name="conditional" select="0"/>
          <xsl:with-param name="default.id" select="'w3c-doctype'"/>
        </xsl:call-template>
        <xsl:choose>
          <xsl:when test="/spec/@w3c-doctype = 'review'">
            <xsl:text>Editor's Draft</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="w3c-doctype[1]"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <xsl:if test="pubdate/day">
          <xsl:apply-templates select="pubdate/day"/>
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:apply-templates select="pubdate/month"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="pubdate/year"/>
        <xsl:if test="$additional.title != ''">
          <xsl:text> -- </xsl:text>
          <xsl:value-of select="$additional.title"/>
        </xsl:if>
      </h2>
      <dl>
        <xsl:apply-templates select="publoc"/>
        <xsl:apply-templates select="latestloc"/>
        <xsl:apply-templates select="prevlocs"/>
        <xsl:apply-templates select="authlist"/>
      </dl>
      <!-- output the errataloc and altlocs -->
      <xsl:apply-templates select="errataloc"/>
      <xsl:apply-templates select="preverrataloc"/>
      <xsl:apply-templates select="translationloc"/>
      <xsl:apply-templates select="altlocs"/>
      <xsl:choose>
        <xsl:when test="copyright">
          <xsl:apply-templates select="copyright"/>
        </xsl:when>
        <xsl:otherwise>
          <p class="copyright">
            <a href="http://www.w3.org/Consortium/Legal/ipr-notice#Copyright">Copyright</a> &#169; <xsl:apply-templates select="pubdate/year"/>
            <xsl:text> </xsl:text>
            <a href="http://www.w3.org/">
              <acronym title="World Wide Web Consortium">W3C</acronym>
            </a>
            <sup>&#174;</sup> (<a href="http://www.csail.mit.edu/">
              <acronym title="Massachusetts Institute of Technology">MIT</acronym>
            </a>, <a href="http://www.ercim.eu/">
              <acronym title="European Research Consortium for Informatics and Mathematics">ERCIM</acronym>
            </a>, <a href="http://www.keio.ac.jp/">Keio</a>, <a href="http://ev.buaa.edu.cn/">Beihang</a>). W3C <a href="http://www.w3.org/Consortium/Legal/ipr-notice#Legal_Disclaimer">liability</a>, <a href="http://www.w3.org/Consortium/Legal/ipr-notice#W3C_Trademarks">trademark</a> and <a href="http://www.w3.org/Consortium/Legal/copyright-documents">document use</a> rules apply.</p>
        </xsl:otherwise>
      </xsl:choose>
    	<hr/>
    </div>

    <xsl:apply-templates select="notice"/>
    <xsl:apply-templates select="abstract"/>
    <xsl:apply-templates select="status"/>
    <xsl:apply-templates select="revisiondesc"/>
      </xsl:otherwise>
    </xsl:choose>
  	
  	<xsl:call-template name="toc"/>
  </xsl:template>
	
	<xsl:template name="toc">
		    <xsl:if test="$toc.level &gt; 0">
      <div id="toc">
        <xsl:text>
</xsl:text>
        <hr/>
        <h2>
          <xsl:call-template name="anchor">
            <xsl:with-param name="conditional" select="0"/>
            <xsl:with-param name="default.id" select="'contents'"/>
          </xsl:call-template>
          <xsl:text>Table of Contents</xsl:text>
        </h2>
        <ul class="toc">
          <xsl:choose>
            <xsl:when test="$quickref='1'">
              <xsl:apply-templates select="//div1" mode="tocquickref"/>
            </xsl:when>
            <xsl:otherwise>
                <li><a href="#abstract">Abstract </a></li>
            	<li><a href="#status">Status of This Document </a></li>
              <xsl:apply-templates select="//div1[not(@id = 'placeholders')]" mode="toc"/>
            </xsl:otherwise>
          </xsl:choose>
        </ul>
        
        <xsl:choose>
          <xsl:when test="$bytech = 1"></xsl:when>
          <xsl:otherwise>
            <xsl:if test="../back">
              <xsl:text>
              </xsl:text>
              <h3>
                <xsl:call-template name="anchor">
                  <xsl:with-param name="conditional" select="0"/>
                  <xsl:with-param name="default.id" select="'appendices'"/>
                </xsl:call-template>
                <xsl:text>Appendi</xsl:text>
                <xsl:choose>
                  <xsl:when test="count(../back/div1 | ../back/inform-div1) &gt; 1">
                    <xsl:text>ces</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>x</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </h3>
              <ul class="toc">
                <xsl:apply-templates mode="toc" select="../back/div1[not(@id='placeholders')] | ../back/inform-div1"/>
                <xsl:call-template name="autogenerated-appendices-toc"/>
              </ul>
            </xsl:if>
            <xsl:if test="//footnote[not(ancestor::table)]">
              <ul class="toc">
                <a href="#endnotes">
                  <xsl:text>End Notes</xsl:text>
                </a>
              </ul>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      	<hr/>
      </div>
    </xsl:if>

	</xsl:template>

	<xsl:template match="revisiondesc">
    <xsl:if test="/spec/@w3c-doctype = 'review'">
      <xsl:apply-templates/>
    </xsl:if>
  </xsl:template>
  <!-- note: a note about the spec -->
  <!-- BBC validation problems with xmlns attributes on note with original style - used constraintnote styles instead and modified accordingly -->
  <!-- see also note/p -->
  <xsl:template match="note">
    <div class="note">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="note/p">
    <xsl:variable name="notenumber">
      <xsl:value-of select="count(ancestor::note/p)"/>
    </xsl:variable>
    <p class="prefix">
      <xsl:if test="../@id">
        <a name="{../@id}" id="{../@id}"/>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="../@role='nonumber'"/>
        <xsl:otherwise>
          <em><xsl:choose>
            <xsl:when test="$notenumber = '1'">
              <xsl:text>Note: </xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>Note </xsl:text>
              <xsl:number count="p" format="1"/>:
					</xsl:otherwise>
          </xsl:choose></em>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  <!-- note: an example in the spec -->
  <!-- see also note/p -->
  <xsl:template match="example">
    <div class="example">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <xsl:template match="example/p">
    <xsl:variable name="exnumber">
      <xsl:value-of select="count(ancestor::example/p)"/>
    </xsl:variable>
    <p class="prefix">
      <xsl:if test="../@id">
        <a name="{../@id}" id="{../@id}"/>
      </xsl:if>
      <em><xsl:choose>
        <xsl:when test="$exnumber = '1'">
          <xsl:text>Example: </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Example </xsl:text>
          <xsl:number count="p" format="1"/>:
					</xsl:otherwise>
      </xsl:choose></em>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  <!-- BBC: modified to make TOCs into actual lists -->
  <xsl:template match="body">
    <div class="body">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <!-- mode: toc rewrote this section so that TOC into actual lists-->
  <xsl:template mode="toc" match="div1">
    <li>
      <xsl:apply-templates select="." mode="divnum"/>
      <xsl:choose>
        <!--BBC - this may be useful in generating techniques slices, so leaving it in for now -->
        <xsl:when test="$slices = 'tech'">
          <xsl:apply-templates select="head" mode="text"/>
        </xsl:when>
        <xsl:otherwise>
          <a>
            <xsl:attribute name="href"><xsl:call-template name="href.target"><xsl:with-param name="target" select="."/></xsl:call-template></xsl:attribute>
            <xsl:apply-templates select="head" mode="text"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$toc.level &gt; 1">
        <xsl:variable name="children1">
          <xsl:value-of select="count(div2)"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$children1 = 0"/>
          <xsl:otherwise>
            <ul class="toc">
              <xsl:for-each select="div2[not(@diff = 'del')]">
                <li>
                  <xsl:apply-templates select="." mode="divnum"/>
                  <a>
                    <xsl:attribute name="href"><xsl:call-template name="href.target"><xsl:with-param name="target" select="."/></xsl:call-template></xsl:attribute>
                    <xsl:choose>
                      <xsl:when test="@id='perceivable'">1 Perceivable</xsl:when>
                      <xsl:when test="@id='operable'">2 Operable</xsl:when>
                      <xsl:when test="@id='understandable'">3 Understandable</xsl:when>
                      <xsl:when test="@id='robust'">4 Robust</xsl:when>
                      <xsl:otherwise><xsl:apply-templates select="head" mode="text"/></xsl:otherwise>
                    </xsl:choose>
                    
                  </a>
                  <xsl:if test="$toc.level &gt; 2">
                    <xsl:variable name="children2">
                      <xsl:value-of select="count(div3[@role!='front'])"/>
                    </xsl:variable>
                    <xsl:choose>
                      <xsl:when test="$children2 = 0"/>
                      <xsl:otherwise>
                        <ul class="toc">
                          <xsl:for-each select="div3[@role!='front']">
                            <li>
                              <xsl:apply-templates select="." mode="divnum-alt"/>
                              <a>
                                <xsl:attribute name="href"><xsl:call-template name="href.target"><xsl:with-param name="target" select="."/></xsl:call-template></xsl:attribute>
                                <xsl:apply-templates select="head" mode="text"/>
                              </a>
                            </li>
                          </xsl:for-each>
                        </ul>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:if>
                </li>
              </xsl:for-each>
            </ul>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </li>
              </xsl:template>
  <!-- BBC: modified to make Appendix TOCs into actual lists -->
  <xsl:template mode="toc" match="inform-div1">
    <li>
      <xsl:apply-templates select="." mode="divnum"/>
      <a>
        <xsl:attribute name="href"><xsl:call-template name="href.target"><xsl:with-param name="target" select="."/></xsl:call-template></xsl:attribute>
        <xsl:apply-templates select="head" mode="text"/>
      </a>
      <xsl:if test="@role='normative'">
        <xsl:text> (Normative)</xsl:text>
      </xsl:if>
    </li>
    <xsl:text> </xsl:text>
  </xsl:template>
  <!-- status: the status of the spec -->
  <!-- BBC modified to include paragraph in status section reflecting review copy status -->
  <xsl:template match="status">
    <div>
      <xsl:text>
</xsl:text>
      <h2>
        <xsl:call-template name="anchor">
          <xsl:with-param name="conditional" select="0"/>
          <xsl:with-param name="default.id" select="'status'"/>
        </xsl:call-template>
        <xsl:text>Status of This Document</xsl:text>
      </h2>
      <xsl:choose>
        <xsl:when test="/spec/@w3c-doctype='review'">
          <p>
            <strong>This document is the internal working draft used by the <acronym title="Web Content Accessibility Guidelines Working Group">WCAG WG</acronym> and is updated continuously and without notice. This document has no formal standing within W3C. Please consult the <a href="http://www.w3.org/WAI/GL/">group's home page</a> and the <a href="http://www.w3.org/TR/">W3C technical reports index</a> for information about the latest publications by this group.</strong>
          </p>
            <p>This draft includes revisions that have been made since the <a href="http://www.w3.org/TR/2008/CR-WCAG20-20080430/">30 April 2008 Candidate Recommendation</a> was published.  Please refer to the <a href="/TR/WCAG20/">latest public version of WCAG 2.0</a> for information about the status of WCAG 2.0 as well as information about submitting comments to the working group.</p>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>
  <!-- BBC: pulled this in to call a variation on the "css" template with custom styles -->
  <xsl:template match="spec">
    <xsl:choose>
      <xsl:when test="$bytech = 1">
<!--BBC: This is kind of a kludge, but it gets around the problem of having to redefine a bunch of templates to make the listing by technology work. Note that it will need to updated the CSS or other slice templates change--> 
        <html>
        	<xsl:if test="/spec/header/langusage/language">
        		<xsl:attribute name="lang"><xsl:value-of select="/spec/header/langusage/language/@id"/></xsl:attribute>
        		<xsl:attribute name="xml:lang"><xsl:value-of select="/spec/header/langusage/language/@id"/></xsl:attribute>
        	</xsl:if>
        	<head>
            <title>
              <xsl:value-of select="//header/title"/>  | Techniques for WCAG 2.0
            </title>
        		<xsl:call-template name="canonical-link"/>
            <link rel="stylesheet" type="text/css" href="slicenav.css"/>
            
            <xsl:call-template name="css"/>
        		<xsl:call-template name="additional-head"/>
            <xsl:if test="$show.diff.markup != 0">
              <script type="text/javascript" src="diffmarks.js"><xsl:text> </xsl:text></script>
              <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="diffs.css" />
            </xsl:if>
          </head>
          <body class="slices">
            <div id="masthead">
            	<p class="logo"><a href="http://www.w3.org/"><img width="72" height="48" alt="W3C" src="https://www.w3.org/StyleSheets/TR/2016/logos/W3C"/></a></p>
              <p class="collectiontitle"><a href="./">Techniques for WCAG 2.0</a></p></div>
            <div id="skipnav"><p class="skipnav"><a href="#maincontent">Skip to Content (Press Enter)</a></p></div>
            <a name="top"><xsl:text> </xsl:text> </a>
            <!-- TOP NAVIGATION BAR
            <ul id="navigation"><li><strong><a href="Overview#contents" title="Table of Contents">Contents</a></strong></li><li><strong><a href="intro" title="Introduction to Techniques for WCAG 2.0"><abbr title="Introduction">Intro</abbr></a></strong></li></ul> -->
            <div class="div1"><a name="maincontent"> </a>
              <h1 id="techs"> <xsl:value-of select="//header/title"/> for WCAG 2.0</h1>
            	<p>This Web page lists <xsl:value-of select="//header/title"/> from <a href="Overview.html">Techniques for WCAG 2.0: Techniques and Failures for Web Content Accessibility Guidelines 2.0</a>. Technology-specific techniques do not replace the general techniques: content developers should consider both general techniques and technology-specific techniques as they work toward conformance.</p>
            	<p>Publication of techniques for a specific technology does not imply that the technology can be used in all situations to create content that meets WCAG 2.0 success criteria and conformance requirements. Developers need to be aware of the limitations of specific technologies and provide content in a way that is accessible to people with disabilities. </p>
            	<p>For information about the techniques, see <a href="intro.html">Introduction to Techniques for WCAG 2.0</a>. For a list of techniques for other technologies, see the <a href="Overview.html#contents">Table of Contents</a>.</p>
            <xsl:apply-templates/>
            </div>
          	<xsl:if test="$show.diff.markup != 0">
          		<div class="diff-delete"><span class="difftext">[begin delete] </span>
          			<xsl:call-template name="techniques.informative.disclaimer"/>
          			<span class="difftext">[end delete]</span></div>
          		<hr />
          	</xsl:if>
          	<div class="footer"><p class="copyright">This Web page is part of <a href="Overview.html">Techniques for WCAG 2.0</a>. The entire document is also available as a <a href="complete.html">single HTML file</a>. See the <a href="http://www.w3.org/WAI/intro/wcag20">The WCAG 2.0 Documents</a> for an explanation of how this document fits in with other Web Content Accessibility Guidelines (WCAG) 2.0 documents.
          	</p><p class="copyright"><a href="http://www.w3.org/Consortium/Legal/ipr-notice#Copyright">Copyright</a> © <xsl:apply-templates select="//pubdate/year"/><xsl:text> </xsl:text><a href="http://www.w3.org/"><acronym title="World Wide Web Consortium">W3C</acronym></a><sup>®</sup> (<a href="http://www.csail.mit.edu/"><acronym title="Massachusetts Institute of Technology">MIT</acronym></a>, <a href="http://www.ercim.eu/"><acronym title="European Research Consortium for Informatics and Mathematics">ERCIM</acronym></a>, <a href="http://www.keio.ac.jp/">Keio</a>, <a href="http://ev.buaa.edu.cn/">Beihang</a>). W3C <a href="http://www.w3.org/Consortium/Legal/ipr-notice#Legal_Disclaimer">liability</a>, <a href="http://www.w3.org/Consortium/Legal/ipr-notice#W3C_Trademarks">trademark</a> and <a href="http://www.w3.org/Consortium/Legal/copyright-documents">document use</a> rules apply.</p></div><script src="//www.w3.org/scripts/TR/2016/fixup.js" type="text/javascript"></script></body></html>
      </xsl:when>
      <xsl:otherwise>
        <html>
        	<xsl:if test="/spec/header/langusage/language">
        		<xsl:attribute name="lang"><xsl:value-of select="/spec/header/langusage/language/@id"/></xsl:attribute>
        		<xsl:attribute name="xml:lang"><xsl:value-of select="/spec/header/langusage/language/@id"/></xsl:attribute>
        	</xsl:if>
        	<head>
            <title>
              <xsl:value-of select="header/title"/>
              <xsl:if test="header/version">
                <xsl:text> </xsl:text>
                <xsl:value-of select="header/version"/>
              </xsl:if>
              <xsl:if test="$additional.title != ''">
                <xsl:text> -- </xsl:text>
                <xsl:value-of select="$additional.title"/>
              </xsl:if>
            </title>
        		<xsl:call-template name="canonical-link"/>
            <xsl:call-template name="css"/>
        		<xsl:call-template name="additional-head"/>
            <xsl:if test="$show.diff.markup != 0">
              <script type="text/javascript" src="diffmarks.js"><xsl:text> </xsl:text></script>
                <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="diffs.css" />
            </xsl:if>
          </head>
          <body>
            <xsl:if test="$show.diff.markup != 0">
              <xsl:attribute name="onload">jscheck()</xsl:attribute>
            </xsl:if>
            <xsl:if test="$show.diff.markup != 0">
              <div id="diffexp">
                <p class="screenreader">This document is a draft, and is designed to show changes from a previous version. It is presently showing <span class="diff-add">added text,</span> <span class="diff-change">changed text,</span> <span class="diff-delete">deleted text,</span><span class="difftext">[start]/[end] markers,</span> <span class="issue">and Issue Numbers</span>.</p>
                <p class="options"><a href="#" onclick="javascript:hideClass('diff-delete'); hideClass('issue'); hideClass('difftext');showClean('diff-change');showClean('diff-add')">Hide<!--Show-->&#160;All&#160;Edits</a> &#160; | &#160; <a href="#" onclick="javascript:toggleClass('diff-delete')">Toggle&#160;Deletions</a>&#160; | &#160; <a href="#"  onclick="javascript:toggleClass('issue')">Toggle&#160;Issue&#160;Numbers</a> &#160; | &#160; <a href="#" onclick="javascript:toggleClass('difftext')">Toggle<!--Hide-->&#160;[start]/[end]&#160;Markers</a> <!--&#160; | &#160; <a href="#">Show&#160;All&#160;Edits</a>-->&#160; | &#160; <a href="#" onclick="javascript:showClass('issue');showClass('diff-delete');showClass('difftext');showChange('diff-change');showAdd('diff-add')">Show&#160;All&#160;Edits</a></p><p class="state">Changes are displayed as follows:</p><ul>     <li> <span class="diff-add"><span class="difftext"> [begin add]</span> new, added text <span class="difftext">[end add] </span></span></li>     <li><span class="diff-change"><span class="difftext"> [begin change]</span> changed text <span class="difftext">[end change], </span></span></li>     <li><span class="diff-delete"><span class="difftext"> [begin delete]</span> deleted text <span class="difftext">[end delete] </span></span></li></ul>        
              </div>
            </xsl:if>
            <!-- BBC a plain old apply-templates item here will put things back the way they're supposed to be... 
              
              <h1>WCAG 2.0 Conformance Proposals for 04 January 2007</h1>
              <p><em>Updated 18 January based on survey comments and meeting resolutions.</em></p>
              <p>The following is a set of draft revisions for the conformance section of WCAG 2.0. It includes an updated version of the conformance and glossary sections. For the most up-to-date version of WCAG 2.0, please refer to the <a href="http://w3.org/WAI/GL/WCAG20/">latest internal working draft</a>.</p> 
              <div id="toc">
              <hr/><h2><a id="contents" name="contents"> </a>Table of Contents</h2><ul class="toc"><li><a href="#conformance">Conformance</a>
              <ul class="toc">
              <li><a href="#ua-tech"> User agents, technology-independence and "relied upon" technologies 
              </a></li>
              <li><a href="#conformance-reqs">Conformance requirements</a></li>
              <li><a href="#conformance-claims">Conformance claims</a></li>
              <li><a href="#conformance-wcag1">Content that conforms to WCAG 1.0</a></li>
              </ul>
              </li>
              <li><ul class="toc"><li></li></ul></li></ul>
              <h3><a id="appendices" name="appendices"> </a>Appendices</h3><ul class="toc"><li>Appendix A: <a href="#glossary">Glossary</a> (Normative)</li> <li></li> </ul>
              
              </div>
              <hr/>
              <xsl:apply-templates select="//front/div1[@id='conformance']"/>
              <xsl:apply-templates select="//back/inform-div1[@id='glossary']"/>-->
            <xsl:apply-templates/>
            <xsl:if test="//footnote[not(ancestor::table)]">
              <div class="endnotes">
              	<hr/>
              	<xsl:text> </xsl:text>
                <h3>
                  <xsl:call-template name="anchor">
                    <xsl:with-param name="conditional" select="0"/>
                    <xsl:with-param name="default.id" select="'endnotes'"/>
                  </xsl:call-template>
                  <xsl:text>End Notes</xsl:text>
                </h3>
                <dl>
                  <xsl:apply-templates select="//footnote[not(ancestor::table)]" mode="notes"/>
                </dl>
              </div>
            </xsl:if>
          	<script src="//www.w3.org/scripts/TR/2016/fixup.js" type="text/javascript"></script>
          </body>
        </html>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--BBC - pulled in glist to resolve xmlns issue -->
  <!-- glist: glossary list -->
  <!-- create <dl> and handle children -->
  <xsl:template match="glist">
    <xsl:if test="$validity.hacks = 1 and local-name(..) = 'p'">
      <xsl:text disable-output-escaping="yes">&lt;/p&gt;</xsl:text>
    </xsl:if>
    <dl>
      <xsl:apply-templates/>
    </dl>
    <xsl:if test="$validity.hacks = 1 and local-name(..) = 'p'">
      <xsl:text disable-output-escaping="yes">&lt;p&gt;</xsl:text>
    </xsl:if>
  </xsl:template>
  <!-- BBC some modifications to how numbering gets handling in mode: divnum -->
  <!-- mode: divnum -->
  <xsl:template mode="divnum" match="div1 | div2">
    <!--<xsl:number format="1 "/>-->
  </xsl:template>
    <xsl:template mode="divnum-specref" match="div1 | div2">
    <xsl:apply-templates select="head" mode="text"/>
  </xsl:template>
  <xsl:template mode="divnum" match="back/div1 | inform-div1">Appendix <xsl:number count="div1 | inform-div1" format="A"/>: </xsl:template>
  <xsl:template mode="divnum" match="front/div1 | front//div2 | front//div3 | front//div4 | front//div5"/>
  <!-- BBC commented out b/c numbering is not needed at this level -->
  <xsl:template mode="divnum" match="div3 | technique"> 	Guideline <xsl:number level="multiple" count="div2 | div3" format="1.1"/>
    <xsl:text> </xsl:text><xsl:call-template name="sc-handle">
          <xsl:with-param name="handleid" select="@id"/>
        </xsl:call-template>:<xsl:text> </xsl:text>
  </xsl:template>
  <!--BBC: Created to fix extra spaces for inline specrefs -->
  <xsl:template mode="divnum-specref" match="div3 | technique">Guideline <xsl:number level="multiple" count="div2 | div3" format="1.1"/></xsl:template>
	<xsl:template mode="divnum-specref" match="div3[head/@role = 'cc']">Conformance Requirement <xsl:value-of select="count(preceding-sibling::div3[not(@diff = 'del')]) + 1"/>: <xsl:value-of select="head"/></xsl:template>
  <xsl:template mode="divnum-alt" match="div3 | technique"> <xsl:number level="multiple" count="div2 | div3" format="1.1"/>
    <xsl:text> </xsl:text>
  </xsl:template>
  <xsl:template mode="divnum" match="back//div2"/>
  <xsl:template mode="divnum" match="back//div3"/>
  <!-- BBC modified to do automatic header insertion and numbering for required and best practice SC headings-->
  <xsl:template mode="divnum" match="div4">
    <xsl:choose>
      <xsl:when test="@role='req'">Level 1 Success Criteria for Guideline <xsl:number level="multiple" count="div2[@role='principle'] | div3" format="1.1"/>
      </xsl:when>
      <xsl:when test="@role='bp'">Level 2 Success Criteria for Guideline <xsl:number level="multiple" count="div2[@role='principle'] | div3" format="1.1"/>
      </xsl:when>
      <xsl:when test="@role='additional'">Level 3 Success Criteria for Guideline <xsl:number level="multiple" count="div2[@role='principle'] | div3" format="1.1"/>
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!--<xsl:number level="multiple" count="div1 | div2 | div3 | div4 " format="1.1.1.1 "/>-->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template mode="divnum" match="div5">
    <xsl:number level="multiple" count="div2 | div3 | div5" format="1.1.1 "/>
  </xsl:template>
  <!-- BBC revised editor's note to remove table data -->
  <!-- ednote: editors' note -->
  <xsl:template match="ednote">
    <xsl:if test="$show.ednotes != 0">
      <div class="revnote">
        <p>
          <xsl:call-template name="anchor"/>
          <strong>
            <xsl:choose>
              <xsl:when test="@role='CR'">
                <xsl:text>Candidate Recommendation Process Note</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>Editorial Note</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="name">
              <xsl:text>:</xsl:text>
              <xsl:apply-templates select="name"/>
            </xsl:if>
          </strong>
          <xsl:choose>
            <xsl:when test="date"> 								 (<xsl:apply-templates select="date"/>):  							</xsl:when>
            <xsl:otherwise>: </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates select="edtext|issue"/>
        </p>
        <xsl:apply-templates select="p|olist|ulist|slist"/>
      </div>
    </xsl:if>
  </xsl:template>
  <!-- revised to address a bug in Home Page Reader where page skips all over the place with xhtml-style closed named anchors -->
  <xsl:template name="object.id">
    <xsl:param name="node" select="."/>
    <xsl:param name="default.id" select="''"/>
    <xsl:choose>
      <!-- can't use the default ID if it's used somewhere else in the document! -->
      <xsl:when test="$default.id != '' and not(key('ids', $default.id))">
        <xsl:value-of select="$default.id"/>
      </xsl:when>
      <xsl:when test="$node/@id">
        <xsl:value-of select="$node/@id"/>
      </xsl:when>
      <xsl:otherwise>
      	<xsl:message terminate="yes">Generating ID for <!--"<xsl:value-of select="$node"/>"<xsl:text>: </xsl:text>--><xsl:call-template name="genPath"/></xsl:message>
        <xsl:value-of select="generate-id($node)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="anchor">
    <xsl:param name="node" select="."/>
    <xsl:param name="conditional" select="1"/>
    <xsl:param name="default.id" select="''"/>
    <xsl:variable name="id">
      <xsl:call-template name="object.id">
        <xsl:with-param name="node" select="$node"/>
        <xsl:with-param name="default.id" select="$default.id"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$conditional = 0 or $node/@id">
      <a name="{$id}" id="{$id}">
        <xsl:text> </xsl:text>
      </a>
    </xsl:if>
  </xsl:template>
  <!-- 20040114 - BBC added processing instructions for abbr so that it is output as acronym (for current browser support) -->
  <!-- this could be expanded to address the differences between abbreviations and acronyms, but hasn't been done here since acronym -->
  <!-- seems to be the only reliably supported method for marking up either at the moment.-->
  <!-- take expansion attribute and put it in title attribute -->
  <xsl:template match="abbr">
    <acronym>
      <xsl:if test="@expansion">
        <xsl:attribute name="title"><xsl:value-of select="@expansion"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </acronym>
  </xsl:template>
  <xsl:template match="issue">
    <xsl:if test="$show.issue.links != '0'">
      <span class="issue">
        <!--xsl:if test="@id">
				<a name="{@id}"> </a>
			</xsl:if--> 				 					[<a href="http://trace.wisc.edu/bugzilla_wcag/issuereports/issue_ind.php?id={p}"><xsl:value-of select="p"/>
        </a>]			 			<!--</p> 			<xsl:apply-templates/> 			<xsl:if test="not(resolution)"> 				<p class="prefix"> 					<strong> 						<xsl:text>Resolution:</xsl:text> 					</strong> 				</p> 				<p>None recorded.</p> 			</xsl:if>-->
      </span>
    </xsl:if>
  </xsl:template>
  <!-- emph: in-line emphasis -->
  <!-- equates to HTML <em> -->
  <!-- the role attribute could be used for multiple kinds of
       emphasis, but that would not be kind -->
  <!-- BBC - Might not be kind, but this was the simplest way to get at the need for <strong> and <em> -->
  <xsl:template match="emph">
    <xsl:choose>
      <xsl:when test="@role='italic'">
        <em>
          <xsl:apply-templates/>
        </em>
      </xsl:when>
      <xsl:when test="@role='bold'">
        <strong>
          <xsl:apply-templates/>
        </strong>
      </xsl:when>
      <xsl:when test="@role='bolditalic'">
        <strong>
          <em>
            <xsl:apply-templates/>
          </em>
        </strong>
      </xsl:when>
      <xsl:when test="@role='sc-handle'">
        <strong class="sc-handle">
          <xsl:apply-templates/>
        </strong>
      </xsl:when>
      <xsl:otherwise>
        <em>
          <xsl:apply-templates/>
        </em>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="p[@id='copy-seizure-warning-paragraph']">
    <p>
      <xsl:apply-templates select="$gl-src//spec/body/div1/div2/div3/div4/div5/p[@id='seizure-warning-paragraph']" mode="text"/>
    </p>
  </xsl:template>
  <!-- BBC 20051025 - leave informative sections out for now-->
  <xsl:template match="div4[@role='informative']">  </xsl:template>
  <!-- BBC 20051025 - add a classname to terms so that they are distinct from other links-->
  <!-- termref: reference to a defined term -->
  <xsl:template match="termref">
    <a title="definition: {key('ids', @def)/label}">
      <xsl:attribute name="href"><xsl:call-template name="href.target"><xsl:with-param name="target" select="key('ids', @def)"/></xsl:call-template></xsl:attribute>
      <xsl:attribute name="class">termref</xsl:attribute>
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  <!-- BBC 20051028 - truncated the default - we typically refer to "guideline n.n in notes, so the entire head isn't needed eventually, it might be nice to add a parameter so that divnum can be called in a way that it generates lowercase only output using translate(), but am leaving that for another time. -->
  <xsl:template match="div1|div2|div3|div4|div5" mode="specref">
    <a>
      <xsl:attribute name="href"><xsl:call-template name="href.target"/></xsl:attribute>
      <xsl:apply-templates select="." mode="divnum-specref"/><!--xsl:apply-templates select="head" mode="text"/--></a>
  </xsl:template>
  	<xsl:template match="div5[@role='sc']" mode="specref">
		<a xmlns="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="href"><xsl:call-template name="href.target"/></xsl:attribute>
				Success Criterion <xsl:call-template name="sc-number"><xsl:with-param name="criterion" select="."/></xsl:call-template>
		</a>
	</xsl:template>
  <!--BBC handle div4 such that placeholders are inserted when no SC are present at each level. Also includes code for toggling on and off the links to bugzilla -->
  <xsl:template match="div4">
    <xsl:choose>
      <xsl:when test="@role='informative'">
        <div class="informative">
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:when test="@role='additional'">
        <div class="additional">
          <xsl:apply-templates/>
          <xsl:choose>
            <xsl:when test="./div5" />
            <xsl:otherwise>
              <!--p>
								(No level 3 success criteria for Guideline <xsl:number level="multiple" count="div2[@role='principle'] | div3" format="1.1"/>)
							</p-->
            </xsl:otherwise>
          </xsl:choose>
        </div>
        <!--BBC - added a test and parameter to allow links to issue reports to be included/excluded from the draft
				<xsl:if test="$show.issue.links != '0'">
					<xsl:variable name="glid">
						<xsl:value-of select="../@id"/>
					</xsl:variable>
					<p>
						<a href="http://trace.wisc.edu/bugzilla_wcag/issuereports/{$glid}_issues.php">Guideline <xsl:number level="multiple" count="div2 | div3" format="1.1 "/>(<xsl:value-of select="$glid"/>) Issues</a>
					</p>
				</xsl:if>-->
      </xsl:when>
      <xsl:when test="@role='bp'">
        <div class="bp">
          <xsl:apply-templates/>
          <xsl:choose>
            <xsl:when test="./div5" />
            <xsl:otherwise>
              <!--p>
								(No level 2 success criteria for Guideline <xsl:number level="multiple" count="div2[@role='principle'] | div3" format="1.1"/>)
							</p-->
            </xsl:otherwise>
          </xsl:choose>
        </div>
      </xsl:when>
      <xsl:when test="@role='req'">
        <div class="req">
          <xsl:apply-templates/>
          <xsl:choose>
            <xsl:when test="../@role='group2'">
              <!--p>
								(No level 1 success criteria for this guideline)
							</p-->
            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div class="div4">
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--BBC add classes for principle and guideline headings -->
  <xsl:template match="div2/head">
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="../@role='principle'">
        <h2 class="principle">
          <xsl:call-template name="anchor">
            <xsl:with-param name="conditional" select="0"/>
            <xsl:with-param name="node" select=".."/>
          </xsl:call-template>
          <xsl:apply-templates/>
        </h2>
      </xsl:when>
      <xsl:otherwise>
        <h3>
          <xsl:call-template name="anchor">
            <xsl:with-param name="conditional" select="0"/>
            <xsl:with-param name="node" select=".."/>
          </xsl:call-template>
          <xsl:apply-templates select=".." mode="divnum"/>
          <xsl:apply-templates/>
        </h3>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- BBC added test for differntiating checkpoints from other h3 headings -->

    <xsl:template match="div3/head">
    <xsl:choose>
      <xsl:when test="../@role='front'">
      <xsl:choose>
        <xsl:when test="@role='suppressed'">
          <!-- This gets around the problem of paragraphs at the end of sections (ex. see also at the end of a div2 that shouldn't be a subset of a div3 in the conformance section.-->
        </xsl:when>
        <xsl:when test="@role='cc'"><xsl:call-template name="anchor">
            <xsl:with-param name="conditional" select="0"/>
            <xsl:with-param name="node" select=".."/>
          </xsl:call-template></xsl:when>
        <xsl:otherwise><h4>
          <xsl:call-template name="anchor">
            <xsl:with-param name="conditional" select="0"/>
            <xsl:with-param name="node" select=".."/>
          </xsl:call-template>
          <xsl:apply-templates/>
        </h4></xsl:otherwise>
      </xsl:choose> 
        
      </xsl:when>
      <xsl:otherwise>
		<xsl:variable name="filename"><xsl:apply-templates select="$guide-src//*[@id = current()/../@id]" mode="slice-understanding-filename"/></xsl:variable>
		<xsl:variable name="fragment"><xsl:if test="../@id != substring-before($filename, '.')">#<xsl:value-of select="../@id"/></xsl:if></xsl:variable>
          <div class="guideline">
          <h3>
          <xsl:call-template name="anchor">
            <xsl:with-param name="conditional" select="0"/>
            <xsl:with-param name="node" select=".."/>
          </xsl:call-template>
          <xsl:apply-templates select=".." mode="divnum"/>
          <xsl:apply-templates/>
          </h3>
              <p class="und-gl-link"><a href="{$guidethisversion}{$filename}{$fragment}">Understanding Guideline <xsl:number level="multiple" count="div2 | div3" format="1.1"/>
              </a></p>
          </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--BBC suppress header inclusion for div5 items-->
  <xsl:template match="div5/head">
    <xsl:choose>
      <xsl:when test="../@role='sc'"/>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="div4/head">
    <!-- BBC Check to see if there are level 2 or 3 items before generating header -->
    <xsl:choose>
     <xsl:when test="../div5[@role='sc']">
    </xsl:when>
    <xsl:otherwise>
<h4>
        <xsl:call-template name="anchor">
          <xsl:with-param name="conditional" select="0"/>
          <xsl:with-param name="node" select=".."/>
        </xsl:call-template>
        <xsl:apply-templates select=".." mode="divnum"/>
        <xsl:apply-templates/>
      </h4>    
    </xsl:otherwise>    </xsl:choose>
  </xsl:template>
  <xsl:template match="div5">
    <div class="sc" id="{@id}">
         
       <div class="scinner"><xsl:apply-templates/></div>
              <!-- BBC: Experimental updates to put HTM and UND links below the SC and all assoc. bullets and notes -->
        <div class="doclinks">
        <p class="supportlinks"><xsl:variable name="scnum"><xsl:call-template name="sc-number"><xsl:with-param name="criterion" select="."/></xsl:call-template></xsl:variable>
        <xsl:variable name="filename"><xsl:apply-templates select="$guide-src//*[@id = current()/@id]" mode="slice-understanding-filename"/></xsl:variable>
        <xsl:variable name="fragment"><xsl:if test="@id != substring-before($filename, '.')">#<xsl:value-of select="@id"/></xsl:if></xsl:variable>
            <a href="{$quickrefthisversion}#qr-{@id}" class="HTMlink" title="How to Meet Success Criterion {$scnum}">How to Meet <xsl:call-template name="sc-number"><xsl:with-param name="criterion" select="."/></xsl:call-template>
            </a>
         <xsl:text> </xsl:text>
            <span class="screenreader">|</span>
        <xsl:text> </xsl:text>
            <a href="{$guidethisversion}{$filename}{$fragment}" class="HTMlink" title="Understanding Success Criterion {$scnum}">Understanding <xsl:call-template name="sc-number"><xsl:with-param name="criterion" select="."/></xsl:call-template>
        </a></p></div>
       
       

    </div>
  </xsl:template>
  <!-- BBC added some code here to handle the glossary appendix  - this seems to not be supported in xsltproc (alpha order won't mix cases, so have switched to xalan. -->
  <xsl:template match="glist[@id='terms']">
    <dl>
      <xsl:for-each select="/spec/back/inform-div1/glist/gitem">
        <xsl:apply-templates/>
      </xsl:for-each>
    </dl>
  </xsl:template>
  <xsl:template match="p[@role='indent']">
    <p class="indented">
      <xsl:apply-templates />
    </p>
    </xsl:template>
    <!-- BBC apply the sctxt class where spacing is an issue (ex. conformance reqs and claims section) -->
    <xsl:template match="p[@role='sctxt']">
        <p class="sctxt">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <!-- BBC added some functinality to number SC and included a test so that public drafts reference the latest version while internal drafts reference this version -->
  <xsl:template match="p[@role='i'] | p[@role='v']">
    <p class="sctxt">
      <xsl:if test="@id">
        <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
      </xsl:if>
      <strong class="sc-handle">
        <xsl:choose>
          <xsl:when test="$guide='0'"><xsl:call-template name="sc-number-link"><xsl:with-param name="criterion" select=".."/></xsl:call-template></xsl:when>
          <xsl:otherwise><xsl:call-template name="sc-number"><xsl:with-param name="criterion" select=".."/></xsl:call-template></xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
        <xsl:call-template name="sc-handle">
          <xsl:with-param name="handleid" select="../@id"/>
        </xsl:call-template>
        <xsl:text>:</xsl:text>
      </strong>
      <xsl:text> </xsl:text>
      <xsl:apply-templates/>
      <xsl:text> </xsl:text>
      <xsl:if test="$guide='1'">
(Level <xsl:choose>
          <xsl:when test="ancestor::div4[@role='req']">A</xsl:when>
          <xsl:when test="ancestor::div4[@role='bp']">AA</xsl:when>
          <xsl:when test="ancestor::div4[@role='additional']">AAA</xsl:when>
        </xsl:choose>)      
      </xsl:if>
      <xsl:if test="$guide='0'">
					(Level <xsl:choose>
          <xsl:when test="ancestor::div4[@role='req']">A</xsl:when>
          <xsl:when test="ancestor::div4[@role='bp']">AA</xsl:when>
          <xsl:when test="ancestor::div4[@role='additional']">AAA</xsl:when>
        </xsl:choose>)
				</xsl:if>
    </p>
  </xsl:template>
  <xsl:template match="p[@role='cc']">
    <p class="sctxt">
      <xsl:if test="@id">
        <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
      </xsl:if>
      <strong class="sc-handle">
        <xsl:call-template name="cc-number"/>.<xsl:text> </xsl:text>
        <xsl:call-template name="sc-handle">
          <xsl:with-param name="handleid" select="../@id"/>
        </xsl:call-template>
        <xsl:text>:</xsl:text>
      </strong>
      <xsl:text> </xsl:text>
      <xsl:apply-templates/>
      <xsl:text> </xsl:text>
      <xsl:if test="$guide='1'">
      </xsl:if>
    </p>
  </xsl:template>
	<xsl:template name="sc-number">
    <xsl:param name="id" select="../@id"/>
    <xsl:param name="criterion" select="$gl-src//*[@id = $id]"/>
    <xsl:choose>
      <xsl:when test="$criterion/ancestor::div4[@role='bp']">
        <xsl:variable name="sc" select="count($criterion/ancestor::div3/div4[@role='req']/div5) + 1"/>
        <xsl:value-of select="concat(count($criterion/ancestor::div2/preceding-sibling::div2) + 1, '.', count($criterion/ancestor::div3/preceding-sibling::div3) + 1, '.', count($criterion/ancestor-or-self::div5/preceding-sibling::div5) + $sc)"/>
      </xsl:when>
      <xsl:when test="$criterion/ancestor::div4[@role='additional']">
        <xsl:variable name="sc" select="count($criterion/ancestor::div3/div4[@role='req']/div5) + count($criterion/ancestor::div3/div4[@role='bp']/div5) + 1"/>
        <xsl:value-of select="concat(count($criterion/ancestor::div2/preceding-sibling::div2) + 1, '.', count($criterion/ancestor::div3/preceding-sibling::div3) + 1, '.', count($criterion/ancestor-or-self::div5/preceding-sibling::div5) + $sc)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(count($criterion/ancestor::div2/preceding-sibling::div2) + 1, '.', count($criterion/ancestor::div3/preceding-sibling::div3) + 1, '.', count($criterion/ancestor-or-self::div5/preceding-sibling::div5) + 1)"/>
      </xsl:otherwise>
    </xsl:choose>
	</xsl:template>
	<xsl:template name="sc-number-link">
		<xsl:param name="id" select="../@id"/>
		<xsl:param name="criterion" select="$gl-src//*[@id = $id]"/>
		<a href="{$gl-src//latestloc/loc}#{$id}"><xsl:call-template name="sc-number"><xsl:with-param name="id" select="$id"/><xsl:with-param name="criterion" select="$criterion"/></xsl:call-template></a>
	</xsl:template>
  <xsl:template name="cc-number">
    <xsl:value-of select="count(preceding::p[@role='cc']) + 1"/>
  </xsl:template>
  <!--BBC: Added a template to include short-names. -->
  <xsl:template name="sc-handle">
    <xsl:param name="handleid"/>
    <xsl:variable name="handle">
    <xsl:choose>
    <!-- GL handles -->
 <xsl:when test="$handleid='text-equiv'">Text Alternatives</xsl:when>
<xsl:when test="$handleid='media-equiv'">Time-based Media</xsl:when>
<xsl:when test="$handleid='content-structure-separation'">Adaptable</xsl:when>
<xsl:when test="$handleid='visual-audio-contrast'">Distinguishable</xsl:when>
<xsl:when test="$handleid='keyboard-operation'">Keyboard Accessible</xsl:when>
<xsl:when test="$handleid='time-limits'">Enough Time</xsl:when>
<xsl:when test="$handleid='seizure'">Seizures</xsl:when>
<xsl:when test="$handleid='navigation-mechanisms'">Navigable</xsl:when>
<xsl:when test="$handleid='meaning'">Readable</xsl:when>
<xsl:when test="$handleid='consistent-behavior'">Predictable</xsl:when>
<xsl:when test="$handleid='minimize-error'">Input Assistance</xsl:when>
<xsl:when test="$handleid='ensure-compat'">Compatible</xsl:when>
    
    <!-- SC handles -->
    <!-- replaced by using <head> of the SC -->
    <xsl:otherwise><xsl:value-of select="$gl-src//*[@id = $handleid]/head"/></xsl:otherwise></xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length(normalize-space($handle)) &gt; 0"><xsl:value-of select="$handle"/></xsl:when>
      <xsl:otherwise>@@</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="loc">
    <xsl:variable name="techanchor"><xsl:choose>
      <xsl:when test="@locn-note">#<xsl:value-of select="@locn-note"/></xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose></xsl:variable>
    <xsl:choose>
      <xsl:when test="@linktype='general'">
        <a href="{$techsthisversion}{@href}{$techanchor}" class="tech-ref">
          <xsl:value-of select="@href"/>: <xsl:apply-templates select="$techs-src//technique[@id=current()/@href]/short-name" mode="text"/>
        </a>
      </xsl:when>
      <xsl:when test="@linktype='html'">
        <a href="{$techsthisversion}{@href}{$techanchor}" class="tech-ref">
          <xsl:value-of select="@href"/>: <xsl:apply-templates select="$techs-src//technique[@id=current()/@href]/short-name" mode="text"/>
        </a>  (HTML)
			</xsl:when>
      <xsl:when test="@linktype='guideline'">
        <a href="{$glthisversion}#{@href}" class="gl-ref">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:when test="@linktype='glossary'">
        <a href="{$glthisversion}#{@href}" class="gl-ref">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:when test="@linktype='understanding'">
		<xsl:variable name="filename"><xsl:apply-templates select="$guide-src//*[@id = current()/@href]" mode="slice-understanding-filename"/></xsl:variable>
		<xsl:variable name="fragment"><xsl:if test="@href != substring-before($filename, '.')">#<xsl:value-of select="@href"/></xsl:if><xsl:if test="@locn-note">#<xsl:value-of select="@locn-note"/></xsl:if></xsl:variable>
        <a href="{$guidethisversion}{$filename}{$fragment}" class="understanding-ref">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:when test="@linktype='techniques'">
      	<xsl:variable name="filename"><xsl:apply-templates select="$techs-src//*[@id = current()/@href]" mode="slice-techniques-filename"/></xsl:variable>
      	<xsl:variable name="fragment"><xsl:if test="@href != substring-before($filename, '.')">#<xsl:value-of select="@href"/></xsl:if><xsl:if test="@locn-note">#<xsl:value-of select="@locn-note"/></xsl:if></xsl:variable>
        <a href="{$techsthisversion}{$filename}{$fragment}" class="tech-ref">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:when test="@linktype='text'">
        <a href="{$techsthisversion}{@href}{$techanchor}" class="tech-ref">
          <xsl:value-of select="@href"/>: <xsl:apply-templates select="$techs-src//technique[@id=current()/@href]/short-name" mode="text"/>
        </a>  (Text)
			</xsl:when>
      <xsl:when test="@linktype='css'">
        <a href="{$techsthisversion}{@href}{$techanchor}" class="tech-ref">
          <xsl:value-of select="@href"/>: <xsl:apply-templates select="$techs-src//technique[@id=current()/@href]/short-name" mode="text"/>
        </a>  (CSS)
			</xsl:when>
      <xsl:when test="@linktype='script'">
        <a href="{$techsthisversion}{@href}{$techanchor}" class="tech-ref">
          <xsl:value-of select="@href"/>: <xsl:apply-templates select="$techs-src//technique[@id=current()/@href]/short-name" mode="text"/>
        </a>  (Scripting)
			</xsl:when>
			<xsl:when test="@linktype='aria'">
			  <a href="{$techsthisversion}{@href}{$techanchor}" class="tech-ref">
          <xsl:value-of select="@href"/>: <xsl:apply-templates select="$techs-src//technique[@id=current()/@href]/short-name" mode="text"/>
        </a>  (ARIA)
			</xsl:when>
      <xsl:when test="@linktype='failure'">
        <a href="{$techsthisversion}{@href}{$techanchor}" class="tech-ref">
          <xsl:value-of select="@href"/>: <xsl:apply-templates select="$techs-src//technique[@id=current()/@href]/short-name" mode="text"/>
        </a>
      </xsl:when>
      <xsl:when test="@linktype='smil'">
        <a href="{$techsthisversion}{@href}{$techanchor}" class="tech-ref">
          <xsl:value-of select="@href"/>: <xsl:apply-templates select="$techs-src//technique[@id=current()/@href]/short-name" mode="text"/>
        </a> (SMIL)
			</xsl:when>
    	<xsl:when test="@linktype='flash'">
    	  <a href="{$techsthisversion}{@href}{$techanchor}" class="tech-ref">
    			<xsl:value-of select="@href"/>: <xsl:apply-templates select="$techs-src//technique[@id=current()/@href]/short-name" mode="text"/>
    		</a> (Flash)
    	</xsl:when>
    	<xsl:when test="@linktype='pdf'">
    	  <a href="{$techsthisversion}{@href}{$techanchor}" class="tech-ref">
    			<xsl:value-of select="@href"/>: <xsl:apply-templates select="$techs-src//technique[@id=current()/@href]/short-name" mode="text"/>
    		</a> (PDF)
    	</xsl:when>
    	<xsl:when test="@linktype='silverlight'">
    	  <a href="{$techsthisversion}{@href}{$techanchor}" class="tech-ref">
    			<xsl:value-of select="@href"/>: <xsl:apply-templates select="$techs-src//technique[@id=current()/@href]/short-name" mode="text"/>
    		</a> (Silverlight)
    	</xsl:when>
    	<xsl:when test="@linktype='examples'">
    	  <a href="/WAI/WCAG20/Techniques/working-examples/{ancestor::technique/@id}/{@href}" class="ex-ref">
            <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:when test="@linktype='tests'">
        <a href="test-files/{ancestor::technique/@id}/{@href}" class="test-ref">
          <xsl:apply-templates/>
        </a>
      </xsl:when>
      <xsl:when test="@linktype='server'">
        <a href="{$techsthisversion}{@href}{$techanchor}" class="tech-ref">
          <xsl:value-of select="@href"/>: <xsl:apply-templates select="$techs-src//technique[@id=current()/@href]/short-name" mode="text"/>
        </a> (SERVER)
			</xsl:when>
      <xsl:otherwise>
        <xsl:element name="a" namespace="http://www.w3.org/1999/xhtml">
          <xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
          <xsl:if test="@id">
            <xsl:attribute name="name"><xsl:value-of select="@id"/></xsl:attribute>
          </xsl:if>
          <xsl:if test="@role">
            <xsl:choose>
              <xsl:when test="@role='disclosures'">
                <xsl:attribute name="rel">disclosure</xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="class"><xsl:value-of select="@role"/></xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="altlocs">
      <!-- BBC: Suppress output of these links in diff-marked version -->
      <!--xsl:if test="$show.diff.markup = 1"-->
    <p>
      <xsl:text>This document is also available </xsl:text>
      <xsl:text>in these non-normative formats: </xsl:text>
    </p>
    <ul>
      <xsl:for-each select="loc">
        <li>
          <xsl:apply-templates select="."/>
          <xsl:if test="position() &gt; 1">
            <xsl:if test="last() &gt; 2">
              <xsl:text>,</xsl:text>
            </xsl:if>
            <xsl:text> </xsl:text>
            <xsl:if test="position() = last() - 1">and </xsl:if>
          </xsl:if>
        </li>
      </xsl:for-each>
    </ul>
          <!--/xsl:if-->
  </xsl:template>
  <xsl:template match="p" mode="label">
    <p class="sctxt">
      <xsl:if test="@id">
        <xsl:attribute name="id"><xsl:value-of select="@id"/>c</xsl:attribute>
      </xsl:if>
      <xsl:if test="@role">
        <xsl:attribute name="class"><xsl:value-of select="@role"/>c</xsl:attribute>
        <label for="{../@id}cb">
          <strong>
            <em>
              <xsl:call-template name="sc-number"/>
            </em>
          </strong>
          <xsl:text> </xsl:text>
          <xsl:apply-templates/>
          <xsl:text> </xsl:text>
          <xsl:if test="$guide='1'">
			<xsl:variable name="filename"><xsl:apply-templates select="$guide-src//*[@id = current()/../@id]" mode="slice-understanding-filename"/></xsl:variable>
			<xsl:variable name="fragment"><xsl:if test="../@id != substring-before($filename, '.')">#<xsl:value-of select="../@id"/></xsl:if></xsl:variable>
					[<xsl:choose>
              <xsl:when test="/spec/@w3c-doctype='review'">
				<a href="{$guidethisversion}{$filename}{$fragment}">
				  How to Meet <xsl:call-template name="sc-number"/>
				</a>
                <!--<a href="{$guidethisversion}Overview#{../@id}">How to Meet <xsl:call-template name="sc-number"/>
                </a>-->
              </xsl:when>
              <xsl:otherwise>
				<a href="/TR/UNDERSTANDING-WCAG20/{$filename}{$fragment}">
				  How to Meet <xsl:call-template name="sc-number"/>
				</a>
                <!--<a href="/TR/UNDERSTANDING-WCAG20/Overview#{../@id}">How to Meet <xsl:call-template name="sc-number"/>
                </a>-->
              </xsl:otherwise>
            </xsl:choose>]
				</xsl:if>
          <xsl:if test="$guide='0'">
					(Level <xsl:choose>
              <xsl:when test="ancestor::div4[@role='req']">1</xsl:when>
              <xsl:when test="ancestor::div4[@role='bp']">2</xsl:when>
              <xsl:when test="ancestor::div4[@role='additional']">3</xsl:when>
            </xsl:choose>)
				</xsl:if>
        </label>
      </xsl:if>
    </p>
     
  </xsl:template>
  <xsl:template match="def">
    <dd class="prefix">
      <xsl:apply-templates/>
    </dd>
  </xsl:template>
  <!--BBC: Added hadling for current vs. previous editors -->
  <xsl:template match="authlist">
    <dt>
      <xsl:text>Editor</xsl:text>
      <xsl:if test="count(author) &gt; 1">
        <xsl:text>s</xsl:text>
      </xsl:if>
      <xsl:text>:</xsl:text>
    </dt>
    <xsl:apply-templates select="author[@role='current']"/>
    <xsl:if test="child::author[@role='past']">
      <dt>
        <xsl:text>Previous Editor</xsl:text>
        <xsl:if test="count(author) &gt; 1">
          <xsl:text>s</xsl:text>
        </xsl:if>
        <xsl:text>:</xsl:text>
      </dt>
      <xsl:apply-templates select="author[@role='past']"/>
    </xsl:if>
  </xsl:template>
  <!-- author: an editor of a spec -->
  <!-- only appears in authlist -->
  <!-- called in <dl> context -->
  <xsl:template match="author">
    <dd>
      <xsl:apply-templates/>
      <xsl:if test="@role = '2e'">
        <xsl:text> - Second Edition</xsl:text>
      </xsl:if>
    </dd>
  </xsl:template>
  <xsl:template match="author[@role='current']">
    <dd>
      <xsl:apply-templates/>
      <xsl:if test="@role = '2e'">
        <xsl:text> - Second Edition</xsl:text>
      </xsl:if>
    </dd>
  </xsl:template>
  <xsl:template match="author[@role='past']">
    <dd>
      <xsl:apply-templates/>
      <xsl:if test="@role = '2e'">
        <xsl:text> - Second Edition</xsl:text>
      </xsl:if>
    </dd>
  </xsl:template>
  <!-- The following templates determine the filenames for each slice in the Understanding docs. Note that it's better to stick with using ids as filenames as some of the specref links get screwed up between multiple docs. -->
  <xsl:template match="spec" mode="slice-understanding-filename">
    <xsl:text>Overview.html</xsl:text>
  </xsl:template>
  <xsl:template match="front/div1[@id='intro']" mode="slice-understanding-filename">
    <xsl:text>intro.html</xsl:text>
  </xsl:template>
	<xsl:template match="front/div1[@id='understanding-techniques']" mode="slice-understanding-filename">
		<xsl:text>understanding-techniques.html</xsl:text>
	</xsl:template>
	<xsl:template match="body/div1[@id='conformance']" mode="slice-understanding-filename">
    <xsl:text>conformance.html</xsl:text>
  </xsl:template>
  <xsl:template match="body/div1[@role='extsrc'] | body/div1/div2 | body/div1/div2/div3" mode="slice-understanding-filename">
    <xsl:value-of select="@id"/>
    <xsl:text>.html</xsl:text>
  </xsl:template>
   <xsl:template match="back/div1 | back/inform-div1" mode="slice-understanding-filename">
    <xsl:variable name="docnumber">
      <xsl:number count="div1|inform-div1" level="multiple" format="A"/>
    </xsl:variable>
    <xsl:text>appendix</xsl:text>
    <xsl:value-of select="$docnumber"/>
    <xsl:text>.html</xsl:text>
  </xsl:template>
	<!-- When a node retrieved by id isn't the filename itself, walk up the tree to find the closest ancestor that is -->
  <xsl:template match="*" mode="slice-understanding-filename"><xsl:apply-templates select="parent::*" mode="slice-understanding-filename"/></xsl:template>
  
    <xsl:template match="*" mode="slice-techniques-filename"><xsl:apply-templates select="parent::*" mode="slice-understanding-filename"/></xsl:template>
    
  <xsl:template match="spec" mode="slice-techniques-filename">
    <xsl:text>Overview.html</xsl:text>
  </xsl:template>
  <xsl:template match="front/div1[@id='intro']" mode="slice-techniques-filename">
    <xsl:text>intro.html</xsl:text>
  </xsl:template>
  <xsl:template match="body/div1| body/div1/technique | body/div1/div2" mode="slice-techniques-filename">
    <xsl:value-of select="@id"/>
    <xsl:text>.html</xsl:text>
  </xsl:template>
   <xsl:template match="back/div1 | inform-div1" mode="slice-techniques-filename">
    <xsl:variable name="docnumber">
      <xsl:number count="div1|inform-div1" level="multiple" format="A"/>
    </xsl:variable>
    <xsl:text>appendix</xsl:text>
    <xsl:value-of select="$docnumber"/>
    <xsl:text>.html</xsl:text>
   </xsl:template>
    
    <!--BBC: Misc templates used for copying the definitions from guidelines into understanding definition X sections -->
    <xsl:template match="//p[@id='copywebpagedef']">
        <dl>
            <xsl:apply-templates select="$gl-src//gitem[@id='webpagedef']"/>
        </dl>
    </xsl:template>
    <xsl:template match="//p[@id='copyprogrammaticallydetermineddef']">
        <dl>
            <xsl:apply-templates select="$gl-src//gitem[@id='programmaticallydetermineddef']"/>
        </dl>
    </xsl:template>
    <xsl:template match="//p[@id='copyconforming-alternate-versiondef']">
        <dl>
            <xsl:apply-templates select="$gl-src//gitem[@id='conforming-alternate-versiondef']"/>
        </dl>
    </xsl:template>
    <xsl:template match="//p[@id='copyaccessibility-supporteddef']">
        <dl>
            <xsl:apply-templates select="$gl-src//gitem[@id='accessibility-supporteddef']"/>
        </dl>
    </xsl:template>
    <xsl:template match="//p[@id='copysynchronizedmediadef']">
        <dl>
            <xsl:apply-templates select="$gl-src//gitem[@id='synchronizedmediadef']"/>
        </dl>
    </xsl:template>
    <xsl:template match="//p[@id='satisfiesdef']">
        <dl>
            <xsl:apply-templates select="$gl-src//gitem[@id='satisfiesdef']"/>
        </dl>
    </xsl:template>
    <xsl:template match="//p[@id='conformancedef']">
        <dl>
            <xsl:apply-templates select="$gl-src//gitem[@id='conformancedef']"/>
        </dl>
    </xsl:template>
    <xsl:template match="//p[@id='processdef']">
        <dl>
            <xsl:apply-templates select="$gl-src//gitem[@id='processdef']"/>
        </dl>
    </xsl:template>
    <xsl:template match="//p[@id='technologydef']">
        <dl>
            <xsl:apply-templates select="$gl-src//gitem[@id='technologydef']"/>
        </dl>
    </xsl:template>
    <xsl:template match="//p[@id='reliedupondef']">
        <dl>
            <xsl:apply-templates select="$gl-src//gitem[@id='reliedupondef']"/>
        </dl>
    </xsl:template>
	
	<!-- The use-id attribute allows a substitute, complete element to replace a placeholder, so common content only needs to be edited once -->
  <xsl:template match="*[@use-id]" priority="1">
    <xsl:variable name="copied">
      <xsl:apply-templates select="id(@use-id)"/>
    </xsl:variable>
    <xsl:apply-templates select="$copied" mode="copy-without-id"/>
  </xsl:template>
  
  <xsl:template match="node()|@*" mode="copy-without-id">
    <xsl:copy>
      <xsl:apply-templates select="@*[name() != 'id']"/>
      <xsl:copy-of select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="techniques.informative.disclaimer">
		<div>
			<h2>Techniques are Informative</h2>
			<p>Techniques are informative—that means they are not required. The basis for determining conformance to WCAG 2.0 is the success criteria from the <a href="http://www.w3.org/TR/WCAG20/">WCAG 2.0 standard</a>—not the techniques. For important information about techniques, please see the <a href="{$guide-src//publoc/loc[@href]}understanding-techniques.html">Understanding Techniques for WCAG Success Criteria</a> section of Understanding WCAG 2.0.</p>
		</div>
	</xsl:template>
  
	<xsl:template name="techniques.information.reference">
		<xsl:param name="id"/>
		<div>
			<xsl:if test="$id">
				<xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
			</xsl:if>
			<h2>Important Information about Techniques</h2>
			<p>See <a href="{$guide-src//publoc/loc[@href]}understanding-techniques.html">Understanding Techniques for WCAG Success Criteria</a> for important information about the usage of these informative techniques and how they relate to the normative WCAG 2.0 success criteria. The Applicability section explains the scope of the technique, and the presence of techniques for a specific technology does not imply that the technology can be used in all situations to create content that meets WCAG 2.0.</p>
		</div>
	</xsl:template>
	
	<!-- Only output stuff suited to the current maturity -->
  <xsl:template match="*[@role = 'int-review' and /spec/@status != 'int-review']"/>
  <xsl:template match="*[@role = 'ext-review' and /spec/@status != 'ext-review']"/>
  <xsl:template match="*[@role = 'final' and /spec/@status != 'final']"/>

	<!-- ================================================================= -->
	
	<!-- Link to latest version of current page -->
	<xsl:template name="canonical-link">
		<link rel="canonical">
			<xsl:attribute name="href">
				<xsl:choose>
					<xsl:when test="$bytech = 1"><xsl:value-of select="$techs-src//latestloc/loc"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="ancestor-or-self::spec//latestloc/loc"/></xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="$bytech = 1"><xsl:value-of select="//body/div1/@id"/></xsl:when>
					<xsl:when test="$slices = 1"><xsl:apply-templates select="." mode="slice-techniques-filename"/></xsl:when> <!-- would like to remove Overview.html and file extensions -->
					<xsl:when test="$show.diff.markup = 1">complete-diff</xsl:when>
					<xsl:otherwise>complete</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</link>
	</xsl:template>
</xsl:transform>
