import { glob } from "glob";
import { basename } from "path";

import { flattenDomFromFile } from "./cheerio";
import { resolveDecimalVersion } from "./common";

type WcagVersion = "20" | "21" | "22";
function assertIsWcagVersion(v: string): asserts v is WcagVersion {
	if (!/^2[012]$/.test(v)) throw new Error(`Unexpected version found: ${v}`);
}

/**
 * Returns an object with keys for each existing WCAG 2 version,
 * each mapping to an array of basenames of HTML files under understanding/<version>
 * (Functionally equivalent to "guidelines-versions" target in build.xml)
 **/
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

interface DocNode {
	id: string;
	name: string;
	/** Helps distinguish entity type when passed out-of-context; used for navigation */
	type?: "Principle" | "Guideline" | "SC";
}

export interface Principle extends DocNode {
	num: `${number}`; // typed as string for consistency with guidelines/SC
	version: "WCAG20";
	guidelines: Guideline[];
}

export interface Guideline extends DocNode {
	num: `${Principle["num"]}.${number}`;
	version: `WCAG${"20" | "21"}`;
	successCriteria: SuccessCriterion[];
}

export interface SuccessCriterion extends DocNode {
	num: `${Guideline["num"]}.${number}`;
	level: "A" | "AA" | "AAA";
	version: `WCAG${WcagVersion}`;
}

/**
 * Resolves information from guidelines/index.html;
 * comparable to the principles section of wcag.xml from the guidelines-xml Ant task.
 * NOTE: Currently does not cover content and contenttext
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
					id: scEl.attribs.id,
					name: $("h4", scEl).text().trim(),
					num: `${i + 1}.${j + 1}.${k + 1}`,
					level: $("p.conformance-level", scEl).text().trim() as SuccessCriterion["level"],
					type: "SC",
					version: `WCAG${resolvedVersion}`,
				});
			});

			guidelines.push({
				id: guidelineEl.attribs.id,
				name: $("h3", guidelineEl).text().trim(),
				num: `${i + 1}.${j + 1}`,
				type: "Guideline",
				version: guidelineEl.attribs.id === "input-modalities" ? "WCAG21" : "WCAG20",
				successCriteria,
			});
		});

		principles.push({
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
 * Resolves information from guidelines/index.html for top-level understanding pages;
 * ported from generate-structure-xml.xslt
 */
export async function getUnderstandingDocs(version: WcagVersion): Promise<DocNode[]> {
	const decimalVersion = resolveDecimalVersion(version);
	return [
		{
			id: "intro",
			name: `Introduction to Understanding WCAG ${decimalVersion}`,
		},
		{
			id: "understanding-techniques",
			name: "Understanding Techniques for WCAG Success Criteria",
		},
		{
			id: "understanding-act-rules",
			name: "Understanding Test Rules for WCAG Success Criteria",
		},
		{
			id: "conformance",
			name: "Understanding Conformance",
		},
		{
			id: "refer-to-wcag",
			name: `How to Refer to WCAG ${decimalVersion} from Other Documents`,
		},
		{
			id: "documenting-accessibility-support",
			name: "Documenting Accessibility Support for Uses of a Web Technology",
		},
		{
			id: "understanding-metadata",
			name: "Understanding Metadata",
		},
	]
}

interface NavData {
	parent?: DocNode;
	previous?: DocNode;
	next?: DocNode;
}

/**
 * Generates mappings from guideline/SC/understanding doc IDs to next/previous/parent information,
 * for efficient lookup when rendering navigation banner
 */
export async function generateUnderstandingNavMap(version: WcagVersion) {
	const principles = await getPrinciples();
	const allGuidelines =
		Object.values(principles).flatMap(({ guidelines }) => guidelines);
	const understandingDocs = await getUnderstandingDocs(version);
	const map: Record<string, NavData> = {};

	// Guideline navigation wraps across principles, so iterate over flattened list
	allGuidelines.forEach((guideline, i) => {
		map[guideline.id] = {
			...(i > 0 && { previous: allGuidelines[i - 1] }),
			...(i < allGuidelines.length - 1 && { next: allGuidelines[i + 1] })
		};
		guideline.successCriteria.forEach((criterion, j) => {
			map[criterion.id] = {
				parent: guideline,
				...(j > 0 && { previous: guideline.successCriteria[j - 1] }),
				...(j < guideline.successCriteria.length - 1 &&
					{ next: guideline.successCriteria[j + 1] })
			}
		});
	});

	understandingDocs.forEach((doc, i) => {
		map[doc.id] = {
			...(i > 0 && { previous: understandingDocs[i - 1] }),
			...(i < understandingDocs.length - 1 && { next: understandingDocs[i + 1] }),
		}
	});

	return map;
}
