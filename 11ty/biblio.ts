import axios from "axios";
import { readFile } from "fs/promises";
import { glob } from "glob";
import uniq from "lodash-es/uniq";

export const biblioPattern = /\[\[\??([\w-]+)\]\]/g;

/** Compiles URLs from local biblio + specref for linking in Understanding documents. */
export async function getBiblio() {
  const localBiblio = eval(
    (await readFile("biblio.js", "utf8"))
      .replace(/^respecConfig\.localBiblio\s*=\s*/, "(")
      .replace("};", "})")
  );
  
  const refs: string[] = [];
  for (const path of await glob(["guidelines/**/*.html", "understanding/*/*.html"])) {
    const content = await readFile(path, "utf8");
    let match;
    while ((match = biblioPattern.exec(content))) if (!localBiblio[match[1]]) refs.push(match[1]);
  }
  const uniqueRefs = uniq(refs);
  
  const response = await axios.get(`https://api.specref.org/bibrefs?refs=${uniqueRefs.join(",")}`);
  const fullBiblio = {
    ...response.data,
    ...localBiblio,
  };
  
  const resolvedRefs = Object.keys(fullBiblio);
  const unresolvedRefs = uniqueRefs.filter((ref) => !resolvedRefs.includes(ref));
  if (unresolvedRefs.length) console.warn(`Unresolved biblio refs: ${unresolvedRefs.join(", ")}`);
  
  return fullBiblio;
}
