#!/bin/bash
rm .version
# Bash Color
green='\033[01;32m'
red='\033[01;31m'
cyan='\033[01;36m'
blue='\033[01;34m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
DEFCONFIG="msm8909_a16c3h_defconfig"
KERNEL="zImage"

#Hyper Kernel Details
BASE_VER="CAF-ARM-A16C3H"
VER="-$(date +"%Y-%m-%d"-%H%M)-"
Hyper_VER="$BASE_VER$VER$TC"

# Vars
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER=padang
export KBUILD_BUILD_HOST=fzkdevmod
export LOCALVERSION="-g9fzkd3v"

# Paths
KERNEL_DIR=`pwd`
RESOURCE_DIR="/home/fzk/hasil"
ANYKERNEL_DIR="$RESOURCE_DIR/hyper"
TOOLCHAIN_DIR="/home/fzk/devmod/toolchain"
REPACK_DIR="$ANYKERNEL_DIR"
PATCH_DIR="$ANYKERNEL_DIR/patch"
MODULES_DIR="$ANYKERNEL_DIR/modules"
ZIP_MOVE="$RESOURCE_DIR/kernel_out"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm/boot"
FINAL_DIR="/home/fzk/rendang_kernel"

# Functions
function make_kernel {
		make $DEFCONFIG $THREAD
		make $THREAD
		make dtbs $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

#function make_modules {
#		cd $KERNEL_DIR
#		make modules $THREAD
#		find $KERNEL_DIR -name '*.ko' -exec cp {} $MODULES_DIR/ \;
#		cd $MODULES_DIR
#       $STRIP --strip-unneeded *.ko
#      cd $KERNEL_DIR
#}

function make_dtb {
		$KERNEL_DIR/dtbToolCM -2 -o $KERNEL_DIR/arch/arm/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
		cp -vr $KERNEL_DIR/arch/arm/boot/dt.img $REPACK_DIR/dtb
}

function make_zip {
		cd $REPACK_DIR
		zip -r `echo $Hyper_VER$TC`.zip *
		mv  `echo $Hyper_VER$TC`.zip $ZIP_MOVE
		cd $ZIP_MOVE
		cp  `echo $Hyper_VER$TC`.zip $FINAL_DIR
		cd $KERNEL_DIR
}

DATE_START=$(date +"%s")


echo -e "${green}"
echo "--------------------------------------------------------"
echo "Wellcome !!!   Initiatig To Compile $Hyper_VER    "
echo "--------------------------------------------------------"
echo -e "${restore}"

echo -e "${cyan}"
while read -p "Plese Select Desired Toolchain for compiling FzkDevmod Kernel

GOOGLE-TC-4.8 (ARM)---->(1)

LINARO-7.3 (ARM)---->(2)


" echoice
do
case "$echoice" in
	1 )
		export CROSS_COMPILE=$TOOLCHAIN_DIR/google/arm-eabi-4.8-android/bin/arm-eabi-
		export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/google/arm-eabi-4.8-android/lib/
		STRIP=$TOOLCHAIN_DIR/google/arm-eabi-4.8-android/bin/arm-eabi-strip
		TC="GCC"
		rm -rf $MODULES_DIR/*
		rm -rf $ZIP_MOVE/*
		rm -rf $KERNEL_DIR/arch/arm/boot/dt.img
		cd $ANYKERNEL_DIR
		rm -rf zImage
		rm -rf dtb
		cd $KERNEL_DIR
		make clean && make mrproper
		echo "cleaned directory"
		echo "Compiling Kernel Using GOOGLE-TC-4.8 Toolchain"
		break
		;;
	2 )
		export CROSS_COMPILE=$TOOLCHAIN_DIR/linaro/arm/gcc-linaro-7.3.1-2018.05-x86_64_arm-eabi/bin/arm-eabi-
		export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/linaro/arm/gcc-linaro-7.3.1-2018.05-x86_64_arm-eabi/lib/
		STRIP=$TOOLCHAIN_DIR/linaro/arm/gcc-linaro-7.3.1-2018.05-x86_64_arm-eabi/bin/arm-eabi-strip
		TC="LN"
		rm -rf $MODULES_DIR/*
		rm -rf $ZIP_MOVE/*
		rm -rf $KERNEL_DIR/arch/arm/boot/dt.img
		cd $ANYKERNEL_DIR
		rm -rf zImage
		rm -rf dtb
		cd $KERNEL_DIR
		make clean && make mrproper
		echo "cleaned directory"
		echo "Compiling Kernel Using LINARO-7.3 Toolchain"
		break
		;;

	* )
		echo
		echo "Invalid Selection try again !!"
		echo
		;;
esac
done
echo -e "${restore}"

echo
while read -p "Do you want to start Building FzkDevmod Kernel ?

Yes Or No ? 

Enter Y for Yes Or N for No
" dchoice
do
case "$dchoice" in
	y|Y )
		make_kernel
		make_dtb
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid Selection try again !!"
		echo
		;;
esac
done
echo -e "${green}"
echo $Hyper_VER$TC.zip
echo "------------------------------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo " "
