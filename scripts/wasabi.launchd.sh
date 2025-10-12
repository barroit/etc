#!/bin/zsh
# SPDX-License-Identifier: GPL-3.0-or-later

scripts=$(dirname $(readlink -f $0))

trap '$scripts/wasabi.sh umount' SIGTERM

export PATH=$PATH:/usr/local/bin

$scripts/wasabi.sh

tail -f /dev/null &
wait $!
