import { Liquid } from "liquidjs";
import { flattenDom } from "./cheerio";

// Dev note: Eleventy doesn't expose typings for its template engines for us to neatly extend.
// Fortunately, it passes both the content string and the file path through to Liquid#parse:
// https://github.com/11ty/eleventy/blob/9c3a7619/src/Engines/Liquid.js#L253

/**
 * Liquid class extension that adds support for parts of the existing build process:
 * - flattening data-include directives
 * - inserting header/footer content within the body of index and about pages
 *   prior to parsing Liquid tags (permitting Liquid even inside data-included files).
 */
export class CustomLiquid extends Liquid {
	public parse(html: string, filepath?: string) {
		// Filter out Liquid calls for computed data
		if (filepath && !html.startsWith("(((11ty") && !html.endsWith(".html")) {
			const $ = flattenDom(html, filepath);

			if (/\/(index|about)\.html$/.test(filepath)) {
				$("body").prepend(`
					{% include "header.html" %}
					{% include "navigation.html" %}
				`).append(`
					{% include "wai-site-footer.html" %}
					{% include "site-footer.html" %}
				`);
			}

			// Extract body innerHTML from Cheerio,
			// since it doesn't seem to fully preserve doctype and head
			const replacedHtml =
				html.replace(/(<body[^>]*>)[\s\S]+(<\/body>)/, `$1${$("body").html()}$2`);
			return super.parse(replacedHtml, filepath);
		}
		return super.parse(html);
	}
}
