import { Liquid, type Template } from "liquidjs";
import type { RenderOptions } from "liquidjs/dist/liquid-options";

import { flattenDom, load } from "./cheerio";
import type { TocLink } from "./types";

/** Generates {% include "foo.html" %} directives from 1 or more basenames */
const generateIncludes = (...basenames: string[]) =>
	`\n${basenames.map(basename => `{% include "${basename}.html" %}`).join("\n")}\n`;

const titleSuffix = " | WAI | W3C";

const techniqueTocSections = [
	"applicability",
	"description",
	"examples",
	"resources",
	"related",
	"tests",
];

const understandingTocSections = [
	// For SCs:
	"brief",
	"intent", // Common with guidelines
	"benefits",
	"examples",
	"resources",
	"techniques",
	// For guidelines:
	"success-criteria",
];

const techniquesPattern = /\btechniques\//;
const understandingPattern = /\bunderstanding\//;

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
	label.replace(/^When to Use$/, "Applicability")
		.replace(/In brief/, "In Brief")
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
			/** Matches paths that originally went through process-index.xslt */
			const isIndex = /(techniques|understanding)\/(index|about)\.html$/.test(filepath);
			const isTechniques = techniquesPattern.test(filepath);
			const isUnderstanding = understandingPattern.test(filepath);

			const $ = flattenDom(html, filepath);

			// Clean out elements to be removed (e.g. editors.css & sources.css)
			$(".remove").remove();

			// Ensure suffix is at end of all titles
			// (this was done in XSLT for non-index/about pages in the previous build process)
			const $title = $("title");
			if (!$title.text().endsWith(titleSuffix)) $title.append(titleSuffix);

			const prependedIncludes = ["header"];
			const appendedIncludes = ["wai-site-footer", "site-footer"];

			if (isUnderstanding)
				prependedIncludes.push(
					isIndex ? "understanding/navigation-index" : "understanding/navigation");

			if (!isIndex) {
				$("head").append(generateIncludes("head"));

				// Rearrange h2-level sections (any that don't exist will no-op)
				if (isTechniques)
					techniqueTocSections.forEach((id) => $("body").append("\n", $(`body > section#${id}`)));
				else if (isUnderstanding)
					understandingTocSections.forEach((id) => $("body").append("\n", $(`body > section#${id}`)));

				// Fix incorrect heading levels in both directions
				$("body > section section h2").each((_, el) => {
					el.tagName = "h3";
				})
				$("body > section > h3").each((_, el) => {
					el.tagName = "h2";
				})
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
					.wrapInner(`<div class="default-grid with-gap leftcol"></div>`)

				// TODO: reformat h1, add aside as appropriate for techniques and understanding
				$("h1 + section").after(`<div class="excol-all"></div>`)

				appendedIncludes.push("waiscript");
			}

			$("body")
				.prepend(generateIncludes(...prependedIncludes))
				.append(generateIncludes(...appendedIncludes))

			return super.parse($.html(), filepath);
		}
		return super.parse(html);
	}

	public async render(templates: Template[], scope?: any, options?: RenderOptions) {
		const html = (await super.render(templates, scope, options)).toString();
		if (!isHtmlFileContent(html)) return html;

		const $ = load(html);
		const $tocList = $(".sidebar nav ul");

		// Generate table of contents after parsing and rendering,
		// when we have sections already reordered and sidebar skeleton rendered
		const childSelector = "> h2:first-child";
		$(`section[id]:has(${childSelector})`).each((_, el) => {
			$("<a></a>")
				.attr("href", `#${el.attribs.id}`)
				.text(normalizeTocLabel($(el).find(childSelector).text()))
				.appendTo($tocList)
				.wrap("<li></li>");
			$tocList.append("\n");
		});

		// Return new html with comments removed
		return $.html().replace(/<!--[\s\S]*?-->/g, "");
	}
}
