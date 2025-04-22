#!/bin/bash
set -e
cd luckfox-sdk
ln -sf "$PWD/../BoardConfig-SD_CARD-Custom-RV1103_Luckfox_Pico_Mini_A-IPC.mk" .BoardConfig.mk
# hack: workaround when using remainder of storage as rootfs
sed -i 's/echo "0"/echo "128000000"/' project/build.sh
./build.sh
# hack: make it upload images even if the build fails
exit 0
