import {
  assertIsWcagVersion,
  getFlatGuidelines,
  getPrinciples,
  getPrinciplesForVersion,
  type FlatGuidelinesMap,
} from "./guidelines";
import {
  getTechniquesByTechnology,
  getFlatTechniques,
  getTechniqueAssociations,
  isTechniqueObsolete,
  type Technology,
} from "./techniques";
import { getUnderstandingDocs, generateUnderstandingNavMap } from "./understanding";

/**
 * Central function that loads data necessary for the Eleventy build process,
 * exposed for reuse in separate scripts (e.g. techniques changelog generation).
 * @param version A version string, e.g. from process.env.WCAG_VERSION; may be undefined
 */
export async function loadDataDependencies(version?: string) {
  const definedVersion = version ?? "22";
  assertIsWcagVersion(definedVersion);

  /** Tree of Principles/Guidelines/SC across all versions (including later than selected) */
  const allPrinciples = await getPrinciples();
  const allFlatGuidelines = getFlatGuidelines(allPrinciples);

  async function resolveRelevantPrinciples() {
    // Resolve from local filesystem if input version was unset (e.g. no explicit WCAG_VERSION)
    if (!version) return allPrinciples;
    // Also resolve from local filesystem if explicit path was given via environment variable
    if (process.env.WCAG_FORCE_LOCAL_GUIDELINES)
      return await getPrinciples(process.env.WCAG_FORCE_LOCAL_GUIDELINES);
    // Otherwise, resolve from published guidelines (requires internet connection)
    assertIsWcagVersion(definedVersion);
    return await getPrinciplesForVersion(definedVersion);
  }

  // Note: many of these variables are documented in the return value instead of up-front,
  // in order to provide docs to consumers of this function

  const principles = await resolveRelevantPrinciples();
  const flatGuidelines = getFlatGuidelines(principles);
  /** Flattened Principles/Guidelines/SC that only exist in later versions (to filter techniques) */
  const futureGuidelines: FlatGuidelinesMap = {};
  for (const [key, value] of Object.entries(allFlatGuidelines)) {
    if (value.version > definedVersion) futureGuidelines[key] = value;
  }

  const techniques = await getTechniquesByTechnology(flatGuidelines);
  const flatTechniques = getFlatTechniques(techniques);

  const techniqueAssociations = await getTechniqueAssociations(flatGuidelines, definedVersion);
  const futureTechniqueAssociations = await getTechniqueAssociations(
    futureGuidelines,
    definedVersion
  );
  const futureExclusiveTechniqueAssociations: typeof techniqueAssociations = {};
  for (const [id, associations] of Object.entries(futureTechniqueAssociations)) {
    if (!techniqueAssociations[id]) futureExclusiveTechniqueAssociations[id] = associations;
  }

  for (const [id, associations] of Object.entries(techniqueAssociations)) {
    // Prune associations from non-obsolete techniques to obsolete SCs
    techniqueAssociations[id] = associations.filter(
      ({ criterion }) =>
        criterion.level !== "" || isTechniqueObsolete(flatTechniques[id], definedVersion)
    );
  }

  for (const [technology, list] of Object.entries(techniques)) {
    // Prune techniques that are obsolete or associated with SCs from later versions
    // (only prune hierarchical structure for ToC; keep all in flatTechniques for lookups)
    techniques[technology as Technology] = list.filter(
      (technique) =>
        (!technique.obsoleteSince || technique.obsoleteSince > definedVersion) &&
        !futureExclusiveTechniqueAssociations[technique.id]
    );
  }

  const understandingDocs = getUnderstandingDocs(definedVersion);
  const understandingNav = generateUnderstandingNavMap(principles, understandingDocs);

  return {
    /** Tree of Principles/Guidelines/SC relevant to selected version */
    principles,
    /** Flattened Principles/Guidelines/SC relevant to selected version */
    flatGuidelines,
    /** Flattened Principles/Guidelines/SC across all versions (including later than selected) */
    allFlatGuidelines,
    /**
     * Techniques organized hierarchically per technology;
     * excludes obsolete techniques and techniques that only reference SCs of future WCAG versions
     **/
    techniques,
    /**
     * Techniques organized in a flat map indexed by ID;
     * _does not_ exclude obsolete/future techniques (so that cross-page links can be resolved)
     */
    flatTechniques,
    /** Maps technique IDs to SCs found in target version */
    techniqueAssociations,
    /** Only maps techniques that only reference SCs introduced in future WCAG versions */
    futureExclusiveTechniqueAssociations,
    /** Information for other top-level understanding pages */
    understandingDocs,
    /** Contains next/previous/parent information for each understanding page, for rendering nav */
    understandingNav,
    // Pass back version so the consumer doesn't need to re-assert
    version: definedVersion,
  };
}
