import { load, type CheerioAPI } from "cheerio";
import pick from "lodash-es/pick";

import { readFile, writeFile } from "fs/promises";
import { join } from "path";

import { loadFromFile, type CheerioAnyNode, type CheerioElement } from "./cheerio";
import { resolveDecimalVersion } from "./common";
import {
  type SuccessCriterion,
  type WcagVersion,
  type WcagItem,
  getPrinciplesForVersion,
  getTermsMapForVersion,
  assertIsWcagVersion,
  getFlatGuidelines,
} from "./guidelines";
import {
  getFlatTechniques,
  getTechniquesByTechnology,
  techniqueAssociationTypes,
  type Technique,
  type TechniqueAssociationType,
} from "./techniques";

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

interface TechniquesSituation {
  content: string;
  title: string;
}

type TechniquesHtmlMap = Partial<Record<TechniqueAssociationType, string | TechniquesSituation[]>>;

async function createTechniquesHtmlFromSc(
  sc: SuccessCriterion,
  techniquesMap: Record<string, Technique>
) {
  const $ = await loadFromFile(join("_site", "understanding", `${sc.id}.html`));

  function cleanHtml($el: CheerioElement) {
    // Remove links within notes, which point to definitions or Understanding sections
    $el.find(".note a").each((_, aEl) => {
      const $aEl = $(aEl);
      $aEl.replaceWith($aEl.html()!);
    });
    // Reduce single-paragraph note markup
    $el.find("div.note:has(p.note-title)").each((_, noteEl) => {
      const noteParagraphSelector = "p.note-title + div > p, p.note-title + p";
      const $noteEl = $(noteEl);
      if ($noteEl.find(noteParagraphSelector).length !== 1) return;
      const $titleEl = $noteEl.children("p.note-title").eq(0);
      // Lift the content out from both the nested p and div (if applicable)
      $noteEl.find("p.note-title + div > p").unwrap();
      const $pEl = $noteEl.find(noteParagraphSelector).eq(0);
      $pEl.replaceWith($pEl.html()!);
      $titleEl.replaceWith(`<em>${$titleEl.html()!}:</em>`);
      noteEl.tagName = "p";
    });
    return $el
      .html()!
      .trim()
      .replace(/\n\s*\n/g, "\n");
  }

  const htmlMap: TechniquesHtmlMap = {};
  for (const type of techniqueAssociationTypes) {
    const $section = $(`section#${type}`);
    if (!$section.length) continue;

    $section.children("h3 + p:not(:has(a))").remove();
    $section.children("h3").remove();

    // Make techniques links absolute
    // (this uses a different selector than the build process, to handle pre-built output)
    $section.find("[href*='/techniques/' i]").each((_, el) => {
      const $el = $(el);
      const technique = techniquesMap[$el.attr("href")!.replace(/^.*\//, "")];
      $el.attr(
        "href",
        $el
          .attr("href")!
          .replace(/^.*\/([\w-]+\/[^\/]+)$/, "https://www.w3.org/WAI/WCAG22/Techniques/$1")
      );
      $el.removeAttr("class");
      // Restore full title (whereas links in build output used truncatedTitle)
      $el.html(`${technique.id}: ${technique.title.replace(/\n\s+/g, " ")}`);
    });

    // Remove superfluous subheadings/subsections, e.g. "CSS Techniques (Advisory)"
    $section.find("h4").each((_, el) => {
      const $el = $(el);
      if (new RegExp(` Techniques(?: \\(${type}\\))?$`, "gi").test($el.text())) {
        const $closestSection = $el.closest("section");
        $el.remove(); // Remove while $el reference is still valid
        if (!$closestSection.is($section)) $closestSection.replaceWith($closestSection.html()!);
      }
    });
    // Merge any consecutive lists (likely due to superfluous subsections)
    $section.find("ul + ul").each((_, el) => {
      const $el = $(el);
      $el.prev().append($el.children());
      $el.remove();
    });

    // Create situations array out of remaining h4s (also used for requirements in 1.4.8)
    const situations = $section.find("section:has(h4)").toArray();
    if (situations.length) {
      htmlMap[type] = situations.map((situationEl) => {
        const $situationEl = $(situationEl);
        const $h4 = $situationEl.children("h4");
        $h4.remove();
        return {
          title: $h4.text().trim(),
          content: cleanHtml($situationEl),
        };
      });
    } else {
      // Remove links within notes, which point to definitions or Understanding sections
      $section.find(".note a").each((_, el) => {
        const $el = $(el);
        $el.replaceWith($el.html()!);
      });
      const html = cleanHtml($section);
      if (html) htmlMap[type] = html;
    }
  }
  return htmlMap;
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
                techniquesHtml: await createTechniquesHtmlFromSc(sc, techniquesMap),
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
  let version: WcagVersion | undefined;
  try {
    const understandingIndex = await readFile(join("_site", "understanding", "index.html"), "utf8");
    const match = /\<title\>Understanding WCAG (\d)\.(\d)/.exec(understandingIndex);
    if (match && match[1] && match[2]) {
      const parsedVersion = `${match[1]}${match[2]}`;
      assertIsWcagVersion(parsedVersion);
      version = parsedVersion;
    }
  } catch (error) {}
  if (!version) {
    console.error("No _site directory found; run `npm run build` first");
    process.exit(1);
  }

  console.log(`Generating wcag.json for version ${resolveDecimalVersion(version)}`);
  await writeFile(join("_site", "wcag.json"), await generateWcagJson(version));
}
