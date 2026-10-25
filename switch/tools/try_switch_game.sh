#!/bin/sh
export PATH=$DEVKITPRO/devkitA64/bin:$PATH
R=lib/N64ModernRuntime
mkdir -p /tmp/gen /tmp/rg
echo '#define MINIZ_EXPORT' > /tmp/gen/miniz_export.h
INC="-Iswitch/overrides/include -Iinclude -I/tmp/gen -I$R/thirdparty -I$R/ultramodern/include -I$R/librecomp/include -I$R/librecomp/include/librecomp -I$R/ultramodern/include/ultramodern -I$R/librecomp/src -I$R/ultramodern/src -I$R/N64Recomp/include -I$DEVKITPRO/libnx/include -I$DEVKITPRO/portlibs/switch/include"
for d in $R/thirdparty/* $R/N64Recomp/lib/*; do
  INC="$INC -I$d"
  [ -d "$d/include" ] && INC="$INC -I$d/include"
done
INC="$INC -I$(dirname $(find $R/N64Recomp -name rabbitizer.hpp | head -1))"
: > fail_game.log
CXXF="-std=gnu++20 -O0 -w -fno-strict-aliasing -march=armv8-a+crc+crypto -mtune=cortex-a57 -mtp=soft -fPIE -D__SWITCH__ -DSNP_HAS_RECOMPILED_FUNCS"
for f in src/game/overlay_loader.cpp src/game/rom_version.cpp src/game/spin_wait.cpp src/main/register_overlays.cpp rsp/n_aspMain.cpp; do
  if [ ! -f "$f" ]; then echo "MISSING $f" >> fail_game.log; continue; fi
  echo "== $f" >> fail_game.log
  aarch64-none-elf-g++ $CXXF $INC -c "$f" -o "/tmp/rg/$(basename $f).o" 2>>fail_game.log || echo "FAIL $f" >> fail_game.log
done
CF="-std=gnu17 -O0 -w -Wno-error=implicit-function-declaration -fno-strict-aliasing -march=armv8-a+crc+crypto -mtune=cortex-a57 -mtp=soft -fPIE -D__SWITCH__"
for f in RecompiledPatches/patches.c RecompiledPatches/patches_bin.c; do
  echo "== $f" >> fail_game.log
  aarch64-none-elf-gcc $CF -Iinclude -IRecompiledPatches -I$R/ultramodern/include -I$R/librecomp/include -I$R/N64Recomp/include -c "$f" -o "/tmp/rg/$(basename $f).o" 2>>fail_game.log || echo "FAIL $f" >> fail_game.log
done
echo finished >> fail_game.log