import { type Options as SlugifyOptions, slugifyWithCounter } from "@sindresorhus/slugify";
import hljs from "highlight.js";
import { Liquid, type Template } from "liquidjs";
import type { LiquidOptions, RenderOptions } from "liquidjs/dist/liquid-options";
import compact from "lodash-es/compact";
import uniq from "lodash-es/uniq";

import { basename } from "path";

import type { GlobalData } from "eleventy.config";

import { biblioPattern, getBiblio, getWcag20Biblio } from "./biblio";
import { flattenDom, load, type CheerioAnyNode } from "./cheerio";
import { getAcknowledgementsForVersion, type TermsMap } from "./guidelines";
import { resolveTechniqueIdFromHref, understandingToTechniqueLinkSelector } from "./techniques";
import { techniqueToUnderstandingLinkSelector } from "./understanding";

const titleSuffix = " | WAI | W3C";

/** Matches index and about pages, traditionally processed differently than individual pages */
const indexPattern = /(techniques|understanding)\/(index|about|changelog)\.html$/;
const techniquesPattern = /\btechniques\//;
const understandingPattern = /\bunderstanding\//;

const biblio = await getBiblio();
const wcag20Biblio = await getWcag20Biblio();
const termLinkSelector = "a:not([href])";

/** Generates {% include "foo.html" %} directives from 1 or more basenames */
const generateIncludes = (...basenames: string[]) =>
  `\n${basenames.map((basename) => `{% include "${basename}.html" %}`).join("\n")}\n`;

/** Version of generateIncludes for a single include with parameters */
const generateIncludeWithParams = (basename: string, params: Record<string, string>) => {
  const strParams = Object.entries(params).reduce(
    (str, [key, value]) => `${str}, ${key}: ${JSON.stringify(value)}`,
    ""
  );
  return `\n{% include "${basename}.html"${strParams} %}\n`;
};

/**
 * Determines whether a given string is actually HTML,
 * not e.g. a data value Eleventy sent to the templating engine.
 */
const isHtmlFileContent = (html: string) => !html.startsWith("(((11ty") && !html.endsWith(".html");

/**
 * Performs common cleanup of in-page headings, and by extension, table of contents links,
 * for final output.
 */
const normalizeHeading = (label: string) =>
  label
    .trim()
    .replace(/In brief/, "In Brief")
    .replace(/^(\S+) (of|for) .*$/, "$1")
    .replace(/^Techniques and Failures .*$/, "Techniques")
    .replace(/^Specific Benefits .*$/, "Benefits")
    .replace(/^.* Examples$/, "Examples")
    .replace(/^(Related )?Resources$/i, "Related Resources");

/**
 * Performs additional common cleanup for table of contents links for final output.
 * This is expected to piggyback off of normalizeHeading, which should be called on
 * headings prior to processing the table of contents from them.
 */
const normalizeTocLabel = (label: string) =>
  label.replace(/ for this Guideline$/, "").replace(/ \(SC\)$/, "");

/**
 * Replaces a link with a technique URL with a Liquid tag which will
 * expand to a link with the full technique ID and title.
 * @param $el a $()-wrapped link element
 */
function expandTechniqueLink($el: CheerioAnyNode) {
  const href = $el.attr("href");
  if (!href) throw new Error("expandTechniqueLink: non-link element encountered");
  const id = resolveTechniqueIdFromHref(href);
  // id will be empty string for links to index, which we don't need to modify
  if (id) $el.replaceWith(`{{ "${id}" | linkTechniques }}`);
}

const stripHtmlComments = (html: string) => html.replace(/<!--[\s\S]*?-->/g, "");

interface CustomLiquidOptions extends LiquidOptions {
  termsMap: TermsMap;
}

// Dev note: Eleventy doesn't expose typings for its template engines for us to neatly extend.
// Fortunately, it passes both the content string and the file path through to Liquid#parse:
// https://github.com/11ty/eleventy/blob/9c3a7619/src/Engines/Liquid.js#L253

/**
 * Liquid class extension that adds support for parts of the existing build process:
 * - flattening data-include directives prior to parsing Liquid tags
 *   (permitting Liquid even inside data-included files)
 * - inserting header/footer content within the body of pages
 * - generating/expanding sections with auto-generated content
 */
export class CustomLiquid extends Liquid {
  termsMap: TermsMap;
  constructor(options: CustomLiquidOptions) {
    super(options);
    this.termsMap = options.termsMap;
  }

  private renderErrata(html: string) {
    const $ = load(html);

    const $tocList = $("#contents .toc");
    let $childList: CheerioAnyNode | null = null;
    $("main section[id]:has(h2:first-child, h3:first-child)").each((_, el) => {
      const $el = $(el);
      // Only one of the following queries will match for each section
      $el.find("> h2:first-child").each((_, h2El) => {
        $childList = null;
        $tocList.append(`<li><a href="#${el.attribs.id}">${$(h2El).text()}</a></li>`);
      });
    });

    return $.html();
  }

  public parse(html: string, filepath?: string) {
    // Filter out Liquid calls for computed data and includes themselves
    if (
      filepath &&
      !filepath.includes("_includes/") &&
      !filepath.includes("errata/") &&
      isHtmlFileContent(html)
    ) {
      const isIndex = indexPattern.test(filepath);
      const isTechniques = techniquesPattern.test(filepath);
      const isUnderstanding = understandingPattern.test(filepath);

      if (!isTechniques && !isUnderstanding) return super.parse(html);

      const $ = flattenDom(html, filepath);

      // Clean out elements to be removed
      // (e.g. editors.css & sources.css, and leftover template paragraphs)
      // Note: the link selector accounts for ~40 files forgetting class="remove" on editors.css
      $(".remove, link[href$='editors.css'], section#meta, section.meta").remove();

      if ($("p.instructions").length > 0) {
        console.error(
          `${filepath} contains a <p class="instructions"> element.\n` +
            "  This suggests that a template was copied and not fully filled out.\n" +
            "  If the paragraph has been modified and should be retained, remove the class.\n" +
            "  Otherwise, if the corresponding section has been updated, remove the paragraph."
        );
        throw new Error("Instructions paragraph found; please resolve.");
      }

      // Add charset to pages that forgot it
      if (!$("meta[charset]").length) $('<meta charset="UTF-8">').prependTo("head");

      const $missingHljsOverrides = $("pre code:not([class])");
      if ($missingHljsOverrides.length) {
        $missingHljsOverrides.each((_, el) => {
          const code = $(el).html()!.replace(/\n/g, "\\n");
          const excerpt = `${code.slice(0, 40)}${code.length > 40 ? "..." : ""}`;
          console.log(
            `${filepath} missing "language-*" or "no-highlight" class on <pre><code> starting with ${excerpt}`
          );
        });
        if (process.env.ELEVENTY_RUN_MODE === "build") {
          throw new Error(
            "Please ensure all code blocks have a highlight.js class (language-* or no-highlight)."
          );
        }
      }

      $("pre code[class*='language-']").each((_, el) => {
        const $el = $(el);
        // Unescape any HTML entities (which were originally needed for client-side highlight.js)
        const code = $el.html()!.replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&amp;/g, "&");
        const language = $el.attr("class")!.replace(/^.*language-(\S+).*$/, "$1");
        $el.html(hljs.highlight(code, { language }).value);
        $el.addClass("hljs");
      });

      const prependedIncludes = ["header"];
      const appendedIncludes = ["wai-site-footer", "site-footer"];

      // Include draft banner at top of informative pages for GH Pages builds and PR previews
      if (process.env.WCAG_MODE === "editors" || (process.env.COMMIT_REF && !process.env.WCAG_MODE))
        prependedIncludes.unshift("draft-banner");

      if (isUnderstanding)
        prependedIncludes.push(
          isIndex ? "understanding/navigation-index" : "understanding/navigation"
        );

      if (isIndex) {
        if (isTechniques) $("section#changelog li a").each((_, el) => expandTechniqueLink($(el)));
      } else {
        $("head").append(generateIncludes("head"));
        appendedIncludes.push("waiscript");

        // Remove resources section if it only has a placeholder item
        const $resourcesOnlyItem = $("section#resources li:only-child");
        if (
          $resourcesOnlyItem.length &&
          ($resourcesOnlyItem.html() === "Resource" || $resourcesOnlyItem.html() === "Link")
        )
          $("section#resources").remove();

        // Fix incorrect level-2 and first-child level-3 headings
        // (avoid changing h3s that are appropriate but aren't nested within a subsection)
        $("body > section section h2").each((_, el) => {
          el.tagName = "h3";
        });
        $("body > section > h3:first-child").each((_, el) => {
          el.tagName = "h2";
        });

        if (isTechniques) {
          // Expand related technique links to include full title
          // (the XSLT process didn't handle this in this particular context)
          const siblingCode = basename(filepath).replace(/^([A-Z]+).*$/, "$1");
          $("section#related li")
            .find(`a[href^='../'], a[href^=${siblingCode}]`)
            .each((_, el) => expandTechniqueLink($(el)));

          // XSLT orders related and tests last, but they are not last in source files
          $("body")
            .append("\n", $(`body > section#related`))
            .append("\n", $(`body > section#tests`));

          $("h1")
            .after(generateIncludes("techniques/about"))
            .replaceWith(generateIncludes("techniques/h1"));

          const detectedSections: Record<string, true> = {};
          $("body > section[id]").each((_, el) => {
            const id = el.attribs.id.toLowerCase();
            // Fix non-lowercase top-level section IDs (e.g. H99)
            el.attribs.id = id;
            // Fail on duplicate sections
            if (id in detectedSections) {
              console.error(`${filepath}: Multiple sections with id="${id}" found.`);
              throw new Error("Please resolve duplicate section IDs.");
            } else {
              detectedSections[id] = true;
            }
          });

          $("section#resources h2").after(generateIncludes("techniques/intro/resources"));
          $("section#examples section.example").each((i, el) => {
            const $el = $(el);
            const exampleText = `Example ${i + 1}`;
            // Check for multiple h3 under one example, which should be h4 (e.g. SCR33)
            $el.find("h3:not(:only-of-type)").each((_, el) => {
              el.tagName = "h4";
            });

            const $h3 = $el.find("h3");
            if ($h3.length) {
              const h3Text = $h3.text(); // Used for comparisons below
              // Some examples really have an empty h3...
              if (!h3Text) $h3.text(exampleText);
              // Only prepend "Example N: " if it won't be redundant (e.g. C31, F83)
              else if (!/example \d+$/i.test(h3Text) && !/^example \d+/i.test(h3Text))
                $h3.prepend(`${exampleText}: `);
            } else {
              $el.prepend(`<h3>${exampleText}</h3>`);
            }
          });
        } else if (isUnderstanding) {
          // Add numbers to figcaptions
          $("figcaption").each((i, el) => {
            const $el = $(el);
            if (!$el.find("p").length) $el.wrapInner("<p></p>");
            $el
              .find("p")
              .first()
              .prepend(`<span>Figure ${i + 1}.</span> `);
          });

          // Remove spurious copy-pasted content in 2.5.3 that doesn't belong there
          if ($("section#benefits").length > 1) $("section#benefits").first().remove();
          // Prevent pages from nesting Benefits inside Intent (old issue that has been fixed)
          if ($("section#intent section#benefits").length) {
            console.error(`${filepath}: Benefits section should not be nested inside Intent.`);
            throw new Error("Incorrectly-nested Benefits section found: please resolve.");
          }

          // Expand top-level heading and add box for guideline/SC pages
          if ($("section#intent").length) $("h1").replaceWith(generateIncludes("understanding/h1"));
          $("section#intent").before(generateIncludes("understanding/about"));

          // Disallow handwritten success-criteria section (should be auto-generated)
          if ($("section#success-criteria").length) {
            console.error(
              `${filepath}: success-criteria section will be auto-generated; ` +
                "please remove this from the source file."
            );
            throw new Error("Please remove success-criteria section from guideline pages.");
          }
          // success-criteria template only renders content for guideline (not SC) pages
          $("body").append(generateIncludes("understanding/success-criteria"));

          // Add intro prose to populated sections
          $("section#resources h2").after(generateIncludes("understanding/intro/resources"));

          // Expand techniques links to always include title
          $(understandingToTechniqueLinkSelector).each((_, el) => expandTechniqueLink($(el)));

          // Add key terms and references by default, to be removed in #parse if not needed
          $("body").append(generateIncludeWithParams("dl-section", { title: "Key Terms" }));
          $("body").append(generateIncludeWithParams("dl-section", { title: "References" }));
        }

        // Remove h2-level sections with no content other than heading
        $("body > section:not(:has(:not(h2)))").remove();

        $("body")
          .attr("dir", "ltr") // Already included in index/about pages
          .append(generateIncludes("test-rules", "back-to-top"))
          .wrapInner(`<main id="main" class="standalone-resource__main"></main>`)
          .prepend(generateIncludes("sidebar"))
          .append(generateIncludes("help-improve"))
          // index/about pages already include this wrapping; others do not, and need it.
          // This wraps around table of contents & help improve, but not other includes
          .wrapInner(`<div class="default-grid with-gap leftcol"></div>`);
      }

      $("body")
        .prepend(generateIncludes(...prependedIncludes))
        .append(generateIncludes(...appendedIncludes));

      return super.parse($.html(), filepath);
    }
    return super.parse(html);
  }

  public async render(templates: Template[], scope: GlobalData, options?: RenderOptions) {
    // html contains markup after Liquid tags/includes have been processed
    const html = (await super.render(templates, scope, options)).toString();
    if (!isHtmlFileContent(html) || !scope || scope.page.url === false) return html;
    if (scope.page.inputPath.includes("errata/")) return this.renderErrata(html);

    const $ = load(html);

    if (indexPattern.test(scope.page.inputPath)) {
      // Remove empty list items due to obsolete technique link removal
      if (scope.isTechniques) $("ul.toc-wcag-docs li:empty").remove();

      // Replace acknowledgements with pinned content for older versions
      if (process.env.WCAG_VERSION && $("section#acknowledgements").length) {
        const pinnedAcknowledgements = await getAcknowledgementsForVersion(scope.version);
        for (const [id, content] of Object.entries(pinnedAcknowledgements)) {
          $(`#${id} h3 +`).html(content);
        }
      }
    } else {
      const $title = $("head title");

      if (scope.isTechniques) {
        const isObsolete =
          scope.technique.obsoleteSince && scope.technique.obsoleteSince <= scope.version;
        if (isObsolete) $("body").addClass("obsolete");

        $title.text(
          (isObsolete ? "[Obsolete] " : "") +
            `${scope.technique.id}: ${scope.technique.title}${titleSuffix}`
        );

        const aboutBoxSelector = "section#technique .box-i";

        // Strip applicability paragraphs with metadata IDs (e.g. H99)
        $("section#applicability").find("p#id, p#technology, p#type").remove();
        // Check for custom applicability paragraph before removing the section
        const customApplicability = $("section#applicability p")
          .html()
          ?.trim()
          .replace(/^th(e|is) (technique|failure)s? (is )?/i, "")
          .replace(/^general( technique|ly applicable)?(\.|$).*$/i, "all technologies")
          .replace(/^appropriate to use for /i, "")
          .replace(/^use this technique on /i, "");
        if (customApplicability) {
          const appliesPattern = /^(?:appli(?:es|cable)|relates) (to|when(?:ever)?)\s*/i;
          const rephrasedApplicability = customApplicability.replace(appliesPattern, "");

          // Failure pages have no default applicability paragraph, so append one first
          if (scope.technique.technology === "failures")
            $("section#technique .box-i").append("<p></p>");

          const noun = scope.technique.technology === "failures" ? "failure" : "technique";
          const appliesMatch = appliesPattern.exec(customApplicability);
          const connector = /^not/.test(customApplicability)
            ? "is"
            : `applies ${appliesMatch?.[1] || "to"}`;
          $("section#technique .box-i p:last-child").html(
            `This ${noun} ${connector} ` +
              // Uncapitalize original sentence, except for all-caps abbreviations or titles
              (/^[A-Z]{2,}/.test(rephrasedApplicability) ||
              /^([A-Z][a-z]+(\s+|\.?$))+(\/|$)/.test(rephrasedApplicability)
                ? rephrasedApplicability
                : rephrasedApplicability[0].toLowerCase() + rephrasedApplicability.slice(1)) +
              (/(\.|:)$/.test(rephrasedApplicability) ? "" : ".")
          );

          // Append any relevant subsequent paragraphs or lists from applicability section
          const $additionalApplicability = $("section#applicability").find(
            "p:not(:first-of-type), ul, ol"
          );
          const additionalApplicabilityText = $additionalApplicability.text();
          const excludes = [
            "None listed.", // Template filler
            "This technique relates to:", // Redundant of auto-generated content
          ];
          if (excludes.every((exclude) => !additionalApplicabilityText.includes(exclude)))
            $additionalApplicability.appendTo(aboutBoxSelector);
        }
        $("section#applicability").remove();

        // Remove any effectively-empty techniques/resources sections,
        // due to template boilerplate or obsolete technique removal
        $("section#related:not(:has(a))").remove();
        $("section#resources:not(:has(a, li))").remove();

        // Update understanding links to always use base URL
        // (mainly to avoid any case-sensitivity issues)
        $(techniqueToUnderstandingLinkSelector).each((_, el) => {
          el.attribs.href = el.attribs.href.replace(/^.*\//, scope.understandingUrl);
        });
      } else if (scope.isUnderstanding) {
        if (scope.guideline) {
          const type = scope.guideline.type === "SC" ? "Success Criterion" : scope.guideline.type;
          $title.text(
            `Understanding ${type} ${scope.guideline.num}: ${scope.guideline.name}${titleSuffix}`
          );
        } else {
          $title.text(
            $title.text().replace(/WCAG 2( |$)/, `WCAG ${scope.versionDecimal}$1`) + titleSuffix
          );
        }

        // Remove Techniques section from obsolete SCs (e.g. Parsing in 2.2)
        if (scope.guideline?.level === "") $("section#techniques").remove();
      }

      // Process defined terms within #render, where we have access to
      // global data and the rendered HTML for the About box and related Techniques
      const $termLinks = $(termLinkSelector);
      const extractTermName = ($el: CheerioAnyNode) => {
        const name = $el
          .text()
          .toLowerCase()
          .trim()
          .replace(/\s*\n+\s*/, " ");
        const term = this.termsMap[name];
        if (!term) {
          console.warn(`${scope.page.inputPath}: Term not found: ${name}`);
          return;
        }
        // Return standardized name for Key Terms definition lists
        return term.name;
      };

      if (scope.isTechniques) {
        $termLinks.each((_, el) => {
          const $el = $(el);
          const termName = extractTermName($el);
          $el
            .attr("href", `${scope.guidelinesUrl}#${termName ? this.termsMap[termName].trId : ""}`)
            .attr("target", "terms");
        });
      } else if (scope.isUnderstanding) {
        const $termsList = $("section#key-terms dl");
        const extractTermNames = ($links: CheerioAnyNode) =>
          compact(uniq($links.toArray().map((el) => extractTermName($(el)))));

        if ($termLinks.length) {
          let termNames = extractTermNames($termLinks);
          // This is one loop but effectively multiple passes,
          // since terms may reference other terms in their own definitions.
          // Each iteration may append to termNames.
          for (let i = 0; i < termNames.length; i++) {
            const term = this.termsMap[termNames[i]];
            if (!term) continue; // This will already warn via extractTermNames

            const $definition = load(term.definition);
            const $definitionTermLinks = $definition(termLinkSelector);
            if ($definitionTermLinks.length) {
              termNames = uniq(termNames.concat(extractTermNames($definitionTermLinks)));
            }
          }

          // Iterate over sorted names to populate alphabetized Key Terms definition list
          termNames.sort((a, b) => {
            if (a.toLowerCase() < b.toLowerCase()) return -1;
            if (a.toLowerCase() > b.toLowerCase()) return 1;
            return 0;
          });
          for (const name of termNames) {
            const term = this.termsMap[name]; // Already verified existence in the earlier loop
            let termBody = term.definition;
            if (scope.errata[term.id]) {
              termBody += `
                <p><strong>Errata:</strong></p>
                <ul>${scope.errata[term.id].map((erratum) => `<li>${erratum}</li>`)}</ul>
                <p><a href="https://www.w3.org/WAI/WCAG${scope.version}/errata/">View all errata</a></p>
              `;
            }
            $termsList.append(`\n      <dt id="${term.id}">${term.name}</dt><dd>${termBody}</dd>`);
          }

          // Iterate over non-href links once more in now-expanded document to add hrefs
          $(termLinkSelector).each((_, el) => {
            const name = extractTermName($(el));
            el.attribs.href = `#${name ? this.termsMap[name].id : ""}`;
          });
        } else {
          // No terms: remove skeleton that was placed in #parse
          $("section#key-terms").remove();
        }
      }

      // Remove items that end up empty due to invalid technique IDs during #parse
      // (e.g. removed/deprecated)
      if (scope.isTechniques) {
        $("section#related li:empty").remove();
      } else if (scope.isUnderstanding) {
        // :empty doesn't work here since there may be whitespace
        // (can't trim whitespace in the liquid tag since some links have more text after)
        $(`section#techniques li`)
          .filter((_, el) => !$(el).text().trim())
          .remove();

        // Prepend guidelines base URL to non-dfn anchor links in guidelines-derived content
        // (including both the guideline/SC box at the top and Key Terms at the bottom)
        $("#guideline, #success-criterion, #key-terms")
          .find("a[href^='#']:not([href^='#dfn-'])")
          .each((_, el) => {
            el.attribs.href = scope.guidelinesUrl + el.attribs.href;
          });
      }
    }

    // Expand note paragraphs after parsing and rendering,
    // after Guideline/SC content for Understanding pages is rendered.
    // (This is also needed for techniques/about)
    $("div.note").each((_, el) => {
      const $el = $(el);
      const classes = el.attribs.class;
      $el.replaceWith(`<div class="${classes}">
				<p class="note-title marker">Note</p>
				<div>${$el.html()}</div>
			</div>`);
    });
    // Handle p variant after div (the reverse would double-process)
    $("p.note").each((_, el) => {
      const $el = $(el);
      const classes = el.attribs.class;
      $el.replaceWith(`<div class="${classes}">
				<p class="note-title marker">Note</p>
				<p>${$el.html()}</p>
			</div>`);
    });

    // Add header to example sections in Key Terms (aside) and Conformance (div)
    $("aside.example, div.example").each((_, el) => {
      const $el = $(el);
      $el.prepend(`<p class="example-title marker">Example</p>`);
    });

    // Perform second pass over notes/examples, to number when there are multiple in one section or dd
    $("#key-terms dd, #success-criterion").each((_, containerEl) => {
      for (const selector of [".example-title", ".note-title"]) {
        const $titles = $(containerEl).find(selector);
        if ($titles.length > 1) {
          $titles.each((i, el) => {
            $(el).text(`${$(el).text()} ${i + 1}`);
          });
        }
      }
    });

    // We don't need to do any more processing for index/about pages other than stripping comments
    if (indexPattern.test(scope.page.inputPath)) return stripHtmlComments($.html());

    // Handle new-in-version content
    $("[class^='wcag']").each((_, el) => {
      // Just like the XSLT process, this naively assumes that version numbers are the same length
      const classMatch = el.attribs.class.match(/\bwcag(\d\d)\b/);
      if (!classMatch) throw new Error(`Invalid wcagXY class found: ${el.attribs.class}`);
      const classVersion = +classMatch[1];
      if (isNaN(classVersion)) throw new Error(`Invalid wcagXY class found: ${el.attribs.class}`);
      const buildVersion = +scope.version;

      if (classVersion > buildVersion) {
        $(el).remove();
      } else if (classVersion === buildVersion) {
        if (/\bnote\b/.test(el.attribs.class))
          $(el).find(".marker").append(` (new in WCAG ${scope.versionDecimal})`);
        else
          $(el).prepend(`<span class="new-version">New in WCAG ${scope.versionDecimal}: </span>`);
      }
      // Output as-is if content pertains to a version older than what's being built
    });

    if (!scope.isUnderstanding || scope.guideline) {
      // Fix inconsistent heading labels
      // (another pass is done on top of this for table of contents links below)
      $("h2").each((_, el) => {
        const $el = $(el);
        $el.text(normalizeHeading($el.text()));
      });
    }

    // Link biblio references
    if (scope.isUnderstanding) {
      const wcag20BiblioReferences: string[] = [];
      $("p").each((_, el) => {
        const $el = $(el);
        const html = $el.html();
        if (html && biblioPattern.test(html)) {
          $el.html(
            html.replace(biblioPattern, (substring, code) => {
              if (biblio[code]?.href) return `[<a href="${biblio[code].href}">${code}</a>]`;
              if (code in wcag20Biblio) {
                wcag20BiblioReferences.push(code);
                return `[<a href="#${code}">${code}</a>]`;
              }
              console.warn(`${scope.page.inputPath}: Unresolved biblio ref: ${code}`);
              return substring;
            })
          );
        }
      });

      // Populate references section, or remove if unused
      if (wcag20BiblioReferences.length) {
        for (const ref of uniq(wcag20BiblioReferences).sort()) {
          $("section#references dl").append(
            `\n      <dt id="${ref}">${ref}</dt><dd>${
              wcag20Biblio[ref as keyof typeof wcag20Biblio]
            }</dd>`
          );
        }
      } else $("section#references").remove();
    }

    const slugify = slugifyWithCounter();
    const slugifyOptions: SlugifyOptions = { decamelize: false };

    // Allow autogenerating missing top-level section IDs in understanding docs,
    // but don't pick up incorrectly-nested sections in some techniques pages (e.g. H91)
    const sectionSelector = scope.isUnderstanding ? "section" : "section[id]:not(.obsolete)";
    const sectionH2Selector = "h2:first-child";
    const $h2Sections = $(`${sectionSelector}:has(${sectionH2Selector})`);
    if ($h2Sections.length) {
      // Generate table of contents after parsing and rendering,
      // when we have sections and sidebar skeleton already reordered
      const $tocList = $(".sidebar nav ul");
      $h2Sections.each((_, el) => {
        if (!el.attribs.id)
          el.attribs.id = slugify($(el).find(sectionH2Selector).text(), slugifyOptions);
        $("<a></a>")
          .attr("href", `#${el.attribs.id}`)
          .text(normalizeTocLabel($(el).find(sectionH2Selector).text()))
          .appendTo($tocList)
          .wrap("<li></li>");
        $tocList.append("\n");
      });
    } else {
      // Remove ToC sidebar that was added in #parse if there's nothing to list in it
      $(".sidebar").remove();
    }

    // Autogenerate remaining IDs after constructing table of contents.
    // NOTE: This may overwrite some IDs set in HTML (for techniques examples),
    // and may result in duplicates; this is consistent with the XSLT process.
    const sectionHeadingSelector = ["h3", "h4", "h5"]
      .map((tag) => `> ${tag}:first-child`)
      .join(", ");
    const autoIdSectionSelectors = ["section:not([id])"];
    if (scope.isTechniques) autoIdSectionSelectors.push("section.example");
    $(autoIdSectionSelectors.join(", "))
      .filter(`:has(${sectionHeadingSelector})`)
      .each((_, el) => {
        el.attribs.id = slugify($(el).find(sectionHeadingSelector).text(), slugifyOptions);
      });

    // Also autogenerate IDs for any headings with no dedicated section nor explicit ID
    $(":is(h3, h4, h5):not(:first-child):not([id])").each((_, el) => {
      el.attribs.id = slugify($(el).text(), slugifyOptions);
    });

    return stripHtmlComments($.html());
  }
}
