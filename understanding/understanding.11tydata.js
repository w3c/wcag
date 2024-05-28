export default function (data) {
    return {
        headerLabel: "Understanding Docs", // i.e. documentset.name
        headerUrl: data.understandingUrl,
        isUnderstanding: true,
        eleventyComputed: {
            // Flatten pages into top-level directory, out of version subdirectories
            permalink: (data) =>
                `${data.page.filePathStem.replace(/\/2\d/, "")}/index.html`,
        }
    };
}
