<?xml version="1.0" encoding="UTF-8"?>
<!-- NOTE: This file should be named using the format "{$day}-mapping.html" where $day = the publication day of the draft to which it corresponds -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" encoding="iso-8859-1" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="yes" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
	<!-- create some variables to allow for extracting headings from various techniques documents -->
	<xsl:param name="techniques.file">../wcag20-merged-techs.xml</xsl:param>
	<xsl:param name="techniques.doc" select="document($techniques.file)"/>
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
				<h1>ID/Heading Listing (Experimental)</h1>
				<p>This XSLT generates various lists and combinations of gudideline id's headings/etc for the purposes of cutting and pasting into other resources (techs submission form, bugzilla, etc.) This list was generated from the 
					 <a href="{$thisversion}">
						<xsl:value-of select="$draftDate"/> Working Draft</a>. </p>
				<ul>
					<xsl:for-each select="//div3[@role='group1'] | //div3[@role='group2']">
						<li>
							<xsl:variable name="anchor">
								<xsl:value-of select="@id"/>
							</xsl:variable>
							<strong>
								<a href="{$thisversion}#{$anchor}"> Guideline <xsl:number level="multiple" count="div2 | div3" format="1.1 "/>
								</a>
							</strong> (<xsl:value-of select="@id"/>)	
						</li>
					</xsl:for-each>
				</ul>
				<h2>Techniques Submission Form (guideline reference field)</h2>
				<p>
					<select name="guideline" id="checkpoint">
						<xsl:for-each select="//div3[@role='group1'] | //div3[@role='group2']">
							<xsl:variable name="anchor">
								<xsl:value-of select="@id"/>
							</xsl:variable>
							<option value="{$anchor}">Guideline <xsl:number level="multiple" count="div2 | div3" format="1.1"/> (advisory)</option>
								 <xsl:for-each select="./div4[@role='req']/div5[not(@diff = 'del')] | ./div4[@role='bp']/div5[not(@diff = 'del')] | ./div4[@role='additional']/div5[not(@diff = 'del')]">
														<xsl:variable name="anchor2">
											<xsl:value-of select="@id"/>
										</xsl:variable>
										
										<option value="{$anchor2}">Success Criterion <xsl:call-template name="sc-number"/>
									</option>
								</xsl:for-each>
						</xsl:for-each>
					</select>
				</p>
				<h2>Techniques Sections (technology field)</h2>
				<select name="category" id="category">
					<option value="not_selected">(select one)</option>
					<xsl:for-each select="$techniques.doc//spec/body/div1">
							<xsl:variable name="head">
								<xsl:value-of select="head"/>
							</xsl:variable>
							<option value="{$head}">
								<xsl:value-of select="$head"/>
							</option>
						</xsl:for-each>
					<option value="other">other</option>
				</select>
				
				<h2>Related Techniques</h2>
				<select name="related_techniques" id="related_techniques" multiple="multiple" size="10">
				<xsl:for-each select="$techniques.doc//spec/body/div1">
								<xsl:variable name="head">
								<xsl:value-of select="head"/>
							</xsl:variable>
							<optgroup label="{$head}">
								 <xsl:for-each select="technique">
									
										<option value="{@id}"><xsl:value-of select="@id"></xsl:value-of>: <xsl:value-of select="substring(short-name, 1, 85)"></xsl:value-of>...
									</option>
								</xsl:for-each>
								</optgroup>
						</xsl:for-each>
						</select>
				 
     			<h2>Guideline Item Number</h2>
						$itemnumber_array[0] = "(none selected)";
				<xsl:for-each select="//front/div1 | //div2[@role='principle'] | //back">
								<xsl:variable name="head">
								<xsl:value-of select="head"/>
							</xsl:variable>				
							<xsl:variable name="count">1</xsl:variable>
														 <xsl:for-each select="div2[not(@diff = 'del')] | div3[not(@diff = 'del')] | div3/div4[@role='req']/div5[not(@diff = 'del')] | div3/div4[@role='bp']/div5[not(@diff = 'del')] | div3/div4[@role='additional']/div5[not(@diff = 'del')]">
								 $itemnumber_array[<xsl:value-of select="($count + 1)"/>] = "<xsl:choose>
          <xsl:when test="@role!='sc'"><xsl:value-of select="head"></xsl:value-of></xsl:when><xsl:otherwise>Success Criterion <xsl:call-template name="sc-number"></xsl:call-template></xsl:otherwise>
        </xsl:choose>";</xsl:for-each>
						</xsl:for-each>
						
										$itemid_array[0] = "(none selected)";
				<xsl:for-each select="//front/div1 | //div2[@role='principle'] | //back">
								<xsl:variable name="head">
								<xsl:value-of select="head"/>
							</xsl:variable>				
							<xsl:variable name="count">1</xsl:variable>

								 <xsl:for-each select="div2[not(@diff = 'del')] | div3[not(@diff = 'del')] | div3/div4[@role='req']/div5[not(@diff = 'del')] | div3/div4[@role='bp']/div5[not(@diff = 'del')] | div3/div4[@role='additional']/div5[not(@diff = 'del')]">
								 $itemid_array[<xsl:value-of select="($count + 1)"/>] = "<xsl:choose>
          <xsl:when test="@role!='sc'"><xsl:value-of select="head"></xsl:value-of></xsl:when><xsl:otherwise>Success Criterion <xsl:call-template name="sc-number"></xsl:call-template></xsl:otherwise>
        </xsl:choose>";</xsl:for-each>
						</xsl:for-each>
		-->				
						
						        				<h2>Understanding Item Number</h2>
						        				
						        				<!--BBC: Note that the numbering on these arrays isn't working quite right. Looks like there needs to be another layer of counting as it seems to skip numbers when moving into new principles-->
				<p>
					<select name="item_number" id="item_number">
					    $itemnumber_array[0] = "(none selected)";
					    $itemnumber_array[1] = "Introduction to Understanding WCAG 2.0";
						<xsl:for-each select="//div3[@role='group1'] | //div3[@role='group2']">
							$itemnumber_array[<xsl:value-of select="(count(preceding-sibling::div3) + count(preceding::div5[not(@diff = 'del')])+2)"/>] = "Understanding Guideline <xsl:number level="multiple" count="div2 | div3" format="1.1 "/>";
								 <xsl:for-each select="./div4[@role='req']/div5[not(@diff = 'del')] | ./div4[@role='bp']/div5[not(@diff = 'del')] | ./div4[@role='additional']/div5[not(@diff = 'del')]">
							$itemnumber_array[<xsl:value-of select="(count(preceding::div5[not(@diff = 'del')]) + count(ancestor::div3/preceding-sibling::div3) +3)"/>] = "Understanding Success Criterion <xsl:call-template name="sc-number"/>";</xsl:for-each></xsl:for-each>
					</select>
				</p>
				
								<p>
					<select name="item_id" id="item_id">
					    $itemnumber_array[0] = "(none selected)";
					    $itemnumber_array[1] = "intro";
						<xsl:for-each select="//div3[@role='group1'] | //div3[@role='group2']">
							$itemid_array[<xsl:value-of select="(count(preceding-sibling::div3) + count(preceding::div5[not(@diff = 'del')])+2)"/>] = "<xsl:value-of select="@id"/>";
								 <xsl:for-each select="./div4[@role='req']/div5[not(@diff = 'del')] | ./div4[@role='bp']/div5[not(@diff = 'del')] | ./div4[@role='additional']/div5[not(@diff = 'del')]">
							$itemid_array[<xsl:value-of select="(count(preceding::div5[not(@diff = 'del')]) + count(ancestor::div3/preceding-sibling::div3) +3)"/>] = "<xsl:value-of select="@id"/>";</xsl:for-each></xsl:for-each>
							$itemnumber_array[59] = "conformance";
					</select>
				</p>
				
										        				<h2>Techniques Item Number</h2>
				<!-- Don't know why this is generating PHP that generates HTML, changing to just output HTML -->
				<p>
<select name="item_number" id="item_number">
	<optgroup label="none"><option value="(none selected)">(none selected)</option></optgroup>
	
	<xsl:comment>Reuse the optgroup and options generated in id-list.xslt here</xsl:comment>
	
	<xsl:for-each select="$techniques.doc//spec/body/div1">
		<xsl:variable name="head" select="head"/>
			<optgroup label="{$head}">
				<xsl:processing-instruction name="php">
				$item = null;
					<xsl:for-each select="technique">
						$item['<xsl:value-of select="@id"/>'] = htmlspecialchars("<xsl:value-of select="@id"/>: <xsl:value-of select="replace(substring(short-name, 1, 85), '&quot;', '\\&quot;')"/><xsl:if test="string-length(short-name) > 85">...</xsl:if>");</xsl:for-each>
					<![CDATA[
	foreach ($item as $key => $val)
	{
	 	if ($item_number == $key)
	 	{
	 		echo ("<option value=\"" . $key . "\" selected=\"selected\">" . $val . "</option>");
	 	}
	 	else
	 	{
	 		echo ("<option value=\"" . $key . "\">" . $val . "</option>");
	 	}
	}
					]]></xsl:processing-instruction>
			</optgroup>
	</xsl:for-each>
</select>
				</p>

				<hr/>
				<h2>Success Criteria ids</h2>
			  <p>There are a total of <xsl:value-of select="count(//div4[@role='req']/div5[not(@diff='del')])+count(//div4[@role='bp']/div5[not(@diff='del')])+count(//div4[@role='additional']/div5[not(@diff='del')])"/> success criteria in the <a href="{$thisversion}">
						<xsl:value-of select="$draftDate"/> Working Draft</a>. The list below includes a list of each of the unique ids used to reference these criteria.
				
</p>
				<ul>
					<xsl:for-each select="//div3[@role='group1'] | //div3[@role='group2']">
						<li>
							<xsl:variable name="anchor">
								<xsl:value-of select="@id"/>
							</xsl:variable>
							<strong>
								<a href="{$thisversion}#{$anchor}"> 
								<xsl:value-of select="@id"/>
								</a> 
							</strong> 
							<ul>
							  <xsl:for-each select="./div4[@role='req']/div5[not(@diff='del')] | ./div4[@role='bp']/div5[not(@diff='del')] | ./div4[@role='additional']/div5[not(@diff='del')]">
									<li>
										<xsl:variable name="anchor2">
											<xsl:value-of select="@id"/>
										</xsl:variable>
										
										<a href="{$thisversion}#{$anchor2}">
										<xsl:value-of select="@id"/>
										</a> (SC <xsl:call-template name="sc-number"/>)
									</li>
								</xsl:for-each>
							</ul>
						</li>
					</xsl:for-each>
				</ul>
				<h2>Techniques placeholders:</h2>
				<p>This generates the placeholder section from the front element in gateway techniques. (view source to cut and paste)</p>
				<xsl:for-each select="//div3[@role='group1'] | //div3[@role='group2'] | //div4[@role='req']/div5 | //div4[@role='bp']/div5 | //div4[@role='additional']/div5">
					<xsl:variable name="anchor3">
						<xsl:value-of select="@id"/>
					</xsl:variable>
					<p id="{$anchor3}">placeholder for <xsl:value-of select="@id"/>
					</p>
				</xsl:for-each>
			  <xsl:for-each select="$techniques.doc//technique">
			    <p id="{@id}">placeholder for <xsl:value-of select="@id"/>
			    </p>
			  </xsl:for-each>
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