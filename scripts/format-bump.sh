#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later

set -e

ver=$1
name=$(head -n1 README)

printf %s "$ver" | grep -xq '[[:digit:]]\.[[:digit:]]\.[[:digit:]]'
test -n "$name"

if [ -n "$TAG_PREFIX" ]; then
	prefix="$TAG_PREFIX-"
fi

cat <<-EOF
	commit	$name $ver
	tag	${prefix}v$ver
EOF
