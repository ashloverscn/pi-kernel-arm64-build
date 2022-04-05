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


