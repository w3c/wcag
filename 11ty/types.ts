interface EleventyPage {
	date: Date;
	filePathStem: string;
	fileSlug: string;
	inputPath: string;
	outputFileExtension: string;
	outputPath: string;
	rawInput: string;
	templateSyntax: string;
	url: string;
}

interface EleventyDirectories {
	data: string;
	includes: string;
	input: string;
	layouts?: string;
	output: string;
}

type EleventyRunMode = "build" | "serve" | "watch";

interface EleventyMeta {
	directories: EleventyDirectories;
	env: {
		config: string;
		root: string;
		runMode: EleventyRunMode;
		source: "cli" | "script";
	};
	generator: string;
	version: string;
}

export interface EleventyData {
	content: string;
	eleventy: EleventyMeta;
	page: EleventyPage;
	[index: string]: any; // Allow access to data cascade
}

export interface EleventyEvent {
	dir: EleventyDirectories;
	outputMode: "fs" | "json" | "ndjson";
	runMode: EleventyRunMode;
}

/**
 * Interface describing format of entries in guidelines/act-mapping.json
 */
interface ActRule {
	deprecated: boolean;
	permalink: string;
	proposed: boolean;
	successCriteria: string[];
	title: string;
	wcagTechniques: string[];
}

export type ActMapping = {
	"act-rules": ActRule[];
}

/**
 * Common interface used for table of contents data
 * under both techniques and understanding
 */
export interface TocLink {
	href: string;
	label: string;
}