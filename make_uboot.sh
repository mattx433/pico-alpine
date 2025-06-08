#!/bin/bash
set -e
export ARCH=arm
if [ -z ${CROSS_COMPILE+x} ]; then
  # apt install gcc-arm-none-eabi
  export CROSS_COMPILE=arm-none-eabi-
fi
if [ ! -f vendor/rk-u-boot/.config ]; then
  cp configs/rv1103-uboot.config vendor/rk-u-boot/.config
fi
cd vendor/rk-u-boot
make -j$(nproc)
make -j$(nproc) u-boot.itb
cp u-boot.itb ../../output
