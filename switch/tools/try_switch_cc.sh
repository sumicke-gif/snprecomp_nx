#!/bin/sh
export PATH=$DEVKITPRO/devkitA64/bin:$PATH
mkdir -p /tmp/o
: > fail.log
for f in RecompiledFuncs/*.c; do
  aarch64-none-elf-gcc -std=gnu17 -O0 -w -fno-strict-aliasing \
    -march=armv8-a+crc+crypto -mtune=cortex-a57 -mtp=soft -fPIE \
    -include include/snp_recomp_hooks.h -Iinclude \
    -Ilib/N64ModernRuntime/ultramodern/include \
    -Ilib/N64ModernRuntime/librecomp/include \
    -Ilib/N64ModernRuntime/N64Recomp/include \
    -c "$f" -o "/tmp/o/$(basename "$f").o" 2>>fail.log || echo "FAIL $f" >> fail.log
done
echo finished >> fail.log