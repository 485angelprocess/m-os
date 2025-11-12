#!/bin/zsh
# nim c \
#     --nimcache:build \
#     --noMain:on \
#     -d:useMalloc \
#     -d:nimNoLibC \
#     -d:noSignalHandler \
#     --cpu:amd64 \
#     --os:any \
#     --cc:clang \
#     --passc:"-target x86_64-unknown-windows" \
#     --passc:"-ffreestanding" \
#     --passc:"-I/usr/include" \
#     --passl:"-target x86_64-unknown-windows" \
#     --passl:"-fuse-ld=lld-link" \
#     --passl:"-nostdlib" \
#     --passl:"-Wl,-entry:main" \
#     --passl:"-Wl,-subsystem:efi_application" \
#     --out:build/main.exe \
#     src/mos.nim

nim c --os:any --out:build/main.efi src/bootx64.nim