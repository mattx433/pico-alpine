#!/bin/bash
set -e
cd luckfox-sdk
ln -sf project/cfg/BoardConfig_IPC/BoardConfig-SPI_NAND-Buildroot-RV1103_Luckfox_Pico_Mini_B-IPC.mk .BoardConfig.mk
echo "export CONFIG_USE_PREBUILT_ROOTFS=y" >> .BoardConfig.mk
echo "export RK_BOOTARGS_CMA_SIZE=1K" >> .BoardConfig.mk
./build.sh
