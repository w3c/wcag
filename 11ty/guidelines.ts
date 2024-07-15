import axios from "axios";
import type { Cheerio, CheerioAPI, Element } from "cheerio";
import { glob } from "glob";

import { readFile } from "fs/promises";
import { basename } from "path";

import { flattenDomFromFile, load } from "./cheerio";
import { generateId } from "./common";

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

/**
 * Flattened object hash, mapping each WCAG 2 SC slug to the earliest WCAG version it applies to.
 * (Functionally equivalent to "guidelines-versions" target in build.xml; structurally inverted)
 */
const scVersions = await (async function () {
  const paths = await glob("*/*.html", { cwd: "understanding" });
  const map: Record<string, WcagVersion> = {};

  for (const path of paths) {
    const [fileVersion, filename] = path.split("/");
    assertIsWcagVersion(fileVersion);
    map[basename(filename, ".html")] = fileVersion;
  }

  return map;
})();

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

export function isSuccessCriterion(criterion: any): criterion is SuccessCriterion {
  return !!(criterion?.type === "SC" && "level" in criterion);
}

/** Version-dependent overrides of SC shortcodes for older versions */
export const scSlugOverrides: Record<string, (version: WcagVersion) => string> = {
  "target-size-enhanced": (version) => (version < "22" ? "target-size" : "target-size-enhanced"),
};

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
const getContentHtml = ($el: Cheerio<Element>) => {
  // Load HTML into a new instance, remove elements we don't want, then return the remainder
  const $ = load($el.html()!, null, false);
  $(contentIgnores.join(", ")).remove();
  return $.html().trim();
};

/** Performs processing common across WCAG versions */
function processPrinciples($: CheerioAPI) {
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
 * Resolves information from guidelines/index.html;
 * comparable to the principles section of wcag.xml from the guidelines-xml Ant task.
 */
export const getPrinciples = async () =>
  processPrinciples(await flattenDomFromFile("guidelines/index.html"));

/**
 * Retrieves and processes a pinned WCAG version using published guidelines.
 */
export const getPrinciplesForVersion = async (version: WcagVersion) => {
  const $ = load(
    (await axios.get(`https://www.w3.org/TR/WCAG${version}/`, { responseType: "text" })).data
  );

  // Re-collapse definition links and notes, to be processed by this build system
  $(".guideline a.internalDFN").removeAttr("class data-link-type id href title");
  $(".guideline [role='note'] .marker").remove();
  $(".guideline [role='note']").find("> div, > p").addClass("note").unwrap();

  // Bibliography references are not processed in Understanding SC boxes
  $(".guideline cite:has(a.bibref:only-child)").each((_, el) => {
    const $el = $(el);
    const $parent = $el.parent();
    $el.remove();
    // Remove surrounding square brackets (which aren't in a dedicated element)
    $parent.html($parent.html()!.replace(/ \[\]/g, ""));
  });

  // Remove extra markup from headings so they can be parsed for names
  $("bdi").remove();

  return processPrinciples($);
};

/**
 * Returns a flattened object hash, mapping shortcodes to each principle/guideline/SC.
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
  /** generated id for use in Understanding pages */
  id: string;
  name: string;
  /** id of dfn in TR, which matches original id in terms file */
  trId: string;
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
      // Note: All applicable <dfn>s have explicit id attributes for TR,
      // but the XSLT process generates id from the element's text which is not always the same
      id: `dfn-${generateId($el.text())}`,
      definition: getContentHtml($el.parent().next()),
      name: $el.text(),
      trId: el.attribs.id,
    };

    // Include both original and all-lowercase version to simplify lookups
    // (since most synonyms are lowercase) while preserving case in name
    const names = [term.name, term.name.toLowerCase()].concat(
      (el.attribs["data-lt"] || "").toLowerCase().split("|")
    );
    for (const name of names) terms[name] = term;
  });

  return terms;
}
