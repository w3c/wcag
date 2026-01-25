<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:wcag="http://www.w3.org/WAI/GL/WCAG20/"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:import href="../xmlspec-wcag.xsl"/>
	<xsl:param name="understanding.file">../guide-to-wcag2-src.xml</xsl:param>
	<xsl:param name="techniques.file">../wcag20-merged-techs.xml</xsl:param>
	
	<xsl:param name="understanding.doc" select="document($understanding.file)"/>
	<xsl:param name="techniques.doc" select="document($techniques.file)"/>
	
	<xsl:variable name="tech-linktypes" select="('aria', 'script', 'css', 'failure', 'flash', 'general', 'html', 'pdf', 'server', 'silverlight', 'smil', 'text')"/>
	<xsl:variable name="linktypes" select="($tech-linktypes, 'understanding')"/>
	
	<xsl:output method="text"/>
	
	<xsl:function name="wcag:json-string" as="xs:string">
		<xsl:param name="val"/>
		<xsl:variable name="string">
			<xsl:choose>
				<xsl:when test="string($val) = $val">
					<xsl:copy-of select="$val"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="$val"/>					
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="replace(normalize-space($string), '&quot;', '\\&quot;')"/>
	</xsl:function>
	
	<xsl:template match="text()">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	<xsl:template match="/">
		<xsl:text>{</xsl:text>
		<xsl:text>"principles": [</xsl:text>
		<xsl:apply-templates select="//div2[@role='principle']"></xsl:apply-templates>
		<xsl:text>]</xsl:text>
		<xsl:text>}</xsl:text>
	</xsl:template>
	
	<xsl:template match="div2[@role='principle']">
		<xsl:text>{</xsl:text>
		<xsl:text>"id": "WCAG2:</xsl:text><xsl:value-of select="@id"/><xsl:text>",</xsl:text>
		<xsl:text>"num": "</xsl:text><xsl:number/><xsl:text>",</xsl:text>
		<xsl:text>"handle": "</xsl:text>
		<!-- principle handles not usefully in the XML or imported XSLT, so manually outputting here -->
		<xsl:choose>
			<xsl:when test="@id='perceivable'">Perceivable</xsl:when>
			<xsl:when test="@id='operable'">Operable</xsl:when>
			<xsl:when test="@id='understandable'">Understandable</xsl:when>
			<xsl:when test="@id='robust'">Robust</xsl:when>
		</xsl:choose>
		<xsl:text>",</xsl:text><!-- requested key was title -->
		<xsl:text>"title": "</xsl:text><xsl:value-of select="wcag:json-string(replace(head, 'Principle [1-9]: .* - ', ''))"/><xsl:text>",</xsl:text><!-- full text of the principle, not in the requested key -->

		<xsl:text>"guidelines": [</xsl:text>
		<xsl:apply-templates select="div3[@role='group1']"></xsl:apply-templates>
		<xsl:text>]</xsl:text>

		<xsl:text>}&#10;</xsl:text>
		<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="div3[@role='group1']">
		<xsl:variable name="handle">
			<xsl:call-template name="sc-handle">
				<xsl:with-param name="handleid" select="@id"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:text>{</xsl:text>
		<xsl:text>"id": "WCAG2:</xsl:text><xsl:value-of select="@id"/><xsl:text>",</xsl:text>
		<xsl:text>"num": "</xsl:text><xsl:number level="multiple" count="div2[@role='principle'] | div3" format="1.1"/><xsl:text>",</xsl:text>
		<xsl:text>"handle": "</xsl:text><xsl:value-of select="wcag:json-string($handle)"/><xsl:text>",</xsl:text><!-- requested key was title -->
		<xsl:text>"title": "</xsl:text><xsl:value-of select="wcag:json-string(head)"/><xsl:text>",</xsl:text><!-- requested key was intro -->

		<xsl:text>"techniques": [</xsl:text>
		<xsl:apply-templates select="$understanding.doc//*[@id = current()/@id]//*[@role = 'gladvisory']"></xsl:apply-templates>
		<xsl:text>],</xsl:text>

		<xsl:text>"successcriteria": [</xsl:text>
		<xsl:apply-templates select="div4/div5[@role = 'sc']"></xsl:apply-templates>
		<xsl:text>]</xsl:text>

		<xsl:text>}</xsl:text>
		<xsl:if test="position() != last()">,</xsl:if>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="div5[@role = 'sc']">
		<xsl:variable name="sc">
			<xsl:apply-templates select="p[@role = 'i' or @role = 'v']" mode="sc-text"/>
		</xsl:variable>
		<xsl:text>{</xsl:text>
		<xsl:text>"id": "WCAG2:</xsl:text><xsl:value-of select="@id"/><xsl:text>",</xsl:text>
		<xsl:text>"num": "</xsl:text><xsl:number level="multiple" count="div2[@role='principle'] | div3" format="1.1."/><xsl:value-of select="count(../preceding-sibling::div4/div5) + count(preceding-sibling::div5) + 1"/><xsl:text>",</xsl:text>
		<xsl:text>"level": "</xsl:text><xsl:call-template name="sc-level"/><xsl:text>",</xsl:text>
		<xsl:text>"handle": "</xsl:text><xsl:value-of select="wcag:json-string(head)"/><xsl:text>",</xsl:text><!-- requested key was title -->
		<xsl:text>"title": "</xsl:text><xsl:value-of select="wcag:json-string(string($sc))"/><xsl:text>",</xsl:text>
		<xsl:if test="p/following-sibling::*">
			<xsl:text>"details": [</xsl:text>
			<xsl:apply-templates select="p/following-sibling::*" mode="sc-details"/>
			<xsl:text>],</xsl:text>
		</xsl:if>

		<xsl:text>"techniques": [</xsl:text>
		<xsl:apply-templates select="$understanding.doc//*[@id = current()/@id]//*[@role='sufficient' or @role='advisory' or @role='tech-optional' or @role='failures'][olist or ulist or div5]"></xsl:apply-templates>
		<xsl:text>]</xsl:text>
		
		<xsl:text>}</xsl:text>
		<xsl:if test="position() != last()">,</xsl:if>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template name="sc-level">
		<xsl:param name="sc" select="."/>
		<xsl:choose>
			<xsl:when test="$sc/parent::*/@role = 'req'">A</xsl:when>
			<xsl:when test="$sc/parent::*/@role = 'bp'">AA</xsl:when>
			<xsl:when test="$sc/parent::*/@role = 'additional'">AAA</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ulist | olist" mode="sc-details">
		<xsl:text>{</xsl:text>
		<xsl:text>"type": "</xsl:text><xsl:value-of select="name()"/><xsl:text>",</xsl:text>
		<xsl:text>"items": [</xsl:text>
		<xsl:apply-templates select="item" mode="sc-details"/>
		<xsl:text>]</xsl:text>
		<xsl:text>}</xsl:text>
		<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="item" mode="sc-details">
		<xsl:variable name="content"><xsl:apply-templates select="p" mode="sc-text"/></xsl:variable>
		<xsl:text>{</xsl:text>
		<xsl:text>"handle": "</xsl:text><xsl:value-of select="wcag:json-string(substring-before(p/emph[@role = 'sc-handle'], ':'))"/><xsl:text>",</xsl:text><!-- requested key was title -->
		<xsl:text>"text": "</xsl:text><xsl:value-of select="wcag:json-string($content)"/><xsl:text>"</xsl:text>
		<xsl:text>}</xsl:text>
		<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="p" mode="sc-details">
		<xsl:variable name="content"><xsl:apply-templates/></xsl:variable>
		<xsl:if test="descendant::specref"><xsl:message><xsl:value-of select="$content"/></xsl:message></xsl:if>
		<xsl:text>{</xsl:text>
		<xsl:text>"type": "p",</xsl:text>
		<xsl:text>"text": "</xsl:text><xsl:value-of select="wcag:json-string($content)"/><xsl:text>"</xsl:text>
		<xsl:text>}</xsl:text>
		<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="note/p" mode="sc-details">
		<xsl:variable name="content"><xsl:apply-templates/></xsl:variable>
		<xsl:text>{</xsl:text>
		<xsl:text>"type": "note",</xsl:text>
		<xsl:text>"handle": "Note </xsl:text><xsl:value-of select="count(preceding-sibling::*) + 1"/><xsl:text>",</xsl:text>
		<xsl:text>"text": "</xsl:text><xsl:value-of select="wcag:json-string($content)"/><xsl:text>"</xsl:text>
		<xsl:text>}</xsl:text>
		<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="p" mode="sc-text">
		<xsl:apply-templates mode="sc-text"/>
	</xsl:template>
	
	<xsl:template match="emph[@role = 'sc-handle']" mode="sc-text"/>
	
	<xsl:template match="*|text()" mode="sc-text">
		<xsl:apply-templates select="."/>
	</xsl:template>
	
	<xsl:template match="div2[@role = 'gladvisory'] | div4[@role = 'sufficient'] | div4[@role = 'advisory'] | div4[@role = 'failures'] | div4[@role = 'tech-optional'][olist or ulist or div5]">
		<xsl:text>{</xsl:text>
		<xsl:text>"</xsl:text>
		<xsl:choose>
			<xsl:when test="@role = 'sufficient'">sufficient</xsl:when>
			<xsl:when test="@role = 'failures'">failure</xsl:when>
			<xsl:otherwise>advisory</xsl:otherwise>
		</xsl:choose>
		<xsl:text>": [</xsl:text>
		<xsl:apply-templates select="ulist/item | olist/item" mode="technique"/>
		<xsl:if test="div5"><!-- removed [@role = 'situation'], so other div5 will be treated like situation -->
			<xsl:if test="ulist"><xsl:text>,</xsl:text></xsl:if>
			<xsl:text>{</xsl:text>
			<xsl:text>"situations": [</xsl:text>
			<xsl:apply-templates select="div5" mode="situation"/><!-- removed [@role = 'situation'], so other div5 will be treated like situation -->
			<xsl:text>]</xsl:text>
			<xsl:text>}</xsl:text>
		</xsl:if>
		<xsl:text>]</xsl:text>
		<xsl:text>}</xsl:text>
		<xsl:if test="position() != last()">,</xsl:if>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="div5" mode="situation"><!-- removed [@role = 'situation'], so other div5 will be treated like situation -->
		<xsl:text>{</xsl:text>
		<xsl:text>"title": "</xsl:text><xsl:value-of select="wcag:json-string(head)"/><xsl:text>",</xsl:text>
		<xsl:text>"techniques": [</xsl:text>
		<xsl:apply-templates select="ulist | olist" mode="technique"/>
		<xsl:text>]</xsl:text>
		<!-- sections, comma before last brace -->
		<xsl:text>}</xsl:text>
		<xsl:if test="position() != last()">,</xsl:if>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="div2/ulist | div4/ulist | div5/ulist"></xsl:template>
	
	<xsl:template match="olist" mode="technique">
		<xsl:apply-templates select="item" mode="technique"/>
		<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="group" mode="technique">
		<xsl:text>{"group": {</xsl:text>
		<xsl:text>"title": "</xsl:text><xsl:value-of select="wcag:json-string(title)"/><xsl:text>",</xsl:text>
		<xsl:text>"techniques": [</xsl:text>
		<xsl:apply-templates select="techniques/ulist | techniques/olist" mode="technique"/>
		<xsl:apply-templates select="techniques/div5" mode="situation"/>
		<xsl:text>]</xsl:text>
		<xsl:text>}}</xsl:text>
		<xsl:if test="position() != last()">,</xsl:if>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<xsl:template match="ulist[not(preceding-sibling::olist)]" mode="technique">
		<xsl:apply-templates select="item" mode="technique"/>
		<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>

	<xsl:template match="item[p/loc][count(p//loc[@linktype and exists(index-of($tech-linktypes, @linktype))]) = 1 and not(p//loc[not(@linktype)]) and not(p//loc[@linktype = 'understanding'])]" mode="technique">
		<xsl:variable name="using">
			<xsl:call-template name="check-using"/>
		</xsl:variable>
		<xsl:apply-templates select="p/loc" mode="technique">
			<xsl:with-param name="using" select="$using"/>
		</xsl:apply-templates>		
		<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="item[p/loc][count(p//loc[@linktype and exists(index-of($tech-linktypes, @linktype))]) = 1 and p//loc[@linktype = 'understanding']]" mode="technique">
		<xsl:variable name="using">
			<xsl:call-template name="check-using"/>
		</xsl:variable>
		<xsl:apply-templates select="p/loc[@linktype and exists(index-of($tech-linktypes, @linktype))]" mode="technique">
			<xsl:with-param name="using" select="$using"/>
		</xsl:apply-templates>		
		<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="item[p/loc][count(p//loc[@linktype and exists(index-of($tech-linktypes, @linktype))]) > 1]" mode="technique">
		<xsl:text>{</xsl:text>
		<xsl:text>"and": </xsl:text>
		<xsl:text>[</xsl:text>
		<xsl:apply-templates select="p/loc" mode="technique"/>
		<xsl:text>]</xsl:text>
		<xsl:call-template name="check-using"/>
		<xsl:text>}</xsl:text>
		<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="item[p/loc][count(p//loc[@linktype and exists(index-of($linktypes, @linktype))]) = 1 and p//loc[not(@linktype)]]" mode="technique">
		<xsl:variable name="using">
			<xsl:call-template name="check-using"/>
		</xsl:variable>
		<xsl:apply-templates select="p/loc[@linktype]" mode="technique">
			<xsl:with-param name="using" select="$using"/>
		</xsl:apply-templates>		
		<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<!-- This is a super special-case -->
	<xsl:template match="item[count(p/loc) = 1 and count(p//loc[@linktype = 'understanding']) = 1]" mode="technique">
		<xsl:variable name="ref" select="//*[@id = current()/p/loc/@href]"/>
		<xsl:apply-templates select="$ref/descendant::div4[@role = 'sufficient']/olist" mode="technique"/>
		<xsl:apply-templates select="$ref/descendant::div4[@role = 'sufficient']/div5" mode="situation"/>
		<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="item[not(p/loc)]" mode="technique">
		<xsl:variable name="content"><xsl:apply-templates select="p"/></xsl:variable>
		<xsl:text>{</xsl:text>
		<xsl:text>"id": "TECH:future</xsl:text><xsl:number/><xsl:text>",</xsl:text>
		<xsl:text>"title": "</xsl:text><xsl:value-of select="wcag:json-string($content)"/><xsl:text>"</xsl:text><!-- requested key was text -->
		<xsl:call-template name="check-using"/>
		<xsl:text>}</xsl:text>
		<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template name="check-using">
		<xsl:choose>
			<xsl:when test="ulist | olist">
				<xsl:call-template name="using">
					<xsl:with-param name="list" select="ulist | olist"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="p//loc[not(@linktype)]">
				<xsl:variable name="list">
					<xsl:for-each select="p//loc[not(@linktype)]">
						<group>
							<title><xsl:copy-of select="//*[@id = substring-after(current()/@href, '#')]"/></title>
							<techniques>
								<xsl:variable name="target" select="//*[@id = substring-after(current()/@href, '#')]/following-sibling::*[1]"/>
								<xsl:choose>
									<xsl:when test="$target/@use-id">
										<xsl:copy-of select="//*[@id = $target/@use-id]"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:copy-of select="$target"/>
									</xsl:otherwise>
								</xsl:choose>
							</techniques>
						</group>
					</xsl:for-each>
				</xsl:variable>
				<xsl:call-template name="using">
					<xsl:with-param name="list" select="$list"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="p//loc[@linktype = 'understanding']">
				<xsl:variable name="list">
					<xsl:for-each select="p//loc[@linktype = 'understanding']">
						<group>
							<title><xsl:value-of select="."/></title>
							<techniques>
								<xsl:variable name="ref" select="//*[@id = current()/@href]"/>
								<xsl:copy-of select="$ref/descendant::div4[@role = 'sufficient']/olist | $ref/descendant::div4[@role = 'sufficient']/div5"/>
							</techniques>
						</group>
					</xsl:for-each>
				</xsl:variable>
				<xsl:call-template name="using">
					<xsl:with-param name="list" select="$list"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="loc[@linktype and exists(index-of($tech-linktypes, @linktype))]" mode="technique">
		<xsl:param name="using"/>
		<xsl:variable name="technique.title">
			<xsl:apply-templates select="$techs-src//technique[@id=current()/@href]/short-name" mode="text"/>
		</xsl:variable>
		<xsl:text>{</xsl:text>
		<xsl:text>"id": "TECH:</xsl:text>
		<xsl:value-of select="@href"/>
		<xsl:text>",</xsl:text>
		<xsl:text>"title": "</xsl:text><xsl:value-of select="wcag:json-string($technique.title)"/><xsl:text>"</xsl:text>
		<xsl:value-of select="$using"/>
		<xsl:text>}</xsl:text>
		<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>

	<xsl:template name="using">
		<xsl:param name="list" select="."/>
		<xsl:text>,"using": [</xsl:text>
		<xsl:apply-templates select="$list" mode="technique"/>
		<xsl:text>]</xsl:text>
	</xsl:template>
	
	<xsl:template match="*[@use-id]" mode="#all" priority="1">
		<xsl:apply-templates select="//*[@id = current()/@use-id]" mode="#current"/>
	</xsl:template>
	
	<!-- Override imported templates that are causing problems -->
	<!--
	<xsl:template match="head">
		<xsl:apply-templates/>
	</xsl:template>
	-->
</xsl:stylesheet>