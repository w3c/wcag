import { glob } from "glob";
import matter from "gray-matter";
import capitalize from "lodash-es/capitalize";
import lowerFirst from "lodash-es/lowerFirst";
import uniqBy from "lodash-es/uniqBy";

import { readFile } from "fs/promises";
import { basename, sep } from "path";

import type {
  UnderstandingAssociatedTechniqueArray,
  UnderstandingAssociatedTechniqueGroup,
  UnderstandingAssociatedTechniqueParent,
  UnderstandingAssociatedTechniqueSection,
} from "understanding/understanding";
import eleventyUnderstanding from "understanding/understanding.11tydata";

import { load } from "./cheerio";
import {
  assertIsWcagVersion,
  generateScSlugOverrides,
  isSuccessCriterion,
  type FlatGuidelinesMap,
  type SuccessCriterion,
  type WcagVersion,
} from "./guidelines";
import { wcagSort } from "./common";

/** Maps each technology to its title for index.html */
export const technologyTitles = {
  aria: "ARIA Techniques",
  "client-side-script": "Client-Side Script Techniques",
  css: "CSS Techniques",
  failures: "Common Failures",
  flash: "Flash Techniques", // Deprecated in 2020
  general: "General Techniques",
  html: "HTML Techniques",
  pdf: "PDF Techniques",
  "server-side-script": "Server-Side Script Techniques",
  smil: "SMIL Techniques",
  silverlight: "Silverlight Techniques", // Deprecated in 2020
  text: "Plain-Text Techniques",
};
export type Technology = keyof typeof technologyTitles;
export const technologies = Object.keys(technologyTitles) as Technology[];

function assertIsTechnology(
  technology: string
): asserts technology is keyof typeof technologyTitles {
  if (!(technology in technologyTitles)) throw new Error(`Invalid technology name: ${technology}`);
}

/**
 * Returns boolean indicating whether a technique is obsolete for the given version.
 * Tolerates undefined for use with hash lookups.
 */
export const isTechniqueObsolete = (technique: Technique | undefined, version: WcagVersion) =>
  !!technique?.obsoleteSince && technique.obsoleteSince <= version;

export const techniqueAssociationTypes = ["sufficient", "advisory", "failure"] as const;
export type TechniqueAssociationType = (typeof techniqueAssociationTypes)[number];

interface TechniqueAssociation {
  criterion: SuccessCriterion;
  type: Capitalize<TechniqueAssociationType>;
  /** Indicates this technique must be paired with specific "child" techniques to fulfill SC */
  hasUsageChildren: boolean;
  /**
   * Technique ID of "parent" technique(s) this is paired with to fulfill SC.
   * This is typically 0 or 1 technique, but may be multiple in rare cases.
   */
  usageParentIds: string[];
  /**
   * Text description of "parent" association, if it does not reference a specific technique;
   * only populated if usageParentIds is empty.
   */
  usageParentDescription: string;
  /** Technique IDs this technique must be implemented with to fulfill SC, if any */
  with: string[];
}

/**
 * Pulls the basename out of a technique link href.
 * This intentionally returns empty string (falsy) if a directory link happens to be passed.
 */
export const resolveTechniqueIdFromHref = (href: string) =>
  href.replace(/^.*\//, "").replace(/\.html$/, "");

/**
 * Selector that can detect relative and absolute technique links from understanding docs
 */
export const understandingToTechniqueLinkSelector = [
  "[href^='../Techniques/' i]",
  "[href^='../../techniques/' i]",
  "[href^='https://www.w3.org/WAI/WCAG' i][href*='/Techniques/' i]",
]
  .map((value) => `a${value}`)
  .join(", ") as "a";

/**
 * Given a shorthand string of either a technique ID or title,
 * expands to an object with either the id or title property defined.
 */
export function expandTechniqueToObject<O>(idOrTitle: string | O) {
  if (typeof idOrTitle !== "string") return idOrTitle; // Already expanded
  if (/^[A-Z]+\d+$/.test(idOrTitle)) return { id: idOrTitle as string };
  return { title: idOrTitle as string };
}

/** Convenience function used to report validation errors */
function throwCriterionError(criterion: SuccessCriterion, description: string): never {
  throw new Error(`Associated techniques for ${criterion.id} contains ${description}`);
}

/**
 * Returns object mapping technique IDs to SCs that reference it,
 * essentially inverting understanding.11tydata.js.
 */
export async function getTechniqueAssociations(
  guidelines: FlatGuidelinesMap,
  version: WcagVersion
) {
  const associations: Record<string, TechniqueAssociation[]> = {};
  const associatedTechniques = eleventyUnderstanding({}).associatedTechniques;
  const scOverrides = generateScSlugOverrides(version);

  function addAssociation(id: string, association: TechniqueAssociation) {
    if (!(id in associations)) associations[id] = [association];
    else associations[id].push(association);
  }

  interface TraverseContext {
    groups?: UnderstandingAssociatedTechniqueGroup[];
    parent?: UnderstandingAssociatedTechniqueParent;
  }
  /** Traverses one level of techniques; called recursively for `using`. */
  function traverse(
    techniques: UnderstandingAssociatedTechniqueArray,
    criterion: SuccessCriterion,
    type: TechniqueAssociationType,
    { groups, parent }: TraverseContext = {}
  ) {
    if (techniques.length < 1) throwCriterionError(criterion, "an empty array of techniques");

    function resolveParentIds() {
      if (!parent) return [];
      if ("and" in parent)
        return parent.and.reduce((ids, techniqueOrString) => {
          const technique = expandTechniqueToObject(techniqueOrString);
          if (technique.id) ids.push(technique.id);
          return ids;
        }, [] as string[]);
      return parent.id ? [parent.id] : [];
    }

    function resolveParentDescription() {
      if (groups) return "using a more specific technique"; // Groups imply "using"

      if (!parent || !parent.using) return "";
      const { usingQuantity } = parent;
      const isSingular = !usingQuantity || usingQuantity === "one";

      if (isSingular) {
        if ("title" in parent && parent.title)
          return `when used for ${lowerFirst(parent.title.trim())}`;
        else if ("and" in parent) {
          const description = parent.and.reduce((description, technique) => {
            const { title } = expandTechniqueToObject(technique);
            if (title)
              return `${description ? `${description} and ` : ""}${lowerFirst(title.trim())}`;
            return description;
          }, "");
          return `when used for ${description}`;
        }
      }
      return "when combined with other techniques";
    }

    const usageParentIds = resolveParentIds();
    const commonAssociationData = {
      criterion,
      type: capitalize(type) as Capitalize<TechniqueAssociationType>,
      hasUsageChildren: false,
      usageParentIds,
      usageParentDescription: usageParentIds.length ? "" : resolveParentDescription(),
    } satisfies Partial<TechniqueAssociation>;

    for (const techniqueOrString of techniques) {
      const technique = expandTechniqueToObject(techniqueOrString);
      if ("groups" in technique)
        throwCriterionError(
          criterion,
          "`groups` in unexpected context (only valid in top-level sections)"
        );

      if ("and" in technique) {
        if (technique.and.length < 2)
          throwCriterionError(criterion, "`and` with less than 2 entries");
        for (const andEntry of technique.and) {
          const expandedEntry = expandTechniqueToObject(andEntry);
          if ("and" in expandedEntry || "using" in expandedEntry)
            throwCriterionError(
              criterion,
              "invalid nested structure under `and` (cannot contain `and` or `using`)"
            );
          if (!expandedEntry.id || !isSuccessCriterion(criterion)) continue;
          addAssociation(expandedEntry.id, {
            ...commonAssociationData,
            hasUsageChildren: "using" in technique,
            with: technique.and.reduce((ids, entry) => {
              if (entry === andEntry) return ids;
              const expandedEntry = expandTechniqueToObject(entry);
              if (expandedEntry.id) ids.push(expandedEntry.id);
              return ids;
            }, [] as string[]),
          });
        }
      } else if (technique.id) {
        addAssociation(technique.id, {
          ...commonAssociationData,
          hasUsageChildren: "using" in technique,
          with: [],
        });
      }

      if ("using" in technique) traverse(technique.using, criterion, type, { parent: technique });
      else if (Object.keys(technique).some((key) => key.startsWith("using")))
        throwCriterionError(criterion, "a using-related key but no `using` array");
    }
  }

  for (const id of Object.keys(associatedTechniques)) {
    const criterion = guidelines[scOverrides[id] || id];
    if (!criterion || !isSuccessCriterion(criterion)) continue; // Skip SCs not present in the version being processed
    const association = associatedTechniques[id];

    if (
      !("sufficient" in association) &&
      Object.keys(association).some((key) => key.startsWith("sufficient"))
    ) {
      throwCriterionError(criterion, "sufficient-related key but no `sufficient` array");
    }

    for (const type of techniqueAssociationTypes) {
      if (!(type in association)) continue;
      const topLevelEntries = association[type];
      if (!topLevelEntries?.length)
        throwCriterionError(criterion, `empty \`${type}\` array; either add items, or omit it`);

      const sectionCount = topLevelEntries.filter(
        (entry) => typeof entry !== "string" && "techniques" in entry
      ).length;
      if (sectionCount !== 0 && sectionCount !== topLevelEntries.length)
        throwCriterionError(criterion, "a mix of top-level sections and techniques");

      if (sectionCount)
        for (const section of topLevelEntries as UnderstandingAssociatedTechniqueSection[]) {
          if ("groups" in section && section.groups) {
            if (section.techniques.some((t) => typeof t !== "string" && "using" in t))
              throwCriterionError(
                criterion,
                "`using` in the context of a section with groups; the latter already implies the former"
              );
            traverse(section.techniques, criterion, type, { groups: section.groups });
            for (const group of section.groups) traverse(group.techniques, criterion, type);
          } else {
            traverse(section.techniques, criterion, type);
          }
        }
      else traverse(topLevelEntries as UnderstandingAssociatedTechniqueArray, criterion, type);
    }
  }

  // Remove duplicates (due to similar shape across understanding docs) and sort by SC number
  for (const [key, list] of Object.entries(associations)) {
    const deduplicatedList = uniqBy(list, (v) => JSON.stringify(v)).sort((a, b) =>
      wcagSort(a.criterion, b.criterion)
    );
    // Remove entries that are redundant of a more generalized preceding entry
    for (let i = 1; i < deduplicatedList.length; i++) {
      const previousEntry = deduplicatedList[i - 1];
      const entry = deduplicatedList[i];
      if (
        entry.criterion.id === previousEntry.criterion.id &&
        entry.type === previousEntry.type &&
        !previousEntry.hasUsageChildren &&
        !previousEntry.usageParentDescription &&
        !previousEntry.usageParentIds.length &&
        !previousEntry.with.length
      ) {
        deduplicatedList.splice(i, 1);
        i--; // Next item is now in this index; repeat processing it
      }
    }
    associations[key] = deduplicatedList;
  }

  return associations;
}

interface TechniqueFrontMatter {
  /** May be specified via front-matter; message to display RE a technique's obsolescence. */
  obsoleteMessage?: string;
  /** May be specified via front-matter to indicate a technique is obsolete as of this version. */
  obsoleteSince?: WcagVersion;
}

export interface Technique extends TechniqueFrontMatter {
  /** Letter(s)-then-number technique code; corresponds to source HTML filename */
  id: string;
  /** Technology this technique is filed under */
  technology: Technology;
  /** Title derived from each technique page's h1 */
  title: string;
  /** Title derived from each technique page's h1, with HTML preserved */
  titleHtml: string;
  /**
   * Like title, but preserving the XSLT process behavior of truncating
   * text on intermediate lines between the first and last for long headings.
   * (This was probably accidental, but helps avoid long link text.)
   */
  truncatedTitle: string;
}

/**
 * Returns an object mapping each technology category to an array of Techniques.
 * Used to generate index table of contents.
 * (Functionally equivalent to "techniques-list" target in build.xml)
 */
export async function getTechniquesByTechnology(guidelines: FlatGuidelinesMap) {
  const paths = await glob("*/*.html", { cwd: "techniques" });
  const techniques = technologies.reduce(
    (map, technology) => ({
      ...map,
      [technology]: [] as string[],
    }),
    {} as Record<Technology, Technique[]>
  );
  const scNumbers = Object.values(guidelines)
    .filter((entry): entry is SuccessCriterion => entry.type === "SC")
    .map(({ num }) => num);

  // Check directory data files (we don't have direct access to 11ty's data cascade here)
  const technologyData: Partial<Record<Technology, any>> = {};
  for (const technology of technologies) {
    try {
      const data = JSON.parse(
        await readFile(`techniques/${technology}/${technology}.11tydata.json`, "utf8")
      );
      if (data) technologyData[technology] = data;
    } catch {}
  }

  for (const path of paths) {
    const [technology, filename] = path.split(sep);
    assertIsTechnology(technology);
    // Support front-matter within HTML files
    const { content, data: frontMatterData } = matter(await readFile(`techniques/${path}`, "utf8"));
    const data = { ...technologyData[technology], ...frontMatterData };

    if (data.obsoleteSince) {
      data.obsoleteSince = "" + data.obsoleteSince;
      assertIsWcagVersion(data.obsoleteSince);
    }

    // Isolate h1 from each file before feeding into Cheerio to save ~300ms total
    const h1Match = content.match(/<h1[^>]*>([\s\S]+?)<\/h1>/);
    if (!h1Match || !h1Match[1]) throw new Error(`No h1 found in techniques/${path}`);
    const $h1 = load(h1Match[1], null, false);

    let title = $h1.text();
    let titleHtml = $h1.html();
    if (process.env.WCAG_VERSION) {
      // Check for invalid SC references for the WCAG version being built
      const multiScPattern = /(?:\d\.\d+\.\d+(,?) )+and \d\.\d+\.\d+/;
      if (multiScPattern.test(title)) {
        const scPattern = /\d\.\d+\.\d+/g;
        const criteria: typeof scNumbers = [];
        let match;
        while ((match = scPattern.exec(title)))
          criteria.push(match[0] as `${number}.${number}.${number}`);
        const filteredCriteria = criteria.filter((sc) => scNumbers.includes(sc));
        if (filteredCriteria.length) {
          const finalSeparator =
            filteredCriteria.length > 2 && multiScPattern.exec(title)?.[1] ? "," : "";
          const replacement = `${filteredCriteria.slice(0, -1).join(", ")}${finalSeparator} and ${
            filteredCriteria[filteredCriteria.length - 1]
          }`;
          title = title.replace(multiScPattern, replacement);
          titleHtml = titleHtml.replace(multiScPattern, replacement);
        }
        // If all SCs were filtered out, do nothing - should be pruned when associations are checked
      }
    }

    techniques[technology].push({
      ...data, // Include front-matter
      id: basename(filename, ".html"),
      technology,
      title,
      titleHtml,
      truncatedTitle: title.trim().replace(/\s*\n[\s\S]*\n\s*/, " … "),
    });
  }

  for (const technology of technologies) {
    techniques[technology].sort((a, b) => {
      const aId = +a.id.replace(/\D/g, "");
      const bId = +b.id.replace(/\D/g, "");
      if (aId < bId) return -1;
      if (aId > bId) return 1;
      return 0;
    });
  }

  return techniques;
}

/**
 * Returns a flattened object hash, mapping each technique ID directly to its data.
 */
export const getFlatTechniques = (
  techniques: Awaited<ReturnType<typeof getTechniquesByTechnology>>
) =>
  Object.values(techniques)
    .flat()
    .reduce(
      (map, technique) => {
        map[technique.id] = technique;
        return map;
      },
      {} as Record<string, Technique>
    );
