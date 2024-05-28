/** @fileoverview Common functions used by multiple parts of the build process */

/** Generates an ID for heading permalinks. Equivalent to wcag:generate-id. */
export function generateId(title: string) {
	if (title === "Parsing (Obsolete and removed)") return "parsing";
	return title.replace(/\s+/g, "-").replace(/[,\():]+/g, "").toLowerCase();
}
