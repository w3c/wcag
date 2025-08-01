// TODOs:
// - Handle running for 2.1 vs. 2.2 (would probably be easier by reusing techniques.ts, either as part of 11ty build or otherwise)
// - Create techniques/changelog.html template, migrating changelog out of techniques/index.html
//   - Ideally use {{ linkTechniques | ... }} for additions; removals should get titles but shouldn't link
//     - Create cousin `labelTechnique` filter that only applies title logic w/o link?
// - Figure out workflow story (i.e. when do we run this? Could do it ahead of w3c build...)

import { exec } from "child_process";
import { access, readFile, writeFile } from "fs/promises";
import { glob } from "glob";
import { basename, join } from "path";
import { promisify } from "util";

import { resolveDecimalVersion } from "./common";
import type { WcagVersion } from "./guidelines";
import { technologies, technologyTitles } from "./techniques";
import { loadDataDependencies } from "./data-dependencies";

const execAsync = promisify(exec);

// Only list changes since initial 2.1 rec publication.
// Note: this script intentionally searches the full commit list,
// then later filters by date, rather than truncating the list of commits.
// The latter would cause additional edge cases
// (e.g. due to a few files being re-added after deletion)
// and would only save ~10% of total run time.
const sinceDate = new Date(2018, 5, 6);

interface Entry {
  date: Date;
  technique: string;
  type: "added" | "removed";
}

interface CompoundEntry extends Omit<Entry, "technique"> {
  techniques: string[];
}

const excludes = {
  G222: true, // Was added then removed, related to a SC that was never published
};

/** Checks for existence and non-obsolescene of technique. */
const checkTechnique = async (path: string) =>
  access(path).then(
    () => readFile(path, "utf8").then((content) => !/^obsoleteSince:/m.test(content)),
    () => false
  );

function resolveEarliestDate(a: Date | null, b: Date | null) {
  if (a && b) return new Date(Math.min(+a, +b));
  if (a || b) return a || b;
  return null;
}

// Cache getEarliestDate results to save time processing across versions
const earliestDateCache: Record<string, Date | null> = {};

// Common function called by getEarlest...Date functions below
async function getEarliestDate(path: string, logArgs: string) {
  const cacheKey = `${path} ${logArgs}`;
  if (!(cacheKey in earliestDateCache)) {
    const command = `git log ${logArgs} --format=%ad --date=iso-strict -- ${path} | tail -1`;
    const output = (await execAsync(command)).stdout.trim();
    earliestDateCache[cacheKey] = output ? new Date(output) : null;
  }
  return earliestDateCache[cacheKey];
}

// --diff-filter=A is NOT used for additions because it misses odd merge commit cases e.g. F99.
// (Not using it seems to have negligible performance difference and causes no other changes.)
const getEarliestAdditionDate = (path: string) => getEarliestDate(path, "");
const getEarliestRemovalDate = (path: string) => getEarliestDate(path, "--diff-filter=D");
const getEarliestObsolescenceDate = (path: string, version: WcagVersion) => {
  const valuePattern = `2[0-${version[1]}]`;
  return getEarliestDate(
    path,
    `-G'${
      path.endsWith(".json")
        ? `"obsoleteSince": "${valuePattern}"`
        : `obsoleteSince: ${valuePattern}`
    }'`
  );
};

async function generateChangelog(version: WcagVersion) {
  const { futureExclusiveTechniqueAssociations } = await loadDataDependencies(version);
  const entries: Entry[] = [];

  for (const technology of technologies) {
    const techniquesPath = join("techniques", technology);
    const techniquesFiles = (await glob("*.html", { cwd: techniquesPath })).filter((filename) =>
      /^[A-Z]+\d+\.html$/.test(filename)
    );
    if (!techniquesFiles.length) continue;

    const code = techniquesFiles[0].replace(/\d+\.html$/, "");
    const technologyObsolescenceDate = await getEarliestObsolescenceDate(
      join(techniquesPath, `${technology}.11tydata.json`),
      version
    );
    if (technologyObsolescenceDate && technologyObsolescenceDate > sinceDate) {
      // The above check can handle future cases of marking an entire folder as obsolete;
      // for legacy cases (Flash/SL), check the first technique file for removal
      const technologyRemovalDate = await getEarliestRemovalDate(
        join(techniquesPath, `${code}1.html`)
      );
      entries.push({
        date: technologyRemovalDate || technologyObsolescenceDate,
        technique: `all ${technologyTitles[technology]}`,
        type: "removed",
      });
      continue;
    }

    const max = techniquesFiles.reduce((currentMax, filename) => {
      const num = +basename(filename, ".html").replace(/^[A-Z]+/, "");
      return Math.max(num, currentMax);
    }, 0);

    for (let i = 1; i <= max; i++) {
      const techniquePath = join(techniquesPath, `${code}${i}.html`);
      const technique = basename(techniquePath, ".html");
      if (technique in excludes || technique in futureExclusiveTechniqueAssociations) continue;

      const additionDate = await getEarliestAdditionDate(techniquePath);
      if (!additionDate) continue; // Skip if added prior to start date
      if (additionDate > sinceDate)
        entries.push({
          date: additionDate,
          technique,
          type: "added",
        });

      const removalDate = (await checkTechnique(techniquePath))
        ? null
        : resolveEarliestDate(
            await getEarliestRemovalDate(techniquePath),
            await getEarliestObsolescenceDate(techniquePath, version)
          );
      if (removalDate && removalDate > sinceDate)
        entries.push({
          date: removalDate,
          technique,
          type: "removed",
        });
    }
  }

  // Sort most-recent-first, tie-breaking by additions before removals
  entries.sort((a, b) => {
    if (a.date > b.date) return -1;
    if (a.date < b.date) return 1;
    if (a.type < b.type) return -1;
    if (a.type > b.type) return 1;
    return 0;
  });

  return entries.reduce((collectedEntries, { date, technique, type }) => {
    const previousEntry = collectedEntries[collectedEntries.length - 1];
    if (previousEntry && previousEntry.type === type && +previousEntry.date === +date)
      previousEntry.techniques.push(technique);
    else collectedEntries.push({ date, techniques: [technique], type });
    return collectedEntries;
  }, [] as CompoundEntry[]);
}

for (const version of ["22", "21"] as const) {
  const startTime = Date.now();
  await writeFile(
    join("techniques", `changelog.${version}.11tydata.json`),
    JSON.stringify(await generateChangelog(version), null, "  ")
  );
  console.log(`Wrote ${resolveDecimalVersion(version)} changelog in ${Date.now() - startTime}ms`);
}
