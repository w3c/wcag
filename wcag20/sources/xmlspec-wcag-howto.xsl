<?xml version="1.0" encoding="utf-8"?>
<!--This file is used for items unique to the UNDERSTANDING/GUIDE/HOWTO documents. It draws from xmlspec-wcag.xsl and xmlspec.xsl for most styles.-->
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:saxon="http://icl.com/saxon" exclude-result-prefixes="saxon" version="1.0">
  <xsl:import href="xmlspec-wcag.xsl"/>
  <xsl:param name="slices" select="0"/>
  <xsl:param name="guide" select="0"/>
<!--BBC: Make below "3" to include links to subsections of each HTM-->
  <xsl:param name="toc.level" select="2"/>
  <!-- don't copy the placeholders -->
  <xsl:template match="div1[@id='placeholders']"/>
  <!-- don't copy the placeholders -->
  <xsl:template match="div1/head">
    <xsl:text> </xsl:text>
    <h2>
      <xsl:call-template name="anchor">
        <xsl:with-param name="conditional" select="0"/>
        <xsl:with-param name="node" select=".."/>
      </xsl:call-template>
      <!--<xsl:apply-templates select=".." mode="divnum"/>
			BBC Added a test to replace guideline headings with value from current source-->
      <xsl:choose>
        <xsl:when test="../@role='extsrc'">
				   <strong><xsl:call-template name="sc-handle">
          <xsl:with-param name="handleid" select="../@id"/>
        </xsl:call-template></strong><span class="screenreader">:</span><br />Understanding Guideline <xsl:value-of select="../head"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </h2>
    
    <xsl:if test="../@role='extsrc'">
    <blockquote class="glquote">
          <div><p><strong>Guideline <xsl:value-of select="../head"/>: </strong><xsl:value-of select="$gl-src//div3[@id=current()/../@id]/head"/></p></div>
    </blockquote>
    </xsl:if>
  </xsl:template>

  <xsl:template match="p[@role='ccextsrc']">
  <blockquote class="scquote">
      <xsl:if test="@id">
        <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
        <xsl:attribute name="cite"><xsl:value-of select="$gl-src//publoc/loc"/><xsl:text>#</xsl:text><xsl:value-of select="@id"/></xsl:attribute>
      </xsl:if>
    <xsl:apply-templates select="$gl-src//div3[@id=current()/@id]"/>
      <xsl:text> </xsl:text>
      <!--<xsl:variable name="gl" select="$gl-src//*[@id = current()/@id]"/>-->
  </blockquote>
  </xsl:template>

  <!-- head in div3 -->
  <xsl:template match="div2/head">
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="../@role='glintent'">
        <h3>
          <xsl:call-template name="anchor">
            <xsl:with-param name="conditional" select="0"/>
            <xsl:with-param name="node" select=".."/>
          </xsl:call-template>
			Intent of Guideline <xsl:value-of select="../../head"/>
        </h3>
      </xsl:when>
           <xsl:when test="../@role='normal'">
        <h3>
          <xsl:call-template name="anchor">
            <xsl:with-param name="conditional" select="0"/>
            <xsl:with-param name="node" select=".."/>
          </xsl:call-template>
			<xsl:value-of select="../head"/>
        </h3>
      </xsl:when>
        <xsl:when test="../@role='suppressed'">
      </xsl:when>
      <xsl:when test="../@role='gladvisory'">
        <h3>
          <xsl:call-template name="anchor">
            <xsl:with-param name="conditional" select="0"/>
            <xsl:with-param name="node" select=".."/>
          </xsl:call-template>
			Advisory Techniques for Guideline <xsl:value-of select="../../head"/> (not success criteria specific)</h3>
        <div   class="textbody">
          <p>Specific techniques for meeting each Success Criterion for this guideline are listed in the understanding sections for each Success Criterion (listed below). If there are techniques, however, for addressing this guideline that do not fall under any of the success criteria, they are listed here. These techniques are not required or sufficient for meeting any success criteria, but can make certain types of Web content more accessible to more people.</p>
          <xsl:choose>
            <xsl:when test="count(../ulist) = 0">
              <ul>
                <li>All advisory techniques for this guideline relate to specific success criteria.</li>
              </ul>
            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <h2>
          <xsl:call-template name="anchor">
            <xsl:with-param name="conditional" select="0"/>
            <xsl:with-param name="node" select=".."/>
          </xsl:call-template>
          <xsl:apply-templates select=".." mode="h1handle"/>
          <!--BBC Added a test to replace guideline headings with value from current source-->
        </h2>
        <blockquote class="scquote"><xsl:apply-templates select="$gl-src//div5[@id=current()/../@id]"/></blockquote>
        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
 
  <xsl:template match="div3/head">
  <xsl:choose>
  <xsl:when test="../@role='cc'">

			</xsl:when>
   <xsl:when test="../@role='front'">
		</xsl:when>
			<xsl:when test="../@role='normal'">
			<h3 id="{ancestor::div2/@id}-{../@id}-head" class="section">
						 <xsl:apply-templates mode="text"/>
			</h3>
			</xsl:when>
<xsl:otherwise>
  <!--BBC test to figure out if this is a success or a conformance criterion -->
<xsl:variable name="criteriontype"> 
  <xsl:choose>
      <xsl:when test="../../@role='cc'">Conformance</xsl:when>
      <xsl:otherwise>Success</xsl:otherwise>
    </xsl:choose></xsl:variable> 
    <h3 id="{ancestor::div2/@id}-{../@role}-head" class="section">
      <!--BBC Added a test to replace guideline headings with value from current source-->
      <xsl:choose>
        <xsl:when test="../@role='intent'">
				Intent of this <xsl:value-of select="$criteriontype" /> Criterion
			</xsl:when>
        <xsl:when test="../@role='techniques'">
				Techniques and Failures for <xsl:value-of select="$criteriontype" /> Criterion <xsl:call-template name="sc-number"><xsl:with-param name="id" select="../../@id"/></xsl:call-template><xsl:text> </xsl:text> - <xsl:call-template name="sc-handle">
      <xsl:with-param name="handleid" select="../../@id"/>
    </xsl:call-template>
        </xsl:when>
        <xsl:when test="../@role='examples'">
				Examples of <xsl:value-of select="$criteriontype" /> Criterion <xsl:call-template name="sc-number"><xsl:with-param name="id" select="../../@id"/></xsl:call-template>
        </xsl:when>
        <xsl:when test="../@role='resources'">
				Related Resources
			</xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="text"/>
        </xsl:otherwise>
      </xsl:choose>
    </h3>
    <xsl:choose>
      <xsl:when test="../@role='techniques'">
      	<xsl:call-template name="understanding.notrestricted.disclaimer"/>
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="../@role='resources'">
        <p>Resources are for information purposes only, no endorsement implied.</p>
      	<xsl:if test="not(../p or ../olist or ../ulist or ../div4)">
          <p>(none currently documented)</p>
        </xsl:if>
      </xsl:when>
    	<xsl:when test="../@role='examples'">
    		<xsl:if test="not(../p or ../olist or ../ulist or ../div4)">
    			<p>(none currently documented)</p>
    		</xsl:if>
    	</xsl:when>
    </xsl:choose>
    </xsl:otherwise>  </xsl:choose>
  </xsl:template>
  <xsl:template match="div4/head">
  <xsl:variable name="criteriontype"> 
  <xsl:choose>
      <xsl:when test="../../../@role='cc'">Conformance</xsl:when>
      <xsl:otherwise>Success</xsl:otherwise>
  </xsl:choose></xsl:variable> 
  	<xsl:variable name="id">
  		<xsl:choose>
  			<xsl:when test="../@id"><xsl:value-of select="ancestor::div2/@id"/>-<xsl:value-of select="../@id"/>-head</xsl:when>
  			<xsl:otherwise><xsl:value-of select="ancestor::div2/@id"/>-<xsl:value-of select="count(preceding::div4) +1"/>-head</xsl:otherwise>
  		</xsl:choose>
  	</xsl:variable>
  	<h4 id="{$id}" class="div3head">
      <!--
			<xsl:call-template name="anchor">
				<xsl:with-param name="conditional" select="0"/>
				<xsl:with-param name="node" select=".."/>
			</xsl:call-template>
			-->
      <!--a name="{ancestor::div4/@id}-{parent::div5/@role}">
				<xsl:text> </xsl:text>
			</a-->
      <!--BBC Added a test to replace guideline headings with value from current source-->
      <xsl:choose>
        <xsl:when test="../@role='sufficient'">
				Sufficient Techniques  
			</xsl:when>
        <xsl:when test="../@role='tech-specific'">
				Technology-Specific Techniques
			</xsl:when>
        <xsl:when test="../@role='failures'">
				 Common Failures for <abbr title="Success Criterion">SC</abbr><xsl:text> </xsl:text><xsl:call-template name="sc-number"><xsl:with-param name="id" select="../../../@id"/></xsl:call-template>
			</xsl:when>
        <xsl:when test="../@role='tech-optional'">
				 Additional Techniques (Advisory) for <xsl:call-template name="sc-number"><xsl:with-param name="id" select="../../../@id"/></xsl:call-template>
        </xsl:when>
        <xsl:when test="../@role='sufficient'">
				</xsl:when>
				<xsl:when test="../@role='benefits'">
				Specific Benefits of <xsl:value-of select="$criteriontype" /> Criterion <xsl:call-template name="sc-number"><xsl:with-param name="id" select="../../../@id"/></xsl:call-template>
			</xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="text"/>
        </xsl:otherwise>
      </xsl:choose>
    </h4>
    <xsl:choose>
      <xsl:when test="../@role='failures'">
        <p>The following are common mistakes that are considered failures of Success Criterion <xsl:call-template name="sc-number"><xsl:with-param name="id" select="../../../@id"/></xsl:call-template> by the <acronym title="Web Content Accessibility Guidelines">WCAG</acronym> Working Group.</p>
      	<xsl:if test="not(../p or ../olist or ../ulist or ../div5)">
          <p>(No failures currently documented)</p>
        </xsl:if>
      </xsl:when>
      <xsl:when test="../@role='tech-optional'">
        <p>Although not required for conformance, the following additional techniques should be considered in order to make content more accessible. Not all techniques can be used or would be effective in all situations.</p>
      	<xsl:if test="not(../p or ../olist or ../ulist or ../div5)">
          <p>(none currently documented)</p>
        </xsl:if>
      </xsl:when>
      <xsl:when test="../div5[@role='situation']">
        <p class="instructions">
          <strong>Instructions:</strong> Select the situation below that matches your content. Each situation includes numbered techniques (or combinations of techniques) that the Working Group deems to be sufficient for that situation.
</p>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- mode: divnum -->
  <xsl:template mode="divnum" match="div1">
	Guideline <xsl:value-of select="head"/>:<xsl:text> </xsl:text>
  </xsl:template>
  <xsl:template mode="divnum" match="back/div1 | inform-div1">Appendix <xsl:number count="div1 | inform-div1" format="A "/>
  </xsl:template>
  <xsl:template mode="divnum" match="front/div1 | front//div2 | front//div3 | front//div4 | front//div5"/>
  <xsl:template mode="divnum" match="div3">
    <xsl:apply-templates select="head" mode="text"/>: 
	</xsl:template>
  <xsl:template mode="divnum" match="technique">
    <!--<xsl:number level="multiple" count="div1 | div2 | div3 | technique" format="1.1.1.1"/><xsl:text> </xsl:text>-->
  </xsl:template>
  <xsl:template mode="divnum" match="div2[not(@role='glintent' or @role='gladvisory' or @role='cc' or @role='normal')]">
		Understanding Success Criterion <xsl:call-template name="sc-number"><xsl:with-param name="id" select="@id"/></xsl:call-template>  [<xsl:call-template name="sc-handle">
      <xsl:with-param name="handleid" select="@id"/>
    </xsl:call-template>]
	</xsl:template>
	<xsl:template mode="h1handle" match="div2[not(@role='glintent' or @role='gladvisory' or @role='cc' or @role='normal')]">
		<strong><xsl:call-template name="sc-handle">
      <xsl:with-param name="handleid" select="@id"/>
    </xsl:call-template></strong><span class="screenreader">:</span><br />Understanding <abbr title="Success Criterion">SC</abbr><xsl:text> </xsl:text><xsl:call-template name="sc-number"><xsl:with-param name="id" select="@id"/></xsl:call-template> 
	</xsl:template>
	  <xsl:template mode="divnum" match="div2[@role='cc']">
		Understanding Conformance Requirement <xsl:value-of select="head"/>  [<xsl:call-template name="sc-handle">
      <xsl:with-param name="handleid" select="@id"/>
    </xsl:call-template>]
	</xsl:template>
  <xsl:template mode="divnum" match="back//div2">
    <xsl:number level="multiple" count="div1 | div2 | inform-div1" format="A.1 "/>
  </xsl:template>
  <xsl:template mode="divnum" match="back//div3">
    <xsl:number level="multiple" count="div1 | div2 | div3 | inform-div1" format="A.1.1 "/>
  </xsl:template>
  <!-- BBC modified to do automatic header insertion and numbering for required and best practice SC headings-->
  <xsl:template mode="divnum" match="back//div4">
    <xsl:number level="multiple" count="div1 | div2 | div3 | div4 | inform-div1" format="A.1.1.1 "/>
  </xsl:template>
  <xsl:template mode="divnum" match="div4">

	</xsl:template>
  <xsl:template mode="divnum" match="div5">

	</xsl:template>
  <xsl:template mode="divnum" match="back//div5">
    <xsl:number level="multiple" count="div1 | div2 | div3 | div4 | div5 | inform-div1" format="A.1.1.1.1 "/>
  </xsl:template>
  <xsl:template name="copy-common-atts">
    <xsl:for-each select="@*">
      <xsl:if test="name()='dir'">
        <xsl:copy/>
      </xsl:if>
      <xsl:if test="name()='xml:lang'">
        <xsl:copy/>
        <xsl:attribute name="lang"><xsl:value-of select="."/></xsl:attribute>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  <!-- copy-common-atts: does what it says (see comments for previous template). -->
  <xsl:template name="preferred-copy-common-atts">
    <xsl:for-each select="@*">
      <xsl:copy/>
    </xsl:for-each>
  </xsl:template>
  <!-- mode: toc rewrote this section so that TOC would result in actual lists-->
  <xsl:template mode="toc" match="div1">
    <li>
              <xsl:attribute name="class"><xsl:value-of select="@id"></xsl:value-of></xsl:attribute>
      <a>
        <xsl:attribute name="href"><xsl:call-template name="href.target"><xsl:with-param name="target" select="."/></xsl:call-template></xsl:attribute>
        <!--xsl:apply-templates select="."/-->
        <xsl:text> </xsl:text>
        <xsl:choose>
          <xsl:when test="@role='extsrc'">
					Understanding Guideline <xsl:value-of select="head"/>
            <xsl:text> </xsl:text>[<xsl:call-template name="sc-handle">
          <xsl:with-param name="handleid" select="@id"/>
        </xsl:call-template>]
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="head" mode="text"/>
          </xsl:otherwise>
        </xsl:choose>
      </a>
      <xsl:if test="$toc.level &gt; 1">
        <xsl:variable name="children1">
          <xsl:value-of select="count(div2[@role!='suppressed'])"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$children1 = 0"/>
          <xsl:otherwise>
            <ul>
              <xsl:for-each select="div2[not(@role='glintent' or @role='gladvisory' or @diff='del')]">
                <li>
                  <a>
                    <xsl:attribute name="href"> 
<!-- For whatever reason, the href.target template doesn't work here. The following is a kludge, but it works...-->                    
                    <xsl:choose>
                      <xsl:when test="@id='fourprincs'">intro.html#<xsl:value-of select="@id"></xsl:value-of></xsl:when>
                      <xsl:otherwise><xsl:call-template name="href.target"><xsl:with-param name="target" select="."/></xsl:call-template></xsl:otherwise>
                    </xsl:choose></xsl:attribute>
                    <xsl:apply-templates select="." mode="divnum"/>
                    <xsl:choose>
                      <xsl:when test="@role='extsrc' or @role='cc'" />
                      <xsl:otherwise>
                        <xsl:apply-templates select="head" mode="text"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </a>
                  <xsl:if test="$toc.level > 2">
                    <xsl:variable name="children2">
                      <xsl:value-of select="count(div3[not(@role='normal')])"/>
                    </xsl:variable>
                    <xsl:choose>
                      <xsl:when test="$children2 = 0"/>
                      <xsl:otherwise>
                        <ul>
                          <li>
                            <xsl:value-of select="head"/>: 
															<xsl:for-each select="div3">
                              <a href="#{ancestor::div2/@id}-{@role}-head">
                              <xsl:attribute name="title">Success Criterion <xsl:value-of select="head"/> <xsl:value-of select="@role"/></xsl:attribute>
                                <xsl:choose>
                                  <xsl:when test="@role='intent'">Intent</xsl:when>
                                  <xsl:when test="@role='techniques'">Techniques</xsl:when>
                                  <xsl:when test="@role='benefits'">Benefits</xsl:when>
                                  <xsl:when test="@role='examples'">Examples</xsl:when>
                                  <xsl:when test="@role='resources'">Resources</xsl:when>
                                  <xsl:otherwise>
                                    <xsl:apply-templates select="." mode="divnum"/>
                                  </xsl:otherwise>
                                </xsl:choose>
                               
                              </a> <xsl:text> </xsl:text>
                            </xsl:for-each>
                          </li>
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
  <xsl:template match="termref">
    <!--<xsl:variable name="glthisversion">
      <xsl:value-of select="$gl-src//publoc/loc[@href]"/>
    </xsl:variable>-->
    <a href="{$glthisversion}#{@def}" class="termref"  >
      <xsl:choose>
        <xsl:when test="count(child::node())=0">
          <xsl:value-of select="@def"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>
  <xsl:template match="div5/head">
    <xsl:choose>
      <xsl:when test="../@role='sc'">
		</xsl:when>
      <xsl:otherwise>
      	<h5>
          <xsl:call-template name="anchor">
            <xsl:with-param name="conditional" select="0"/>
            <xsl:with-param name="node" select=".."/>
          	<xsl:with-param name="default.id">
          		<xsl:choose>
          			<xsl:when test="../@id"><xsl:value-of select="ancestor::div2/@id"/>-<xsl:value-of select="../@id"/>-head</xsl:when>
          			<xsl:otherwise><xsl:value-of select="ancestor::div2/@id"/>-<xsl:choose>
          				<xsl:when test="../@role"><xsl:value-of select="../@role"/></xsl:when>
          				<xsl:otherwise>section</xsl:otherwise>
          			</xsl:choose>-<xsl:value-of select="count(preceding::div5) +1"/>-head</xsl:otherwise>
          		</xsl:choose>
          	</xsl:with-param>
          </xsl:call-template>
          <xsl:apply-templates select=".." mode="divnum"/>
          <xsl:apply-templates/>
        </h5>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:template match="div2[not(@role='glintent' or @role='gladvisory')]">
    <xsl:apply-templates/>
    <xsl:if test="@role='extsrc'">
    <xsl:variable name="gl" select="$gl-src//*[@id = current()/@id]"/>
    	<xsl:if test="$gl/descendant::termref[not(@diff = 'del')]">
          <h3 id="{@id}-terms"   class="terms">Key Terms</h3>
          <dl>
            <xsl:for-each select="$gl/descendant::termref[not(@diff = 'del')]">
            <xsl:sort data-type="text" select="$gl-src//*[@id = current()/@def]/label"/>
              <xsl:apply-templates select="$gl-src//*[@id = current()/@def]"/>
            </xsl:for-each>
          </dl>
        </xsl:if>
      </xsl:if>
    <hr class="divider"  />
  </xsl:template>
    <xsl:template match="div1|div2|div3|div4|div5" mode="specref">
    <em><a>
      <xsl:attribute name="href"><xsl:choose>
      	<!-- MC: This is a special case kludge to get link to cc4 and cc5 from glossary to work. Really we need to handle specref from included content, but I'm low on time. -->
      	<xsl:when test="@id = 'cc4' or @id = 'cc5'"><xsl:value-of select="concat($glthisversion, '#', @id)"/></xsl:when><xsl:otherwise><xsl:call-template name="href.target"/></xsl:otherwise></xsl:choose></xsl:attribute>
      <xsl:apply-templates select="." mode="divnum-specref"/><!--xsl:apply-templates select="head" mode="text"/--></a></em>
  </xsl:template>
  <xsl:template match="div5[@role='sc']" mode="specref">
		<a xmlns="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="href"><xsl:call-template name="href.target"/></xsl:attribute>
				Success Criterion <xsl:call-template name="sc-number"><xsl:with-param name="criterion" select="."/></xsl:call-template>
		</a>
	</xsl:template>
      <xsl:template mode="divnum-specref" match="div1"><xsl:apply-templates select="head" mode="text"/></xsl:template>
  <xsl:template mode="divnum-specref" match="div2">
    Understanding Success Criterion <xsl:call-template name="sc-number"><xsl:with-param name="id" select="@id"/></xsl:call-template><xsl:text> </xsl:text><xsl:call-template name="sc-handle"><xsl:with-param name="handleid" select="@id"/></xsl:call-template></xsl:template>
  <!--BBC suppress anchor names on key terms that are pulled in from guidelines source -->
	<xsl:template match="gitem">
		<xsl:apply-templates mode="noid"/>
	</xsl:template>
		<xsl:template match="label" mode="noid">
		<dt   class="label">
			<xsl:apply-templates/>
		</dt>
	</xsl:template>
		<xsl:template match="def" mode="noid">
		<dd>
			<xsl:apply-templates/>
		</dd>
	</xsl:template>
  <xsl:template match="div5">
    <div>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  
  	<!-- termdef: sentence or phrase defining a term - BBC: modified here to remove duplicate ids -->
	<xsl:template match="termdef">
		<xsl:text></xsl:text>
		<a name="{@id}" title="{@term}">	</a>
		 <strong><xsl:value-of select="@term"></xsl:value-of>:</strong>
		<xsl:text> </xsl:text>
		<xsl:apply-templates/>
		<xsl:text> </xsl:text>
	</xsl:template>
	<xsl:template match="body">
    <div   class="body">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  
  
  
  <xsl:template match="div4">
    <xsl:choose>
      <xsl:when test="@role='sufficient' or @role='failures' or @role='tech-optional'">
        <div class="boxed">
          <xsl:apply-templates />
        </div>
      </xsl:when>
      <xsl:when test="@role='benefits'">
        <div class="benefits">
          <xsl:apply-templates />
        </div>
      </xsl:when>
      <xsl:when test="@role='resources'">
        <div class="resources">
          <xsl:apply-templates />
        </div>
      </xsl:when>
      <xsl:otherwise>
          <xsl:apply-templates />
      </xsl:otherwise>
      </xsl:choose>
      </xsl:template>
      
          <xsl:template match="div3">
    <xsl:choose>
    <xsl:when test="@role='intent'">
        <div class="intent">
          <xsl:apply-templates />
        </div>
      </xsl:when>
      <xsl:when test="@role='resources'">
        <div class="resources">
          <xsl:apply-templates />
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div class="div3">
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
      </xsl:choose>
      </xsl:template>
      
      	<xsl:template match="blist">
		<dl xmlns="http://www.w3.org/1999/xhtml" class="slicerefs">
			<xsl:apply-templates/>
		</dl>
	</xsl:template>
	
    <xsl:template match="graphic">
        <xsl:variable name="guidepubloc">
            <xsl:value-of select="$guide-src//publoc/loc[@href]"/>
        </xsl:variable>
        <img src="{$guidepubloc}{@source}">
            <xsl:if test="@alt">
                <xsl:attribute name="alt"><xsl:value-of select="@alt"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="@width">
                <xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="@height">
                <xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
            </xsl:if>
        </img>
    </xsl:template>

<!--Quick hack to use role so that circular links aren't included in documents-->
<xsl:template match="p[@role='circref']">
</xsl:template>
    
    <!--Suppress Key Terms Section in single file version-->
    <xsl:template match="div3[@id='conformance-terms']"></xsl:template>
    	
<xsl:template name="understanding.notrestricted.disclaimer">
	<p>Each numbered item in this section represents a technique or combination of techniques that the <acronym title="Web Content Accessibility Guidelines">WCAG</acronym> Working Group deems sufficient for meeting this Success Criterion. However, it is not necessary to use these particular techniques. For information on using other techniques, see <a href="{$guide-src//publoc/loc[@href]}understanding-techniques.html">Understanding Techniques for WCAG Success Criteria</a>, particularly the "Other Techniques" section.</p>
</xsl:template>
</xsl:transform>
