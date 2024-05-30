export default async function (data) {
	return {
		headerLabel: "Techniques", // i.e. documentset.name
		headerUrl: data.techniquesUrl,
		isTechniques: true,
	};
}
