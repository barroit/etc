#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later

set -e

cd /lib/modules/$(uname -r)/updates/dkms
trap 'sudo rm -f *.ko' EXIT

ls | cut -d. -f1-2 | while read name; do
	sudo zstd -d $name.zst
	sudo /usr/src/linux-headers-$(uname -r)/scripts/sign-file \
	     sha256 $HOME/.mok/secureboot $HOME/.mok/secureboot.crt $name
	sudo zstd -f $name
done

sudo rm -f *.ko
trap - EXIT

cd /lib/modules/$(uname -r)/misc

ls | while read name; do
	sudo /usr/src/linux-headers-$(uname -r)/scripts/sign-file \
	     sha256 $HOME/.mok/secureboot $HOME/.mok/secureboot.crt $name

	sudo modprobe ${name%.ko}
done

sudo depmod
