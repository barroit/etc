#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later

set -e

cd /lib/modules/$(uname -r)/updates/dkms

export PATH="/usr/src/linux-headers-$(uname -r)/scripts:$PATH"

ls | cut -d. -f1-2 | while read name; do
	sudo zstd -d $name.zst

	sudo /usr/src/linux-headers-$(uname -r)/scripts/sign-file \
	     sha256 $HOME/.mok/secureboot $HOME/.mok/secureboot.crt $name

	sudo zstd -f $name

done

sudo rm -f *.ko
sudo depmod
