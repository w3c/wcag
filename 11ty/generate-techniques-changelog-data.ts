import { exec } from "child_process";
import { access, readFile, writeFile } from "fs/promises";
import { glob } from "glob";
import { basename, join } from "path";
import { promisify } from "util";

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
  hash: string;
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

function resolveEarliest(a: EarliestInfo | null, b: EarliestInfo | null) {
  if (a && b) {
    if (a.date > b.date) return b;
    return a;
  }
  if (a || b) return a || b;
  return null;
}

interface EarliestInfo {
  date: Date;
  hash: string;
}

// Cache getEarliestDate results to save time processing across versions
const earliestCache: Record<string, EarliestInfo | null> = {};

// Common function called by getEarlest...Date functions below
async function getEarliest(path: string, logArgs: string) {
  const cacheKey = `${path} ${logArgs}`;
  if (!(cacheKey in earliestCache)) {
    const command = `git log ${logArgs} --format='%h %ad' --date=iso-strict -- ${path} | tail -1`;
    const output = (await execAsync(command)).stdout.trim();
    if (output) {
      const match = /^(\w+) (.+)$/.exec(output);
      if (!match) throw new Error("Unexpected git log output format");
      earliestCache[cacheKey] = { date: new Date(match[2]), hash: match[1] };
    } else earliestCache[cacheKey] = null;
  }
  return earliestCache[cacheKey];
}

// --diff-filter=A is NOT used for additions because it misses odd merge commit cases e.g. F99.
// (Not using it seems to have negligible performance difference and causes no other changes.)
const getEarliestAddition = (path: string) => getEarliest(path, "");
const getEarliestRemoval = (path: string) => getEarliest(path, "--diff-filter=D");
const getEarliestObsolescence = (path: string, version: WcagVersion) => {
  const valuePattern = `2[0-${version[1]}]`;
  return getEarliest(
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
    const technologyObsolescence = await getEarliestObsolescence(
      join(techniquesPath, `${technology}.11tydata.json`),
      version
    );
    if (technologyObsolescence && technologyObsolescence.date > sinceDate) {
      // The above check can handle future cases of marking an entire folder as obsolete;
      // for legacy cases (Flash/SL), check the first technique file for removal
      const technologyRemoval = await getEarliestRemoval(join(techniquesPath, `${code}1.html`));
      entries.push({
        date: (technologyRemoval || technologyObsolescence).date,
        hash: (technologyRemoval || technologyObsolescence).hash,
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

      const addition = await getEarliestAddition(techniquePath);
      if (!addition) continue; // Skip if added prior to start date
      if (addition.date > sinceDate)
        entries.push({
          ...addition,
          technique,
          type: "added",
        });

      const removal = (await checkTechnique(techniquePath))
        ? null
        : resolveEarliest(
            await getEarliestRemoval(techniquePath),
            await getEarliestObsolescence(techniquePath, version)
          );
      if (removal && removal.date > sinceDate)
        entries.push({
          ...removal,
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

  return entries.reduce((collectedEntries, { date, hash, technique, type }) => {
    const previousEntry = collectedEntries[collectedEntries.length - 1];
    if (previousEntry && previousEntry.type === type && +previousEntry.date === +date)
      previousEntry.techniques.push(technique);
    else collectedEntries.push({ date, hash, techniques: [technique], type });
    return collectedEntries;
  }, [] as CompoundEntry[]);
}

const startTime = Date.now();
await writeFile(
  join("techniques", `changelog.11tydata.json`),
  JSON.stringify(
    {
      "//": "DO NOT EDIT THIS FILE; it is automatically generated",
      changelog: {
        "21": await generateChangelog("21"),
        "22": await generateChangelog("22"),
      },
    },
    null,
    "  "
  )
);
console.log(`Wrote changelog in ${Date.now() - startTime}ms`);
