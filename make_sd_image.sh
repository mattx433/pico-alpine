#!/bin/bash
set -e

TARGET=output/sd.img
[ -f $TARGET ] && rm $TARGET
fallocate -l 128M $TARGET

## PARTITIONS ##
sgdisk --clear --mbrtogpt $TARGET
# 4MiB partition for Rockchip miniloader
# using the Android bootloader partition type as it's the closest match
sgdisk --set-alignment=64 --new=1:64:8255 --change-name=1:idblock -t 1:a000 $TARGET
# 4MiB partition for U-Boot
# using the U-Boot bootloader partition type
sgdisk --set-alignment=64 --new=2:16384:24575 --change-name=2:uboot -t 2:b000 $TARGET
# 32KiB partition for U-Boot environment
# using the Linux reserved partition type as there's nothing that seems to match
sgdisk --set-alignment=64 --new=3:24576:24639 --change-name=3:env -t 3:8301 $TARGET
# rest of the disk goes to rootfs, which is also marked bootable
sgdisk --set-alignment=64 --new=4:24640:$(sgdisk --end-of-largest $TARGET) --change-name=4:rootfs -t 4:8300 --attributes=4:set:2 $TARGET

## U-BOOT ENVIRONMENT ##
mkenvimage -s 0x8000 -o output/env.img configs/default-env.txt
chmod 644 output/env.img

## INSTALLATION ##
dd if=output/idblock.img of=$TARGET bs=512 seek=64 conv=notrunc
dd if=output/u-boot.itb of=$TARGET bs=512 seek=16384 conv=notrunc
dd if=output/env.img of=$TARGET bs=512 seek=24576 conv=notrunc

## LOOP SETUP ##
LOOPDEV=$(losetup -f)
losetup $LOOPDEV $TARGET
kpartx -a $LOOPDEV
MAPPER=$(echo $LOOPDEV | sed "s+loop+mapper/loop+g")

## ROOTFS INSTALLATION ##
mkdir mnt
mkfs.ext4 ${MAPPER}p4
mount ${MAPPER}p4 mnt
tar -C mnt -xpf output/rootfs.tar.gz
mkdir -p mnt/boot
cp output/zImage mnt/boot
cp output/rv1103g-luckfox-pico-mini.dtb mnt/boot
mkimage -A arm -T script -C none -n 'System boot script' -d configs/boot.cmd mnt/boot/boot.scr
umount mnt
rmdir mnt

## LOOP TEARDOWN ##
kpartx -d $LOOPDEV
losetup -d $LOOPDEV
