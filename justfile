nimflags := "--os:any"

bootloader:
  nim c {{nimflags}} --out:build/bootx64.efi src/boot/bootx64.nim

kernel:
  nim c {{nimflags}} --out:build/kernel.bin src/kernel/main.nim

run: bootloader kernel
  mkdir -p diskimg/efi/boot
  mkdir -p diskimg/efi/fusion
  cp build/bootx64.efi diskimg/efi/boot/bootx64.efi
  cp build/kernel.bin diskimg/efi/fusion/kernel.bin
  qemu-system-x86_64 \
      -machine q35 \
      -drive if=pflash,format=raw,readonly=on,file=/usr/share/ovmf/OVMF.fd \
      -drive format=raw,file=fat:rw:diskimg \
      -net none
