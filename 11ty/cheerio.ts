import { load, type CheerioAPI, type CheerioOptions } from "cheerio";
import { readFileSync } from "fs";
import { readFile } from "fs/promises";
import { dirname, resolve } from "path";

export { load } from "cheerio";

/** Superset of the type returned by any Cheerio $() call */
export type CheerioAnyNode = ReturnType<CheerioAPI>;
/** Type returned by e.g. $(...).find() */
export type CheerioElement = ReturnType<CheerioAnyNode["find"]>;

/** Convenience function that combines readFile and load. */
export const loadFromFile = async (
  inputPath: string,
  options?: CheerioOptions | null,
  isDocument?: boolean
) => load(await readFile(inputPath, "utf8"), options, isDocument);

/**
 * Retrieves content for a data-include, either from _includes,
 * or relative to the input file.
 * Operates synchronously for simplicity of use within Cheerio callbacks.
 *
 * @param includePath A data-include attribute value
 * @param inputPath Path (relative to repo root) to file containing the directive
 * @returns
 */
function readInclude(includePath: string, inputPath: string) {
  const relativePath = resolve(dirname(inputPath), includePath);
  if (includePath.startsWith("..")) return readFileSync(relativePath, "utf8");

  try {
    // Prioritize any match under _includes (e.g. over local toc.html built via XSLT)
    return readFileSync(resolve("_includes", includePath), "utf8");
  } catch (error) {
    return readFileSync(relativePath, "utf8");
  }
}

/**
 * Resolves data-include directives in the given file, a la flatten-document.xslt.
 * This is a lower-level version for use in Eleventy configuration;
 * you'd probably rather use flattenDomFromFile in other cases.
 *
 * @param content String containing HTML to process
 * @param inputPath Path (relative to repo root) to file containing the HTML
 *                  (needed for data-include resolution)
 * @returns Cheerio instance containing "flattened" DOM
 */
export function flattenDom(content: string, inputPath: string) {
  const $ = load(content);

  $("body [data-include]").each((_, el) => {
    const replacement = readInclude(el.attribs["data-include"], inputPath);
    // Replace entire element or children, depending on data-include-replace
    if (el.attribs["data-include-replace"]) $(el).replaceWith(replacement);
    else $(el).removeAttr("data-include").html(replacement);
  });

  return $;
}

/**
 * Convenience version of flattenDom that requires only inputPath to be passed.
 * @see flattenDom
 */
export const flattenDomFromFile = async (inputPath: string) =>
  flattenDom(await readFile(inputPath, "utf8"), inputPath);
