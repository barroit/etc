#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later

set -e

branch=$(git branch --show-current)

if [ -z "$(git for-each-ref --format '%(upstream:short)' $branch)" ]; then
	git push --set-upstream origin $branch
else
	git push
fi

if [ $(git status --porcelain | wc -l) -eq 0 ]; then
	exit
fi

trap 'git reset HEAD^' EXIT

git add .
git commit -smTMP

if [ $(uname -o) = GNU/Linux ]; then
	target=node.raider
else
	target=node.lancer
fi

upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
remote=${upstream%%/*}
branch=${upstream#*/}
repo=$(git remote get-url $remote)

name=$(basename $PWD)
dir=$(dirname $PWD)

git format-patch HEAD~1 --stdout | ssh $target "
set -e

export PATH=\"\$HOME/.local/bin:\$PATH\"

trap 'git remote | grep -xqF mvtree && git remote remove mvtree' EXIT

cd \$HOME/${dir#$HOME/}

if [ ! -d $name ]; then
	git clone $repo $name
fi

cd $name

git remote add mvtree $repo
git fetch --all

git switch -C $branch
git reset --hard mvtree/$branch

git am -

git reset HEAD^
"

trap 'git reset --hard HEAD^' EXIT
