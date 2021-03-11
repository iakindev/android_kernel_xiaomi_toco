export ARCH=arm64
export SUBARCH=arm64
export DTC_EXT=/home/disty/bin/dtc

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
                      CROSS_COMPILE=aarch64-linux-gnu- | tee kernel.log
