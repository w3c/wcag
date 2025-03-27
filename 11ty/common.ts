/** @fileoverview Common functions used by multiple parts of the build process */

import { AxiosError, type AxiosResponse } from "axios";

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
export function wcagSort(
  a: WcagItem,
  b: WcagItem
) {
  const aParts = a.num.split(".").map((n) => +n);
  const bParts = b.num.split(".").map((n) => +n);

  for (let i = 0; i < 3; i++) {
    if (aParts[i] > bParts[i] || (aParts[i] && !bParts[i])) return 1;
    if (aParts[i] < bParts[i] || (bParts[i] && !aParts[i])) return -1;
  }
  return 0;
}

/**
 * Handles HTTP error responses from Axios requests in local dev;
 * re-throws error during builds to fail loudly.
 * This should only be used for non-critical requests that can tolerate null data
 * without major side effects.
 */
export const wrapAxiosRequest = <T, D>(promise: Promise<AxiosResponse<T, D>>) =>
  promise.catch((error) => {
    if (!(error instanceof AxiosError) || !error.response || !error.request) throw error;
    const { response, request } = error;
    console.warn(
      `AxiosError: status ${response.status} received from ${
        request.protocol + "//" + request.host
      }${request.path || ""}`
    );

    if (process.env.ELEVENTY_RUN_MODE === "build") throw error;
    else return { data: null };
  });
