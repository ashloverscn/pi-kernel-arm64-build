#!/bin/bash
whoami
# The arm64 bit PreeMPT Patch for RT-Linux OS on Raspbian x64 BullsEye #
#https://github.com/raspberrypi/linux #### pi kernel source ####
#https://wiki.linuxfoundation.org/realtime/start #### rt patch for preempt kernel ####
#https://cdn.kernel.org/pub/linux/kernel/projects/rt/5.15/ #### latest rt patch ####

# Define environment variables to the target source kernel

KERNEL_VERSION=5.15
# You need to match the linux kernel source sub version with the patch sub version 
# To check current sub version run "head Makefile -n 3" inside source directory
RT_PATCH_VERSION=$KERNEL_VERSION.34-rt40
DEFCONFIG=bcm2711_defconfig
# 32-bit # kernel7 # For Raspberry Pi2,3,3+ and Zero2W # bcm2709_defconfig #
# 32-bit # kernel7l # For Raspberry Pi 4 and 400 # bcm2711_defconfig #
# 32-bit # kernel # For Raspberry Pi 1, Zero and Zero W and CM1 # bcmrpi_defconfig #
# 64-bit # kernel8 # For Raspberry Pi3,3+,4,400,Zero2W,andCM3, 3+ and 4 # bcm2711_defconfig #
KERNEL=kernel8-rt # kernel file name that will be installed on the boot
#LINUX=zImage # for 32 bit
LINUX=Image # for 64 bit
KERNEL_BRANCH=rpi-$KERNEL_VERSION.y

# Automatic Zone no input need after this
# All work will be done in $PWD/rtkernel.  The final result will be packaged as $PWD/rtkernel/result
PROJECT_DIR=`pwd`/rtkernel-$KERNEL_VERSION
#rm -rf $PROJECT_DIR
mkdir $PROJECT_DIR
cd $PROJECT_DIR

# update && upgrade and install necessary dependency packages
#sudo apt update --allow-releaseinfo-change
sudo apt update 
#sudo apt upgrade -y
sudo apt install -y wget git bc bison flex libssl-dev make libc6-dev libncurses5-dev crossbuild-essential-armhf crossbuild-essential-arm64

# download the kernel source code
git clone --branch $KERNEL_BRANCH https://github.com/raspberrypi/linux

# download the RT patch and extract it in the source directory
wget http://cdn.kernel.org/pub/linux/kernel/projects/rt/$KERNEL_VERSION/older/patch-$RT_PATCH_VERSION.patch.gz
gunzip xf patch-$RT_PATCH_VERSION.patch.gz
 
cd linux

# clean previous build
make clean
# Need this to get precisely the correct kernel version
git checkout $KERNEL_BRANCH
 
# Patch the kernel
patch -p1 < ../patch-$RT_PATCH_VERSION.patch

# Clean any previous kernel build and prepare a new configuration 
make mrproper
make $DEFCONFIG

# Configure the kernel
# At this step, select "General setup" --> "Preemption Model" --> "Fully Preemptible Kernel (Real-Time)"
# For 64 bit processors, unselect (inside menu only, not whole tree) "Virtualization" -->  "Kernel-based Virtual Machine (KVM) support (NEW)"
make menuconfig

# Compile
make -j`nproc` $LINUX modules dtbs

# install modules to the default modules directory
make modules_install

# For 32 bit copy boot files to boot partition
if [ $LINUX = "zImage" ]
then
echo "installing 32bit kernel"
sudo cp arch/arm/boot/zImage /boot/$KERNEL.img
sudo cp arch/arm/boot/dts/*.dtb /boot/
sudo cp arch/arm/boot/dts/overlays/*.dtb* /boot/overlays/
sudo cp arch/arm/boot/dts/overlays/README /boot/overlays/
fi

# For 64 bit copy boot files to boot partition
if [ $LINUX = "Image" ]
then
echo "installing 64bit kernel"
sudo cp arch/arm64/boot/Image /boot/$KERNEL.img
sudo cp arch/arm64/boot/dts/broadcom/*.dtb /boot/
sudo cp arch/arm64/boot/dts/overlays/*.dtb* /boot/overlays/
sudo cp arch/arm64/boot/dts/overlays/README /boot/overlays/
fi

echo "All complete,  MODULES, DTBS and BOOT files copied to respective partition on the sdcard"
echo "Create an entry in the /boot/config.txt of rpi's sdcard as "kernel=$KERNEL.img" and reboot to boot in new kernel"

