import { resolveDecimalVersion } from "./common";
import type { DocNode, Principle, WcagVersion } from "./guidelines";

/**
 * Resolves information for top-level understanding pages;
 * ported from generate-structure-xml.xslt
 */
export async function getUnderstandingDocs(version: WcagVersion): Promise<DocNode[]> {
	const decimalVersion = resolveDecimalVersion(version);
	return [
		{
			id: "intro",
			name: `Introduction to Understanding WCAG ${decimalVersion}`,
		},
		{
			id: "understanding-techniques",
			name: "Understanding Techniques for WCAG Success Criteria",
		},
		{
			id: "understanding-act-rules",
			name: "Understanding Test Rules for WCAG Success Criteria",
		},
		{
			id: "conformance",
			name: "Understanding Conformance",
		},
		{
			id: "refer-to-wcag",
			name: `How to Refer to WCAG ${decimalVersion} from Other Documents`,
		},
		{
			id: "documenting-accessibility-support",
			name: "Documenting Accessibility Support for Uses of a Web Technology",
		},
		{
			id: "understanding-metadata",
			name: "Understanding Metadata",
		},
	]
}

interface NavData {
	parent?: DocNode;
	previous?: DocNode;
	next?: DocNode;
}

/**
 * Generates mappings from guideline/SC/understanding doc IDs to next/previous/parent information,
 * for efficient lookup when rendering navigation banner
 */
export function generateUnderstandingNavMap(version: WcagVersion, principles: Principle[], understandingDocs: DocNode[]) {
	const allGuidelines =
		Object.values(principles).flatMap(({ guidelines }) => guidelines);
	const map: Record<string, NavData> = {};

	// Guideline navigation wraps across principles, so iterate over flattened list
	allGuidelines.forEach((guideline, i) => {
		map[guideline.id] = {
			...(i > 0 && { previous: allGuidelines[i - 1] }),
			...(i < allGuidelines.length - 1 && { next: allGuidelines[i + 1] })
		};
		guideline.successCriteria.forEach((criterion, j) => {
			map[criterion.id] = {
				parent: guideline,
				...(j > 0 && { previous: guideline.successCriteria[j - 1] }),
				...(j < guideline.successCriteria.length - 1 &&
					{ next: guideline.successCriteria[j + 1] })
			}
		});
	});

	understandingDocs.forEach((doc, i) => {
		map[doc.id] = {
			...(i > 0 && { previous: understandingDocs[i - 1] }),
			...(i < understandingDocs.length - 1 && { next: understandingDocs[i + 1] }),
		}
	});

	return map;
}
