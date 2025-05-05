<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:wcag="https://www.w3.org/WAI/GL/"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="#all"
	version="3.0">
	
	<xsl:param name="guidelines.version"/>
	<xsl:variable name="guidelines.version.decimal" select="replace($guidelines.version, '(\d)(\d)', '$1.$2')" />
	
	<xsl:param name="loc.guidelines">/guidelines/</xsl:param>
	<xsl:param name="loc.understanding">/understanding/</xsl:param>
	<xsl:param name="loc.techniques">/techniques/</xsl:param>
	
	<xsl:param name="techniques.file">../techniques/techniques.xml</xsl:param>
	<xsl:variable name="techniques.doc" select="document($techniques.file)"/>

	<xsl:param name="versions.file">../guidelines/versions.xml</xsl:param>
	<xsl:variable name="versions.doc" select="document($versions.file)"/>
	
	<xsl:param name="guidelines.file">../guidelines/wcag.xml</xsl:param>
	<xsl:variable name="meta-guidelines" select="document($guidelines.file)"/>
	
	<xsl:param name="act.file">../guidelines/act-mapping.json</xsl:param>
	<xsl:variable name="act.doc" select="json-to-xml(unparsed-text($act.file))"/>
	
	<xsl:param name="documentset"/>
	<xsl:variable name="documentset.name">
		<xsl:choose>
			<xsl:when test="$documentset = 'Techniques'">Techniques</xsl:when>
			<xsl:when test="$documentset = 'Understanding'">Understanding Docs</xsl:when>
			<xsl:otherwise><xsl:value-of select="$documentset"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:function name="wcag:isheading" as="xs:boolean">
		<xsl:param name="el"/>
		<xsl:choose>
			<xsl:when test="name($el) = 'h1' or name($el) = 'h2' or name($el) = 'h3' or name($el) = 'h4' or name($el) = 'h5' or name($el) = 'h6'">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="wcag:generate-id">
		<xsl:param name="title"/>
		<xsl:choose>
			<xsl:when test="$title = 'Parsing (Obsolete and removed)'">parsing</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="lower-case(replace(replace($title, '\s+', '-'), '[\s,\():]+', ''))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="wcag:find-heading">
		<xsl:param name="el"/>
		<xsl:copy-of select="$el/html:h1[1] | $el/html:h2[1]| $el/html:h3[1] | $el/html:h4[1] | $el/html:h5[1] | $el/html:h6[1]"/>
	</xsl:function>
	
	<xsl:function name="wcag:number-in-id">
		<xsl:param name="value"/>
		<xsl:analyze-string select="$value" regex="\d+">
			<xsl:matching-substring>
				<xsl:value-of select="."/>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:function>
	
	<xsl:function name="wcag:is-technique-link" as="xs:boolean">
		<xsl:param name="link"/>
		<xsl:choose>
			<!--
			<xsl:when test="$link/@class and index-of(('aria', 'client-side-script', 'css', 'failure', 'failures', 'flash', 'general', 'html', 'pdf', 'server-side-script', 'silverlight', 'smil', 'text', 'technqiues'), $link/@class)"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="starts-with($link/@href, 'https://www.w3.org/WAI/WCAG21/Techniques/')"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="starts-with($link/@href, 'https://w3c.github.io/techniques/')"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="starts-with($link/@href, 'https://rawgit.com/w3c/wcag/') and contains($link/@href, '/techniques/')"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="starts-with($link/@href, '../') and contains($link/@href, '/techniques/')"><xsl:value-of select="true()"/></xsl:when>
			-->
			<xsl:when test="(starts-with($link/@href, 'https://www.w3.org/WAI/WCAG21/Techniques/') or starts-with($link/@href, 'https://w3c.github.io/techniques/') or starts-with($link/@href, 'https://rawgit.com/w3c/wcag/') or starts-with($link/@href, '../')) and matches($link/@href, '[A-Z]+\d+(.html)?$')"><xsl:value-of select="true()"/></xsl:when>
			<xsl:when test="matches($link/@href, '^([a-z\-]+/)?[A-Z]+\d+(.html)?$')"><xsl:value-of select="true()"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="wcag:section-meaningfully-exists" as="xs:boolean">
		<xsl:param name="id"/>
		<xsl:param name="section"/>
		<xsl:choose>
			<xsl:when test="$id = 'applicability'"><xsl:value-of select="$section and ($section/html:p[not(@class = 'instructions')] or $section/html:ol or $section/html:ul)"/></xsl:when>
			<xsl:when test="$id = 'description'"><xsl:value-of select="$section and $section/html:p[not(@class = 'instructions')]"/></xsl:when>
			<xsl:when test="$id = 'examples'"><xsl:value-of select="$section and ($section/html:p[not(@class = 'instructions')] or $section/html:ol or $section/html:ul or $section/html:dl or $section/html:section[@class = 'example'])"/></xsl:when>
			<xsl:when test="$id = 'resources'"><xsl:value-of select="$section and ($section/html:p[not(@class = 'instructions')] or $section//html:li[not(. = 'Resource')] or $section//html:a[@href])"/></xsl:when>
			<xsl:when test="$id = 'related'"><xsl:value-of select="$section and $section//html:li//html:a[@href]"/></xsl:when>
			<xsl:when test="$id = 'tests'"><xsl:value-of select="$section and $section//html:section[@class = 'test-procedure' or @class = 'procedure']//html:li and $section//html:section[@class = 'test-results' or @class = 'results']"/></xsl:when>
			<xsl:when test="$id = 'sufficient' or $id = 'advisory' or $id = 'gladvisory' or $id = 'failure'"><xsl:value-of select="$section and ($section/html:*[not(@class = 'instructions')]//html:li)"/></xsl:when>
			<xsl:when test="$id = 'brief'"><xsl:value-of select="exists($section)"/></xsl:when>
		</xsl:choose>
	</xsl:function>
	
	<xsl:template match="node()|@*" mode="#all" priority="-1">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:a[wcag:is-technique-link(.)]">
		<xsl:variable name="technique-id" select="replace(@href, '^.*/([\w\d]*)(\.html)?$', '$1')"/>
		<xsl:choose>
			<xsl:when test="$technique-id">
				<xsl:variable name="technique" select="$techniques.doc//technique[@id = $technique-id]"/>
				<xsl:copy>
					<xsl:apply-templates select="@*[not(name() = 'href')]"/>
					<xsl:attribute name="href">
						<xsl:value-of select="$loc.techniques"/>
						<xsl:value-of select="$technique/parent::technology/@name"/>
						<xsl:text>/</xsl:text>
						<xsl:value-of select="$technique-id"/>
					</xsl:attribute>
					<xsl:value-of select="$technique-id"/>
					<xsl:text>: </xsl:text>
					<xsl:value-of select="$technique/title"/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<xsl:text>IN DEVELOPMENT: </xsl:text>
					<xsl:apply-templates/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="html:p[@class = 'note'] | html:div[@class = 'note']">
		<div class="note">
			<div role="heading" class="note-title marker" aria-level="{count(ancestor::html:section) + 2}">Note</div>
			<xsl:copy><xsl:apply-templates select="@*[not(name() = 'class')]|node()"/></xsl:copy>
		</div>
	</xsl:template>
	
	<xsl:template match="html:li[@class = 'note']">
		<xsl:copy>
			<xsl:apply-templates select="@*[not(name() = 'class')]"/>
			<div class="note">
				<div role="heading" class="note-title marker" aria-level="{count(ancestor::html:section) + 2}">Note</div>
				<xsl:apply-templates/>
			</div>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:*[@class = 'generate-date']">
		<xsl:value-of select="format-date(current-date(), '[D] [MNn] [Y]')"/>
	</xsl:template>
	
	<xsl:template match="html:*[@class = 'generate-year']">
		<xsl:value-of select="format-date(current-date(), '[Y]')"/>
	</xsl:template>
	
	<xsl:template match="html:link[@href][contains(@href, 'css/editors.css')]"/>
	
	<xsl:template match="html:figure">
		<xsl:if test="not(@id)">
			<xsl:message terminate="yes">ID is required on figure: src=<xsl:value-of select="html:img/@src"/> in <xsl:value-of select="base-uri()"/></xsl:message>
		</xsl:if>
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:figcaption">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:text>Figure </xsl:text>
			<xsl:value-of select="count(parent::html:figure/preceding::html:figure) + 1"/>
			<xsl:text> </xsl:text>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="html:p[@class = 'change']"/>
	
	<xsl:template match="element()[@data-include]">
		<xsl:choose>
			<xsl:when test="@data-include-replace = 'true'"><xsl:value-of select="unparsed-text(resolve-uri(@data-include, document-uri(ancestor::document-node())))" disable-output-escaping="yes"/></xsl:when>
			<xsl:otherwise>
				<xsl:copy><xsl:apply-templates select="@*[not(name() = 'data-include')]"/><xsl:value-of select="unparsed-text(resolve-uri(@data-include, document-uri(ancestor::document-node())))" disable-output-escaping="yes"/></xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="html:*[starts-with(@class, 'wcag')]">
		<xsl:if test="not($guidelines.version)">
			<xsl:message terminate="yes">Guidelines version not provided</xsl:message>
		</xsl:if>
		<xsl:variable name="version" select="substring-after(@class, 'wcag')"/>
		<xsl:choose>
			<xsl:when test="$version &lt; $guidelines.version">
				<xsl:copy>
					<xsl:apply-templates select="node()|@*"/>
				</xsl:copy>
			</xsl:when>
			<xsl:when test="$version = $guidelines.version">
				<xsl:copy>
					<xsl:apply-templates select="@*"/>
					<xsl:text> </xsl:text><span class="new-version">New in WCAG <xsl:value-of select="$guidelines.version"/>: </span>
					<xsl:apply-templates/>
				</xsl:copy>
			</xsl:when>
			<xsl:when test="$version &gt; $guidelines.version"><!-- don't output --></xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="header">
    <a href="#main" class="button button--skip-link">Skip to content</a>
		<div class="minimal-header-container default-grid">
				<div class="minimal-header" id="site-header">
					<div class="minimal-header-name">
						<a>
							<xsl:attribute name="href">
								<xsl:if test="$documentset = 'Understanding'"><xsl:value-of select="$loc.understanding"/></xsl:if>
								<xsl:if test="$documentset = 'Techniques'"><xsl:value-of select="$loc.techniques"/></xsl:if>
							</xsl:attribute>
						<xsl:text>WCAG </xsl:text>
						<xsl:value-of select="$guidelines.version.decimal"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="$documentset.name"/>
						</a>
					</div>
          <xsl:choose>
            <xsl:when test="$documentset = 'Techniques'">
    					<div class="minimal-header-subtitle">Examples of ways to meet WCAG; not required</div>
            </xsl:when>
            <xsl:when test="$documentset = 'Understanding'">
    					<div class="minimal-header-subtitle">Informative explanations, not required to meet WCAG</div>
            </xsl:when>
          </xsl:choose>
						<a class="minimal-header-link">
							<xsl:attribute name="href">
								<xsl:if test="$documentset = 'Understanding'"><xsl:value-of select="$loc.understanding"/>about</xsl:if>
								<xsl:if test="$documentset = 'Techniques'"><xsl:value-of select="$loc.techniques"/>about</xsl:if>
							</xsl:attribute>
							<xsl:text>About WCAG </xsl:text>
							<xsl:value-of select="$documentset.name"/>
						</a>
						<div class="minimal-header-logo">
								<a href="http://w3.org/" aria-label="W3C">
									<svg
										xmlns="http://www.w3.org/2000/svg"
										height="2em"
										viewBox="0 0 91.968 44"
										style="margin: 0.75em 0 0.75em 0.5em"
									>
										<g fill-rule="evenodd" fill="none"><path
												fill="#015a9c"
												d="M-.231-.21h92.917v44.659H-.23z"
											/>
												<g fill-rule="nonzero" fill="#fff"><path
													d="M21.752 0l7.789 26.78L37.329 0H58.444v2.662l-7.95 13.852c2.792.907 4.905 2.555 6.337 4.944 1.432 2.391 2.149 5.196 2.149 8.419 0 3.985-1.048 7.335-3.143 10.05C53.742 42.642 51.029 44 47.7 44c-2.507 0-4.691-.806-6.552-2.417-1.862-1.611-3.24-3.793-4.136-6.546l4.403-1.846c.646 1.666 1.496 2.979 2.552 3.938 1.056.96 2.3 1.438 3.733 1.438 1.504 0 2.775-.85 3.813-2.552 1.039-1.703 1.558-3.747 1.558-6.14 0-2.643-.556-4.69-1.664-6.138-1.29-1.701-3.314-2.554-6.071-2.554h-2.148v-2.606l7.52-13.147H41.63l-.516.889-11.04 37.678h-.536L21.48 16.73l-8.056 27.268h-.537L0 0h5.64l7.787 26.78 5.264-18.033L16.113 0zM87.958 0c-1.077 0-2.044.388-2.777 1.133-.777.79-1.21 1.81-1.21 2.866s.412 2.034 1.167 2.8C85.905 7.579 86.892 8 87.959 8c1.043 0 2.055-.422 2.843-1.188.755-.733 1.166-1.711 1.166-2.811a3.997 3.997 0 00-1.155-2.811A3.946 3.946 0 0087.958 0zm3.476 4.034a3.32 3.32 0 01-1.01 2.41c-.69.668-1.544 1.023-2.489 1.023a3.405 3.405 0 01-2.42-1.033c-.655-.667-1.022-1.523-1.022-2.433 0-.911.378-1.8 1.055-2.489.633-.645 1.488-.988 2.42-.988.955 0 1.81.356 2.477 1.033.645.643.99 1.51.99 2.477zm-3.366-2.378h-1.71v4.533h.855V4.256h.845l.922 1.933h.955l-1.012-2.066c.655-.134 1.033-.578 1.033-1.223 0-.822-.621-1.244-1.888-1.244zm-.155.555c.8 0 1.165.222 1.165.778 0 .533-.365.722-1.144.722h-.722v-1.5zM82.109 0l.862 5.914-3.05 6.588s-1.172-2.795-3.118-4.342c-1.64-1.303-2.708-1.586-4.378-1.198-2.145.5-4.577 3.394-5.638 6.963-1.27 4.27-1.283 6.336-1.328 8.234-.071 3.042.354 4.841.354 4.841s-1.853-3.868-1.835-9.533c.012-4.043.576-7.71 2.233-11.328 1.459-3.181 3.626-5.09 5.55-5.315 1.99-.232 3.562.85 4.777 2.02 1.276 1.23 2.565 3.918 2.565 3.918zM82.202 31.824s-1.338 2.567-2.171 3.556c-.834.99-2.326 2.732-4.167 3.603-1.842.872-2.808 1.036-4.628.849-1.82-.188-3.51-1.319-4.102-1.79-.592-.472-2.106-1.861-2.962-3.156C63.317 33.59 61.98 31 61.98 31s.745 2.596 1.212 3.698c.269.635 1.094 2.574 2.265 4.262 1.092 1.576 3.214 4.287 6.438 4.899 3.224.613 5.44-.942 5.987-1.319.549-.376 1.704-1.416 2.436-2.256.763-.877 1.486-1.995 1.886-2.666.292-.49.768-1.485.768-1.485z"
												/></g>
										</g>
									</svg>
								</a>
								<a href="http://w3.org/WAI/" aria-label="Web Accessibility Initiative">
									<svg
										xmlns="http://www.w3.org/2000/svg"
										height="2em"
										viewBox="0 0 162.5 45.9"
										style="margin: 0.75em 0 0.75em 0.5em"
									>
										<g fill="none" fill-rule="evenodd">
												<path d="M0 0h162.5v45.9H0z" fill="#015a9c" />
												<path
												d="M1.2 24.5h160"
												stroke="#eed009"
												stroke-linecap="square"
												stroke-width="2"
											/>
												<g fill="#fff" fill-rule="nonzero">
													<path
													d="M15.741 15.5h-1.816L11.14 6.145c-.41-1.394-.65-2.334-.722-2.823-.104.749-.332 1.71-.684 2.881L7.04 15.5H5.223L1.444 1.223H3.32l2.217 8.72c.3 1.14.527 2.272.684 3.399.143-1.068.397-2.237.761-3.506l2.52-8.613h1.855l2.627 8.681c.339 1.127.6 2.272.781 3.438.105-.899.336-2.038.694-3.418l2.207-8.701h1.875zm10.127.195c-1.608 0-2.87-.486-3.784-1.46-.915-.973-1.372-2.312-1.372-4.018 0-1.719.426-3.088 1.279-4.107.853-1.019 2.005-1.528 3.457-1.528 1.348 0 2.422.435 3.223 1.304.8.869 1.2 2.046 1.2 3.53v1.064h-7.343c.033 1.218.342 2.142.928 2.774.586.631 1.416.947 2.49.947a8.46 8.46 0 001.631-.151c.514-.101 1.116-.298 1.807-.591v1.543a8.506 8.506 0 01-1.67.537c-.521.104-1.136.156-1.846.156zm-.44-9.677c-.84 0-1.503.27-1.992.81-.488.54-.778 1.292-.869 2.256h5.46c-.014-1.003-.245-1.764-.694-2.285-.45-.521-1.084-.781-1.904-.781zm12.237-1.416c1.413 0 2.503.486 3.271 1.46.769.973 1.153 2.332 1.153 4.077 0 1.77-.39 3.14-1.172 4.106-.781.967-1.865 1.45-3.252 1.45-.723 0-1.367-.13-1.934-.39a3.384 3.384 0 01-1.386-1.162h-.137a48.165 48.165 0 01-.362 1.357h-1.26V.305h1.759v3.691c0 .736-.033 1.471-.098 2.207h.098c.722-1.068 1.829-1.601 3.32-1.601zm-.293 1.455c-1.08 0-1.856.306-2.324.918-.47.612-.703 1.647-.703 3.105v.078c0 1.465.239 2.512.717 3.14.479.628 1.262.942 2.349.942.963 0 1.681-.353 2.153-1.06.472-.706.708-1.726.708-3.06 0-1.355-.237-2.37-.713-3.048-.475-.677-1.204-1.015-2.187-1.015zM59.286 15.5l-1.719-4.424h-5.664l-1.7 4.424h-1.816l5.577-14.336h1.62L61.152 15.5zM57.03 9.484L55.43 5.158l-.684-2.138c-.195.78-.4 1.494-.615 2.138l-1.621 4.326zm10.137 6.211c-1.543 0-2.744-.473-3.604-1.42-.86-.948-1.289-2.307-1.289-4.078 0-1.797.435-3.182 1.304-4.155.87-.973 2.108-1.46 3.716-1.46.52 0 1.037.054 1.548.161.51.108.932.246 1.264.415l-.537 1.465c-.905-.338-1.676-.508-2.314-.508-1.081 0-1.879.34-2.393 1.02-.514.681-.771 1.695-.771 3.043 0 1.295.257 2.287.771 2.973.514.687 1.276 1.03 2.285 1.03.944 0 1.872-.208 2.783-.624v1.562c-.742.384-1.663.576-2.763.576zm9.6 0c-1.544 0-2.745-.473-3.604-1.42-.86-.948-1.29-2.307-1.29-4.078 0-1.797.435-3.182 1.305-4.155.869-.973 2.107-1.46 3.715-1.46.521 0 1.037.054 1.548.161.511.108.933.246 1.265.415l-.537 1.465c-.905-.338-1.677-.508-2.315-.508-1.08 0-1.878.34-2.392 1.02-.515.681-.772 1.695-.772 3.043 0 1.295.257 2.287.772 2.973.514.687 1.276 1.03 2.285 1.03.944 0 1.872-.208 2.783-.624v1.562c-.742.384-1.663.576-2.764.576zm9.863 0c-1.608 0-2.87-.486-3.784-1.46-.915-.973-1.373-2.312-1.373-4.018 0-1.719.427-3.088 1.28-4.107.853-1.019 2.005-1.528 3.457-1.528 1.347 0 2.422.435 3.222 1.304.801.869 1.202 2.046 1.202 3.53v1.064H83.29c.032 1.218.342 2.142.928 2.774.586.631 1.416.947 2.49.947a8.46 8.46 0 001.63-.151c.515-.101 1.117-.298 1.807-.591v1.543a8.506 8.506 0 01-1.67.537c-.52.104-1.136.156-1.845.156zm-.44-9.677c-.84 0-1.504.27-1.992.81s-.778 1.292-.87 2.256h5.46c-.013-1.003-.244-1.764-.693-2.285-.45-.521-1.084-.781-1.905-.781zm14.14 6.523c0 1.003-.373 1.779-1.122 2.33-.749.55-1.8.824-3.154.824-1.413 0-2.536-.224-3.37-.674V13.42c1.179.573 2.315.86 3.409.86.885 0 1.53-.144 1.933-.43.404-.287.606-.671.606-1.153 0-.423-.194-.781-.581-1.074-.388-.293-1.076-.628-2.066-1.006-1.009-.39-1.719-.724-2.129-1-.41-.277-.711-.588-.903-.933-.192-.345-.288-.765-.288-1.26 0-.88.358-1.572 1.074-2.08.716-.508 1.7-.762 2.95-.762a8.17 8.17 0 013.417.723L99.511 6.7c-1.088-.456-2.068-.683-2.94-.683-.73 0-1.282.115-1.66.346-.378.231-.566.549-.566.952 0 .391.162.715.488.972.325.257 1.084.614 2.275 1.07.892.331 1.551.64 1.978.927.426.287.74.609.942.967.202.358.303.788.303 1.289zm9.58 0c0 1.003-.373 1.779-1.122 2.33-.749.55-1.8.824-3.154.824-1.413 0-2.536-.224-3.37-.674V13.42c1.179.573 2.315.86 3.409.86.885 0 1.53-.144 1.933-.43.404-.287.606-.671.606-1.153 0-.423-.194-.781-.581-1.074-.388-.293-1.076-.628-2.066-1.006-1.009-.39-1.719-.724-2.129-1-.41-.277-.71-.588-.903-.933-.192-.345-.288-.765-.288-1.26 0-.88.358-1.572 1.074-2.08.716-.508 1.7-.762 2.95-.762a8.17 8.17 0 013.417.723l-.595 1.396c-1.088-.456-2.067-.683-2.94-.683-.729 0-1.282.115-1.66.346-.378.231-.566.549-.566.952 0 .391.162.715.488.972.325.257 1.084.614 2.275 1.07.892.331 1.551.64 1.978.927.426.287.74.609.942.967.202.358.303.788.303 1.289zm4.356 2.959h-1.757V4.777h1.757zm-1.894-13.623c0-.39.1-.674.298-.85.198-.175.444-.263.737-.263.273 0 .513.088.718.263.205.176.307.46.307.85 0 .384-.102.667-.307.85a1.047 1.047 0 01-.718.273 1.05 1.05 0 01-.737-.273c-.199-.183-.298-.466-.298-.85zm10.371 2.725c1.413 0 2.503.486 3.271 1.46.769.973 1.153 2.332 1.153 4.077 0 1.77-.39 3.14-1.172 4.106-.781.967-1.865 1.45-3.252 1.45-.723 0-1.367-.13-1.934-.39a3.384 3.384 0 01-1.386-1.162h-.137a48.244 48.244 0 01-.361 1.357h-1.26V.305h1.758v3.691c0 .736-.033 1.471-.098 2.207h.098c.722-1.068 1.83-1.601 3.32-1.601zm-.293 1.455c-1.08 0-1.855.306-2.324.918-.469.612-.703 1.647-.703 3.105v.078c0 1.465.239 2.512.717 3.14.479.628 1.262.942 2.35.942.963 0 1.68-.353 2.152-1.06.472-.706.708-1.726.708-3.06 0-1.355-.237-2.37-.713-3.048-.475-.677-1.204-1.015-2.187-1.015zm9.277 9.443h-1.757V4.777h1.757zm-1.894-13.623c0-.39.1-.674.298-.85.198-.175.444-.263.737-.263.273 0 .513.088.718.263.205.176.307.46.307.85 0 .384-.102.667-.307.85a1.047 1.047 0 01-.718.273 1.05 1.05 0 01-.737-.273c-.199-.183-.298-.466-.298-.85zm7.05 13.623h-1.757V.305h1.758zm5.157 0h-1.758V4.777h1.758zm-1.895-13.623c0-.39.1-.674.298-.85.199-.175.444-.263.737-.263.274 0 .513.088.718.263.205.176.308.46.308.85 0 .384-.103.667-.308.85a1.047 1.047 0 01-.718.273 1.05 1.05 0 01-.737-.273c-.198-.183-.298-.466-.298-.85zm8.877 12.383c.228 0 .495-.023.801-.069.306-.045.537-.097.693-.156v1.348c-.162.071-.415.141-.756.21a5.29 5.29 0 01-1.04.102c-2.097 0-3.145-1.103-3.145-3.31v-6.24h-1.514v-.84l1.534-.703.703-2.286h1.045v2.461h3.095v1.368h-3.095v6.19c0 .62.148 1.095.444 1.427.296.332.708.498 1.235.498zm1.953-9.483h1.885l2.315 6.104c.488 1.328.787 2.301.898 2.92h.078c.059-.241.192-.692.4-1.353.209-.66.385-1.19.528-1.587l2.178-6.084h1.894l-4.619 12.207c-.45 1.185-.983 2.035-1.602 2.55-.618.514-1.383.77-2.294.77-.489 0-.974-.055-1.456-.165v-1.397c.326.078.717.117 1.172.117.56 0 1.035-.154 1.426-.463.39-.31.71-.787.957-1.431l.557-1.426zM7.157 45.5H2.001v-1.035l1.68-.381V32.658l-1.68-.4v-1.035h5.156v1.035l-1.68.4v11.426l1.68.38zm9.824 0v-6.855c0-.873-.193-1.522-.58-1.949-.388-.426-.995-.64-1.822-.64-1.1 0-1.9.305-2.398.914-.498.608-.747 1.6-.747 2.973V45.5H9.677V34.777h1.416l.263 1.465h.098a3.31 3.31 0 011.396-1.225 4.492 4.492 0 011.983-.435c1.315 0 2.292.319 2.93.957.638.638.957 1.63.957 2.979V45.5zm6.817 0H22.04V34.777h1.758zm-1.895-13.623c0-.39.1-.674.298-.85.199-.175.444-.263.737-.263.274 0 .513.088.718.263.205.176.308.46.308.85 0 .384-.103.667-.308.85a1.047 1.047 0 01-.718.273 1.05 1.05 0 01-.737-.273c-.199-.183-.298-.466-.298-.85zM30.78 44.26c.228 0 .495-.023.8-.069.307-.045.538-.097.694-.156v1.348c-.163.071-.415.141-.757.21a5.29 5.29 0 01-1.04.102c-2.096 0-3.144-1.103-3.144-3.31v-6.24h-1.514v-.84l1.533-.703.703-2.286H29.1v2.461h3.096v1.368H29.1v6.19c0 .62.149 1.095.445 1.427.296.332.708.498 1.235.498zm5.39 1.24h-1.757V34.777h1.758zm-1.894-13.623c0-.39.1-.674.298-.85.199-.175.444-.263.737-.263.274 0 .513.088.718.263.205.176.308.46.308.85 0 .384-.103.667-.308.85a1.047 1.047 0 01-.718.273 1.05 1.05 0 01-.737-.273c-.199-.183-.298-.466-.298-.85zM46.19 45.5l-.342-1.523h-.078c-.534.67-1.066 1.124-1.596 1.362-.53.237-1.2.356-2.007.356-1.055 0-1.882-.276-2.48-.83-.6-.553-.9-1.334-.9-2.344 0-2.174 1.716-3.313 5.147-3.417l1.817-.069V38.4c0-.813-.176-1.414-.528-1.801-.351-.388-.914-.581-1.689-.581-.566 0-1.102.084-1.606.253-.505.17-.979.359-1.421.567l-.537-1.318a7.958 7.958 0 011.767-.674 7.642 7.642 0 011.895-.244c1.295 0 2.259.286 2.89.859.632.573.948 1.484.948 2.734V45.5zm-3.623-1.22c.983 0 1.756-.266 2.32-.797.563-.53.844-1.284.844-2.26v-.967l-1.582.068c-1.23.046-2.127.241-2.69.586-.563.345-.845.889-.845 1.631 0 .56.171.99.513 1.29.342.299.822.448 1.44.448zm11.807-.02c.228 0 .495-.023.8-.069.307-.045.538-.097.694-.156v1.348c-.163.071-.415.141-.757.21a5.29 5.29 0 01-1.04.102c-2.096 0-3.144-1.103-3.144-3.31v-6.24h-1.514v-.84l1.533-.703.703-2.286h1.045v2.461h3.096v1.368h-3.096v6.19c0 .62.148 1.095.444 1.427.297.332.708.498 1.236.498zm5.39 1.24h-1.757V34.777h1.757zM57.87 31.877c0-.39.1-.674.298-.85.198-.175.444-.263.737-.263.274 0 .513.088.718.263.205.176.307.46.307.85 0 .384-.102.667-.307.85a1.047 1.047 0 01-.718.273 1.05 1.05 0 01-.737-.273c-.199-.183-.298-.466-.298-.85zM65.526 45.5l-4.062-10.723h1.884l2.276 6.319c.45 1.27.736 2.216.86 2.842h.077a11.495 11.495 0 01.176-.64c.04-.127.28-.861.723-2.202l2.285-6.319h1.875L67.548 45.5zm12.354.195c-1.608 0-2.87-.486-3.784-1.46-.915-.973-1.373-2.312-1.373-4.018 0-1.719.427-3.088 1.28-4.107.853-1.019 2.005-1.528 3.457-1.528 1.347 0 2.422.435 3.222 1.304.801.869 1.202 2.046 1.202 3.53v1.064H74.54c.032 1.218.342 2.142.928 2.774.586.631 1.416.947 2.49.947a8.46 8.46 0 001.63-.151c.515-.101 1.117-.298 1.807-.591v1.543a8.506 8.506 0 01-1.67.537c-.52.104-1.136.156-1.845.156zm-.44-9.677c-.84 0-1.504.27-1.992.81s-.778 1.292-.87 2.256h5.46c-.013-1.003-.244-1.764-.693-2.285-.45-.521-1.084-.781-1.905-.781zM137.741 45.5h-1.816l-2.784-9.355c-.41-1.394-.65-2.334-.722-2.823-.104.749-.332 1.71-.684 2.881L129.04 45.5h-1.817l-3.779-14.277h1.875l2.217 8.72c.3 1.14.527 2.272.684 3.399.143-1.068.397-2.237.761-3.506l2.52-8.613h1.855l2.627 8.681c.339 1.127.6 2.272.781 3.438.105-.899.336-2.038.694-3.418l2.207-8.701h1.875zm14.57 0l-1.718-4.424h-5.664l-1.7 4.424h-1.816l5.576-14.336h1.621l5.567 14.336zm-2.256-6.016l-1.601-4.326-.684-2.138c-.195.78-.4 1.494-.615 2.138l-1.621 4.326zm10.098 6.016h-5.156v-1.035l1.68-.381V32.658l-1.68-.4v-1.035h5.156v1.035l-1.68.4v11.426l1.68.38z"
												/>
												</g>
										</g>
									</svg>
								</a>
						</div>
				</div>
		</div>
	</xsl:template>

	<xsl:template name="navigation">
		<xsl:param name="navigation.current" required="no"/>

    <xsl:if test="$documentset = 'Understanding'">
  		<div class="default-grid nav-container nav-page-specific">
  			<div class="default-grid">
  				<nav class="nav" aria-label="{$documentset.name}">
  					<ul>
							<li class="nav__item">
							<a href=".">
								<xsl:if test="$navigation.current = 'all'">
									<xsl:attribute name="class">active</xsl:attribute>
									<xsl:attribute name="aria-current">page</xsl:attribute>
								</xsl:if>
								All Understanding Docs
							</a>
							</li>
  					</ul>
  				</nav>
  			</div>
  		</div>
    </xsl:if>
	</xsl:template>
	
	<xsl:template name="nav-level1-prev"><xsl:message>override nav-level1-prev</xsl:message></xsl:template>
	<xsl:template name="nav-level1-cur"><xsl:message>override nav-level1-cur</xsl:message></xsl:template>
	<xsl:template name="nav-level1-next"><xsl:message>override nav-level1-next</xsl:message></xsl:template>
	<xsl:template name="nav-level2-prev"><xsl:message>override nav-level2-prev</xsl:message></xsl:template>
	<xsl:template name="nav-level2-cur"><xsl:message>override nav-level2-cur</xsl:message></xsl:template>
	<xsl:template name="nav-level2-next"><xsl:message>override nav-level2-next</xsl:message></xsl:template>
	
	<xsl:template name="back-to-top">
		<a class="button button-backtotop" href="#top">
			<span>
				<svg focusable="false" aria-hidden="true" class="icon-arrow-up " viewBox="0 0 26 28">
					<path d="M25.172 15.172c0 0.531-0.219 1.031-0.578 1.406l-1.172 1.172c-0.375 0.375-0.891 0.594-1.422 0.594s-1.047-0.219-1.406-0.594l-4.594-4.578v11c0 1.125-0.938 1.828-2 1.828h-2c-1.062 0-2-0.703-2-1.828v-11l-4.594 4.578c-0.359 0.375-0.875 0.594-1.406 0.594s-1.047-0.219-1.406-0.594l-1.172-1.172c-0.375-0.375-0.594-0.875-0.594-1.406s0.219-1.047 0.594-1.422l10.172-10.172c0.359-0.375 0.875-0.578 1.406-0.578s1.047 0.203 1.422 0.578l10.172 10.172c0.359 0.375 0.578 0.891 0.578 1.422z"></path>
				</svg> Back to Top
			</span>
		</a>
	</xsl:template>

	<xsl:template name="help-improve">
		<aside class="box box-icon box-space-above" id="helpimprove" style="grid-column: 2 / 8; grid-row: 3">
			<header class="box-h  box-h-icon box-h-space-above box-h-icon"> 
				<svg focusable="false" aria-hidden="true" class="icon-comments" viewBox="0 0 28 28">
					<path d="M22 12c0 4.422-4.922 8-11 8-0.953 0-1.875-0.094-2.75-0.25-1.297 0.922-2.766 1.594-4.344 2-0.422 0.109-0.875 0.187-1.344 0.25h-0.047c-0.234 0-0.453-0.187-0.5-0.453v0c-0.063-0.297 0.141-0.484 0.313-0.688 0.609-0.688 1.297-1.297 1.828-2.594-2.531-1.469-4.156-3.734-4.156-6.266 0-4.422 4.922-8 11-8s11 3.578 11 8zM28 16c0 2.547-1.625 4.797-4.156 6.266 0.531 1.297 1.219 1.906 1.828 2.594 0.172 0.203 0.375 0.391 0.313 0.688v0c-0.063 0.281-0.297 0.484-0.547 0.453-0.469-0.063-0.922-0.141-1.344-0.25-1.578-0.406-3.047-1.078-4.344-2-0.875 0.156-1.797 0.25-2.75 0.25-2.828 0-5.422-0.781-7.375-2.063 0.453 0.031 0.922 0.063 1.375 0.063 3.359 0 6.531-0.969 8.953-2.719 2.609-1.906 4.047-4.484 4.047-7.281 0-0.812-0.125-1.609-0.359-2.375 2.641 1.453 4.359 3.766 4.359 6.375z"></path>
				</svg> 
				<h2> Help improve this page </h2>
			</header>
			<div class="box-i">
    		<p>Please share your ideas, suggestions, or comments via e-mail to the publicly-archived list <a href="mailto:public-agwg-comments@w3.org?subject=%5BUnderstanding%20and%20Techniques%20Feedback%5D">public-agwg-comments@w3.org</a> or via GitHub</p>
				<div class="button-group">
					<a href="mailto:public-agwg-comments@w3.org?subject=%5BUnderstanding%20and%20Techniques%20Feedback%5D"
						class="button"><span>E-mail</span></a>
					<a href="https://github.com/w3c/wcag/issues/" class="button"><span>Fork &amp; Edit on GitHub</span></a>
					<a href="https://github.com/w3c/wcag/issues/new" class="button"><span>New GitHub Issue</span></a>
				</div>			
			</div>
		</aside>
	</xsl:template>

	<xsl:template name="wai-site-footer">
		<footer id="wai-site-footer" class="page-footer default-grid" aria-label="Page">
    	<div class="inner" style="grid-column: 2 / 8">
      	<p><strong>Date:</strong> Updated <xsl:value-of select="format-date(current-date(), '[D] [MNn] [Y]')"/>.</p> <p><strong>Developed by</strong><xsl:text> </xsl:text><a href="https://www.w3.org/groups/wg/ag/participants">Accessibility Guidelines Working Group (AG WG) Participants</a> (Co-Chairs: Alastair Campbell, Charles Adams, Rachael Bradley Montgomery. W3C Staff Contact: Kevin White).</p>
    		<p>The content was developed as part of the <a href="https://www.w3.org/WAI/about/projects/#us">WAI-Core projects</a> funded by U.S. Federal funds. The user interface was designed by the Education and Outreach Working Group (<a href="https://www.w3.org/groups/wg/eowg/participants">EOWG</a>) with contributions from Shadi Abou-Zahra, Steve Lee, and Shawn Lawton Henry as part of the <a href="https://www.w3.org/WAI/about/projects/wai-guide/">WAI-Guide</a> project, co-funded by the European Commission.</p>
			</div>
  	</footer>	
	</xsl:template>

	<xsl:template name="site-footer">
		<footer class="site-footer grid-4q" aria-label="Site">
			<div class="q1-start q3-end about">
				<div>
					<p><a class="largelink" href="https://www.w3.org/WAI/" dir="auto" translate="no" lang="en">W3C Web Accessibility Initiative (WAI)</a></p>
					<p>Strategies, standards, and supporting resources to make the Web accessible to people with disabilities.</p>
				</div>
				<div class="social" dir="auto" translate="no" lang="en">
					<ul>
						<li><a href="https://twitter.com/w3c_wai"><svg focusable="false" aria-hidden="true" class="icon-twitter " viewBox="0 0 32 32"><path d="M31.939 6.092c-1.18 0.519-2.44 0.872-3.767 1.033 1.352-0.815 2.392-2.099 2.884-3.631-1.268 0.74-2.673 1.279-4.169 1.579-1.195-1.279-2.897-2.079-4.788-2.079-3.623 0-6.56 2.937-6.56 6.556 0 0.52 0.060 1.020 0.169 1.499-5.453-0.257-10.287-2.876-13.521-6.835-0.569 0.963-0.888 2.081-0.888 3.3 0 2.28 1.16 4.284 2.917 5.461-1.076-0.035-2.088-0.331-2.971-0.821v0.081c0 3.18 2.257 5.832 5.261 6.436-0.551 0.148-1.132 0.228-1.728 0.228-0.419 0-0.82-0.040-1.221-0.115 0.841 2.604 3.26 4.503 6.139 4.556-2.24 1.759-5.079 2.807-8.136 2.807-0.52 0-1.039-0.031-1.56-0.089 2.919 1.859 6.357 2.945 10.076 2.945 12.072 0 18.665-9.995 18.665-18.648 0-0.279 0-0.56-0.020-0.84 1.281-0.919 2.4-2.080 3.28-3.397l-0.063-0.027z"></path></svg> Twitter</a></li>
						<li><a href="https://www.w3.org/WAI/feed.xml"><svg focusable="false" aria-hidden="true" class="icon-rss " viewBox="0 0 32 32"><path d="M25.599 32c0-14.044-11.555-25.6-25.599-25.6v-6.4c17.553 0 32 14.447 32 32h-6.401zM4.388 23.22c2.419 0 4.391 1.972 4.391 4.393 0 2.417-1.98 4.387-4.401 4.387-2.417 0-4.377-1.965-4.377-4.387s1.967-4.392 4.388-4.393zM21.212 32h-6.22c0-8.225-6.767-14.993-14.992-14.993v-6.22c11.636 0 21.212 9.579 21.212 21.213z"></path></svg> Feed</a></li>
						<li><a href="https://www.youtube.com/channel/UCU6ljj3m1fglIPjSjs2DpRA/playlistsv"><svg focusable="false" aria-hidden="true" class="icon-youtube "  viewBox="0 0 32 32"><path d="M31.327 8.273c-0.386-1.353-1.431-2.398-2.756-2.777l-0.028-0.007c-2.493-0.668-12.528-0.668-12.528-0.668s-10.009-0.013-12.528 0.668c-1.353 0.386-2.398 1.431-2.777 2.756l-0.007 0.028c-0.443 2.281-0.696 4.903-0.696 7.585 0 0.054 0 0.109 0 0.163l-0-0.008c-0 0.037-0 0.082-0 0.126 0 2.682 0.253 5.304 0.737 7.845l-0.041-0.26c0.386 1.353 1.431 2.398 2.756 2.777l0.028 0.007c2.491 0.669 12.528 0.669 12.528 0.669s10.008 0 12.528-0.669c1.353-0.386 2.398-1.431 2.777-2.756l0.007-0.028c0.425-2.233 0.668-4.803 0.668-7.429 0-0.099-0-0.198-0.001-0.297l0 0.015c0.001-0.092 0.001-0.201 0.001-0.31 0-2.626-0.243-5.196-0.708-7.687l0.040 0.258zM12.812 20.801v-9.591l8.352 4.803z"></path></svg> YouTube</a></li>
						<li><a href="https://www.w3.org/WAI/news/subscribe/" class="button">Get News in Email</a></li>
					</ul>
				</div>
				<div dir="auto" translate="no" lang="en">
					<p>Copyright © <xsl:value-of select="format-date(current-date(), '[Y]')"/> World Wide Web Consortium (<a href="https://www.w3.org/">W3C</a><sup>®</sup>). See <a href="/WAI/about/using-wai-material/">Permission to Use WAI Material</a>.</p>
				</div>
			</div>
			<div dir="auto" translate="no" class="q4-start q4-end" lang="en">
				<ul style="margin-bottom:0">
					<li><a href="/WAI/about/contacting/">Contact WAI</a></li>
					<li><a href="/WAI/sitemap/">Site Map</a></li>
					<li><a href="/WAI/news/">News</a></li>
					<li><a href="/WAI/about/accessibility-statement/">Accessibility Statement</a></li>
					<li><a href="/WAI/translations/"> Translations</a></li>
					<li><a href="/WAI/roles/">Resources for Roles</a></li>
				</ul>
			</div>
		</footer>
	</xsl:template>
	
	<xsl:template name="waiscript">
		<link rel="stylesheet" href="../a11y-light.css" />
		<script src="../highlight.min.js" />
		<script>
      hljs.configure({
        cssSelector: 'pre'
      });
      hljs.highlightAll();
			var translationStrings = {}; /* fix WAI JS */
		</script>
		<script src="https://www.w3.org/WAI/assets/scripts/main.js"></script>
    <!-- Matomo -->
    <script>
      var _paq = _paq || [];
      /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
      _paq.push(["setDoNotTrack", true]);
      _paq.push(['trackPageView']);
      _paq.push(['enableLinkTracking']);
      (function() {
        var u="//www.w3.org/analytics/piwik/";
        _paq.push(['setTrackerUrl', u+'piwik.php']);
        _paq.push(['setSiteId', '328']);
        var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
        g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
      })();
    </script>
    <noscript><p><img src="//www.w3.org/analytics/piwik/piwik.php?idsite=328&amp;rec=1" style="border:0;" alt="" /></p></noscript>
    <!-- End Matomo Code -->
	</xsl:template>
</xsl:stylesheet>
