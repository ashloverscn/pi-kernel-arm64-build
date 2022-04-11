# pi-kernel-arm64-build
compile the raspberry pi kernel from source with PreeMT patch .This is the standard way to compile and setup toolchain for cross compilation of kernal for raspberry as per the rasberry foundation, up to date documentation. I found a shell script for doing this with arm 32 bit , but i was only convinced when i tested it for my self and tweaked the shell script . I will be commiting more build script for specific build and with new tweaks as much as possible

dont forget to check me out on 
https://youtube.com/ashloverscn
https://github.com/ashloverscn

how to's:
first clone the repo : 
git clone https://github.com/ashloverscn/pi-kernel-arm64-build.git

go inside the source directory : 
cd pi-kernel-arm64-build

always make script executable by doing: 
sudo chmod +x <scriptname>.sh

finally execute the script and grab a cup of coffee:
sudo ./<scriptname>.sh

Testing real-time capabilites using cyclictest utility
Installing cyclictest utility on Raspberry Pi:

git clone git://git.kernel.org/pub/scm/linux/kernel/git/clrkwllms/rt-tests.git 
cd rt-tests
make all
cp ./cyclictest /usr/bin/
cd ~
Testing real-time:

sudo cyclictest -l1000000 -m -n -a0 -t1 
