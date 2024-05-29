import { load as cheerioLoad, type CheerioAPI, type CheerioOptions } from "cheerio";
import { readFileSync } from "fs";
import { readFile } from "fs/promises";
import { dirname, resolve } from "path";

interface ExtendedCheerioAPI {
}

const extendedApi: ExtendedCheerioAPI = {
};

/** Extension of Cheerio's load function that adds extra query plugins. */
export const load: CheerioAPI["load"] = (content, options, isDocument) => {
	const $ = cheerioLoad(content, options, isDocument);
	Object.assign($.fn, extendedApi);
	return $ as CheerioAPI & ExtendedCheerioAPI;
}

/** Convenience function that combines readFile and load. */
export async function loadFromFile(
	inputPath: string,
	options?: CheerioOptions | null,
	isDocument?: boolean
) {
	return load(await readFile(inputPath, "utf8"), options, isDocument);
}

/**
 * Retrieves content for a data-include, either from _includes,
 * or relative to the input file.
 * 
 * @param includePath A data-include attribute value
 * @param inputPath Path (relative to repo root) to file containing the directive
 * @returns 
 */
function readInclude(includePath: string, inputPath: string) {
	try {
		return readFileSync(resolve(dirname(inputPath), includePath), "utf8")
	} catch (error) {
		if (!includePath.startsWith(".."))
			return readFileSync(resolve("_includes", includePath), "utf8");
		throw error;
	}
}

/**
 * Resolves data-include directives in the given file, a la flatten-document.xslt.
 * This is a lower-level version for use in Eleventy configuration;
 * you'd probably rather use flattenDomFromFile in other cases.
 *
 * @param content String containing HTML to process
 * @param inputPath Path (relative to repo root) to file containing the HTML
 *                  (needed for data-include resolution)
 * @returns Cheerio instance containing "flattened" DOM
 */
export function flattenDom(content: string, inputPath: string) {
	const $ = load(content, null, false);

	$("[data-include]").each((i, el) => {
		const replacement = readInclude(el.attribs["data-include"], inputPath);
		// Replace entire element or children, depending on data-include-replace
		if (el.attribs["data-include-replace"]) $(el).replaceWith(replacement);
		else $(el).removeAttr("data-include").html(replacement);
	});

	return $;
}

/**
 * Convenience version of flattenDom that requires only inputPath to be passed.
 * @see flattenDom
 */
export const flattenDomFromFile = async (inputPath: string) => 
	flattenDom(await readFile(inputPath, "utf8"), inputPath);
