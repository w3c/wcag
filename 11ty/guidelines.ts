import type { CheerioAPI } from "cheerio";
import { glob } from "glob";

import { readFile } from "fs/promises";
import { basename, join, sep } from "path";

import { flattenDomFromFile, load, loadFromFile, type CheerioAnyNode } from "./cheerio";
import { fetchText, generateId } from "./common";

export type WcagVersion = "20" | "21" | "22";
export function assertIsWcagVersion(v: string): asserts v is WcagVersion {
  if (!/^2[012]$/.test(v)) throw new Error(`Unexpected version found: ${v}`);
}

/**
 * Interface describing format of entries in guidelines/act-mapping.json
 */
interface ActRule {
  deprecated: boolean;
  permalink: string;
  proposed: boolean;
  successCriteria: string[];
  title: string;
  wcagTechniques: string[];
}

type ActMapping = {
  "act-rules": ActRule[];
};

/** Data used for test-rules sections, from act-mapping.json */
export const actRules = (
  JSON.parse(await readFile("guidelines/act-mapping.json", "utf8")) as ActMapping
)["act-rules"];

/** Generates version-dependent overrides of SC shortcodes for older versions */
export const generateScSlugOverrides = (version: WcagVersion): Record<string, string> => ({
  ...(version < "22" && {
    "target-size-enhanced": "target-size",
  }),
});

/**
 * Flattened object hash, mapping each WCAG 2 SC slug to the earliest WCAG version it applies to.
 * (Functionally equivalent to "guidelines-versions" target in build.xml; structurally inverted)
 */
async function resolveScVersions(version: WcagVersion) {
  const paths = await glob("*/*.html", { cwd: "understanding" });
  const scSlugOverrides = generateScSlugOverrides(version);
  const map: Record<string, WcagVersion> = {};

  for (const path of paths) {
    const [fileVersion, filename] = path.split(sep);
    assertIsWcagVersion(fileVersion);
    const slug = basename(filename, ".html");
    map[slug in scSlugOverrides ? scSlugOverrides[slug] : slug] = fileVersion;
  }

  return map;
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
  version: "20";
  guidelines: Guideline[];
  type: "Principle";
}

export interface Guideline extends DocNode {
  content: string;
  num: `${Principle["num"]}.${number}`;
  version: "20" | "21";
  successCriteria: SuccessCriterion[];
  type: "Guideline";
}

export interface SuccessCriterion extends DocNode {
  content: string;
  num: `${Guideline["num"]}.${number}`;
  /** Level may be empty for obsolete criteria */
  level: "A" | "AA" | "AAA" | "";
  version: WcagVersion;
  type: "SC";
}

export type WcagItem = Principle | Guideline | SuccessCriterion;

export function isSuccessCriterion(criterion: any): criterion is SuccessCriterion {
  return !!(criterion?.type === "SC" && "level" in criterion);
}

/** Selectors ignored when capturing content of each Principle / Guideline / SC */
const contentIgnores = [
  "h1, h2, h3, h4, h5, h6",
  "section",
  ".change",
  ".conformance-level",
  // Selectors below are specific to pre-published guidelines (for previous versions)
  ".header-wrapper",
  ".doclinks",
];

/**
 * Returns HTML content used for Understanding guideline/SC boxes and term definitions.
 * @param $el Cheerio element of the full section from flattened guidelines/index.html
 */
const getContentHtml = ($el: CheerioAnyNode) => {
  // Load HTML into a new instance, remove elements we don't want, then return the remainder
  const $ = load($el.html()!, null, false);
  $(contentIgnores.join(", ")).remove();
  return $.html().trim();
};

/** Performs processing common across WCAG versions */
async function processPrinciples($: CheerioAPI) {
  // Auto-detect version from end of title
  const version = $("title").text().trim().split(" ").pop()!.replace(".", "");
  assertIsWcagVersion(version);
  const scVersions = await resolveScVersions(version);

  const principles: Principle[] = [];
  $(".principle").each((i, el) => {
    const guidelines: Guideline[] = [];
    $("> .guideline", el).each((j, guidelineEl) => {
      const successCriteria: SuccessCriterion[] = [];
      // Source uses sc class, published uses guideline class (again)
      $("> .guideline, > .sc", guidelineEl).each((k, scEl) => {
        const scId = scEl.attribs.id;
        successCriteria.push({
          content: getContentHtml($(scEl)),
          id: scId,
          name: $("h4", scEl).text().trim(),
          num: `${i + 1}.${j + 1}.${k + 1}`,
          // conformance-level contains only letters in source, full (Level ...) in publish
          level: $("p.conformance-level", scEl)
            .text()
            .trim()
            .replace(/^\(Level (.*)\)$/, "$1") as SuccessCriterion["level"],
          type: "SC",
          version: scVersions[scId],
        });
      });

      guidelines.push({
        content: getContentHtml($(guidelineEl)),
        id: guidelineEl.attribs.id,
        name: $("h3", guidelineEl).text().trim(),
        num: `${i + 1}.${j + 1}`,
        type: "Guideline",
        version: guidelineEl.attribs.id === "input-modalities" ? "21" : "20",
        successCriteria,
      });
    });

    principles.push({
      content: getContentHtml($(el)),
      id: el.attribs.id,
      name: $("h2", el).text().trim(),
      num: `${i + 1}`,
      type: "Principle",
      version: "20",
      guidelines,
    });
  });

  return principles;
}

/**
 * Resolves information from a local guidelines/index.html source file;
 * comparable to the principles section of wcag.xml from the guidelines-xml Ant task.
 */
export const getPrinciples = async (path = "guidelines/index.html") =>
  processPrinciples(await flattenDomFromFile(path));

/**
 * Returns a flattened object hash, mapping shortcodes to each principle/guideline/SC.
 */
export function getFlatGuidelines(principles: Principle[]) {
  const map: Record<string, WcagItem> = {};
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
  /** generated id for use in Understanding pages */
  id: string;
  name: string;
  /** id of dfn in TR, which matches original id in terms file */
  trId: string;
}
export type TermsMap = Record<string, Term>;

function processTermsMap($: CheerioAPI, includeSynonyms = true) {
  const terms: TermsMap = {};

  $("dfn").each((_, el) => {
    const $el = $(el);
    const term: Term = {
      // Note: All applicable <dfn>s have explicit id attributes for TR,
      // but the XSLT process generates id from the element's text which is not always the same
      id: `dfn-${generateId($el.text())}`,
      definition: getContentHtml($el.parent().next()),
      name: $el.text(),
      trId: el.attribs.id,
    };

    if (includeSynonyms) {
      // Include both original and all-lowercase version to simplify lookups
      // (since most synonyms are lowercase) while preserving case in name
      const names = [term.name, term.name.toLowerCase()].concat(
        (el.attribs["data-lt"] || "").toLowerCase().split("|")
      );
      for (const name of names) terms[name] = term;
    } else {
      terms[term.name] = term;
    }
  });

  return terms;
}

/**
 * Resolves term definitions from guidelines/index.html (or a specified alternate path)
 * organized for lookup by name;
 * comparable to the term elements in wcag.xml from the guidelines-xml Ant task.
 */
export const getTermsMap = async (path = "guidelines/index.html") =>
  processTermsMap(await flattenDomFromFile(path), true);

// Version-specific APIs

const guidelinesCache: Partial<Record<WcagVersion, string>> = {};

/** Loads guidelines from TR space for specific version, caching for future calls. */
const loadRemoteGuidelines = async (version: WcagVersion, stripRespec = true) => {
  const html =
    guidelinesCache[version] ||
    (guidelinesCache[version] = await fetchText(`https://www.w3.org/TR/WCAG${version}/`));

  const $ = load(html);

  // Remove extra markup from headings, regardless of stripRespec setting,
  // so that names parse consistently
  $("bdi").remove();

  // Remove role="heading" + aria-level from notes/issues, as they cause more harm than good
  // (especially in context of content reuse via wcag.json export)
  $("[role='note'] .marker").removeAttr("role").removeAttr("aria-level");

  if (!stripRespec) return $;

  // Re-collapse definition links and notes, to be processed by this build system
  $("a.internalDFN").removeAttr("class data-link-type id href title");
  $("[role='note'] .marker").remove();
  $("[role='note']").find("> div, > p").addClass("note").unwrap();

  // Convert data-plurals (present in publications) to data-lt
  $("dfn[data-plurals]").each((_, el) => {
    el.attribs["data-lt"] = (el.attribs["data-lt"] || "")
      .split("|")
      .concat(el.attribs["data-plurals"].split("|"))
      .join("|");
    delete el.attribs["data-plurals"];
  });

  // Un-process bibliography references, to be processed by CustomLiquid
  $("cite:has(a.bibref:only-child)").each((_, el) => {
    const $el = $(el);
    $el.replaceWith(`[${$el.find("a.bibref").html()}]`);
  });

  // Remove generated IDs and markers from examples
  $(".example[id]").removeAttr("id");
  $(".example > .marker").remove();

  // Remove abbr elements which exist only in TR, not in informative docs
  $("#acknowledgements li abbr, #glossary abbr").each((_, abbrEl) => {
    $(abbrEl).replaceWith($(abbrEl).text());
  });

  return $;
};

/**
 * Retrieves heading and content information for acknowledgement subsections,
 * for preserving the section in About pages for earlier versions.
 */
export const getAcknowledgementsForVersion = async (version: WcagVersion) => {
  const $ = await loadRemoteGuidelines(version);
  const subsections: Record<string, string> = {};

  $("section#acknowledgements section").each((_, el) => {
    subsections[el.attribs.id] = $(".header-wrapper + *", el).html()!;
  });

  return subsections;
};

/**
 * Retrieves and processes a pinned WCAG version using published guidelines.
 */
export const getPrinciplesForVersion = async (version: WcagVersion, stripRespec?: boolean) =>
  processPrinciples(await loadRemoteGuidelines(version, stripRespec));

interface GetTermsMapForVersionOptions {
  /**
   * Whether to populate additional map keys based on synonyms defined in data-lt;
   * this should typically be true for informative docs, but may be false for other purposes
   */
  includeSynonyms?: boolean;
  /**
   * Whether to strip respec-generated content and attributes;
   * this should typically be true for informative docs, but may be false for other purposes
   */
  stripRespec?: boolean;
}

/**
 * Resolves term definitions from a WCAG 2.x publication,
 * organized for lookup by name.
 */
export const getTermsMapForVersion = async (
  version: WcagVersion,
  { includeSynonyms, stripRespec }: GetTermsMapForVersionOptions = {}
) => processTermsMap(await loadRemoteGuidelines(version, stripRespec), includeSynonyms);

/** Parses errata items from the errata document for the specified WCAG version. */
export const getErrataForVersion = async (version: WcagVersion) => {
  const $ = await loadFromFile(join("errata", `${version}.html`));
  const $guidelines = await loadRemoteGuidelines(version, false);
  const aSelector = `a[href*='}}#']:first-of-type`;
  const errata: Record<string, string[]> = {};

  $("main > section[id]")
    .first()
    .find(`li:has(${aSelector})`)
    .each((_, el) => {
      const $el = $(el);
      const erratumHtml = $el
        .html()!
        // Remove everything before and including the final TR link
        .replace(/^[\s\S]*href="\{\{\s*\w+\s*\}\}#[\s\S]*?<\/a>,?\s*/, "")
        // Remove parenthetical github references (still in Liquid syntax)
        .replace(/\(\{%.*%\}\)\s*$/, "")
        .replace(/^(\w)/, (_, p1) => p1.toUpperCase());

      $el.find(aSelector).each((_, aEl) => {
        const $aEl = $(aEl);
        let hash: string | undefined = $aEl.attr("href")!.replace(/^.*#/, "");

        // Check whether hash pertains to a guideline/SC section or term definition;
        // if it doesn't, attempt to resolve it to one
        const $hashEl = $guidelines(`#${hash}`);
        if (!$hashEl.is("section.guideline, #terms dfn")) {
          const $closest = $hashEl.closest("#terms dd, section.guideline");
          if ($closest.is("#terms dd")) hash = $closest.prev().find("dfn[id]").attr("id");
          else hash = $closest.attr("id");
        }
        if (!hash) return;

        if (hash in errata) errata[hash].push(erratumHtml);
        else errata[hash] = [erratumHtml];
      });
    });

  return errata;
};
