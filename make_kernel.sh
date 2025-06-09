#!/bin/bash
set -e
export ARCH=arm
if [ -z ${CROSS_COMPILE+x} ]; then
  # apt install gcc-arm-none-eabi
  export CROSS_COMPILE=arm-none-eabi-
fi
if [ ! -f vendor/linux-rockchip/.config ]; then
  cp configs/rv1103-linux.config vendor/linux-rockchip/.config
fi
cd vendor/linux-rockchip
make -j$(nproc)
cp arch/arm/boot/zImage ../../output
cp arch/arm/boot/dts/rv1103g-luckfox-pico-mini.dtb ../../output
make modules_install INSTALL_MOD_PATH=$PWD/../../output/modpfx
cd ../../output/modpfx
tar -czvf ../mods.tar.gz lib
cd ..
rm -r modpfx
