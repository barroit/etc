#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later

set -e

cmd=${1:-mount}

if [ $cmd != mount ] && [ $cmd != umount ]; then
	printf "unknown command '%s'\n" $cmd
	exit 1
fi

trap 'rm -f .tmp-$$' EXIT

cat <<EOF | while read remote local; do
wasabi:barroit	$HOME/wasabi
wasabi:cred	$HOME/cred
EOF
	if mount | grep -q $remote; then
		if [ $cmd = umount ]; then
			umount $local
		fi

		continue

	elif [ $cmd = umount ]; then
		continue
	fi

	mkdir -p $local
	rm -f .tmp-$$

	rclone mount --daemon --vfs-cache-mode=full \
	       $remote $local 2>.tmp-$$ || true

	if [ -f .tmp-$$ ]; then
		rclone mount --vfs-cache-mode=full \
		       $remote $local 2>$local.error || true
	fi
done
