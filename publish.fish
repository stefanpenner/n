#!/usr/bin/env fish
mkdir -p tmp/

if test -d tmp/n
  cd tmp/n
  git fetch
  git clean -fdx
  git checkout gh-pages
  git reset --hard origin/gh-pages
else
  git clone git@github.com:stefanpenner/n.git tmp/n/
  git checkout gh-pages
  cd tmp/n
end
cd -

ember build

for FIlE in tmp/n/**/*
  echo "rm $FILE"
  git rm $FILE
end

cp -r dist/ tmp/n

cd tmp/n
  git add .
  git commit -m "update"
  git push origin gh-pages:gh-pages
cd -
