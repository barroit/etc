#! /usr/bin/awk -f
# SPDX-License-Identifier: GPL-3.0-or-later
#
# You should really ensure your /etc/hosts has record like:
#
#	127.0.0.1         macos.dev
#
# And tags in config are well defined and no nesting. Otherwise, script behavior
# is undefined.

BEGIN {
	pretag = "^[ \t]*(#|\/\/) "

	"grep \.dev$ /etc/hosts | grep 127.0.0.1" | getline

	target = $2
}

$0 ~ pretag && /<dev-.+>$/ {
	split($2, fields, /[-<>]/)
	match($0, /^[ \t]*/)

	device = fields[3] ".dev"
	comment = $1
}

! /<\/?dev-.+>$/ && device == target {
	if (filter == "smudge")
		sub(/(#|\/\/) /, "")
	else if (filter == "clean")
		sub(/[ \t]*/, "&" comment " ")
}

$0 ~ pretag && /<\/dev-.+>$/ {
	device = ""
}

{
	print
}
