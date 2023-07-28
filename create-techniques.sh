#!/bin/bash
# $1 = technology
# $2 = filename
# $3 = type
# $4 = title
git checkout -b tech-$2
mkdir techniques/$1
cp techniques/technique-template.html techniques/$1/$2.html
sed -i "s|<p id=\"technology\"></p>|<p id=\"technology\">$1</p>|" techniques/$1/$2.html
sed -i "s|<p id=\"type\"></p>|<p id=\"type\">$3</p>|" techniques/$1/$2.html
sed -i "s|Technique Title|$4|g" techniques/$1/$2.html
git add techniques/$1/$2.html
git commit -m "Set up $2 technique"
git push --set-upstream origin tech-$2
git checkout main