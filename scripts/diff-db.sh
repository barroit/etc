#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later

printf '%s\n' $(sqlite3 $1 .tables) | sort | while read table; do
	printf '======= %s\n' $table
	sqlite3 -json $1 "select * from $table;" | \
	jq --sort-keys -c .[] | sort | jq --tab
done
