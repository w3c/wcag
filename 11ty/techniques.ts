import type { Cheerio } from "cheerio";
import { glob } from "glob";
import matter from "gray-matter";
import capitalize from "lodash-es/capitalize";
import uniqBy from "lodash-es/uniqBy";

import { readFile } from "fs/promises";
import { basename } from "path";

import { load, loadFromFile } from "./cheerio";
import {
  assertIsWcagVersion,
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

const associationTypes = ["sufficient", "advisory", "failure"] as const;
type AssociationType = (typeof associationTypes)[number];

interface TechniqueAssociation {
  criterion: SuccessCriterion;
  type: Capitalize<AssociationType>;
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

function assertIsAssociationType(type?: string): asserts type is AssociationType {
  if (!associationTypes.includes(type as AssociationType))
    throw new Error(`Association processed for unexpected section ${type}`);
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
 * Returns object mapping technique IDs to SCs that reference it;
 * comparable to technique-associations.xml but in a more ergonomic format.
 */
export async function getTechniqueAssociations(guidelines: FlatGuidelinesMap) {
  const associations: Record<string, TechniqueAssociation[]> = {};
  const itemSelector = associationTypes.map((type) => `section#${type} li`).join(", ");

  const paths = await glob("understanding/*/*.html");
  for (const path of paths) {
    const criterion = guidelines[basename(path, ".html")];
    if (!isSuccessCriterion(criterion)) continue;

    const $ = await loadFromFile(path);
    $(itemSelector).each((_, liEl) => {
      const $liEl = $(liEl);
      const $parentListItem = $liEl.closest("ul, ol").closest("li");
      // Identify which expected section the list was found under
      const associationType = $liEl
        .closest(associationTypes.map((type) => `section#${type}`).join(", "))
        .attr("id");
      assertIsAssociationType(associationType);

      /** Finds matches only within the given list item (not under child lists) */
      const queryNonNestedChildren = ($el: Cheerio<any>, selector: string) =>
        $el.find(selector).filter((_, aEl) => $(aEl).closest("li")[0] === $el[0]);

      const $techniqueLinks = queryNonNestedChildren($liEl, understandingToTechniqueLinkSelector);
      $techniqueLinks.each((_, aEl) => {
        const usageParentIds = queryNonNestedChildren(
          $parentListItem,
          understandingToTechniqueLinkSelector
        )
          .toArray()
          .map((el) => resolveTechniqueIdFromHref(el.attribs.href));

        // Capture the "X" in "X or more" phrasing, to include a phrase about
        // combining with other techniques if more than one is required.
        const descriptionDependencyPattern =
          /(?:^|,?\s+)(?:by )?using\s+(?:(\w+) (?:or more )?of )?the\s+(?:following )?techniques(?: below)?(?::|\.)?\s*$/i;
        const parentHtml = usageParentIds.length
          ? null
          : queryNonNestedChildren($parentListItem, "p").html();
        const match = parentHtml && descriptionDependencyPattern.exec(parentHtml);
        const parentDescription = parentHtml
          ? parentHtml.replace(
              descriptionDependencyPattern,
              !match?.[1] || match?.[1] === "one" ? "" : "when combined with other techniques"
            )
          : "";
        const usageParentDescription =
          parentDescription &&
          (parentDescription.startsWith("when")
            ? parentDescription
            : `when used for ${parentDescription[0].toLowerCase()}${parentDescription.slice(1)}`);

        const association: TechniqueAssociation = {
          criterion,
          type: capitalize(associationType) as Capitalize<AssociationType>,
          hasUsageChildren: !!$liEl.find("ul, ol").length,
          usageParentIds,
          usageParentDescription,
          with: $techniqueLinks
            .toArray()
            .filter((el) => el !== aEl)
            .map((el) => resolveTechniqueIdFromHref(el.attribs.href)),
        };

        const id = resolveTechniqueIdFromHref(aEl.attribs.href);
        if (!(id in associations)) associations[id] = [association];
        else associations[id].push(association);
      });
    });
  }

  // Remove duplicates (due to similar shape across understanding docs) and sort by SC number
  for (const [key, list] of Object.entries(associations))
    associations[key] = uniqBy(list, (v) => JSON.stringify(v)).sort((a, b) =>
      wcagSort(a.criterion, b.criterion)
    );

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
export async function getTechniquesByTechnology() {
  const paths = await glob("*/*.html", { cwd: "techniques" });
  const techniques = technologies.reduce(
    (map, technology) => ({
      ...map,
      [technology]: [] as string[],
    }),
    {} as Record<Technology, Technique[]>
  );

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
    const [technology, filename] = path.split("/");
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

    const title = $h1.text();
    techniques[technology].push({
      ...data, // Include front-matter
      id: basename(filename, ".html"),
      technology,
      title,
      titleHtml: $h1.html(),
      truncatedTitle: title.replace(/\s*\n[\s\S]*\n\s*/, " … "),
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
