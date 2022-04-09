#!/bin/bash

# The arm64 bit PreeMT Patch for RT-Linux OS on Raspbian x64 BullsEye #
#https://github.com/raspberrypi/linux #### pi kernel source ####
#https://wiki.linuxfoundation.org/realtime/start #### rt patch for preemt kernel ####
#https://cdn.kernel.org/pub/linux/kernel/projects/rt/5.15/ #### latest rt patch ####

# Define environment variables to the target source kernel

KERNEL_VERSION=5.15
RT_PATCH_VERSION=$KERNEL_VERSION.32-rt39
DEFCONFIG=bcm2711_defconfig
ARCH=arm
TARGET=arm-linux-gnueabihf
#KERNEL=kernel8
 
KERNEL_BRANCH=rpi-$KERNEL_VERSION.y
COMPILER=$TARGET-

# Automatic Zone no input need after this
# All work will be done in $PWD/rtkernel.  The final result will be packaged as $PWD/rtkernel/result
PROJECT_DIR=`pwd`/rtkernel
rm -rf $PROJECT_DIR
mkdir $PROJECT_DIR
cd $PROJECT_DIR

# update && upgrade and install necessary dependency packages
sudo apt update 
sudo apt upgrade -y
sudo apt install -y wget git bc bison flex libssl-dev make libc6-dev libncurses5-dev crossbuild-essential-armhf crossbuild-essential-arm64

# download the kernel source code
git clone --branch $KERNEL_BRANCH https://github.com/raspberrypi/linux

# download the RT patch and extract it in the source directory
wget http://cdn.kernel.org/pub/linux/kernel/projects/rt/$KERNEL_VERSION/older/patch-$RT_PATCH_VERSION.patch.gz
gunzip xf patch-$RT_PATCH_VERSION.patch.gz
 
cd linux

# Need this to get precisely the correct kernel version
git checkout $KERNEL_BRANCH
 
# Patch the kernel
patch -p1 < ../patch-$RT_PATCH_VERSION.patch

# Clean any previous kernel build and prepare a new configuration 
make ARCH=$ARCH CROSS_COMPILE=$COMPILER mrproper
make ARCH=$ARCH CROSS_COMPILE=$COMPILER $DEFCONFIG

# Configure the kernel
# At this step, select "General setup" --> "Preemption Model" --> "Fully Preemptible Kernel (Real-Time)"
make ARCH=$ARCH CROSS_COMPILE=$COMPILER menuconfig
 
# Compile
make -j`nproc` ARCH=$ARCH CROSS_COMPILE=$COMPILER Image modules dtbs

# copy assets to the $PROJECT_DIR/result directory
RESULT_DIR=$PROJECT_DIR/result
mkdir $RESULT_DIR
EXT4_DIR=$RESULT_DIR/ext4
FAT32_DIR=$RESULT_DIR/fat32
mkdir $FAT32_DIR
mkdir $EXT4_DIR
make ARCH=$ARCH CROSS_COMPILE=$COMPILER INSTALL_MOD_PATH=$EXT4_DIR modules_install
cp arch/$ARCH/boot/Image $FAT32_DIR/
cp arch/$ARCH/boot/dts/*.dtb $FAT32_DIR/
mkdir $FAT32_DIR/overlays
cp arch/$ARCH/boot/dts/overlays/*.dtb* $FAT32_DIR/overlays/
# this might show up as non existing file or directory but its not an error
cp arch/$ARCH/boot/dts/overlays/README $FAT32_DIR/overlays/

