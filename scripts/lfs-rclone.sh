#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later

# Assume you have rclone with well defined remote. To use this script, inside
# your repo run:
#
# 	git config lfs.standalonetransferagent <id>
# 	git config lfs.customtransfer.<id>.path <path-to-this-script>
#	git config lfs.customtransfer.<id>.args <remote>
#	git config lfs.customtransfer.<id>.concurrent false
#
#	git config --global lfs.transfer.<id>.remote <remote>
#
# Local config doesn't go to remote, so when you clone your repo, there must be
# an error saying clone succeeded, but checkout failed. To solve this, do local
# config again and run:
#
#	git restore --source=HEAD :/
#

set -e

remote=$1

shift

trap 'rm -f .err-$$ .log-$$ && cd .. rmdir lfs-rclone' EXIT

mkdir -p .git/lfs-rclone
cd .git/lfs-rclone

query()
{
	printf '%s' "$2" | jq --raw-output --monochrome-output $1
}

cat2json()
{
	sed ':a; N; $!ba; s/\n/\\n/g' $1
}

while read line; do
	rm -f .err-$$

	event=$(query .event "$line")
	size=$(query .size "$line")
	oid=$(query .oid "$line")

	if [ $event = init ]; then
		printf '{ }\n'

	elif [ $event = upload ]; then
		src=$(query .path "$line")
		dst=$remote/$oid.$size

		rclone copyto --log-file=.log-$$ --no-traverse \
		       $src $dst >/dev/null 2>&1 ||
		printf '%s\n' $? >.err-$$

		printf '{ "event": "complete", "oid": "%s"' $oid

		if [ ! -f .err-$$ ]; then
			printf ' }\n'
			continue
		fi

		printf ', "error": { "code": %s, "message": "%s" } }\n' \
		       $(cat .err-$$) "$(cat2json .log-$$)"

	elif [ $event = download ]; then
		src=$remote/$oid.$size
		dst=.$oid-$$

		rclone copyto --log-file=.log-$$ $src $dst >/dev/null 2>&1 ||
		printf '%s\n' $? >.err-$$

		printf '{ "event": "complete", "oid": "%s"' $oid

		if [ ! -f .err-$$ ]; then
			printf ', "path": "%s" }\n' $(realpath $dst)
			continue
		fi

		printf ', "error": { "code": %s, "message": "%s" } }\n' \
		       $(cat .err-$$) "$(cat2json .log-$$)"

	elif [ $event = terminate ]; then
		exit
	fi
done
