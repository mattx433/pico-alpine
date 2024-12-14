#!/bin/bash
set -xe

## CHECK QEMU ##
[ ! -f /proc/sys/fs/binfmt_misc/qemu-arm ] && echo "need qemu-arm" && exit 1 || true

## CHECK ROOT ##
[ "$EUID" -ne 0 ] && echo "need root" && exit 1 || true

## CLEANUP PAST ##
# not using rm -rf in case there are mounts inside the rootfs
[ -d rootfs ] && mv rootfs rootfs.old$(date "+%Y%m%d%H%M%S") || true
rm -f rootfs.tar.gz rootfs.tar luckfox-sdk/prebuilt_rootfs.tar.gz

## GET ROOTFS ##
wget https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/armv7/alpine-minirootfs-3.21.0-armv7.tar.gz -O rootfs.tar.gz

## UNPACK ROOTFS ##
mkdir rootfs
tar -C rootfs -xpzf rootfs.tar.gz --numeric-owner
rm rootfs.tar.gz

## SERIAL LOGIN ##
cp inittab rootfs/etc/inittab
echo "ttyFIQ0" >> rootfs/etc/securetty

## ADD EXTRA PACKAGES ##
# util-linux: provides full version of dmesg, mount etc
# ckermit: provides file transfer over serial
# e2fsprogs: provides fsck.ext4
# e2fsprogs-extra: provides resize2fs
# gptfdisk: allows editing GPT partition tables
cp --dereference /etc/resolv.conf rootfs/etc/resolv.conf
chroot rootfs /bin/sh -c "apk add util-linux ckermit e2fsprogs e2fsprogs-extra gptfdisk"

## ADD OPENRC ##
chroot rootfs /bin/sh -c "apk add openrc"
chroot rootfs /bin/sh -c "rc-update add devfs sysinit"
chroot rootfs /bin/sh -c "rc-update add procfs sysinit"
chroot rootfs /bin/sh -c "rc-update add sysfs sysinit"
chroot rootfs /bin/sh -c "rc-update add root boot"
chroot rootfs /bin/sh -c "rc-update add swclock boot"
chroot rootfs /bin/sh -c "rc-update add seedrng boot"

## REMOVE RESOLV.CONF ##
chroot rootfs /bin/sh -c "rm /etc/resolv.conf"

## REPACK ROOTFS ##
tar -C rootfs -cpzf luckfox-sdk/sysdrv/tools/board/custom/custom.tar.gz .

## CLEANUP ##
# rm -rf is not as bad of an idea if script went OK
rm -rf --one-file-system rootfs
