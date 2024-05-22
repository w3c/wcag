// Inputs to eventually expose e.g. via environment variables
/** Takes the place of editors vs. publication distinction */
const isEditors = false;
/** Version of WCAG to build */
const version = "22";

export default function (eleventyConfig) {
  eleventyConfig.addGlobalData("version", version);
  eleventyConfig.addGlobalData("versionDecimal", version.split("."));
  eleventyConfig.addGlobalData(
    "techniquesUrl",
    isEditors
      ? "https://w3c.github.io/wcag/techniques"
      : `https://www.w3.org/WAI/WCAG/${version}/Techniques`
  );
  eleventyConfig.addGlobalData(
    "understandingUrl",
    isEditors
      ? "https://w3c.github.io/wcag/understanding"
      : `https://www.w3.org/WAI/WCAG/${version}/Understanding`
  );
  // Looking for other high-level data? Check /_data and *.11tydata.js

  eleventyConfig.addPassthroughFileCopy("css/*.css");
  eleventyConfig.addPassthroughFileCopy("working-examples/**");

  return {
    dir: {
      layouts: "_layouts",
      output: "output",
    },
  };
}
