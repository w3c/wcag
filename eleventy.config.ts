import compact from "lodash-es/compact";

import { copyFile } from "fs/promises";

import { CustomLiquid } from "11ty/CustomLiquid";
import { actRules, getFlatGuidelines, getPrinciples } from "11ty/guidelines";
import { getFlatTechniques, getTechniqueAssociations, getTechniquesByTechnology, technologies, technologyTitles } from "11ty/techniques";
import { generateUnderstandingNavMap, getUnderstandingDocs } from "11ty/understanding";
import type { EleventyContext, EleventyData, EleventyEvent, TocLink } from "11ty/types";

// Inputs to eventually expose e.g. via environment variables
/** Takes the place of editors vs. publication distinction */
const isEditors = false;
/** Version of WCAG to build */
const version = "22";

const principles = await getPrinciples();
const flatGuidelines = getFlatGuidelines(principles);
const techniques = await getTechniquesByTechnology();
const flatTechniques = getFlatTechniques(techniques);
const techniqueAssociations = await getTechniqueAssociations(flatGuidelines);
const understandingDocs = await getUnderstandingDocs(version);
const understandingNav = await generateUnderstandingNavMap(principles, understandingDocs);

// Declare static global data up-front so we can build typings from it
const globalData = {
	version,
	versionDecimal: version.split("").join("."),
	techniques, // Used for techniques/index.html
	technologies, // Used for techniques/index.html
	technologyTitles, // Used for techniques/index.html
	principles, // Used for understanding/index.html
	understandingDocs, // Used for understanding/index.html
};
export type GlobalData = EleventyData & typeof globalData;

export default function (eleventyConfig: any) {
	for (const [name, value] of Object.entries(globalData)) {
		eleventyConfig.addGlobalData(name, value);
	}
	
	eleventyConfig.addGlobalData(
		"guidelinesUrl",
		isEditors
			? "https://w3c.github.io/wcag/guidelines/"
			: `https://www.w3.org/TR/WCAG${version}/`
	);
	// Note: These were ported from build.xml but it's unclear whether they'll really be needed
	eleventyConfig.addGlobalData(
		"techniquesUrl",
		isEditors
			? "https://w3c.github.io/wcag/techniques/"
			: `https://www.w3.org/WAI/WCAG/${version}/Techniques/`
	);
	eleventyConfig.addGlobalData(
		"understandingUrl",
		isEditors
			? "https://w3c.github.io/wcag/understanding/"
			: `https://www.w3.org/WAI/WCAG/${version}/Understanding/`
	);

	// eleventyComputed data is assigned here rather than in 11tydata files;
	// we have access to typings here, and can keep the latter fully static.
	eleventyConfig.addGlobalData("eleventyComputed", {
		permalink: ({ page, isUnderstanding }: GlobalData) => {
			if (isUnderstanding) {
				// understanding-metadata.html exists in 2 places; top-level wins
				if (/\/20\/understanding-metadata/.test(page.inputPath)) return false;
				// Flatten pages into top-level directory, out of version subdirectories
				return page.inputPath.replace(/\/2\d\//, "/");
			}
			// Preserve existing structure: write to x.html instead of x/index.html
			return page.inputPath;
		},
		nav: ({ page, isUnderstanding }: GlobalData) => 
			isUnderstanding ? understandingNav[page.fileSlug] : null,
		testRules: ({ page, isTechniques, isUnderstanding }: GlobalData) => {
			if (isTechniques)
				return actRules.filter(({ wcagTechniques }) => wcagTechniques.includes(page.fileSlug));
			if (isUnderstanding)
				return actRules.filter(({ successCriteria }) => successCriteria.includes(page.fileSlug));
		},
		// Data for individual technique pages
		technique: ({ page, isTechniques }: GlobalData) =>
			isTechniques ? flatTechniques[page.fileSlug] : null,
		techniqueAssociations: ({ page, isTechniques }: GlobalData) =>
			isTechniques ? techniqueAssociations[page.fileSlug] : null,
		// Data for individual understanding pages
		guideline: ({ page, isUnderstanding }: GlobalData) =>
			isUnderstanding ? flatGuidelines[page.fileSlug] : null,
	});

	// https://www.11ty.dev/docs/copy/#emulate-passthrough-copy-during-serve
	eleventyConfig.setServerPassthroughCopyBehavior("passthrough");

	eleventyConfig.addPassthroughCopy("techniques/*.css");
	eleventyConfig.addPassthroughCopy("techniques/*/img/*");
	eleventyConfig.addPassthroughCopy({
		"css/base.css": "techniques/base.css",
		"css/a11y-light.css": "techniques/a11y-light.css",
		"script/highlight.min.js": "techniques/highlight.min.js",
	});

	eleventyConfig.addPassthroughCopy("understanding/*.css");
	eleventyConfig.addPassthroughCopy({
		"guidelines/relative-luminance.html": "understanding/relative-luminance.html",
		"understanding/*/img/*": "understanding/img", // Intentionally flatten
	});
	eleventyConfig.addPassthroughCopy("working-examples/**");

	eleventyConfig.on("eleventy.after", async ({ dir }: EleventyEvent) => {
		// addPassthroughCopy can only map each file once,
		// but base.css needs to be copied to a 2nd destination
		await copyFile(`${dir.input}/css/base.css`, `${dir.output}/understanding/base.css`);
	});

	const dir = {
		// output: "output", // output to the same place as build.xml
	};

	eleventyConfig.setLibrary("liquid", new CustomLiquid({
		// See https://www.11ty.dev/docs/languages/liquid/#liquid-options
		root: ["_includes", "."],
		jsTruthy: true,
		strictFilters: true,
	}));

	// Filter that transforms a technique ID (or list of them) into links to their pages.
	eleventyConfig.addFilter("linkTechniques", function (this: EleventyContext, ids: string | string[]) {
		const links = (Array.isArray(ids) ? ids : [ids])
			.map((id) => {
				if (typeof id !== "string") throw new Error(`linkTechniques: invalid id ${id}`);
				const technique = flatTechniques[id];
				if (!technique) {
					console.warn(`linkTechniques in ${this.page.inputPath}: ` +
						`skipping unresolvable technique id ${id}`);
					return;
				}
				// Support relative technique links from other techniques or from techniques/index.html,
				// otherwise path-absolute when cross-linked from understanding/*
				const urlBase = /^\/techniques\/.*\//.test(this.page.filePathStem)
					? "../"
					: this.page.filePathStem.startsWith("/techniques") ? "" : "/techniques/";
				const label = `${id}: ${technique.truncatedTitle}`;
				return `<a href="${urlBase}${technique.technology}/${id}">${label}</a>`;
			});
			return compact(links).join("\nand\n");
	});

	// Filter that transforms a guideline or SC shortname (or list of them) into links to their pages.
	eleventyConfig.addFilter("linkUnderstanding", function (this: EleventyContext, ids: string | string[]) {
		return (Array.isArray(ids) ? ids : [ids])
			.map((id) => {
				if (typeof id !== "string") throw new Error("linkUnderstanding: invalid id passed");
				const guideline = flatGuidelines[id];
				if (!guideline) {
					console.warn(`linkUnderstanding in ${this.page.inputPath}: ` +
						`skipping unresolvable guideline shortname ${id}`);
				}
				const urlBase =
					this.page.filePathStem.startsWith("/understanding/") ? "" : "/understanding/";
				const label = `${guideline.num}: ${guideline.name}`;
				return `<a href="${urlBase}${id}">${label}</a>`;
			}).join("\nand\n");
	});

	eleventyConfig.addPairedShortcode("sectionbox", (content: string, id: string, title: string) => `
<section id="${id}" class="box">
	<h2 class="box-h box-h-icon">${title}</h2>
	<div class="box-i">${content}</div>
</section>
	`);

	eleventyConfig.setQuietMode(true);
	return { dir };
}
