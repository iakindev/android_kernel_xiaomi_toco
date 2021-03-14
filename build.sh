export ARCH=arm64
export SUBARCH=arm64
export DTC_EXT=dtc
export KBUILD_COMPILER_STRING="$($HOME/development/proton-clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"

echo CLEAN OUT
rm out -rf
mkdir out

echo DEFCONFIG
make  O=out ARCH=arm64 toco_user_defconfig #$DEFCONFIG

echo MENUCONFIG
make O=out menuconfig

PATH="$HOME/development/proton-clang/bin:$PATH" \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=clang \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      NM=llvm-nm \
                      OBJCOPY=llvm-objcopy \
                      OBJDUMP=llvm-objdump \
                      STRIP=llvm-strip \
                      LD=ld.lld | tee kernel.log
