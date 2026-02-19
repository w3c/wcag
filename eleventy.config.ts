import compact from "lodash-es/compact";

import { copyFile, mkdir, rm, writeFile } from "fs/promises";
import { join } from "path";

import { CustomLiquid } from "11ty/CustomLiquid";
import { fetchText, resolveDecimalVersion } from "11ty/common";
import { loadDataDependencies } from "11ty/data-dependencies";
import {
  actRules,
  generateScSlugOverrides,
  getErrataForVersion,
  getTermsMap,
  getTermsMapForVersion,
  type WcagItem,
} from "11ty/guidelines";
import {
  expandTechniqueToObject,
  isTechniqueObsolete as isTechniqueObsoleteForVersion,
  technologies,
  technologyTitles,
  type Technique,
} from "11ty/techniques";
import type { EleventyContext, EleventyData, EleventyEvent } from "11ty/types";

const {
  principles,
  flatGuidelines,
  allFlatGuidelines,
  techniques,
  flatTechniques,
  techniqueAssociations,
  futureExclusiveTechniqueAssociations,
  understandingDocs,
  understandingNav,
  version,
} = await loadDataDependencies(process.env.WCAG_VERSION);

const skippedTechniques = Object.keys(futureExclusiveTechniqueAssociations).sort().join(", ");
if (skippedTechniques)
  console.log(`Skipping techniques that only reference later-version SCs: ${skippedTechniques}`);

const isTechniqueObsolete = (technique: Technique | undefined) =>
  isTechniqueObsoleteForVersion(technique, version);

/**
 * Returns boolean indicating whether an SC is obsolete for the given version.
 * Tolerates other types for use with hash lookups.
 */
const isGuidelineObsolete = (guideline: WcagItem | undefined) =>
  guideline?.type === "SC" && guideline.level === "";

const scSlugOverrides = generateScSlugOverrides(version);

function resolveRelevantTermsMap() {
  if (!process.env.WCAG_VERSION) return getTermsMap();
  if (process.env.WCAG_FORCE_LOCAL_GUIDELINES)
    return getTermsMap(process.env.WCAG_FORCE_LOCAL_GUIDELINES);
  return getTermsMapForVersion(version);
}

// Declare static global data up-front so we can build typings from it
const globalData = {
  version,
  versionDecimal: resolveDecimalVersion(version),
  errata: process.env.WCAG_VERSION ? await getErrataForVersion(version) : {},
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
const resolveUnderstandingFileSlug = (fileSlug: string) => scSlugOverrides[fileSlug] || fileSlug;

export default async function (eleventyConfig: any) {
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
          if (!flatGuidelines[resolveUnderstandingFileSlug(page.fileSlug)]) return false;

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

  const ignoredEndings = [
    "-template.html",
    "understanding/20/accessibility-support-documenting.html",
    "understanding/20/seizures.html",
  ];
  eleventyConfig.addPreprocessor("ignore-html", "html", ({ page }: GlobalData) => {
    if (
      !page.filePathStem.startsWith("/errata/") &&
      !page.filePathStem.startsWith("/techniques/") &&
      !page.filePathStem.startsWith("/understanding/") &&
      page.filePathStem !== "/index"
    )
      return false;
    if (page.inputPath.includes("/img/")) return false;
    for (const ending of ignoredEndings) if (page.inputPath.endsWith(ending)) return false;
  });
  eleventyConfig.addPreprocessor("ignore-md", "md", () => false);

  // Add explicit watch targets to avoid addPassthroughCopy interference
  eleventyConfig.addWatchTarget("techniques/**");
  eleventyConfig.addWatchTarget("understanding/**");

  eleventyConfig.addPassthroughCopy("techniques/*.css");
  eleventyConfig.addPassthroughCopy("techniques/*/img/*");
  eleventyConfig.addPassthroughCopy({
    "css/base.css": "techniques/base.css",
    "css/a11y-light.css": "techniques/a11y-light.css",
  });

  eleventyConfig.addPassthroughCopy("understanding/*.css");
  eleventyConfig.addPassthroughCopy({
    "guidelines/relative-luminance.html": "understanding/relative-luminance.html",
    "understanding/*/img/*": "understanding/img", // Intentionally flatten
  });

  eleventyConfig.addPassthroughCopy("working-examples/**");
  // working-examples is in .eleventyignore to avoid processing as templates,
  // but should still be included as a watch target to pick up changes in dev
  eleventyConfig.watchIgnores.add("!working-examples/**");

  eleventyConfig.on("eleventy.before", async ({ runMode }: EleventyEvent) => {
    // Clear the _site folder before builds intended for the W3C site,
    // to avoid inheriting dev-only files from previous runs
    if (runMode === "build" && process.env.WCAG_MODE === "publication")
      await rm("_site", { recursive: true });
  });

  let hasDisplayedGuidance = false;
  eleventyConfig.on("eleventy.after", async ({ dir, runMode }: EleventyEvent) => {
    // addPassthroughCopy can only map each file once,
    // but some CSS files need to be copied to 2 destinations
    await copyFile(
      join(dir.input, "css", "base.css"),
      join(dir.output, "understanding", "base.css")
    );
    await copyFile(
      join(dir.input, "css", "a11y-light.css"),
      join(dir.output, "understanding", "a11y-light.css")
    );

    // Output guidelines/index.html and dependencies for PR runs (not for GH Pages or W3C site)
    const sha = process.env.COMMIT_REF; // Read environment variable exposed by Netlify
    if (sha && !process.env.WCAG_MODE) {
      await mkdir(join(dir.output, "guidelines"), { recursive: true });
      await copyFile(
        join(dir.input, "guidelines", "guidelines.css"),
        join(dir.output, "guidelines", "guidelines.css")
      );
      await copyFile(
        join(dir.input, "guidelines", "relative-luminance.html"),
        join(dir.output, "guidelines", "relative-luminance.html")
      );

      const url = `https://raw.githack.com/${GH_ORG}/${GH_REPO}/${sha}/guidelines/index.html?isPreview=true`;
      const processedGuidelines = await fetchText(
        `https://www.w3.org/publications/spec-generator/?type=respec&url=${encodeURIComponent(url)}`
      );
      await writeFile(`${dir.output}/guidelines/index.html`, processedGuidelines);
    }

    // Since json isn't a template format and we're generating it, write it directly
    if (process.env.WCAG_JSON) {
      const { generateWcagJson } = await import("11ty/json");
      await writeFile(`${dir.output}/wcag.json`, await generateWcagJson(version));
    }

    if (runMode === "serve" && !hasDisplayedGuidance) {
      hasDisplayedGuidance = true;
      console.log(
        "The dev server will restart on TypeScript changes. If you are adding new HTML pages, press Enter to restart it manually."
      );
    }
  });

  eleventyConfig.setLibrary(
    "liquid",
    new CustomLiquid({
      // See https://www.11ty.dev/docs/languages/liquid/#liquid-options
      root: ["_includes", "."],
      jsTruthy: true,
      strictFilters: true,
      timezoneOffset: 0, // Avoid off-by-one YYYY-MM-DD date stamp conversions
      termsMap: await resolveRelevantTermsMap(),
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
            const since = resolveDecimalVersion(technique.obsoleteSince!);
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

  // Filter that transforms a technique ID into its title (even if it is obsolete, e.g. for changelog)
  eleventyConfig.addFilter("displayTechniqueTitle", function (this: EleventyContext, id: string) {
    const technique = flatTechniques[id];
    if (!technique) {
      if (process.env.WCAG_VERBOSE) {
        console.warn(
          `displayTechniqueTitle in ${this.page.inputPath}: ` +
            `skipping unresolvable technique id ${id}`
        );
      }
      return;
    }
    return `${id}: ${technique.truncatedTitle}`;
  });

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
          const label = `${guideline.num} ${guideline.name}`;
          return `<a href="${urlBase}${id}">${label}</a>`;
        })
        .join("\nand\n");
    }
  );

  // Strict version of default that will only fall back on null or undefined (not e.g. "")
  eleventyConfig.addFilter("default-strict", (value: any, fallback: any) =>
    value == null ? fallback : value
  );

  // Expands a technique shorthand string to an object with id or title
  eleventyConfig.addFilter("expand-technique", expandTechniqueToObject);

  // Renders a link to a GitHub commit or pull request
  eleventyConfig.addShortcode("gh", (id: string) => {
    if (/^#\d+$/.test(id)) {
      const num = id.slice(1);
      return `<a href="https://github.com/${GH_ORG}/${GH_REPO}/pull/${num}" aria-label="pull request ${num}">${id}</a>`;
    } else if (/^[0-9a-f]{7,}$/.test(id)) {
      const sha = id.slice(0, 7); // Truncate in case full SHA was passed
      return `<a href="https://github.com/${GH_ORG}/${GH_REPO}/commit/${sha}" aria-label="commit ${sha}">${sha}</a>`;
    } else throw new Error(`Invalid SHA or PR ID passed to gh tag: ${id}`);
  });

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
