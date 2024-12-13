#!/bin/bash
set -e
cd luckfox-sdk
ln -sf project/cfg/BoardConfig_IPC/BoardConfig-SD_CARD-Buildroot-RV1103_Luckfox_Pico_Mini_A-IPC.mk .BoardConfig.mk
echo "export CONFIG_USE_PREBUILT_ROOTFS=y" >> .BoardConfig.mk
echo "export RK_BOOTARGS_CMA_SIZE=1K" >> .BoardConfig.mk
./build.sh
