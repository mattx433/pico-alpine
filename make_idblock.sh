#!/bin/bash
set -e
# unfortunately, last time i checked,
# the one in vendor/rk-u-boot/tools/rockchip/boot_merger.c did not work
vendor/rkbin/tools/boot_merger configs/miniloader.ini

