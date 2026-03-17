/** @fileoverview Typings for common Eleventy entities */

interface EleventyPage {
  date: Date;
  filePathStem: string;
  fileSlug: string;
  inputPath: string;
  outputFileExtension: string;
  outputPath: string;
  rawInput: string;
  templateSyntax: string;
  url: string | false; // (false when permalink is set to false for the page)
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

/** Limited 11ty data available when defining filters and shortcodes. */
export interface EleventyContext {
  eleventy: EleventyMeta;
  page: EleventyPage;
}

/** Eleventy-supplied data available to templates. */
export interface EleventyData extends EleventyContext {
  content: string;
  // Allow access to anything else in data cascade
  [index: string]: any;
}

/** Properties available in Eleventy event callbacks (eleventyConfig.on(...)) */
export interface EleventyEvent {
  dir: EleventyDirectories;
  outputMode: "fs" | "json" | "ndjson";
  runMode: EleventyRunMode;
}
