export default function (data) {
	return {
		headerLabel: "Understanding Docs", // i.e. documentset.name
		headerUrl: "/understanding/",
		isUnderstanding: true,
		eleventyComputed: {
			permalink: (data) => {
				// understanding-metadata.html exists in 2 places; top-level wins
				if (/\/20\/understanding-metadata/.test(data.page.inputPath)) return false;
				// Flatten pages into top-level directory, out of version subdirectories
				return data.page.inputPath.replace(/\/2\d\//, "/");
			}
		}
	};
}
