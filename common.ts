/** @fileoverview Common functions used by multiple Eleventy configurations */

import { load } from "cheerio";
import { readFileSync } from "fs";
import { readFile, writeFile } from "fs/promises";
import { glob } from "glob";
import { basename, dirname, resolve } from "path";

/**
 * Returns an object with keys for each existing WCAG 2 version,
 * each mapping to an array of basenames of HTML files under understanding/<version>
 * (Functionally equivalent to "guidelines-versions" target in build.xml)
 **/
export async function getGuidelinesVersions() {
	const files = await glob("understanding/*/*.html");
	const versions = {};
	
	for (const path of files) {
		const [, version, filename] = path.split("/");
		if (!versions[version]) versions[version] = [];
		versions[version].push(basename(filename, ".html"));
	}
	
	for (const version of Object.keys(versions)) {
		versions[version].sort();
	}
	return versions;
}

/**
 * Resolves data-include directives in the given file.
 * @param inputPath Path (relative to repo root) to file to flatten
 * @param outputPath Path to write output to
 * @returns HTML with data-include directives processed
 */
export async function flattenHtml(inputPath: string, outputPath: string) {
	const $ = load(await readFile(inputPath, "utf8"));

	$("[data-include]").each((i, el) => {
		const replacement = readFileSync(resolve(dirname(inputPath), el.attribs["data-include"]), "utf8");
		// Replace entire element or children, depending on data-include-replace
		if (el.attribs["data-include-replace"]) $(el).replaceWith(replacement);
		else $(el).html(replacement);
	});

	return writeFile(outputPath, $.html());
}
