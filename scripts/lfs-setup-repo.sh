#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later
#
#	$ lfs-setup-repo.sh <bucket>
#

set -e

[ -z "$1" ] && printf 'missing bucket\n' >&2 && exit 1

git config lfs.standalonetransferagent $1
git config lfs.customtransfer.$1.path lfs-rclone.sh
git config lfs.customtransfer.$1.args wasabi:$1
git config lfs.customtransfer.$1.concurrent false
