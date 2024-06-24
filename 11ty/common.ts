/** @fileoverview Common functions used by multiple parts of the build process */

import type { Guideline, Principle, SuccessCriterion } from "./guidelines";

/** Generates an ID for heading permalinks. Equivalent to wcag:generate-id. */
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
	a: Principle | Guideline | SuccessCriterion,
	b: Principle | Guideline | SuccessCriterion
) {
	const aParts = a.num.split(".").map((n) => +n);
	const bParts = b.num.split(".").map((n) => +n);

	for (let i = 0; i < 3; i++) {
		if (aParts[i] > bParts[i] || (aParts[i] && !bParts[i])) return 1;
		if (aParts[i] < bParts[i] || (bParts[i] && !aParts[i])) return -1;
	}
	return 0;
}
