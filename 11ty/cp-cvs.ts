/** @fileoverview script to copy already-built output to CVS subfolders */

import { glob } from "glob";

import { copyFile, mkdir, unlink } from "fs/promises";
import { dirname, join } from "path";

import { assertIsWcagVersion } from "./guidelines";

const outputBase = "_site";
const cvsBase = process.env.WCAG_CVSDIR || "../../../w3ccvs";
const wcagVersion = process.env.WCAG_VERSION || "22";
assertIsWcagVersion(wcagVersion);
const wcagBase = `${cvsBase}/WWW/WAI/WCAG${wcagVersion}`;

// Map (git) sources to (CVS) destinations, since some don't match case-sensitively
const dirs = {
  techniques: "Techniques",
  understanding: "Understanding",
  "working-examples": "working-examples",
};

for (const [srcDir, destDir] of Object.entries(dirs)) {
  const cleanPaths = await glob(`**`, {
    cwd: join(wcagBase, destDir),
    ignore: ["**/CVS/**"],
    nodir: true,
  });

  for (const path of cleanPaths) await unlink(join(wcagBase, destDir, path));

  const indexPaths = await glob(`**/index.html`, { cwd: join(outputBase, srcDir) });
  const nonIndexPaths = await glob(`**`, {
    cwd: join(outputBase, srcDir),
    ignore: ["**/index.html"],
    nodir: true,
  });

  for (const path of indexPaths) {
    const srcPath = join(outputBase, srcDir, path);
    const destPath = join(wcagBase, destDir, path.replace(/index\.html$/, "Overview.html"));
    await mkdir(dirname(destPath), { recursive: true });
    await copyFile(srcPath, destPath);
  }

  for (const path of nonIndexPaths) {
    const srcPath = join(outputBase, srcDir, path);
    const destPath = join(wcagBase, destDir, path);
    await mkdir(dirname(destPath), { recursive: true });
    await copyFile(srcPath, destPath);
  }
}

try {
  await copyFile(join(outputBase, "wcag.json"), join(wcagBase, "wcag.json"));
} catch (error) {}

await mkdir(join(wcagBase, "errata"), { recursive: true });
await copyFile(
  join(outputBase, "errata", `${wcagVersion}.html`),
  join(wcagBase, "errata", "Overview.html")
);
