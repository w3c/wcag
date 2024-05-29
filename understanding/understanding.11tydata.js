export default function (data) {
    return {
        headerLabel: "Understanding Docs", // i.e. documentset.name
        headerUrl: data.understandingUrl,
        isUnderstanding: true,
        eleventyComputed: {
            // Flatten pages into top-level directory, out of version subdirectories
            permalink: (data) => {
                // understanding-metadata.html exists in 2 places,
                // under understanding/ and understanding/20/; the former wins
                if (/\/20\/understanding-metadata/.test(data.page.inputPath)) return false;
                return data.page.inputPath.replace(/\/2\d\//, "/");
            }
        }
    };
}
