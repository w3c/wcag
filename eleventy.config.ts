import axios from "axios";
import compact from "lodash-es/compact";
import { mkdirp } from "mkdirp";
import { rimraf } from "rimraf";

import { copyFile, writeFile } from "fs/promises";
import { join } from "path";

import { CustomLiquid } from "11ty/CustomLiquid";
import {
  actRules,
  assertIsWcagVersion,
  getFlatGuidelines,
  getPrinciples,
  getPrinciplesForVersion,
  scSlugOverrides,
  type FlatGuidelinesMap,
  type Guideline,
  type Principle,
  type SuccessCriterion,
} from "11ty/guidelines";
import {
  getFlatTechniques,
  getTechniqueAssociations,
  getTechniquesByTechnology,
  technologies,
  technologyTitles,
  type Technique,
  type Technology,
} from "11ty/techniques";
import { generateUnderstandingNavMap, getUnderstandingDocs } from "11ty/understanding";
import type { EleventyContext, EleventyData, EleventyEvent } from "11ty/types";

/** Version of WCAG to build */
const version = process.env.WCAG_VERSION || "22";
assertIsWcagVersion(version);

/**
 * Returns boolean indicating whether a technique is obsolete for the given version.
 * Tolerates undefined for use with hash lookups.
 */
const isTechniqueObsolete = (technique: Technique | undefined) =>
  !!technique?.obsoleteSince && technique.obsoleteSince <= version;

/**
 * Returns boolean indicating whether an SC is obsolete for the given version.
 * Tolerates other types for use with hash lookups.
 */
const isGuidelineObsolete = (guideline: Principle | Guideline | SuccessCriterion | undefined) =>
  guideline?.type === "SC" && guideline.level === "";

/** Tree of Principles/Guidelines/SC across all versions (including later than selected) */
const allPrinciples = await getPrinciples();
/** Flattened Principles/Guidelines/SC across all versions (including later than selected) */
const allFlatGuidelines = getFlatGuidelines(allPrinciples);

/** Tree of Principles/Guidelines/SC relevant to selected version */
const principles = process.env.WCAG_VERSION
  ? await getPrinciplesForVersion(version)
  : allPrinciples;
/** Flattened Principles/Guidelines/SC relevant to selected version */
const flatGuidelines = getFlatGuidelines(principles);
/** Flattened Principles/Guidelines/SC that only exist in later versions (to filter techniques) */
const futureGuidelines: FlatGuidelinesMap = {};
for (const [key, value] of Object.entries(allFlatGuidelines)) {
  if (value.version > version) futureGuidelines[key] = value;
}

const techniques = await getTechniquesByTechnology();
const flatTechniques = getFlatTechniques(techniques);

/** Maps technique IDs to SCs found in target version */
const techniqueAssociations = await getTechniqueAssociations(flatGuidelines);
for (const [id, associations] of Object.entries(techniqueAssociations)) {
  // Prune associations from non-obsolete techniques to obsolete SCs
  techniqueAssociations[id] = associations.filter(
    ({ criterion }) => criterion.level !== "" || isTechniqueObsolete(flatTechniques[id])
  );
}
/** Maps technique IDs to SCs only found in later versions */
const futureTechniqueAssociations = await getTechniqueAssociations(futureGuidelines);
/** Subset of futureTechniqueAssociations not overlapping with techniqueAssociations */
const futureExclusiveTechniqueAssociations: typeof techniqueAssociations = {};

for (const [id, associations] of Object.entries(futureTechniqueAssociations)) {
  if (!techniqueAssociations[id]) futureExclusiveTechniqueAssociations[id] = associations;
}
const skippedTechniques = Object.keys(futureExclusiveTechniqueAssociations).sort().join(", ");
if (skippedTechniques)
  console.log(`Skipping techniques that only reference later-version SCs: ${skippedTechniques}`);

for (const [technology, list] of Object.entries(techniques)) {
  // Prune techniques that are obsolete or associated with SCs from later versions
  // (only prune hierarchical structure for ToC; keep all in flatTechniques for lookups)
  techniques[technology as Technology] = list.filter(
    (technique) =>
      (!technique.obsoleteSince || technique.obsoleteSince > version) &&
      !futureExclusiveTechniqueAssociations[technique.id]
  );
}

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

export type GlobalData = EleventyData &
  typeof globalData & {
    // Expected data cascade properties from *.11tydata.js
    headerLabel?: string; // akin to documentset.name in build.xml
    headerUrl?: string;
    isTechniques?: boolean;
    isUnderstanding?: boolean;
  };

const [GH_ORG, GH_REPO] = (process.env.GITHUB_REPOSITORY || "w3c/wcag").split("/");

const baseUrls = {
  guidelines: `https://www.w3.org/TR/WCAG${version}/`,
  techniques: "/techniques/",
  understanding: "/understanding/",
};

if (process.env.WCAG_MODE === "editors") {
  // For pushing to gh-pages
  baseUrls.guidelines = `https://${GH_ORG}.github.io/${GH_REPO}/guidelines/${
    version === "21" ? "" : `${version}/`
  }`;
  baseUrls.techniques = `https://${GH_ORG}.github.io/${GH_REPO}/techniques/`;
  baseUrls.understanding = `https://${GH_ORG}.github.io/${GH_REPO}/understanding/`;
} else if (process.env.WCAG_MODE === "publication") {
  // For pushing to W3C site
  baseUrls.guidelines = `https://www.w3.org/TR/WCAG${version}/`;
  baseUrls.techniques = `https://www.w3.org/WAI/WCAG${version}/Techniques/`;
  baseUrls.understanding = `https://www.w3.org/WAI/WCAG${version}/Understanding/`;
}

/** Applies any overridden SC IDs to incoming Understanding fileSlugs */
function resolveUnderstandingFileSlug(fileSlug: string) {
  if (fileSlug in scSlugOverrides) {
    assertIsWcagVersion(version);
    return scSlugOverrides[fileSlug](version);
  }
  return fileSlug;
}

export default function (eleventyConfig: any) {
  for (const [name, value] of Object.entries(globalData)) eleventyConfig.addGlobalData(name, value);

  // Make baseUrls available to templates
  for (const [name, value] of Object.entries(baseUrls))
    eleventyConfig.addGlobalData(`${name}Url`, value);

  // Use git modified time if building for gh-pages or W3C site;
  // otherwise use local mtime to cut build time (~4s difference).
  // See https://www.11ty.dev/docs/dates/#setting-a-content-date-in-front-matter
  eleventyConfig.addGlobalData("date", `${process.env.WCAG_MODE ? "git " : ""}Last Modified`);

  // eleventyComputed data is assigned here rather than in 11tydata files;
  // we have access to typings here, and can keep the latter fully static.
  eleventyConfig.addGlobalData("eleventyComputed", {
    // permalink determines output structure; see https://www.11ty.dev/docs/permalinks/
    permalink: ({ page, isTechniques, isUnderstanding }: GlobalData) => {
      if (page.inputPath === "./index.html" && process.env.WCAG_MODE) return false;
      if (isTechniques) {
        if (futureExclusiveTechniqueAssociations[page.fileSlug]) return false;
      } else if (isUnderstanding) {
        // understanding-metadata.html exists in 2 places; top-level wins in XSLT process
        if (/\/20\/understanding-metadata/.test(page.inputPath)) return false;

        if (page.fileSlug in allFlatGuidelines) {
          // Exclude files not present in the version being built
          if (!flatGuidelines[page.fileSlug]) return false;

          // Flatten pages into top-level directory, out of version subdirectories.
          // Revise any filename that differs between versions, reusing data from guidelines.ts
          return `understanding/${resolveUnderstandingFileSlug(page.fileSlug)}.html`;
        }
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
      // Reference unfiltered map to avoid breaking non-emitted (but still processed) pages
      isTechniques ? flatTechniques[page.fileSlug] : null,
    techniqueAssociations: ({ page, isTechniques }: GlobalData) =>
      isTechniques ? techniqueAssociations[page.fileSlug] : null,

    // Data for individual understanding pages
    guideline: ({ page, isUnderstanding }: GlobalData) =>
      isUnderstanding ? flatGuidelines[resolveUnderstandingFileSlug(page.fileSlug)] : null,
  });

  // See https://www.11ty.dev/docs/copy/#emulate-passthrough-copy-during-serve
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

  eleventyConfig.on("eleventy.before", async ({ runMode }: EleventyEvent) => {
    // Clear the _site folder before builds intended for the W3C site,
    // to avoid inheriting dev-only files from previous runs
    if (runMode === "build" && process.env.WCAG_MODE === "publication") await rimraf("_site");
  });

  eleventyConfig.on("eleventy.after", async ({ dir }: EleventyEvent) => {
    // addPassthroughCopy can only map each file once,
    // but base.css needs to be copied to a 2nd destination
    await copyFile(
      join(dir.input, "css", "base.css"),
      join(dir.output, "understanding", "base.css")
    );

    // Output guidelines/index.html and dependencies for PR runs (not for GH Pages or W3C site)
    const sha = process.env.COMMIT_REF; // Read environment variable exposed by Netlify
    if (sha && !process.env.WCAG_MODE) {
      await mkdirp(join(dir.output, "guidelines"));
      await copyFile(
        join(dir.input, "guidelines", "guidelines.css"),
        join(dir.output, "guidelines", "guidelines.css")
      );
      await copyFile(
        join(dir.input, "guidelines", "relative-luminance.html"),
        join(dir.output, "guidelines", "relative-luminance.html")
      );

      const url = `https://raw.githack.com/${GH_ORG}/${GH_REPO}/${sha}/guidelines/index.html?isPreview=true`;
      const { data: processedGuidelines } = await axios.get(
        `https://labs.w3.org/spec-generator/?type=respec&url=${encodeURIComponent(url)}`,
        { responseType: "text" }
      );
      await writeFile(`${dir.output}/guidelines/index.html`, processedGuidelines);
    }
  });

  eleventyConfig.setLibrary(
    "liquid",
    new CustomLiquid({
      // See https://www.11ty.dev/docs/languages/liquid/#liquid-options
      root: ["_includes", "."],
      jsTruthy: true,
      strictFilters: true,
    })
  );

  // Filter that transforms a technique ID (or list of them) into links to their pages.
  eleventyConfig.addFilter(
    "linkTechniques",
    function (this: EleventyContext, ids: string | string[]) {
      const links = (Array.isArray(ids) ? ids : [ids]).map((id) => {
        if (typeof id !== "string") throw new Error(`linkTechniques: invalid id ${id}`);
        const technique = flatTechniques[id];
        if (!technique) {
          console.warn(
            `linkTechniques in ${this.page.inputPath}: ` +
              `skipping unresolvable technique id ${id}`
          );
          return;
        }

        // Omit links to obsolete techniques, when not also linked from one
        if (
          isTechniqueObsolete(technique) &&
          !isTechniqueObsolete(flatTechniques[this.page.fileSlug]) &&
          !isGuidelineObsolete(flatGuidelines[this.page.fileSlug])
        ) {
          if (process.env.WCAG_VERBOSE) {
            const since = technique.obsoleteSince!.split("").join(".");
            console.warn(
              `linkTechniques in ${this.page.inputPath}: ` +
                `skipping obsolete technique ${id} (as of ${since})`
            );
          }
          return;
        }
        // Same for techniques only introduced in later WCAG versions
        if (
          technique.id in futureExclusiveTechniqueAssociations &&
          !futureExclusiveTechniqueAssociations[this.page.fileSlug] &&
          (!allFlatGuidelines[this.page.fileSlug] ||
            allFlatGuidelines[this.page.fileSlug].version <= version)
        ) {
          if (process.env.WCAG_VERBOSE) {
            console.warn(
              `linkTechniques in ${this.page.inputPath}: ` +
                `skipping future-version technique ${id}`
            );
          }
          return;
        }

        // Support relative technique links from other techniques or from techniques/index.html,
        // otherwise path-absolute when cross-linked from understanding/*
        const urlBase = /^\/techniques\/.*\//.test(this.page.filePathStem)
          ? "../"
          : this.page.filePathStem.startsWith("/techniques")
            ? ""
            : baseUrls.techniques;
        const label = `${id}: ${technique.truncatedTitle}`;
        return `<a href="${urlBase}${technique.technology}/${id}">${label}</a>`;
      });
      return compact(links).join("\nand\n");
    }
  );

  // Filter that transforms a guideline or SC shortname (or list of them) into links to their pages.
  eleventyConfig.addFilter(
    "linkUnderstanding",
    function (this: EleventyContext, ids: string | string[]) {
      return (Array.isArray(ids) ? ids : [ids])
        .map((id) => {
          if (typeof id !== "string") throw new Error("linkUnderstanding: invalid id passed");
          const guideline = flatGuidelines[id];
          if (!guideline) {
            console.warn(
              `linkUnderstanding in ${this.page.inputPath}: ` +
                `skipping unresolvable guideline shortname ${id}`
            );
            return;
          }

          // Warn of links to obsolete SCs, when not also linked from one.
          // This is intentionally not behind WCAG_VERBOSE, and does not remove,
          // as links to Understanding docs are more likely to be in the middle
          // of prose requiring manual adjustments
          if (
            isGuidelineObsolete(guideline) &&
            !isGuidelineObsolete(flatGuidelines[this.page.fileSlug]) &&
            !isTechniqueObsolete(flatTechniques[this.page.fileSlug])
          ) {
            console.warn(
              `linkUnderstanding in ${this.page.inputPath}: ` +
                `reference to obsolete ${guideline.type} ${id}`
            );
          }

          const urlBase = this.page.filePathStem.startsWith("/understanding/")
            ? ""
            : baseUrls.understanding;
          const label = `${guideline.num}: ${guideline.name}`;
          return `<a href="${urlBase}${id}">${label}</a>`;
        })
        .join("\nand\n");
    }
  );

  // Renders a section box (used for About this Technique and Guideline / SC)
  eleventyConfig.addPairedShortcode(
    "sectionbox",
    (content: string, id: string, title: string) => `
<section id="${id}" class="box">
	<h2 class="box-h box-h-icon">${title}</h2>
	<div class="box-i">${content}</div>
</section>
	`
  );

  // Suppress default build output that prints every path, to make our own output clearly visible
  eleventyConfig.setQuietMode(true);
}
