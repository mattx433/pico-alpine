ext4load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} /boot/zImage
ext4load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} /boot/rv1103g-luckfox-pico-mini.dtb
bootz ${kernel_addr_r} - ${fdt_addr_r}
