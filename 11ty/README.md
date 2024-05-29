# Eleventy Infrastructure for WCAG Techniques and Understanding

This subdirectory contains ES Modules re-implementing pieces of the
XSLT-based build process using Eleventy.

## Usage

Make sure you have Node.js v20 installed. You can download an installer
from [https://nodejs.org/en](nodejs.org), or use a tool like
[https://github.com/Schniz/fnm](fnm) which allows installing multiple versions locally.

First, run `npm i` in the root directory of the repository to install dependencies.

Common tasks:

- `build` runs a one-time build
- `serve` runs a local server with hot-reloading to preview changes

## Other points of interest

- The main configuration can be found in top-level `eleventy.config.ts`
- Build commands are defined in top-level `package.json` under `scripts`,
  and can be run via `npm run <name>`
- If you see files named `*.11tydata.js`, these contribute data to the Eleventy build
