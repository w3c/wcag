import { load as cheerioLoad, type CheerioAPI } from "cheerio";
import { readFileSync } from "fs";
import { readFile } from "fs/promises";
import { dirname, resolve } from "path";

interface ExtendedCheerioAPI {
}

const extendedApi: ExtendedCheerioAPI = {
};

/** Extension of Cheerio's load function that adds extra query plugins. */
export function load(html: string) {
	const $ = cheerioLoad(html);
	Object.assign($.fn, extendedApi);
	return $ as CheerioAPI & ExtendedCheerioAPI;
}

/** Convenience function that combines readFile and load. */
export async function loadFromFile(inputPath: string) {
	return load(await readFile(inputPath, "utf8"));
}

/**
 * Resolves data-include directives in the given file, a la flatten-document.xslt
 * @param inputPath Path (relative to repo root) to file to flatten
 * @param outputPath Path to write output to
 * @returns Cheerio instance containing "flattened" DOM
 */
export async function flattenDomFromFile(inputPath: string) {
	const $ = await loadFromFile(inputPath);

	$("[data-include]").each((i, el) => {
		const replacement = readFileSync(resolve(dirname(inputPath), el.attribs["data-include"]), "utf8");
		// Replace entire element or children, depending on data-include-replace
		if (el.attribs["data-include-replace"]) $(el).replaceWith(replacement);
		else $(el).html(replacement);
	});

	return $;
}