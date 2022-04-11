#!/bin/bash
 
KERNEL_VERSION=5.10
RT_PATCH_VERSION=$KERNEL_VERSION.35-rt39
COMMIT_HASH=53a5ac4935c500d32bfc465551cc5107e091c09c
DEFCONFIG=bcm2709_defconfig
ARCH=arm
TARGET=arm-linux-gnueabihf
 
KERNEL_BRANCH=rpi-$KERNEL_VERSION.y
COMPILER=$TARGET-
 
# All work will be done in $PWD/rtkernel.  The final result will be packaged as $PWD/rtkernel/result
PROJECT_DIR=`pwd`/rtkernel
rm -rf $PROJECT_DIR
mkdir $PROJECT_DIR
cd $PROJECT_DIR
 
# install necessary packages
sudo apt update
sudo apt install -y wget git bc bison flex libssl-dev make libc6-dev libncurses5-dev crossbuild-essential-armhf
 
# download the kernel and RT patch
git clone --branch $KERNEL_BRANCH https://github.com/raspberrypi/linux
 
wget http://cdn.kernel.org/pub/linux/kernel/projects/rt/$KERNEL_VERSION/older/patch-$RT_PATCH_VERSION.patch.gz
gunzip xf patch-$RT_PATCH_VERSION.patch.gz
 
cd linux
 
# Need this to get precisely the correct kernel version
git checkout $COMMIT_HASH
 
# Patch the kernel
patch -p1 < ../patch-$RT_PATCH_VERSION.patch
 
# Prepare configuration
make ARCH=$ARCH CROSS_COMPILE=$COMPILER mrproper
make ARCH=$ARCH CROSS_COMPILE=$COMPILER $DEFCONFIG
 
# Configure the kernel
# At this step, select "General setup" --> "Preemption Model" --> "Fully Preemptible Kernel (Real-Time)"
make ARCH=$ARCH CROSS_COMPILE=$COMPILER menuconfig
 
# Compile
make -j16 ARCH=$ARCH CROSS_COMPILE=$COMPILER zImage modules dtbs
 
# copy assets to the $PROJECT_DIR/result directory
RESULT_DIR=$PROJECT_DIR/result
mkdir $RESULT_DIR
EXT4_DIR=$RESULT_DIR/ext4
FAT32_DIR=$RESULT_DIR/fat32
mkdir $FAT32_DIR
mkdir $EXT4_DIR
make ARCH=$ARCH CROSS_COMPILE=$COMPILER INSTALL_MOD_PATH=$EXT4_DIR modules_install
cp arch/$ARCH/boot/zImage $FAT32_DIR/
cp arch/$ARCH/boot/dts/*.dtb $FAT32_DIR/
mkdir $FAT32_DIR/overlays
cp arch/$ARCH/boot/dts/overlays/*.dtb* $FAT32_DIR/overlays/
cp arch/$ARCH/boot/dts/overlays/README $FAT32_DIR/overlays/
