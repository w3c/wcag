import { Liquid } from "liquidjs";
import { flattenDom } from "./cheerio";

// Dev note: Eleventy doesn't expose typings for its template engines for us to neatly extend.
// Fortunately, it passes both the content string and the file path through to Liquid#parse:
// https://github.com/11ty/eleventy/blob/9c3a7619/src/Engines/Liquid.js#L253

/** Matches paths that originally went through process-index.xslt */
const indexPattern = /(techniques|understanding)\/(index|about)\.html$/;

const techniquesPattern = /\btechniques\//;
const understandingPattern = /\bunderstanding\//;

/** Generates {% include "foo.html" %} directives from a list of basenames */
const generateIncludes = (basenames: string[]) =>
	`\n${basenames.map(basename => `{% include "${basename}.html" %}`).join("\n")}\n`;

const titleSuffix = " | WAI | W3C";

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
			const isIndex = indexPattern.test(filepath);
			const isTechniques = techniquesPattern.test(filepath);
			const isUnderstanding = understandingPattern.test(filepath);

			const $ = flattenDom(html, filepath);

			// Ensure suffix is at end of all titles
			// (this was done in XSLT for non-index/about pages in the previous build process)
			const $title = $("title");
			if (!$title.text().endsWith(titleSuffix)) $title.append(titleSuffix);

			if (!isIndex) {
				if (isTechniques) $("head").append(generateIncludes(["techniques/head"]));
				if (isUnderstanding) $("head").append(generateIncludes(["understanding/head"]));
			}

			const prependedIncludes = ["header"];
			if (isUnderstanding)
				prependedIncludes.push(
					isIndex ? "understanding/navigation-index" : "understanding/navigation");

			const appendedIncludes = ["wai-site-footer", "site-footer"];
			if (!isIndex) appendedIncludes.push("waiscript");

			$("body")
				.prepend(generateIncludes(prependedIncludes))
				.append(generateIncludes(appendedIncludes))

			return super.parse($.html(), filepath);
		}
		return super.parse(html);
	}
}
