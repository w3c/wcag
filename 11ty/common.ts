/** @fileoverview Common functions used by multiple parts of the build process */

import type { WcagItem } from "./guidelines";

/** Generates an ID for heading permalinks. Equivalent to wcag:generate-id in base.xslt. */
export function generateId(title: string) {
  if (title === "Parsing (Obsolete and removed)") return "parsing";
  return title
    .replace(/\s+/g, "-")
    .replace(/[,\():]+/g, "")
    .toLowerCase();
}

/** Given a string "xy", returns "x.y" */
export const resolveDecimalVersion = (version: `${number}`) => version.split("").join(".");

/** Sort function for ordering WCAG principle/guideline/SC numbers ascending */
export function wcagSort(a: WcagItem, b: WcagItem) {
  const aParts = a.num.split(".").map((n) => +n);
  const bParts = b.num.split(".").map((n) => +n);

  for (let i = 0; i < 3; i++) {
    if (aParts[i] > bParts[i] || (aParts[i] && !bParts[i])) return 1;
    if (aParts[i] < bParts[i] || (bParts[i] && !aParts[i])) return -1;
  }
  return 0;
}

type FetchText = (...args: Parameters<typeof fetch>) => Promise<string>;

/** Performs a fetch, returning body text or throwing an error if a 4xx/5xx response occurs. */
export const fetchText: FetchText = (input, init) =>
  fetch(input, init).then(
    (response) => {
      if (response.status >= 400)
        throw new Error(`fetching ${input} yielded ${response.status} response`);
      return response.text();
    },
    (error) => {
      throw new Error(`fetching ${input} yielded error: ${error.message}`);
    }
  );

/**
 * Performs a fetch that ignores errors in local dev;
 * throws during builds to fail loudly.
 * This should only be used for non-critical requests that can tolerate no data
 * without major side effects.
 */
export const fetchOptionalText: FetchText =
  process.env.ELEVENTY_RUN_MODE === "build"
    ? fetchText
    : (input, init) =>
        fetchText(input, init).catch((error) => {
          console.warn("Bypassing fetch error:", error.message);
          return "";
        });
