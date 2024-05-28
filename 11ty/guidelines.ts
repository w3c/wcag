import { glob } from "glob";
import { basename } from "path";

import { flattenDomFromFile } from "./cheerio";

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
	const versions: Record<WcagVersion, string[]> = {"20": [], "21": [], "22": []};
	
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

interface GuidelinesNode {
	id: string;
	name: string;
}

interface Principle extends GuidelinesNode {
	num: `${number}`; // typed as string for consistency with guidelines/SC
	version: "WCAG20";
	guidelines: Guideline[];
}

interface Guideline extends GuidelinesNode {
	num: `${Principle["num"]}.${number}`;
	version: `WCAG${"20" | "21"}`;
	successCriteria: SuccessCriterion[];
}

interface SuccessCriterion extends GuidelinesNode {
	id: string;
	name: string;
	num: `${Guideline["num"]}.${number}`;
	level: "A" | "AA" | "AAA";
	version: `WCAG${WcagVersion}`;
}

/**
 * Resolves information from guidelines/index.html;
 * comparable to the principles section of wcag.xml from the guidelines-xml Ant task.
 * NOTE: Currently does not cover content and contenttext
 */
export async function resolvePrinciples() {
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
					version: `WCAG${resolvedVersion}`,
				});
			});

			guidelines.push({
				id: guidelineEl.attribs.id,
				name: $("h3", guidelineEl).text().trim(),
				num: `${i + 1}.${j + 1}`,
				version: guidelineEl.attribs.id === "input-modalities" ? "WCAG21" : "WCAG20",
				successCriteria,
			});
		});

		principles.push({
			id: el.attribs.id,
			name: $("h2", el).text().trim(),
			num: `${i + 1}`,
			version: "WCAG20",
			guidelines,
		})
	});
}