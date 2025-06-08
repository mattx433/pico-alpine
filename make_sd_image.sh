#!/bin/bash
set -e

TARGET=output/sd.img
[ -f $TARGET ] && rm $TARGET
fallocate -l 60M $TARGET

## PARTITIONS ##
sgdisk --clear --mbrtogpt $TARGET
# 4MiB partition for Rockchip miniloader
# using the Android bootloader partition type as it's the closest match
sgdisk --set-alignment=64 --new=1:64:8255 --change-name=1:idblock -t 1:a000 $TARGET
# 4MiB partition for U-Boot
# using the U-Boot bootloader partition type
sgdisk --set-alignment=64 --new=2:16384:24575 --change-name=2:uboot -t 2:b000 $TARGET
# 4MiB partition for trusted firmware (currently unused)
# using Android QSEE/tz partition type as it's the closest match
sgdisk --set-alignment=64 --new=3:24576:32767 --change-name=3:trust -t 3:a016 $TARGET
# 32KiB partition for U-Boot environment
# using the Linux reserved partition type as there's nothing that seems to match
sgdisk --set-alignment=64 --new=4:32768:32831 --change-name=4:env -t 4:8301 $TARGET
# rest of the disk goes to rootfs
sgdisk --set-alignment=64 --new=5:32832:$(sgdisk --end-of-largest $TARGET) --change-name=5:rootfs -t 5:8300 $TARGET

## INSTALLATION ##
dd if=output/idblock.img of=$TARGET bs=512 seek=64 conv=notrunc
dd if=output/u-boot.itb of=$TARGET bs=512 seek=16384 conv=notrunc

## LOOP SETUP ##
LOOPDEV=$(losetup -f)
losetup $LOOPDEV $TARGET
kpartx -a $LOOPDEV
MAPPER=$(echo $LOOPDEV | sed "s+loop+mapper/loop+g")

## ROOTFS INSTALLATION ##
mkdir mnt
mkfs.ext4 ${MAPPER}p5
mount ${MAPPER}p5 mnt
tar -C mnt -xpf output/rootfs.tar.gz
mkdir -p mnt/boot
cp output/zImage mnt/boot
cp vendor/linux-rockchip/arch/arm/boot/dts/rv1103g-luckfox-pico-mini.dtb mnt/boot
umount mnt
rmdir mnt

## LOOP TEARDOWN ##
kpartx -d $LOOPDEV
losetup -d $LOOPDEV
