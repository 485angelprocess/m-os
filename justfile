nimflags := "--os:any"

bootloader:
  nim c {{nimflags}} --out:build/bootx64.efi src/bootx64.nim

run: bootloader
  mkdir -p diskimg/efi/boot
  cp build/bootx64.efi diskimg/efi/boot/bootx64.efi
  qemu-system-x86_64 \
      -machine q35 \
      -drive if=pflash,format=raw,readonly=on,file=/usr/share/ovmf/OVMF.fd \
      -drive format=raw,file=fat:rw:diskimg \
      -net none
