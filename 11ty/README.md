# Eleventy Infrastructure for WCAG Techniques and Understanding

This subdirectory contains ES Modules re-implementing pieces of the
XSLT-based build process using Eleventy.

## Usage

Make sure you have Node.js installed. This has primarily been tested with v20,
the current LTS at time of writing.

If you use [`fnm`](https://github.com/Schniz/fnm) or [`nvm`](https://github.com/nvm-sh/nvm) to manage multiple Node.js versions,
you can switch to the recommended version by typing `fnm use` or `nvm use`
(with no additional arguments) while in the repository directory.

Otherwise, you can download an installer from [nodejs.org](https://nodejs.org/).

First, run `npm i` in the root directory of the repository to install dependencies.

Common tasks:

- `npm run build` runs a one-time build
- `npm start` runs a local server with hot-reloading to preview changes as you make them:
  - http://localhost:8080/techniques
  - http://localhost:8080/understanding

Maintenance tasks (for working with Eleventy config and supporting files used by the build):

- `npm run check` checks for TypeScript errors
- `npm run fmt` formats all TypeScript files

## Publishing to WAI website

The following npm scripts can be used to assist with publishing updates to the WAI website:

- `npm run publish-w3c` to publish 2.2
- `npm run publish-w3c:21` to publish 2.1

Each of these scripts performs the following steps:

1. Updates the data used for the Techniques Change Log page
   - Note that this step may result in changes to `techniques/changelog.11tydata.json`, which should be committed to `main`
2. Runs the build for the appropriate WCAG version, generating pages and `wcag.json` under `_site`
3. Copies the built files from `_site` to the CVS checkout (see [`WCAG_CVSDIR`](#wcag_cvsdir))

## Associated Techniques Data

Each success criterion's page contains a Techniques section which links to associated techniques.
These used to be defined directly in HTML in each respective page, but have since been relocated to
a single data file, `understanding/understanding.11tydata.js`, under the key `associatedTechniques`.

This field is typed, in order to provide some degree of autocomplete in IDEs that support TypeScript
(e.g. Visual Studio Code), as well as some amount of immediate feedback while editing.
Further validation is performed when running the build or dev server, to provide more focused error messages for common mistakes.

### Listing Techniques

Techniques may be indicated via an object as outlined below, or using a shorthand string.
Shorthand strings may function as either `id` or `title` seen below, and are
recommended for brevity when no `using` or `and` relationship is present.

The following list outlines properties available on each technique object:

- `id` - Technique ID
- `title` - Technique description (HTML flow content allowed), to define free-form entries that don't reference a specific technique
- `using` - Optional array of further techniques to be populated into a child list
  - Child techniques may also include `using`
- `usingConjunction` - When `using` is specified, this overrides the word that appears before `usingQuantity`
  - Default: `"using"`; HTML flow content allowed
- `usingQuantity` - When `using` is specified, this overrides the word that appears after `usingConjunction` and before "of the following techniques"
  - Default: `"one"`
  - May be empty string (`""`), in which case the subsequent "of" is dropped
- `usingPrefix` - Adds text to appear before `usingConjunction`
- `skipUsingPhrase` - Omits the entire "... using ... of the following techniques" phrase
  - This is mainly an escape hatch for rare instances where a child list is used but no "using" phrase appears at all (e.g. in 1.4.4: Resize Text)

Typically, either `id` or `title` is required.
If `id` is specified, then `prefix` and/or `suffix` may also be specified (with HTML flow content allowed in each),
resulting in "{prefix} {linked technique title} {suffix}".

In extremely rare cases, `using` may be specified alone without either `id` or `title`,
e.g. for top-level "Using two or more of the following" in 2.4.5: Multiple Ways.

#### Conjunctions

To represent multiple parallel techniques, an `and` key may be specified instead of `id` or `title`. In this case, the following properties are supported:

- `and` - an array of technique objects or shorthand strings (as described above)
- `using` and its related fields (seen above) may optionally be specified alongside `and`
- `andConjunction` may optionally be specified alongside `and`,
  to override the default `"<strong>AND</strong>"` phrasing (e.g. in 4.1.3: Status Messages)
- Techniques listed _within_ `and` should be flat, never containing `and` or `using`

### Situations or Other Subsections (Sufficient only)

The top level of the `sufficient` array may consist entirely of either technique entries (see above)
or subsection entries. It should not contain a mix of both.

Subsections are typically used to define multiple "situations", where each title begins with "Situation A:", "Situation B:", etc.;
in rare cases it is used for other purposes, e.g. in 1.4.8: Visual Presentation.

Subsection entries contain the following:

- `title` (required, HTML allowed)
- `techniques` (required) - array of technique entries (see above)
- `note` (optional, HTML allowed) - content to appear in a Note at the end of the subsection (e.g. in 4.1.3: Status Messages)
- `groups` (optional) - array of objects with `id`, `title`, `techniques`; see more below
  - `techniques` within `groups` are not expected to involve `and` or `using`

#### Groups within Situations

Most of the situations in 1.1.1: Non-text Content include groupings which start with a boldface paragraph (not a heading),
and are referenced one or more times within preceding "using" clauses.
Groups can be defined at the top level of each situation/section entry as mentioned above.
Defining `groups` automatically implies a "using" relationship, without explicitly defining `using` for each technique.

## Environment Variables

### `WCAG_CVSDIR`

**Usage context:** `publish-w3c` script only

Indicates top-level path of W3C CVS checkout, for WAI site updates (via `publish-w3c` script).

**Default:** `../../../w3ccvs` (same as in Ant/XSLT build process)

### `WCAG_VERBOSE`

**Usage context:** Local development, debugging

Prints more log messages that are typically noisy and uninteresting,
but may be useful if you're not seeing what you expect in the output files.

**Default:** Unset (set to any non-empty value to enable)

### `WCAG_VERSION`

**Usage context:** for building informative docs pinned to a publication version

Indicates WCAG version being built, in `XY` format (i.e. no `.`).
Influences which pages get included, guideline/SC content,
and a few details within pages (e.g. titles/URLs, "New in ..." content).
Also influences base URLs for links to guidelines, techniques, and understanding pages.

Explicitly setting this causes the build to reference guidelines and acknowledgements
published under `w3.org/TR/WCAG{version}`, rather than using the local checkout
(which is effectively the 2.2 Editors' Draft). Note this behavior can be further
altered by `WCAG_FORCE_LOCAL_GUIDELINES`.

Possible values: `22`, `21`

### `WCAG_FORCE_LOCAL_GUIDELINES`

**Usage context:** Only applicable when `WCAG_VERSION` is also set;
should not need to be set manually

When building against a fixed publication version, this overrides the behavior of
loading data from published guidelines, to instead load an alternative local
`guidelines/index.html` (e.g. from a separate git checkout of another branch).
This was implemented to enable preview builds of pull requests targeting the
`WCAG-2.1` branch while reusing the existing build process from `main`.

Possible values: A path relative to the project root, e.g. `../guidelines/index.html`

### `WCAG_MODE`

**Usage context:** should not need to be set manually except in specific testing scenarios

Influences base URLs for links to guidelines, techniques, and understanding pages.
Typically set by specific npm scripts or CI processes.

Note that setting `WCAG_MODE` to any non-empty value (even one not listed below) will also result
in page footers referencing last modified times based on git, rather than the local filesystem.

Possible values:

- Unset **(default)** - Sets base URLs appropriate for local testing
- `editors` - Sets base URLs appropriate for `gh-pages` publishing; used by deploy action
- `publication` - Sets base URLs appropriate for WAI site publishing; used by `publish-w3c` script

### `WCAG_JSON`

Generates `_site/wcag.json`. (This is not done by default, as it adds to build time.)

**Default:** Unset by default; `publish-w3c` scripts set this to a non-empty value.

For more information on the output, see [11ty/json/README.md](json#readme).

### `GITHUB_REPOSITORY`

**Usage context:** Automatically set during GitHub workflows; should not need to be set manually

Influences base URLs for links to guidelines, techniques, and understanding pages,
when `WCAG_MODE=editors` is also set.

**Default:** `w3c/wcag`

## Other points of interest

- The main configuration can be found in top-level `eleventy.config.ts`
- Build commands are defined in top-level `package.json` under `scripts`,
  and can be run via `npm run <name>`
- If you see files named `*.11tydata.*`, these contribute data to the Eleventy build
  (see Template and Directory Data files under
  [Sources of Data](https://www.11ty.dev/docs/data/#sources-of-data))
