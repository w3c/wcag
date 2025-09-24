import { load, type CheerioAPI } from "cheerio";
import invert from "lodash-es/invert";
import pick from "lodash-es/pick";

import { writeFile } from "fs/promises";
import { join } from "path";

import type {
  ResolvedUnderstandingAssociatedTechnique,
  UnderstandingAssociatedTechniqueArray,
  UnderstandingAssociatedTechniqueEntry,
  UnderstandingAssociatedTechniqueParent,
  UnderstandingAssociatedTechniqueSection,
} from "understanding/understanding";
import eleventyUnderstanding from "understanding/understanding.11tydata";

import { type CheerioAnyNode } from "../cheerio";
import { resolveDecimalVersion } from "../common";
import {
  type SuccessCriterion,
  type WcagVersion,
  type WcagItem,
  getPrinciplesForVersion,
  getTermsMapForVersion,
  assertIsWcagVersion,
  getFlatGuidelines,
  generateScSlugOverrides,
} from "../guidelines";
import {
  expandTechniqueToObject,
  getFlatTechniques,
  getTechniquesByTechnology,
  techniqueAssociationTypes,
  type Technique,
  type TechniqueAssociationType,
  type Technology,
} from "../techniques";

const removeNewlines = (str: string) => str.trim().replace(/\n\s+/g, " ");

const altIds: Record<string, string> = {
  "text-alternatives": "text-equiv",
  "non-text-content": "text-equiv-all",
  "time-based-media": "media-equiv",
  "audio-only-and-video-only-prerecorded": "media-equiv-av-only-alt",
  "captions-prerecorded": "media-equiv-captions",
  "audio-description-or-media-alternative-prerecorded": "media-equiv-audio-desc",
  "captions-live": "media-equiv-real-time-captions",
  "audio-description-prerecorded": "media-equiv-audio-desc-only",
  "sign-language-prerecorded": "media-equiv-sign",
  "extended-audio-description-prerecorded": "media-equiv-extended-ad",
  "media-alternative-prerecorded": "media-equiv-text-doc",
  "audio-only-live": "media-equiv-live-audio-only",
  adaptable: "content-structure-separation",
  "info-and-relationships": "content-structure-separation-programmatic",
  "meaningful-sequence": "content-structure-separation-sequence",
  "sensory-characteristics": "content-structure-separation-understanding",
  distinguishable: "visual-audio-contrast",
  "use-of-color": "visual-audio-contrast-without-color",
  "audio-control": "visual-audio-contrast-dis-audio",
  "contrast-minimum": "visual-audio-contrast-contrast",
  "resize-text": "visual-audio-contrast-scale",
  "images-of-text": "visual-audio-contrast-text-presentation",
  "contrast-enhanced": "visual-audio-contrast7",
  "low-or-no-background-audio": "visual-audio-contrast-noaudio",
  "visual-presentation": "visual-audio-contrast-visual-presentation",
  "images-of-text-no-exception": "visual-audio-contrast-text-images",
  operable: "operable",
  "keyboard-accessible": "keyboard-operation",
  keyboard: "keyboard-operation-keyboard-operable",
  "no-keyboard-trap": "keyboard-operation-trapping",
  "keyboard-no-exception": "keyboard-operation-all-funcs",
  "enough-time": "time-limits",
  "timing-adjustable": "time-limits-required-behaviors",
  "pause-stop-hide": "time-limits-pause",
  "no-timing": "time-limits-no-exceptions",
  interruptions: "time-limits-postponed",
  "re-authenticating": "time-limits-server-timeout",
  seizures: "seizure",
  "three-flashes-or-below-threshold": "seizure-does-not-violate",
  "three-flashes": "seizure-three-times",
  navigable: "navigation-mechanisms",
  "bypass-blocks": "navigation-mechanisms-skip",
  "page-titled": "navigation-mechanisms-title",
  "focus-order": "navigation-mechanisms-focus-order",
  "link-purpose-in-context": "navigation-mechanisms-refs",
  "multiple-ways": "navigation-mechanisms-mult-loc",
  "headings-and-labels": "navigation-mechanisms-descriptive",
  "focus-visible": "navigation-mechanisms-focus-visible",
  location: "navigation-mechanisms-location",
  "link-purpose-link-only": "navigation-mechanisms-link",
  "section-headings": "navigation-mechanisms-headings",
  understandable: "understandable",
  readable: "meaning",
  "language-of-page": "meaning-doc-lang-id",
  "language-of-parts": "meaning-other-lang-id",
  "unusual-words": "meaning-idioms",
  abbreviations: "meaning-located",
  "reading-level": "meaning-supplements",
  pronunciation: "meaning-pronunciation",
  predictable: "consistent-behavior",
  "on-focus": "consistent-behavior-receive-focus",
  "on-input": "consistent-behavior-unpredictable-change",
  "consistent-navigation": "consistent-behavior-consistent-locations",
  "consistent-identification": "consistent-behavior-consistent-functionality",
  "change-on-request": "consistent-behavior-no-extreme-changes-context",
  "input-assistance": "minimize-error",
  "error-identification": "minimize-error-identified",
  "labels-or-instructions": "minimize-error-cues",
  "error-suggestion": "minimize-error-suggestions",
  "error-prevention-legal-financial-data": "minimize-error-reversible",
  help: "minimize-error-context-help",
  "error-prevention-all": "minimize-error-reversible-all",
  robust: "robust",
  compatible: "ensure-compat",
  parsing: "ensure-compat-parses",
  "name-role-value": "ensure-compat-rsv",
};

interface DetailItem {
  text: string;
}
interface DetailItemWithHandle extends DetailItem {
  handle: string;
}

interface NoteDetail extends DetailItemWithHandle {
  type: "note";
}
interface ParagraphDetail extends DetailItem {
  type: "p";
}
interface UlistDetail {
  items: DetailItem[] | DetailItemWithHandle[];
  type: "ulist";
}

type Details = (NoteDetail | ParagraphDetail | UlistDetail)[];

function createDetailsFromSc(sc: SuccessCriterion) {
  const details: Details = [];
  const $ = load(`<section>${sc.content}</section>`, null, false);

  function cleanText($el: CheerioAnyNode) {
    $el.find("a").each((_, el) => {
      const $el = $(el);
      $el.replaceWith($el.text());
    });
    return removeNewlines($el.html()!);
  }

  // Note handling is in a reusable function to handle 1.4.7 edge case inside dd
  const createNoteDetail = ($el: CheerioAnyNode) => ({
    type: "note" as const,
    handle: $el.find(".note-title").text(),
    text: cleanText($el.find(".note-title + *")),
  });

  // Skip first paragraph of content, reflected in title field
  $("section > *:not(p:first-child)").each((_, el) => {
    const $el = $(el);
    if ($el.hasClass("note")) {
      details.push(createNoteDetail($el));
    } else if (el.tagName === "p") {
      details.push({
        type: "p",
        text: cleanText($el),
      });
    } else if (el.tagName === "dl") {
      // WCAG SCs only ever have one dt per dd and vice versa
      const items: DetailItemWithHandle[] = [];
      const nestedNotes: NoteDetail[] = [];
      const $dts = $el.children("dt");
      const $dds = $el.children("dd");
      if ($dts.length !== $dds.length) throw new Error("Unexpected non-1:1 definition list");
      for (let i = 0; i < $dts.length; i++) {
        const $dd = $dds.eq(i);
        // Remove parent paragraph when it is the only top-level element
        $dd.find(`dd > p:only-child`).each((_, el) => {
          const $el = $(el);
          $el.replaceWith($el.html()!);
        });
        // Push any nested notes (e.g. in 1.4.7) after the dl rather than merging or losing it
        $dd.children(".note").each((_, noteEl) => {
          const $noteEl = $(noteEl);
          nestedNotes.push(createNoteDetail($noteEl));
          $noteEl.remove();
        });
        // ...and remove the surrounding p element if it is now the only one
        // (quickref already wraps each definition in p)
        $dd.children("p:only-child").each((_, pEl) => {
          const $pEl = $(pEl);
          $pEl.replaceWith($pEl.html()!);
        });
        items.push({
          handle: cleanText($dts.eq(i)),
          text: cleanText($dd),
        });
      }
      details.push({ type: "ulist", items });
      for (const note of nestedNotes) details.push(note);
    } else if (el.tagName === "ul") {
      details.push({
        type: `ulist`,
        items: $el
          .children("li")
          .toArray()
          .map((el) => ({ text: cleanText($(el)) })),
      });
    }
  });
  return details;
}

interface SerializedTechniqueAssociation {
  id?: string;
  technology?: Technology;
  title: string;
  prefix?: string;
  suffix?: string;
  using?: SerializedTechniqueAssociationArray;
}

interface SerializedTechniqueConjunction {
  and: SerializedTechniqueAssociation[];
  using?: SerializedTechniqueAssociationArray;
}

type SerializedTechniqueAssociationArray = Array<
  SerializedTechniqueAssociation | SerializedTechniqueConjunction
>;

type SerializedTechniqueSection = {
  title: string;
  groups?: {
    id: string;
    title: string;
    techniques: SerializedTechniqueAssociationArray;
  }[];
  note?: string;
  techniques: SerializedTechniqueAssociationArray;
};

interface SerializedTechniques
  extends Partial<
    Record<
      TechniqueAssociationType,
      SerializedTechniqueAssociationArray | SerializedTechniqueSection[]
    >
  > {
  sufficientNote?: string;
}

/**
 * Converts a technique's using properties to their string representation.
 * This is not reused by the techniques-list template due to differing requirements
 * (the template operates within HTML context and also handles groups).
 */
function stringifyUsingProps(technique: UnderstandingAssociatedTechniqueParent) {
  const { usingConjunction = "using", usingQuantity = "one", usingPrefix } = technique;
  const quantityStr = usingQuantity ? `${usingQuantity} of ` : "";
  return `${usingPrefix ? `${usingPrefix} ` : ""}${usingConjunction} ${quantityStr}the following techniques:`;
}

/** Removes links; intended for use with notes (consistent with previous JSON output) */
const cleanLinks = (html: string) => html.replace(/<a[^>]*>([^<]*)<\/a>/g, "$1");

/** Resolves relative links against the base folder for the WCAG version */
const resolveLinks = (html: string, version: WcagVersion) =>
  html.replace(/href="([^"]*)"/g, (match, href: string) => {
    if (/^https?:/.test(href)) return match;
    const domain = `https://www.w3.org`;
    const baseUrl = `${domain}/WAI/WCAG${version}/Understanding/`;
    if (href.startsWith("/")) return `href="${domain}${href}"`;
    return `href="${baseUrl}${href}"`;
  });

const associatedTechniques = eleventyUnderstanding({}).associatedTechniques;
function createTechniquesFromSc(
  sc: SuccessCriterion,
  techniquesMap: Record<string, Technique>,
  version: WcagVersion
) {
  if (sc.level === "") return {}; // Do not emit techniques for obsolete SC (e.g. 4.1.1)

  // Since SCs are already remapped for previous versions before calling this function,
  // we need to be able to map back to the present to resolve keys in understanding.11tydata.ts
  const scSlugMappings = invert(generateScSlugOverrides(version));

  const scId = scSlugMappings[sc.id] || sc.id;
  const associations = associatedTechniques[scId];
  if (!associations) throw new Error(`No associatedTechniques found for ${scId}`);
  const techniques: SerializedTechniques = {};

  function resolveAssociatedTechniqueTitle(
    technique: ResolvedUnderstandingAssociatedTechnique,
    hasGroups?: boolean
  ) {
    const usingContent =
      (hasGroups && "using one technique from each group outlined below") ||
      ("using" in technique && !technique.skipUsingPhrase && stringifyUsingProps(technique));

    if ("id" in technique && technique.id)
      return {
        title: removeNewlines(techniquesMap[technique.id].title),
        ...(usingContent && { suffix: usingContent }),
      };

    if ("title" in technique && technique.title)
      return {
        title: resolveLinks(removeNewlines(technique.title), version),
        ...(usingContent && { suffix: usingContent }),
      };

    if (usingContent) return { title: usingContent };
    return null;
  }

  function mapAssociatedTechniques(
    techniques: Array<string | UnderstandingAssociatedTechniqueEntry>
  ): SerializedTechniqueAssociation[];
  function mapAssociatedTechniques(
    techniques: UnderstandingAssociatedTechniqueArray,
    hasGroups?: boolean
  ): SerializedTechniqueAssociationArray;
  function mapAssociatedTechniques(
    techniques:
      | Array<string | UnderstandingAssociatedTechniqueEntry>
      | UnderstandingAssociatedTechniqueArray,
    hasGroups?: boolean
  ) {
    return techniques.map((t) => {
      const technique = expandTechniqueToObject(t);
      if ("and" in technique) {
        return {
          and: mapAssociatedTechniques(technique.and.map(expandTechniqueToObject)),
          ...("using" in technique &&
            technique.using && { using: mapAssociatedTechniques(technique.using) }),
        };
      }

      const id = technique.id;
      const titleProps = resolveAssociatedTechniqueTitle(technique, hasGroups);
      if (!titleProps)
        throw new Error(
          "Couldn't resolve title for associated technique under " +
            `${scId}: ${JSON.stringify(technique)}`
        );

      return {
        ...(id && {
          id,
          technology: techniquesMap[id].technology,
        }),
        ...titleProps,
        ...("prefix" in technique && technique.prefix && { prefix: technique.prefix }),
        ...("suffix" in technique && technique.suffix && { suffix: technique.suffix }),
        ...("using" in technique && { using: mapAssociatedTechniques(technique.using) }),
      };
    });
  }

  for (const type of techniqueAssociationTypes) {
    const associationsOfType = associations[type];
    if (!associationsOfType) continue;

    if (typeof associationsOfType[0] !== "string" && "techniques" in associationsOfType[0]) {
      techniques[type] = [];
      for (const section of associationsOfType as UnderstandingAssociatedTechniqueSection[]) {
        techniques[type]!.push({
          title: section.title,
          techniques: mapAssociatedTechniques(section.techniques, "groups" in section),
          ...("groups" in section &&
            section.groups && {
              groups: section.groups.map((group) => ({
                id: group.id,
                title: group.title,
                techniques: mapAssociatedTechniques(group.techniques),
              })),
            }),
          ...(section.note && { note: cleanLinks(section.note) }),
        } satisfies SerializedTechniqueSection);
      }
    } else {
      techniques[type] = mapAssociatedTechniques(
        associationsOfType as UnderstandingAssociatedTechniqueArray
      );
    }

    if (type === "sufficient" && "sufficientNote" in associations && associations.sufficientNote) {
      // Copy sufficient note, with any definitions unlinked
      techniques.sufficientNote = cleanLinks(removeNewlines(associations.sufficientNote));
    }
  }

  return techniques;
}

function expandVersions(item: WcagItem, maxVersion: WcagVersion) {
  const versions: WcagVersion[] = (["20", "21", "22"] as const).filter((v) => v <= maxVersion);
  return (
    item.id === "parsing"
      ? versions.filter((v) => v <= "21")
      : versions.filter((v) => item.version <= v)
  ).map((v) => resolveDecimalVersion(v as WcagVersion));
}

export async function generateWcagJson(version: WcagVersion) {
  const principles = await getPrinciplesForVersion(version, false);
  const termsMap = await getTermsMapForVersion(version, {
    includeSynonyms: false,
    stripRespec: false,
  });
  const techniquesMap = getFlatTechniques(
    await getTechniquesByTechnology(getFlatGuidelines(principles))
  );

  function cleanLinks($: CheerioAPI) {
    $("a[href]").each((_, aEl) => {
      const href = aEl.attribs.href;
      if (/^(?:https?:\/)?\//.test(href)) return;
      $(aEl)
        // Make href absolute
        .attr("href", `https://www.w3.org/TR/WCAG${version}/${aEl.attribs.href}`)
        // Remove attributes specific to source document
        .removeAttr("id class data-link-type");
    });
  }

  const spreadCommonProps = (item: WcagItem) => {
    const $ = load(item.content, null, false);
    cleanLinks($);
    return {
      ...pick(item, "id", "num"),
      ...(item.type !== "Principle" && { alt_id: item.id in altIds ? [altIds[item.id]] : [] }),
      content: $.html(),
      handle: item.name,
      title: $("p").first().text().trim().replace(/\s+/g, " "),
      versions: expandVersions(item, version),
    };
  };

  const data = {
    principles: await Promise.all(
      principles.map(async (principle) => ({
        ...spreadCommonProps(principle),
        guidelines: await Promise.all(
          principle.guidelines.map(async (guideline) => ({
            ...spreadCommonProps(guideline),
            successcriteria: await Promise.all(
              guideline.successCriteria.map(async (sc) => ({
                ...spreadCommonProps(sc),
                level: sc.level,
                details: createDetailsFromSc(sc),
                techniques: createTechniquesFromSc(sc, techniquesMap, version),
              }))
            ),
          }))
        ),
      }))
    ),
    terms: Object.values(termsMap).map(({ definition, name, trId }) => {
      const $ = load(definition, null, false);
      cleanLinks($);
      return {
        id: trId,
        definition: $.html(),
        name: name,
      };
    }),
  };
  return JSON.stringify(data, null, "  ");
}

// Allow running directly, skipping Eleventy build
if (import.meta.filename === process.argv[1]) {
  const version = process.env.WCAG_VERSION || "22";
  assertIsWcagVersion(version);
  console.log(`Generating wcag.json for version ${resolveDecimalVersion(version)}`);
  await writeFile(join("_site", "wcag.json"), await generateWcagJson(version));
}
