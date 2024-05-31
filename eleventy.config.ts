import { copyFile } from "fs/promises";

import { CustomLiquid } from "11ty/CustomLiquid";
import { getTechniques, technologies, technologyTitles } from "11ty/techniques";
import type { EleventyData, EleventyEvent } from "11ty/types";
import { generateUnderstandingNavMap, getPrinciples, getUnderstandingDocs } from "11ty/guidelines";

// Inputs to eventually expose e.g. via environment variables
/** Takes the place of editors vs. publication distinction */
const isEditors = false;
/** Version of WCAG to build */
const version = "22";

export default function (eleventyConfig: any) {
	eleventyConfig.addGlobalData("version", version);
	eleventyConfig.addGlobalData("versionDecimal", version.split("").join("."));

	eleventyConfig.addGlobalData("eleventyComputed", {
		// Preserve existing structure: write to x.html instead of x/index.html
		permalink: ({ page }: EleventyData) => page.inputPath,
	});

	eleventyConfig.addGlobalData("techniques", getTechniques);
	eleventyConfig.addGlobalData("technologies", technologies);
	eleventyConfig.addGlobalData("technologyTitles", technologyTitles);

	eleventyConfig.addGlobalData("principles", getPrinciples);
	eleventyConfig.addGlobalData("understandingDocs", async () => getUnderstandingDocs(version));
	eleventyConfig.addGlobalData("understandingNav", async () => generateUnderstandingNavMap(version));

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
	// If you're looking for other high-level data, check /_data and *.11tydata.js

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
		await copyFile(`${dir.output}/techniques/base.css`, `${dir.output}/understanding/base.css`);
	});

	const dir = {
		// output: "output", // output to the same place as build.xml
	};

	eleventyConfig.setLibrary("liquid", new CustomLiquid({
		// See https://www.11ty.dev/docs/languages/liquid/#liquid-options
		root: ["_includes", "."],
		strictFilters: true,
	}));

	return { dir };
}
