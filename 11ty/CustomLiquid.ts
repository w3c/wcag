import { Liquid, type Template } from "liquidjs";
import type { RenderOptions } from "liquidjs/dist/liquid-options";

import { flattenDom, load } from "./cheerio";
import { getTermsMap } from "./guidelines";
import { techniqueLinkHrefToId } from "./techniques";
import type { EleventyData } from "./types";

const titleSuffix = " | WAI | W3C";

const indexPattern = /(techniques|understanding)\/(index|about)\.html$/;
const techniquesPattern = /\btechniques\//;
const understandingPattern = /\bunderstanding\//;

const termsMap = await getTermsMap();

/** Generates {% include "foo.html" %} directives from 1 or more basenames */
const generateIncludes = (...basenames: string[]) =>
	`\n${basenames.map(basename => `{% include "${basename}.html" %}`).join("\n")}\n`;

/**
 * Determines whether a given string is actually HTML,
 * not e.g. a data value Eleventy sent to the templating engine.
 */
const isHtmlFileContent = (html: string) =>
	!html.startsWith("(((11ty") && !html.endsWith(".html");

/**
 * Performs common cleanup of in-page table of contents links for final output.
 */
const normalizeTocLabel = (label: string) =>
	label.replace(/In brief/, "In Brief")
		.replace(/^(\S+) (of|for) .*$/, "$1")
		.replace(/^Resources$/, "Related Resources");

// Dev note: Eleventy doesn't expose typings for its template engines for us to neatly extend.
// Fortunately, it passes both the content string and the file path through to Liquid#parse:
// https://github.com/11ty/eleventy/blob/9c3a7619/src/Engines/Liquid.js#L253

/**
 * Liquid class extension that adds support for parts of the existing build process:
 * - flattening data-include directives
 * - inserting header/footer content within the body of pages
 *   prior to parsing Liquid tags (permitting Liquid even inside data-included files)
 */
export class CustomLiquid extends Liquid {
	public parse(html: string, filepath?: string) {
		// Filter out Liquid calls for computed data and includes themselves
		if (filepath && !filepath.includes("_includes/") && isHtmlFileContent(html)) {
			/** Matches paths that would go through process-index.xslt in previous process */
			const isIndex = indexPattern.test(filepath);
			const isTechniques = techniquesPattern.test(filepath);
			const isUnderstanding = understandingPattern.test(filepath);

			const $ = flattenDom(html, filepath);

			// Clean out elements to be removed
			// (e.g. editors.css & sources.css, and leftover template paragraphs)
			// NOTE: some paragraphs with the "instructions" class actually have custom content,
			// but for now this remains consistent with the XSLT process by stripping all of them.
			$(".remove, p.instructions, section#meta, section.meta").remove();

			// Ensure suffix is at end of all titles
			// (this was done in XSLT for non-index/about pages in the previous build process)
			const $title = $("title");
			if (!$title.text().endsWith(titleSuffix)) $title.append(titleSuffix);

			const prependedIncludes = ["header"];
			const appendedIncludes = ["wai-site-footer", "site-footer"];

			if (isUnderstanding)
				prependedIncludes.push(
					isIndex ? "understanding/navigation-index" : "understanding/navigation");

			if (isIndex) {
				if (isTechniques) {
					$("section#changelog li a").each((_, el) => {
						const id = techniqueLinkHrefToId(el.attribs.href);
						$(el).replaceWith(`{{ "${id}" | linkTechniques }}`);
					});
				}
			} else {
				$("head").append(generateIncludes("head"));
				appendedIncludes.push("waiscript");

				// Fix incorrect level-2 headings and first-child level 3 headings
				$("body > section section h2").each((_, el) => {
					el.tagName = "h3";
				});
				$("body > section > h3:first-child").each((_, el) => {
					el.tagName = "h2";
				});

				if (isTechniques) {
					// XSLT orders related and tests sections last, but they are not last in source files
					$("body")
						.append("\n", $(`body > section#related`))
						.append("\n", $(`body > section#tests`));
					$("h1")
						.after(generateIncludes("techniques/about"))
						.replaceWith(generateIncludes("techniques/h1"));
					$("body > section[id]").each((_, el) => {
						// Fix non-lowercase top-level section IDs (e.g. H99)
						el.attribs.id = el.attribs.id.toLowerCase();
					});
					$("section#resources h2")
						.after(generateIncludes("techniques/intro/resources"));
					$("section#examples section.example h3").each((i, el) => {
						const $el = $(el);
						const exampleText = `Example ${i + 1}`;
						// Prepend "Example N: " only if it won't be redundant (e.g. F83)
						if (!$el.text().toLowerCase().endsWith(exampleText.toLowerCase()))
							$(el).prepend(`${exampleText}: `);
					});
					$("section#related li a[href^='../']").each((_, el) => {
						// Expand relative technique links to include full title
						// (the XSLT process didn't handle this in this particular context)
						const id = techniqueLinkHrefToId(el.attribs.href);
						$(el).replaceWith(`{{ "${id}" | linkTechniques }}`);
					});
				} else if (isUnderstanding) {
					// Expand top-level heading for guideline/SC pages
					if ($("section#intent").length)
						$("h1").replaceWith(generateIncludes("understanding/h1"));
					$("section#intent").before(generateIncludes("understanding/about"));
					$("section#techniques h2")
						.after(generateIncludes("understanding/intro/techniques"));
					if ($("section#sufficient .situation").length) {
						$("section#sufficient h3").
							after(generateIncludes("understanding/intro/sufficient-situation"));
					}
					$("section#advisory h3")
						.after(generateIncludes("understanding/intro/advisory"));
					$("section#failure h3")
						.after(generateIncludes("understanding/intro/failure"));
					$("section#resources h2")
						.after(generateIncludes("understanding/intro/resources"));
				}

				// Remove h2-level sections with no content other than heading
				$("body > section:not(:has(:not(h2)))").remove();

				// Fix inconsistent heading labels
				// (this is also done for table of contents links in #render)
				$("h2").each((_, el) => {
					const $el = $(el);
					$el.text(normalizeTocLabel($el.text()));
				})

				$("body")
					.attr("dir", "ltr") // Already included in index/about pages
					.append(generateIncludes("test-rules", "back-to-top"))
					.wrapInner(`<main id="main" class="standalone-resource__main"></main>`)
					.prepend(generateIncludes("sidebar"))
					.append(generateIncludes("help-improve"))
					// index/about pages already include this wrapping; others do not, and need it.
					// This wraps around table of contents & help improve, but not other includes
					.wrapInner(`<div class="default-grid with-gap leftcol"></div>`);
			}

			$("body")
				.prepend(generateIncludes(...prependedIncludes))
				.append(generateIncludes(...appendedIncludes))

			return super.parse($.html(), filepath);
		}
		return super.parse(html);
	}

	public async render(templates: Template[], scope: EleventyData, options?: RenderOptions) {
		// html contains markup after Liquid tags/includes have been processed
		const html = (await super.render(templates, scope, options)).toString();
		if (!isHtmlFileContent(html) || !scope) return html;
		const $ = load(html);

		if (scope.isTechniques) {
			// Strip applicability paragraphs with metadata IDs (e.g. H99)
			$("section#applicability").find("p#id, p#technology, p#type").remove();
			// Check for custom applicability paragraph before removing the section
			const customApplicability = $("section#applicability p").html()?.trim();
			if (customApplicability) {
				$("section#technique p:last-child").html(
					`This technique ${/^applies to/i.test(customApplicability) ? "" : "applies to "}` +
					// Uncapitalize original sentence, except for all-caps abbreviations
					(/^[A-Z]{2,}/.test(customApplicability)
						? customApplicability
						: customApplicability[0].toLowerCase() + customApplicability.slice(1)) +
					(customApplicability.endsWith(".") ? "" : "."));
			}
			$("section#applicability").remove();

			// Process definitions within render where we have access to global data
			$("a:not([href])").each((_, el) => {
				const $el = $(el);
				const termName = $el.text().trim().toLowerCase();
				const term = termsMap[termName];
				if (!term) throw new Error(`Term not found: ${termName}`);
				$el.attr("href", `${scope.guidelinesUrl}#${term.id}`)
					.attr("target", "terms");
			});
		} else if (scope.isUnderstanding) {
			// TODO: Key Terms
		}

		if (!indexPattern.test(scope.page.inputPath)) {
			if (scope.isTechniques) {
				// Remove any related list items that failed id lookups in #parse (e.g. removed/deprecated)
				$("section#related li:empty").remove();
			}

			// Prepend guidelines base URL to anchor links in guidelines content
			$("#guideline, #success-criterion").find("a[href^='#']").each((_, el) => {
				el.attribs.href = scope.guidelinesUrl + el.attribs.href;
			});

			// Expand note paragraphs after parsing and rendering,
			// after Guideline/SC content for Understanding pages is rendered
			$("div.note").each((_, el) => {
				const $el = $(el);
				$el.replaceWith(`<div class="note">
					<p class="note-title marker">Note</p>
					<div>${$el.html()}</div>
				</div>`);
			});
			// Handle p variant after div (the reverse would double-process)
			$("p.note").each((_, el) => {
				const $el = $(el);
				$el.replaceWith(`<div class="note">
					<p class="note-title marker">Note</p>
					<p>${$el.html()}</p>
				</div>`);
			});

			// Generate table of contents after parsing and rendering,
			// when we have sections already reordered and sidebar skeleton rendered
			const $tocList = $(".sidebar nav ul");
			const childSelector = "> h2:first-child";
			$(`section[id]:has(${childSelector})`).each((_, el) => {
				$("<a></a>")
					.attr("href", `#${el.attribs.id}`)
					.text(normalizeTocLabel($(el).find(childSelector).text()))
					.appendTo($tocList)
					.wrap("<li></li>");
				$tocList.append("\n");
			});
		}

		// Return new html with comments removed
		return $.html().replace(/<!--[\s\S]*?-->/g, "");
	}
}
