import { readFile } from "fs/promises";
import { glob } from "glob";
import invert from "lodash-es/invert";
import uniq from "lodash-es/uniq";
import { join } from "path";

import { loadFromFile } from "./cheerio";
import { fetchOptionalText } from "./common";

export const biblioPattern = /\[\[\??([\w-]+)\]\]/g;

// Resolve necessary aliases locally rather than requiring an extra round trip to specref
const aliases = {
  "css3-values": "css-values-3",
};

/** Compiles URLs from local biblio + specref for linking in Understanding documents. */
export async function getBiblio() {
  const localBiblio = eval(
    (await readFile("biblio.js", "utf8"))
      .replace(/^respecConfig\.localBiblio\s*=\s*/, "(")
      .replace("};", "})")
  );

  const refs: string[] = [];
  for (const path of await glob(["guidelines/**/*.html", "understanding/*/*.html"])) {
    const content = await readFile(path, "utf8");
    let match;
    while ((match = biblioPattern.exec(content))) if (!localBiblio[match[1]]) refs.push(match[1]);
  }
  const uniqueRefs = uniq(refs).map((ref) =>
    ref in aliases ? aliases[ref as keyof typeof aliases] : ref
  );

  const responseText = await fetchOptionalText(
    `https://api.specref.org/bibrefs?refs=${uniqueRefs.join(",")}`
  );
  const data = responseText ? JSON.parse(responseText) : null;
  if (data) {
    for (const [from, to] of Object.entries(invert(aliases))) data[to] = data[from];
  }

  return {
    ...data,
    ...localBiblio,
  };
}

/** Returns mapping of references included in WCAG 2.0, which largely lack URLs */
export async function getXmlBiblio() {
  const xmlRefs: Record<string, string> = {};
  const $ = await loadFromFile(join("wcag20", "sources", "guide-to-wcag2-src.xml"));
  $("bibl[id]").each((_, el) => {
    const $ref = $(`#${el.attribs.id}`);
    if (!$ref.length) return;
    // Note: Using text() drops links (<loc> tags in the XML),
    // but the only link within refs that are actually used seems to be broken
    xmlRefs[el.attribs.id] = $ref.text();
  });
  return xmlRefs;
}
