import type { Cheerio, Element } from "cheerio";
import { glob } from "glob";

import { readFile } from "fs/promises";
import { basename } from "path";

import { flattenDomFromFile, load } from "./cheerio";
import { generateId } from "./common";
import type { ActMapping } from "./types";

export type WcagVersion = "20" | "21" | "22";
function assertIsWcagVersion(v: string): asserts v is WcagVersion {
	if (!/^2[012]$/.test(v)) throw new Error(`Unexpected version found: ${v}`);
}

/** Data used for test-rules sections, from act-mapping.json */
export const actRules =
	(JSON.parse(await readFile("guidelines/act-mapping.json", "utf8")) as ActMapping)["act-rules"];

/**
 * Returns an object with keys for each existing WCAG 2 version,
 * each mapping to an array of basenames of HTML files under understanding/<version>
 * (Functionally equivalent to "guidelines-versions" target in build.xml)
 */
export async function getGuidelinesVersions() {
	const paths = await glob("*/*.html", { cwd: "understanding" });
	const versions: Record<WcagVersion, string[]> = { "20": [], "21": [], "22": [] };

	for (const path of paths) {
		const [version, filename] = path.split("/");
		assertIsWcagVersion(version);
		versions[version].push(basename(filename, ".html"));
	}

	for (const version of Object.keys(versions)) {
		assertIsWcagVersion(version);
		versions[version].sort();
	}
	return versions;
}

/**
 * Like getGuidelinesVersions, but mapping each basename to the version it appears in
 */
export async function getInvertedGuidelinesVersions() {
	const versions = await getGuidelinesVersions();
	const invertedVersions: Record<string, string> = {};
	for (const [version, basenames] of Object.entries(versions)) {
		for (const basename of basenames) {
			invertedVersions[basename] = version;
		}
	}
	return invertedVersions;
}

export interface DocNode {
	id: string;
	name: string;
	/** Helps distinguish entity type when passed out-of-context; used for navigation */
	type?: "Principle" | "Guideline" | "SC";
}

export interface Principle extends DocNode {
	content: string;
	num: `${number}`; // typed as string for consistency with guidelines/SC
	version: "WCAG20";
	guidelines: Guideline[];
}

export interface Guideline extends DocNode {
	content: string;
	num: `${Principle["num"]}.${number}`;
	version: `WCAG${"20" | "21"}`;
	successCriteria: SuccessCriterion[];
}

export interface SuccessCriterion extends DocNode {
	content: string;
	num: `${Guideline["num"]}.${number}`;
	/** Level may be empty for obsolete criteria */
	level: "A" | "AA" | "AAA" | "";
	version: `WCAG${WcagVersion}`;
}

export function isSuccessCriterion(criterion: any): criterion is SuccessCriterion {
	return !!(criterion?.type === "SC" && "level" in criterion);
}

/**
 * Returns HTML content used for Understanding guideline/SC boxes.
 * @param $el Cheerio element of the full section from flattened guidelines/index.html
 */
const getContentHtml = ($el: Cheerio<Element>) => {
	// Load HTML into a new instance, remove elements we don't want, then return the remainder
	const $ = load($el.html()!, null, false);
	$("h1, h2, h3, h4, h5, h6, section, .change, .conformance-level").remove();
	return $.html();
}

/**
 * Resolves information from guidelines/index.html;
 * comparable to the principles section of wcag.xml from the guidelines-xml Ant task.
 */
export async function getPrinciples() {
	const versions = await getInvertedGuidelinesVersions();
	const $ = await flattenDomFromFile("guidelines/index.html");

	const principles: Principle[] = [];
	$(".principle").each((i, el) => {
		const guidelines: Guideline[] = [];
		$(".guideline", el).each((j, guidelineEl) => {
			const successCriteria: SuccessCriterion[] = [];
			$(".sc", guidelineEl).each((k, scEl) => {
				const resolvedVersion = versions[scEl.attribs.id];
				assertIsWcagVersion(resolvedVersion);

				successCriteria.push({
					content: getContentHtml($(scEl)),
					id: scEl.attribs.id,
					name: $("h4", scEl).text().trim(),
					num: `${i + 1}.${j + 1}.${k + 1}`,
					level: $("p.conformance-level", scEl).text().trim() as SuccessCriterion["level"],
					type: "SC",
					version: `WCAG${resolvedVersion}`,
				});
			});

			guidelines.push({
				content: getContentHtml($(guidelineEl)),
				id: guidelineEl.attribs.id,
				name: $("h3", guidelineEl).text().trim(),
				num: `${i + 1}.${j + 1}`,
				type: "Guideline",
				version: guidelineEl.attribs.id === "input-modalities" ? "WCAG21" : "WCAG20",
				successCriteria,
			});
		});

		principles.push({
			content: getContentHtml($(el)),
			id: el.attribs.id,
			name: $("h2", el).text().trim(),
			num: `${i + 1}`,
			type: "Principle",
			version: "WCAG20",
			guidelines,
		})
	});

	return principles;
}

/**
 * Returns an object mapping shortcodes to each principle/guideline/SC.
 */
export function getFlatGuidelines(principles: Principle[]) {
	const map: Record<string, Principle | Guideline | SuccessCriterion> = {};
	for (const principle of principles) {
		map[principle.id] = principle;
		for (const guideline of principle.guidelines) {
			map[guideline.id] = guideline;
			for (const criterion of guideline.successCriteria) {
				map[criterion.id] = criterion;
			}
		}
	}
	return map;
}
export type FlatGuidelinesMap = ReturnType<typeof getFlatGuidelines>;

interface Term {
	definition: string;
	id: string;
	name: string;
}

/**
 * Resolves term definitions from guidelines/index.html organized for lookup by name;
 * comparable to the term elements in wcag.xml from the guidelines-xml Ant task.
 */
export async function getTermsMap() {
	const $ = await flattenDomFromFile("guidelines/index.html");
	const terms: Record<string, Term> = {};

	$("dfn").each((_, el) => {
		const $el = $(el);
		const term: Term = {
			// Note: All applicable <dfn>s seem to have explicit id attributes,
			// but the XSLT process generates id from the element's text which is not always the same
			id: `dfn-${generateId($el.text())}`,
			definition: $el.parent().next().html()!,
			name: $el.text().toLowerCase(),
		}

		const names = [term.name]
			.concat((el.attribs["data-lt"] || "").toLowerCase().split("|"));
		for (const name of names) terms[name] = term;
	});

	return terms;
}
