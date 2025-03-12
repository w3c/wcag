import { load, type CheerioAPI } from "cheerio";
import pick from "lodash-es/pick";
import { mkdirp } from "mkdirp";

import { writeFile } from "fs/promises";
import { join } from "path";

import type { CheerioAnyNode } from "./cheerio";
import { resolveDecimalVersion } from "./common";
import {
  type SuccessCriterion,
  type WcagVersion,
  type WcagItem,
  getPrinciplesForVersion,
  getTermsMapForVersion,
} from "./guidelines";

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
    return $el.html()!.replace(/\n\s+/g, " ").trim();
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

function expandVersions(item: WcagItem) {
  if (item.id === "parsing") return ["20", "21"];

  const versions: string[] = [];
  for (const version of ["20", "21", "22"])
    if (item.version <= version) versions.push(resolveDecimalVersion(version as WcagVersion));
  return versions;
}

export async function generateWcagJson() {
  const principles = await getPrinciplesForVersion("22", false);
  const termsMap = await getTermsMapForVersion("22", {
    includeSynonyms: false,
    stripRespec: false,
  });

  const spreadCommonProps = (item: WcagItem) => {
    const content$ = load(item.content, null, false);
    return {
      ...pick(item, "id", "num", "content"),
      ...(item.type !== "Principle" && { alt_id: item.id in altIds ? [altIds[item.id]] : [] }),
      handle: item.name,
      title: content$("p").first().text().trim().replace(/\s+/g, " "),
      versions: expandVersions(item),
    };
  };

  const data = {
    principles: principles.map((principle) => ({
      ...spreadCommonProps(principle),
      guidelines: principle.guidelines.map((guideline) => ({
        ...spreadCommonProps(guideline),
        successcriteria: guideline.successCriteria.map((sc) => ({
          ...spreadCommonProps(sc),
          level: sc.level,
          details: createDetailsFromSc(sc),
        })),
      })),
    })),
    terms: Object.values(termsMap).map(({ definition, name, trId }) => ({
      id: trId,
      definition: definition,
      name: name,
    })),
  };
  return JSON.stringify(data, null, "  ");
}

// Allow running directly, skipping Eleventy build
if (import.meta.filename === process.argv[1]) {
  await mkdirp("_site");
  await writeFile(join("_site", "wcag.json"), await generateWcagJson());
}
