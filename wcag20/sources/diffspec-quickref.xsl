<?xml version="1.0"?>

<!-- Version: $Id: diffspec-quickref.xsl,v 1.6 2011/05/27 20:40:54 cooper Exp $ -->

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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version="1.0">

<xsl:import href="quickref.xslt"/>
<xsl:param name="guide" select="1"/>
<xsl:param name="show.diff.markup" select="0"/>

<xsl:param name="additional.css">
<xsl:if test="$show.diff.markup != 0">
<xsl:text>
div.diff-add  { background-color: #FFFF99; }
div.diff-delete  { text-decoration: line-through; }
div.diff-change  { background-color: #99FF99; }
div.diff-off  {  }

span.diff-add { background-color: #FFFF99; }
span.diff-delete { text-decoration: line-through; }
span.diff-change { background-color: #99FF99; }
span.diff-off {  }

td.diff-add   { background-color: #FFFF99; }
td.diff-delete   { text-decoration: line-through }
td.diff-change   { background-color: #99FF99; }
td.diff-off   {  }

	li p {
		margin-top: 0;                  
		margin-bottom: 0; 
	}

	p {
		margin-top: 0;                  
		margin-bottom: .5em; 
	}
	
p.prefix, p.sctxt {
    margin-top: .25em;  
    margin-bottom: 0;
}
dd.prefix p {
		margin-bottom: 0;                  
}
      	dd {
		margin-bottom: .5em;                  
	}
dt.label {padding-top: .5em;}
div.sc ul {
		margin-top: 0;                  
}

h4, h5 {margin-bottom: .5em;}
    .revnote {
        background-color : #adff2f;
        color : black;
      }
    p.revnote , div.revnote {
        padding : 0.5em;
        margin : 0;
      }
    .informative {
        color : #000000;
        background : #ffffff;
        padding-bottom : 0.5em;
        padding-left : 1em;
        margin-top : 0.5em;
        margin-left : 2em;
        padding-right : 0.5em;
        border-style : solid;
        border-width : thin;
        border-color : #f1f1f1;
      }
      
    .principle { 	
		padding: .5em; 	
		border: thin solid #666666; 	
		background-color: #FFFFFF; 	
		color: #000000; 	
		font-weight: bold; 
	}
       
    .guideline {
        border: thin solid #000066; 	
        background-color: #CFE8EF; 	
        padding: .5em .5em .5em .5em; 	
        margin-bottom: 0; 	
        color: #000000;   
      }
      
    .req, .bp, .additional, .terms, .section {      	    
		  display: block; 
		  border-bottom: thin solid #666666;
		  margin-left: 1em;
		  padding-bottom: .5em;
		 } 
		 
		 .terms, .section {      	    
		  display: block; 
		  border-bottom: thin solid #666666;
		  margin-left: 0;
		 } 
		 
	div.sc {
		 margin-left: 1em;
	}	
  
    .bigger {
        font-weight : bold;
      }
    .smaller {
        font-size : 75%;
      }
    .termref {
        color : #006400;
        background : white;
      }
    a.termref:link {
        color : #006400;
        background : transparent;
      }
    a.termref:hover {
        background-color : #fafad2;
        color : #006400;
      }
	table.checklist {
		empty-cells: show;
		width: 94%;
		margin-bottom: 1em;
	}
					 	
	.termref { 	
		color: #006400; 	
		background: white;
	} 
	
	 a:link.termref { 	
		 color: #006400; 	
		 background: transparent; 	
	}   
	
	a:hover.termref { 	
		background-color: #FAFAD2; 	
		color: #006400;
	}
      .sorethumb {color: red
   }
	table.checklist {
		empty-cells: show;
		width: 94%;
		margin-bottom: 1em;
	}
					 
p.sc {font-size: 100%; font-weight: bold; display: inline;}

p.i, p.v {display: inline;}

tr.scrule {
font-size: 95%; 
}

tr.scrule:hover {
background-color: #DCDCDC;
}

tr.scrule {
background-color: #98FB98;
}

tbody.reqcl {
	background-color: #CFE8EF;
}
tbody.bpcl {
	background-color: #FFFFCC;
}
tbody.additionalcl {
	background-color: #DDFDDF;
}

th.reqcl {
	background-color: #CFE8EF;
}
th.bpcl {
	background-color: #FFFFCC;
}
th.additionalcl {
	background-color: #DDFDDF;
}

th {
background-color: #E0E0E0;
}

hr.divider {
	background-color: #000066;
	height: 30px;
}

 p.instructions {
    padding: 1em;
    border: 1px dashed #2f6fab;
    color: Black;
    background-color: #f9f9f9;
    line-height: 1.1em;
    margin-left: 1em;
    margin-right: 1em;
   }
       caption.guideline {
        border : thin solid #000066;
        background-color : #ffffff;
        border-bottom-width : 3px;
		border-top-width: 0px;
		border-left-width: 0px;
		border-right-width: 0px;
	    color : #000000;
		font-size: 1.25em;
		font-weight: bold;
		text-align: left;
		margin-top: 1em;
		margin-bottom: .5em;
		width: 100%;
      }


/* BBC - There are some experimental images in the sources/output directory that may be of use below at some point down the road */
a.HTMlink, a.HTMlink:visited { 
	display: inline;
	font: .9em Arial, Helvetica, sans-serif;
	text-decoration:none;
	padding: 0px 0px 2px 15px;
/*		background: url(images/BG_li.gif) top left no-repeat; */
	}
a.HTMlink:hover { 
	display: inline;
	font: .9em Arial, Helvetica, sans-serif;
	text-decoration:none;
	padding: 0px 0px 2px 15px;
	background-color: transparent;
/*	background: url(images/BG_li_hover.gif) top left no-repeat; */
	}
</xsl:text>
</xsl:if>
</xsl:param>

<xsl:param name="additional.title">
  <xsl:if test="$show.diff.markup != 0">
    <xsl:message><xsl:value-of select="$show.diff.markup"/></xsl:message>
    <xsl:text>Review Version</xsl:text>
  </xsl:if>
</xsl:param>

<xsl:param name="called.by.diffspec" select="0"/>

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

<xsl:template match="*[@diff='chg']" priority="-.5">
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

<xsl:template match="*[@diff='add']" priority="-.5">
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

<xsl:template match="*[@diff='del']" priority="-.5">
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
  
    <xsl:template match="item">
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
	<xsl:choose>
	<!-- BBC: test for role values that require AND or OR relationships that fall outside the norm -->
	<xsl:when test="@role='htmlorflash' or @role='htmlorscript' or @role='htmlorcss'">
        <xsl:variable name="liclass">base<xsl:value-of select="@role"/>base</xsl:variable>
        <xsl:if test="@role='htmlorflash'">
          <xsl:processing-instruction name="php"><![CDATA[ if ($bHTML || $bFlash) { ]]></xsl:processing-instruction>
        </xsl:if>
        <xsl:if test="@role='htmlorscript'">
          <xsl:processing-instruction name="php"><![CDATA[ if ($bHTML || $bScript) { ]]></xsl:processing-instruction>
        </xsl:if>
        <xsl:if test="@role='htmlorcss'">
          <xsl:processing-instruction name="php"><![CDATA[ if ($bHTML || $bCSS) { ]]></xsl:processing-instruction>
        </xsl:if>
        <li xmlns="http://www.w3.org/1999/xhtml">
          <xsl:if test="@id">
            <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
          </xsl:if>
          <xsl:attribute name="class"><xsl:value-of select="$liclass"/></xsl:attribute>
          <xsl:apply-templates/> 
        </li>
        <xsl:processing-instruction name="php"><![CDATA[ } ]]></xsl:processing-instruction>
      </xsl:when>
      <xsl:when test="@role='html' or @role='css' or @role='script' or @role='smil' or @role='flash' or @role='pdf' or @role='silverlight' or @role='aria' or @role='server' or p/loc[@linktype='html'] or p/loc[@linktype='css'] or p/loc[@linktype='script'] or p/loc[@linktype='smil'] or p/loc[@linktype='flash'] or p/loc[@linktype='pdf'] or p/loc[@linktype='silverlight'] or p/loc[@linktype='aria'] or p/loc[@linktype='server']">
        <xsl:variable name="liclass">base<xsl:value-of select="p/loc/@linktype"/>base</xsl:variable>
        <xsl:if test="@role='html' or p/loc[@linktype='html']">
          <xsl:processing-instruction name="php"><![CDATA[ if ($bHTML) { ]]></xsl:processing-instruction>
        </xsl:if>
        <xsl:if test="@role='css' or p/loc[@linktype='css']">
          <xsl:processing-instruction name="php"><![CDATA[ if ($bCSS) { ]]></xsl:processing-instruction>
        </xsl:if>
        <xsl:if test="@role='script' or p/loc[@linktype='script']">
          <xsl:processing-instruction name="php"><![CDATA[ if ($bScript) { ]]></xsl:processing-instruction>
        </xsl:if>
        <xsl:if test="@role='flash' or p/loc[@linktype='flash']">
          <xsl:processing-instruction name="php"><![CDATA[ if ($bFlash) { ]]></xsl:processing-instruction>
        </xsl:if>
        <xsl:if test="@role='pdf' or p/loc[@linktype='pdf']">
          <xsl:processing-instruction name="php"><![CDATA[ if ($bPDF) { ]]></xsl:processing-instruction>
        </xsl:if>
        <xsl:if test="@role='silverlight' or p/loc[@linktype='silverlight']">
          <xsl:processing-instruction name="php"><![CDATA[ if ($bSilverlight) { ]]></xsl:processing-instruction>
        </xsl:if>
       <xsl:if test="@role='aria' or p/loc[@linktype='aria']">
          <xsl:processing-instruction name="php"><![CDATA[ if ($bARIA) { ]]></xsl:processing-instruction>
        </xsl:if>
         <xsl:if test="@role='server' or p/loc[@linktype='server']">
          <xsl:processing-instruction name="php"><![CDATA[ if ($bServerSide) { ]]></xsl:processing-instruction>
        </xsl:if>
        <xsl:if test="@role='smil' or p/loc[@linktype='smil']">
          <xsl:processing-instruction name="php"><![CDATA[ if ($bSMIL) { ]]></xsl:processing-instruction>
        </xsl:if>
        <li xmlns="http://www.w3.org/1999/xhtml">
          <xsl:if test="@id">
            <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
          </xsl:if>
          <xsl:attribute name="class"><xsl:value-of select="$liclass"/></xsl:attribute>
          <xsl:apply-templates/> 
        </li>
        <xsl:processing-instruction name="php"><![CDATA[ } ]]></xsl:processing-instruction>
      </xsl:when>
     
      <xsl:otherwise>
        <li xmlns="http://www.w3.org/1999/xhtml">
          <xsl:if test="@id">
            <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
          </xsl:if>
          <xsl:apply-templates/>
        </li>
      </xsl:otherwise>
    </xsl:choose>
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

</xsl:stylesheet>
