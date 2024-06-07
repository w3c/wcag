# Eleventy Infrastructure for WCAG Techniques and Understanding

This subdirectory contains ES Modules re-implementing pieces of the
XSLT-based build process using Eleventy.

## Usage

Make sure you have Node.js v20 installed. You can download an installer
from [https://nodejs.org/en](nodejs.org), or use a tool like
[https://github.com/Schniz/fnm](fnm) which allows installing multiple versions locally.

First, run `npm i` in the root directory of the repository to install dependencies.

Common tasks:

- `npm run build` runs a one-time build
- `npm start` runs a local server with hot-reloading to preview changes as you make them:
  - http://localhost:8080/techniques
  - http://localhost:8080/understanding

## Other points of interest

- The main configuration can be found in top-level `eleventy.config.ts`
- Build commands are defined in top-level `package.json` under `scripts`,
  and can be run via `npm run <name>`
- If you see files named `*.11tydata.js`, these contribute data to the Eleventy build
  (see Template and Directory Data files under
  [Sources of Data](https://www.11ty.dev/docs/data/#sources-of-data))