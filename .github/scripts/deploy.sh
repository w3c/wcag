#!/bin/bash
set -exu
# e: Exit immediately if a command exits with a non-zero status
# x: Print commands and their arguments as they are executed
# u: Treat unset variables as an error when substituting

git config --global user.email 41898282+github-actions[bot]@users.noreply.github.com
git config --global user.name github-actions[bot]
git config --global user.password $GITHUB_TOKEN

REPO_URL="https://github-actions:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git"

cd ${LOCAL_DIR}

git remote set-url origin "${REPO_URL}"

if [[ -z $(git status --porcelain) ]]; then
    echo "No changes to the output on this push; exiting."
    exit 0
fi

git add -A .
git commit -m ":robot: Deploy to GitHub Pages: $GITHUB_SHA from branch $GITHUB_REF"

git push $REPO_URL $BRANCH

echo done
