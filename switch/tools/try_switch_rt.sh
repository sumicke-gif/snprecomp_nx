#!/bin/sh
export PATH=$DEVKITPRO/devkitA64/bin:$PATH
R=lib/N64ModernRuntime
mkdir -p /tmp/gen /tmp/ro
echo '#define MINIZ_EXPORT' > /tmp/gen/miniz_export.h
INC="-I/tmp/gen -I$R/thirdparty -I$R/ultramodern/include -I$R/librecomp/include -I$R/librecomp/include/librecomp -I$R/ultramodern/include/ultramodern -I$R/librecomp/src -I$R/ultramodern/src -I$R/N64Recomp/include -I$DEVKITPRO/libnx/include -I$DEVKITPRO/portlibs/switch/include"
for d in $R/thirdparty/* $R/N64Recomp/lib/*; do
  INC="$INC -I$d"
  [ -d "$d/include" ] && INC="$INC -I$d/include"
done
INC="$INC -I$(dirname $(find $R/N64Recomp -name rabbitizer.hpp | head -1))"
: > fail_rt.log
for f in $R/ultramodern/src/*.cpp $R/librecomp/src/*.cpp; do
  echo "== $f" >> fail_rt.log
  aarch64-none-elf-g++ -std=gnu++20 -O0 -w -fno-strict-aliasing \
    -march=armv8-a+crc+crypto -mtune=cortex-a57 -mtp=soft -fPIE -D__SWITCH__ \
    $INC -c "$f" -o "/tmp/ro/$(basename "$f").o" 2>>fail_rt.log || echo "FAIL $f" >> fail_rt.log
done
echo finished >> fail_rt.log