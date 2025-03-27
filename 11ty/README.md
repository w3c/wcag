# Eleventy Infrastructure for WCAG Techniques and Understanding

This subdirectory contains ES Modules re-implementing pieces of the
XSLT-based build process using Eleventy.

## Usage

Make sure you have Node.js installed. This has primarily been tested with v20,
the current LTS at time of writing.

If you use [fnm](https://github.com/Schniz/fnm) or [nvm](https://github.com/nvm-sh/nvm) to manage multiple Node.js versions,
you can switch to the recommended version by typing `fnm use` or `nvm use`
(with no additional arguments) while in the repository directory.

Otherwise, you can download an installer from [nodejs.org](https://nodejs.org/).

First, run `npm i` in the root directory of the repository to install dependencies.

Common tasks:

- `npm run build` runs a one-time build
- `npm start` runs a local server with hot-reloading to preview changes as you make them:
  - http://localhost:8080/techniques
  - http://localhost:8080/understanding

Maintenance tasks (for working with Eleventy config and supporting files under this subdirectory):

- `npm run check` checks for TypeScript errors
- `npm run fmt` formats all TypeScript files

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

**Default:** Unset (set to any non-empty value to enable)

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
