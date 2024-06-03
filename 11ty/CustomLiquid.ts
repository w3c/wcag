import { Liquid } from "liquidjs";
import { flattenDom } from "./cheerio";

/** Generates {% include "foo.html" %} directives from 1 or more basenames */
const generateIncludes = (...basenames: string[]) =>
	`\n${basenames.map(basename => `{% include "${basename}.html" %}`).join("\n")}\n`;

const titleSuffix = " | WAI | W3C";

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
		if (filepath && !filepath.includes("_includes/") &&
			!html.startsWith("(((11ty") && !html.endsWith(".html")
		) {
			/** Matches paths that originally went through process-index.xslt */
			const isIndex = /(techniques|understanding)\/(index|about)\.html$/.test(filepath);
			const isTechniques = /\btechniques\//.test(filepath);
			const isUnderstanding = /\bunderstanding\//.test(filepath);

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
				$("body")
					.attr("dir", "ltr") // Already included in index/about pages
					.append(generateIncludes("back-to-top"))
					.wrapInner(`<main id="main" class="standalone-resource__main"></main>`)
					.prepend(generateIncludes("sidebar"))
					.append(generateIncludes("help-improve"))
					// index/about pages already include this wrapping; others do not, and need it.
					// This wraps around table of contents & help improve, but not other includes
					.wrapInner(`<div class="default-grid with-gap leftcol"></div>`)

				// TODO: h1/h2 reformatting and section reordering

				appendedIncludes.push("waiscript");
			}

			$("body")
				.prepend(generateIncludes(...prependedIncludes))
				.append(generateIncludes(...appendedIncludes))

			return super.parse($.html(), filepath);
		}
		return super.parse(html);
	}
}
