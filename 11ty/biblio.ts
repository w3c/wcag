import { readFile } from "fs/promises";
import { glob } from "glob";
import invert from "lodash-es/invert";
import uniq from "lodash-es/uniq";
import { join } from "path";

import { loadFromFile } from "./cheerio";
import { fetchOptionalText } from "./common";

export const biblioPattern = /\[\[\??([\w-]+)\]\]/g;

// Resolve necessary aliases locally rather than requiring an extra round trip to specref
const aliases = {
  "css3-values": "css-values-3",
};

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
  const uniqueRefs = uniq(refs).map((ref) =>
    ref in aliases ? aliases[ref as keyof typeof aliases] : ref
  );

  const responseText = await fetchOptionalText(
    `https://api.specref.org/bibrefs?refs=${uniqueRefs.join(",")}`
  );
  const data = responseText ? JSON.parse(responseText) : null;
  if (data) {
    for (const [from, to] of Object.entries(invert(aliases))) data[to] = data[from];
  }

  return {
    ...data,
    ...localBiblio,
  };
}

/** Refs originally found in wcag20/sources/guide-to-wcag2-src.xml */
const wcag20Refs = {
  "ANSI-HFES-100-1988":
    "ANSI/HFS 100-1988, American National Standard for Human Factors Engineering of Visual Display Terminal Workstations, Section 6, pp. 17-20.",
  ARDITI:
    "Arditi, A. (2002). Effective color contrast: designing for people with partial sight and color deficiencies. New York, Arlene R. Gordon Research Institute, Lighthouse International.",
  "ARDITI-FAYE":
    "Arditi, A. and Faye, E. (2004). Monocular and binocular letter contrast sensitivity and letter acuity in a diverse ophthalmologic practice. Supplement to Optometry and Vision Science, 81 (12S), 287.",
  "ARDITI-KNOBLAUCH-1994":
    "Arditi, A. and Knoblauch, K. (1994). Choosing effective display colors for the partially-sighted. Society for Information Display International Symposium Digest of Technical Papers, 25, 32-35.",
  "ARDITI-KNOBLAUCH-1996":
    "Arditi, A. and Knoblauch, K. (1996). Effective color contrast and low vision. In B. Rosenthal and R. Cole (Eds.) Functional Assessment of Low Vision. St. Louis, Mosby, 129-135.",
  CAPTCHA:
    "The CAPTCHA Project, Carnegie Mellon University. The project is online at http://www.captcha.net.",
  "GITTINGS-FOZARD":
    "Gittings, NS and Fozard, JL (1986). Age related changes in visual acuity. Experimental Gerontology, 21(4-5), 423-433.",
  "HARDING-BINNIE":
    "Harding G. F. A. and Binnie, C.D., Independent Analysis of the ITC Photosensitive Epilepsy Calibration Test Tape. 2002.",
  "HEARING-AID-INT":
    "Levitt, H., Kozma-Spytek, L., & Harkins, J. (2005). In-the-ear measurements of interference in hearing aids from digital wireless telephones. Seminars in Hearing, 26(2), 87.",
  "IEC-4WD":
    "IEC/4WD 61966-2-1: Colour Measurement and Management in Multimedia Systems and Equipment - Part 2.1: Default Colour Space - sRGB. May 5, 1998.",
  "ISO-9241-3":
    "ISO 9241-3, Ergonomic requirements for office work with visual display terminals (VDTs) - Part 3: Visual display requirements. Amendment 1.",
  "I18N-CHAR-ENC":
    "\n" +
    '"Tutorial: Character sets & encodings in XHTML, HTML and CSS," R. Ishida, ed., This tutorial is available at http://www.w3.org/International/tutorials/tutorial-char-enc/. \n',
  KNOBLAUCH:
    "Knoblauch, K., Arditi, A. and Szlyk, J. (1991). Effects of chromatic and luminance contrast on reading. Journal of the Optical Society of America A, 8, 428-439.",
  LAALS:
    "Bakke, M. H., Levitt, H., Ross, M., & Erickson, F. (1999). Large area assistive listening systems (ALS): Review and recommendations (PDF) (Final Report. NARIC Accession Number: O16430). Jackson Heights, NY: Lexington School for the Deaf/Center for the Deaf Rehabilitation Research Engineering Center on Hearing Enhancement.\n",
  sRGB: '"A Standard Default Color Space for the Internet - sRGB," M. Stokes, M. Anderson, S. Chandrasekar, R. Motta, eds., Version 1.10, November 5, 1996. A copy of this paper is available at http://www.w3.org/Graphics/Color/sRGB.html.',
  UNESCO:
    "International Standard Classification of Education, 1997. A copy of the standard is available at http://www.unesco.org/education/information/nfsunesco/doc/isced_1997.htm.",
  WCAG20:
    '"Web Content Accessibility Guidelines 2.0,"  B. Caldwell, M Cooper, L Guarino Reid, and G. Vanderheiden, eds., W3 Recommendation 12 December 2008, http://www.w3.org/TR/2008/REC-WCAG20-20081211. The latest version of WCAG 2.0 is available at http://www.w3.org/TR/WCAG20/.\n',
};

/** Returns mapping of references included in WCAG 2.0, which largely lack URLs */
export const getWcag20Biblio = () => wcag20Refs;
