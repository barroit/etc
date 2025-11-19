#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later

set -e

branch=$(git branch --show-current)

if [ -z "$(git for-each-ref --format '%(upstream:short)' $branch)" ]; then
	git push --set-upstream origin $branch
else
	git push
fi

git add .
git commit -smTMP

trap 'git reset HEAD^' EXIT

if [ $(uname -o) = GNU/Linux ]; then
	host=node.raider
else
	host=node.lancer
fi

upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
remote=${upstream%%/*}
branch=${upstream#*/}
remote_url=$(git remote get-url $remote)

git format-patch HEAD~1 --stdout | ssh $host "
set -e

trap 'git remote | grep -xqF mvtree && git remote remove mvtree' EXIT

cd \$HOME/${PWD#$HOME/}
export PATH=\$HOME/.local/bin:\$PATH

git remote add mvtree $remote_url

git fetch mvtree $branch
git switch -C $branch
git reset --hard mvtree/$branch

git am -

git reset HEAD^
"

trap 'git reset --hard HEAD^' EXIT
