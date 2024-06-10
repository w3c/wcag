import type { Cheerio } from "cheerio";
import { glob } from "glob";
import capitalize from "lodash-es/capitalize";
import uniqBy from "lodash-es/uniqBy";

import { readFile } from "fs/promises";
import { basename } from "path";

import { load, loadFromFile } from "./cheerio";
import { isSuccessCriterion, type FlatGuidelinesMap, type SuccessCriterion } from "./guidelines";
import { wcagSort } from "./common";

/** Maps each technology to its title for the table of contents */
export const technologyTitles = {
	"aria": "ARIA Techniques",
	"client-side-script": "Client-Side Script Techniques",
	"css": "CSS Techniques",
	"failures": "Common Failures",
	"general": "General Techniques",
	"html": "HTML Techniques",
	"pdf": "PDF Techniques",
	"server-side-script": "Server-Side Script Techniques",
	"smil": "SMIL Techniques",
	"text": "Plain-Text Techniques",
};
type Technology = keyof typeof technologyTitles;
export const technologies = Object.keys(technologyTitles) as Technology[];

function assertIsTechnology(technology: string): asserts technology is keyof typeof technologyTitles {
	if (!(technology in technologyTitles)) throw new Error(`Invalid technology name: ${technology}`)
}

const associationTypes = ["sufficient", "advisory", "failure"] as const;
type AssociationType = typeof associationTypes[number];

interface TechniqueAssociation {
	criterion: SuccessCriterion;
	type: Capitalize<AssociationType>;
	/** Indicates this technique must be paired with specific "child" techniques to fulfill SC */
	hasUsageChildren: boolean;
	/**
	 * Technique ID or description of "parent" technique(s) this is paired with to fulfill SC.
	 * This is typically 0 or 1 technique, but may be multiple in rare cases.
	 */
	usageParents: string[];
	/** Technique IDs this technique must be implemented with to fulfill SC, if any */
	with: string[];
}

function assertIsAssociationType(type?: string): asserts type is AssociationType {
	if (!associationTypes.includes(type as AssociationType))
		throw new Error(`Association processed for unexpected section ${type}`);
}

const techniqueLinkHrefToId = (href: string) => basename(href, ".html");

/**
 * Returns object mapping technique IDs to SCs that reference it;
 * comparable to technique-associations.xml but in a more ergonomic format.
 */
export async function getTechniqueAssociations(guidelines: FlatGuidelinesMap) {
	const associations: Record<string, TechniqueAssociation[]> = {};
	const itemSelector = associationTypes.map((type) => `section#${type} li`).join(", ");
	const techniqueLinkSelector = "a[href*='../Techniques/' i]";

	const paths = await glob("understanding/*/*.html");
	for (const path of paths) {
		const criterion = guidelines[basename(path, ".html")];
		if (!isSuccessCriterion(criterion)) continue;
		
		const $ = await loadFromFile(path);
		$(itemSelector).each((_, liEl) => {
			const $liEl = $(liEl);
			const $parentListItem = $liEl.closest("ul, ol").closest("li");
			// Identify which expected section the list was found under
			const associationType =
				$liEl.closest(associationTypes.map((type) => `section#${type}`).join(", ")).attr("id");
			assertIsAssociationType(associationType);

			/** Finds technique links only within the given list item (not under child lists) */
			const queryImmediateChildLinks = ($el: Cheerio<any>) =>
				$el.find(techniqueLinkSelector).filter((_, aEl) => $(aEl).closest("li")[0] === $el[0]);

			const $techniqueLinks = queryImmediateChildLinks($liEl);
			$techniqueLinks.each((_, aEl) => {
				const association: TechniqueAssociation = {
					criterion,
					type: capitalize(associationType) as Capitalize<AssociationType>,
					hasUsageChildren: !!$liEl.find("ul, ol").length,
					usageParents: queryImmediateChildLinks($parentListItem).toArray()
						.map((el) => techniqueLinkHrefToId(el.attribs.href)),
					with: $techniqueLinks.toArray().filter((el) => el !== aEl)
						.map((el) => techniqueLinkHrefToId(el.attribs.href)),
				};

				const id = techniqueLinkHrefToId(aEl.attribs.href);
				if (!(id in associations)) associations[id] = [association];
				else associations[id].push(association);
			});
		});
	}

	// Perform a pass over associations to remove duplicates
	for (const [key, list] of Object.entries(associations))
		associations[key] =
			uniqBy(list, (v) => JSON.stringify(v))
				.sort((a, b) => wcagSort(a.criterion, b.criterion));

	return associations;
}

interface Technique {
	/** Letter(s)-then-number technique code; corresponds to source HTML filename */
	id: string;
	/** Technology this technique is filed under */
	technology: Technology;
	/** Title derived from each technique page */
	title: string;
	/** Title derived from each technique page, with HTML preserved */
	titleHtml: string;
}

/**
 * Returns an object mapping each technology category to an array of Techniques.
 * Used to generate index table of contents.
 * (Functionally equivalent to "techniques-list" target in build.xml)
 */
export async function getTechniquesByTechnology() {
	const paths = await glob("*/*.html", { cwd: "techniques" });
	const techniques = technologies.reduce((map, technology) => ({
		...map,
		[technology]: [] as string[],
	}), {}) as Record<Technology, Technique[]>;

	for (const path of paths) {
		const [technology, filename] = path.split("/");
		assertIsTechnology(technology);

		// Isolate h1 from each file before feeding into Cheerio to save ~300ms total
		const match = (await readFile(`techniques/${path}`, "utf8")).match(/<h1[^>]*>([\s\S]+?)<\/h1>/);
		if (!match || !match[1]) throw new Error(`No h1 found in techniques/${path}`);
		const $h1 = load(match[1], null, false);

		techniques[technology].push({
			id: basename(filename, ".html"),
			title: $h1.text(),
			titleHtml: $h1.html(),
			technology,
		});
	}

	for (const technology of technologies) {
		techniques[technology].sort((a, b) => {
			const aId = +a.id.replace(/[^\d]/g, "");
			const bId = +b.id.replace(/[^\d]/g, "");
			if (aId < bId) return -1;
			if (aId > bId) return 1;
			return 0;
		})
	}

	return techniques;
}

/**
 * Returns an object mapping each technique ID to its data.
 */
export const getFlatTechniques =
	(techniques: Awaited<ReturnType<typeof getTechniquesByTechnology>>) =>
		Object.values(techniques).flat().reduce((map, technique) => {
			map[technique.id] = technique;
			return map;
		}, {} as Record<string, Technique>);
