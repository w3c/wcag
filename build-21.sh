#! /bin/sh

# Download main branch
curl -Lo wcag.tar.gz https://github.com/w3c/wcag/archive/refs/heads/main.tar.gz
tar xf wcag.tar.gz
cd wcag-main
npm i

# Run build using local 2.1 guidelines from active branch
WCAG_VERSION=21 WCAG_FORCE_LOCAL_GUIDELINES=../guidelines/index.html npm run build
