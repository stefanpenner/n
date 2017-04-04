#!/usr/bin/env fish
mkdir -p tmp/

if test -d tmp/n
  cd tmp/n
  git fetch
  git clean -fdx
  git reset --hard origin/master
else
  git clone git@github.com:stefanpenner/n.git tmp/n/
  cd tmp/n
end
cd -

set -x PATH ./node_modules/.bin/ $PATH

for FILE in *.md
  nomdown < $FILE > tmp/n/$FILE
end

cd tmp/n
git add .
git commit -m "update"
git push origin master
cd -
