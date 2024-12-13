#!/bin/bash
set -e
cd luckfox-sdk
ln -sf "$PWD/../BoardConfig-SD_CARD-Custom-RV1103_Luckfox_Pico_Mini_A-IPC.mk" .BoardConfig.mk
./build.sh
