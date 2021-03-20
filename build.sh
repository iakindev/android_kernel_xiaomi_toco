#!/bin/sh

export ARCH=arm64
export SUBARCH=arm64
export DTC_EXT=dtc
export KBUILD_COMPILER_STRING="$($HOME/development/proton-clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"

COMPRESSION="gz"
RELEASE="r1"
OUT_ZIP="toco-experimentum-4-14-226-$RELEASE"
THREAD_COUNT=$(($(nproc --all)-1)) # Keep minus 1 for responsive desktop experience while building on relatively old systems.

echo --CLEAN OUT
echo - cleaning out
rm -rf out
echo - cleaning generated Image
rm _anykernel/Image.$COMPRESSION-dtb
echo - cleaning generated zip
rm $OUT_ZIP
echo - generate out directory
mkdir out

echo DEFCONFIG
make  O=out ARCH=arm64 toco_user_defconfig

echo MENUCONFIG
make O=out menuconfig

PATH="$HOME/development/proton-clang/bin:$PATH" \
make -j$THREAD_COUNT O=out \
                      ARCH=arm64 \
                      CC=clang \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      NM=llvm-nm \
                      OBJCOPY=llvm-objcopy \
                      OBJDUMP=llvm-objdump \
                      STRIP=llvm-strip \
                      LD=ld.lld | tee kernel.log

cp out/arch/arm64/boot/Image.$COMPRESSION-dtb _anykernel/

(cd _anykernel; zip -r ../toco-experimentum.zip .)