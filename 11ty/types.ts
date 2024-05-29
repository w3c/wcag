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

interface EleventyMeta {
	directories: {
		data: string;
		includes: string;
		input: string;
		layouts?: string;
		output: string;
	};
	env: {
		config: string;
		root: string;
		runMode: "build" | "serve" | "watch";
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
