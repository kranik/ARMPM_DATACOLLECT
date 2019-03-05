#!/bin/bash

# Uncomment for debug
# set -x

# Multiple Distro kernel Update

# Do not edit below unless you are sure.
UDEV_RULE="KERNEL==\"fb1\", SYMLINK+=\"fb6\""
INPUT_RULE="KERNEL==\"event*\", SUBSYSTEM==\"input\", MODE=\"0777\", GROUP=\"adm\""
CEC_RULE="KERNEL==\"CEC\", MODE=\"0777\""

zImage_FEDORA="/boot/zImage"
zImage_UBUNTU="/media/boot/zImage"
zImage_OpenSUSE="/boot/zImage"
BOOT_SCR_UBUNTU="http://builder.mdrjr.net/tools/boot.scr_ubuntu.tar"
BOOT_SCR_UBUNTU_XU="http://builder.mdrjr.net/tools/boot.scr_ubuntu_xu.tar"
BOOT_SCR_OpenSUSE="http://builder.mdrjr.net/tools/boot.scr_opensuse.tar" 
BOOT_SCR_FEDORA19="http://builder.mdrjr.net/tools/boot.scr_fedora19.tar"
BOOT_SCR_FEDORA19_XU="http://builder.mdrjr.net/tools/boot.scr_fedora19_xu.tar"
BOOT_SCR_FEDORA20="http://builder.mdrjr.net/tools/boot.scr_fedora20.tar"
BOOT_SCR_FEDORA20_XU="http://builder.mdrjr.net/tools/boot.scr_fedora20_xu.tar" 

FIRMWARE_URL="http://builder.mdrjr.net/tools/firmware.tar.xz"

DATE=`date +%Y.%m.%d-%H.%M`

start_up() { 
	
	if [ -z "$1" ]; then
		export KERNEL_RELEASE="LATEST"
	else
		export KERNEL_RELEASE="$1"
	fi

	export TEMP="/tmp/Kupdate-$KERNEL_RELEASE"
	export K_PKG_URL="http://builder.mdrjr.net/kernel-3.8/$KERNEL_RELEASE"
	export XU_K_PKG_URL="http://builder.mdrjr.net/kernel-3.4/$KERNEL_RELEASE"
	
	echo "*** Download Release: $KERNEL_RELEASE"
	
	# try to clear up old stuff 
	rm -rf $TEMP
	
	# get board
	get_board

	if [ -f /etc/hk-debian ]; then
		echo "*** Debian Found"
		export DISTRO="debian"
		debian_update
	elif [ -f /etc/fedora-19 ]; then 
		echo "*** Fedora 19 Found" 
		export DISTRO="fedora19"
		fedora19_update
	elif [ -f /etc/fedora-20 ]; then
		echo "*** Fedora 20 Found"
		export DISTRO="fedora20"
		fedora20_update
	elif [ -f /etc/ubuntu-server ]; then
		echo "*** Ubuntu Server Found"
		export DISTRO="ubuntu-server"
		ubuntu_server_update
	elif [ -f /etc/lsb-release ]; then
		echo "*** Ubuntu Found"
		export DISTRO="ubuntu"
		# HDMI Retro Compatibility with 3.0
		install_udev_hdmi_compat
		ubuntu_update
	elif [ -f /etc/SuSE-release ]; then
		echo "*** OpenSUSE Found"
		export DISTRO="opensuse"
		# HDMI Retro Compatibility with 3.0
		install_udev_hdmi_compat
		opensuse_update
	fi
}

get_board() {
	B=`cat /proc/cpuinfo  | grep -i odroid | awk {'print $3'}`
	case "$B" in
		"ODROIDXU")
			export BOARD="odroidxu"
			echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
			echo "*** Found board ODROID-XU"
			;;
		"ODROIDX")
			export BOARD="odroidx"
			echo "*** Found board ODROID-X"
			;;
		"ODROIDX2")
			export BOARD="odroidx2"
			echo "*** Found board ODROID-X2"
			;;
		"ODROID-U2/U3")
			export BOARD="odroidu2"
			echo "*** Found board ODROID-U2/U3"
			;;
		"ODROIDU2")
			export BOARD="odroidu2"
			echo "*** Found board ODROID-U2/U3"
			;;
		*)
			echo "*** Couldn't find board! Aborting"
			exit 0
			;;
	esac
}

install_udev_hdmi_compat() { 
	if [ -f /etc/udev/rules.d/50-hk_hdmi.rules ] && [ "$BOARD" != "odroidxu" ]; then
		echo "*** HDMI Compatibility UDEV rule found.. skipping this step"
	else
		echo "*** Installing HDMI Retro Compatibility UDEV Rule"	
		echo $UDEV_RULE > /etc/udev/rules.d/50-hk_hdmi.rules
	fi
	
	if [ -f /etc/udev/rules.d/40-input.rules ]; then
		echo "*** Input UDEV Rules already installed.. Skipping"
	else
		echo "*** Installing UDEV Input rules"
		echo $INPUT_RULE > /etc/udev/rules.d/40-input.rules
	fi
	
	if [ -f /etc/udev/rules.d/60-cec.rules ]; then
		echo "*** CEC Rules already installed"
	else
		echo "*** Installing CEC Rules"
		echo $CEC_RULE > /etc/udev/rules.d/60-cec.rules
	fi
}

kernel_download() { 
	mkdir $TEMP
	cd $TEMP
	
	case "$DISTRO" in
		"debian")
				apt-get -y install axel
				if [ "$BOARD" != "odroidxu" ]; then
					axel -a $BOOT_SCR_UBUNTU
					axel -n 5 -a $K_PKG_URL/$BOARD.tar.xz
				else
					axel -n 5 -o boot.scr_ubuntu.tar -a $BOOT_SCR_UBUNTU_XU
					axel -n 5 -a $XU_K_PKG_URL/$BOARD.tar.xz
				fi			
			;;
		"ubuntu-server")
				apt-get -y install axel
				if [ "$BOARD" != "odroidxu" ]; then
					axel -a $BOOT_SCR_UBUNTU
					axel -n 5 -a $K_PKG_URL/$BOARD.tar.xz
				else
					axel -o boot.scr_ubuntu.tar -a $BOOT_SCR_UBUNTU_XU
					axel -n 5 -a $XU_K_PKG_URL/$BOARD.tar.xz
				fi			
			;;
		"ubuntu")
				apt-get -y install axel
				if [ "$BOARD" != "odroidxu" ]; then
					axel -a $BOOT_SCR_UBUNTU
					axel -n 5 -a $K_PKG_URL/$BOARD.tar.xz
				else
					axel -o boot.scr_ubuntu.tar -a $BOOT_SCR_UBUNTU_XU
					axel -n 5 -a $XU_K_PKG_URL/$BOARD.tar.xz
				fi
			;;
		"fedora20")
				yum -y install axel
				if [ "$BOARD" != "odroidxu" ]; then
					axel -n 5 -a $BOOT_SCR_FEDORA20
					axel -n 5 -a $K_PKG_URL/$BOARD.tar.xz
				else
					axel -n 5 -a -o boot.scr_fedora20.tar $BOOT_SCR_FEDORA20_XU
					axel -n 5 -a $XU_K_PKG_URL/$BOARD.tar.xz
				fi
			;;
		"fedora19")
				yum -y install axel
				if [ "$BOARD" != "odroidxu" ]; then
					axel -n 5 -a $BOOT_SCR_FEDORA19
					axel -n 5 -a $K_PKG_URL/$BOARD.tar.xz
				else
					axel -n 5 -a -o boot.scr_fedora19.tar $BOOT_SCR_FEDORA19_XU
					axel -n 5 -a $XU_K_PKG_URL/$BOARD.tar.xz
				fi
			;;
		"opensuse")
				if [ "$BOARD" != "odroidxu" ]; then
					wget --progress=bar $K_PKG_URL/$BOARD.tar.xz
					wget --progress=bar $BOOT_SCR_OpenSUSE
				else
					wget --progress=bar $XU_K_PKG_URL/$BOARD.tar.xz
					wget --progress=bar $BOOT_SCR_OpenSUSE_XU
				fi					
			;;
		*)
			echo "Something really bad happen on the download of the boot.scr's... report that!"
			exit 0
			;;
	esac
}

debian_update() {
	echo "*** Starting Kernel Update for Debian"
	kernel_download
	
	echo "*** Backing Up current kernel to /root/kernel-backup-$DATE.tar.gz"
	tar zcf /root/kernel-backup-$DATE.tar.gz /lib/modules /boot
	
	echo "*** Unpacking new Kernel and Modules"
	tar -Jxf $TEMP/$BOARD.tar.xz
	
	echo "*** Starting kernel update"
	cd $TEMP
	tar xf boot.scr_ubuntu.tar
	
	echo "*** Clearing old kernel" 
	rm -rf /boot/* /lib/modules/3.8.13* /lib/modules/3.4*
	
	echo "*** Installing new zImage"
	cp $TEMP/boot/zImage /boot
	
	echo "*** Installing new modules"
	cp -aR $TEMP/lib/* /lib
	
	echo "Installing new uInitrd"
	K_VERSION=`ls $TEMP/boot/config-* | sed s/"-"/" "/g | awk '{printf $3}'`
	depmod -a
	cp $TEMP/boot/config-* /boot
	update-initramfs -c -k $K_VERSION
	mkimage -A arm -O linux -T ramdisk -C none -a 0 -e 0 -n "uInitrd $K_VERSION" -d /boot/initrd.img-$K_VERSION /boot/uInitrd-$K_VERSION
	cp /boot/uInitrd-$K_VERSION /boot/uInitrd
	
	echo "*** Installing new boot.scr's"
	if [ "$BOARD" = "odroidxu" ]; then
		cp $TEMP/xu/* /boot
	elif [ "$BOARD" = "odroidx" ]; then
		cp $TEMP/x/*.scr /boot
	else
		cp $TEMP/x2u2/*.scr /boot
	fi
	
	if [ "$BOARD" = "odroidxu" ]; then
		echo "*** Updating Exynos5 HW Composer"
		axel -o $TEMP/hwc.tar -n 2 -a http://builder.mdrjr.net/tools/debian_hwcomposer.tar
		(cd /usr && tar xf $TEMP/hwc.tar)
		echo "*** HW Composer updated!"
	fi

        if [ "$BOARD" != "odroidxu" ]; then
                linux_firmware_update
        fi
                                
		
	if [ "$BOARD" != "odroidxu" ]; then
		echo "*** Installing 720P60Hz HDMI default boot.scr"
		cp /boot/boot-auto.scr /boot/boot.scr
	fi
	
	echo "*** Check /boot for new available boot.scr's!!!"
	warn_new_bootscrs
}

fedora19_update() {
	mkdir -p $TEMP
	
	cd $TEMP

	echo "*** Starting Kernel Update for Fedora 19"
	kernel_download
	
	echo "*** Backing Up current kernel to /root/kernel-backup-$DATE.tar.gz"
	tar zcf /root/kernel-backup-$DATE.tar.gz /lib/modules /boot
	
	echo "*** Unpacking new Kernel and Modules"
	tar -Jxf $TEMP/$BOARD.tar.xz
	
	echo "*** Starting kernel update"
	tar xf boot.scr_fedora19.tar
	
	echo "*** Clearing old kernel" 
	rm -rf /boot/* /lib/modules/3.8.13* /lib/modules/3.4*
	
	echo "*** Installing new zImage"
	cp $TEMP/boot/zImage /boot/uboot/zImage
	
	echo "*** Installing new modules"
	cp -aR $TEMP/lib/* /lib
	
	echo "Installing new uInitrd"
	K_VERSION=`ls $TEMP/boot/config-* | sed s/"-"/" "/g | awk '{printf $3}'`
	depmod -a
	cp $TEMP/boot/config-* /boot
	
	dracut /boot/initramfs-$K_VERSION $K_VERSION
	
	mkimage -A arm -O linux -T ramdisk -C none -a 0 -e 0 -n "uInitrd $K_VERSION" -d /boot/initramfs-$K_VERSION /boot/uInitrd-$K_VERSION
	cp /boot/uInitrd-$K_VERSION /boot/uboot/uInitrd
	
	echo "*** Installing new boot.scr's"
	if [ "$BOARD" = "odroidxu" ]; then
		cp $TEMP/xu/* /boot/uboot
	elif [ "$BOARD" = "odroidx" ]; then
		cp $TEMP/x/*.scr /boot/uboot
	else
		cp $TEMP/x2u2/*.scr /boot/uboot
	fi
	
	if [ "$BOARD" != "odroidxu" ]; then	
		echo "*** Installing 720P60Hz HDMI default boot.scr"
		cp /boot/uboot/boot-hdmi-720p60hz.scr /boot/uboot/boot.scr
	fi
	
	if [ "$BOARD" != "odroidxu" ]; then
		linux_firmware_update
	fi
	
	if [ "$BOARD" != "odroidxu" ]; then
		echo "*** Fixing MFC firmware"
		cp /lib/firmware/s5p-mfc/* /lib/firmware
	fi
	
	if [ "$BOARD" = "odroidxu" ]; then
		echo "*** Updating Exynos5 HW Composer"
		axel -o $TEMP/hwc.tar -n 2 -a http://builder.mdrjr.net/tools/fedora19_hwcomposer.tar
		(cd /usr && tar xf $TEMP/hwc.tar)
		echo "*** HW Composer updated!"
	fi

	echo "*** Check /boot for new available boot.scr's!!!"
	warn_new_bootscrs
}

fedora20_update() {
	mkdir -p $TEMP
	
	cd $TEMP

	echo "*** Starting Kernel Update for Fedora 20"
	kernel_download
	
	echo "*** Backing Up current kernel to /root/kernel-backup-$DATE.tar.gz"
	tar zcf /root/kernel-backup-$DATE.tar.gz /lib/modules /boot
	
	echo "*** Unpacking new Kernel and Modules"
	tar -Jxf $TEMP/$BOARD.tar.xz
	
	echo "*** Starting kernel update"
	tar xf boot.scr_fedora20.tar
	
	echo "*** Clearing old kernel" 
	rm -rf /boot/* /lib/modules/3.8.13* /lib/modules/3.4*
	
	echo "*** Installing new zImage"
	cp $TEMP/boot/zImage /boot/uboot/zImage
	
	echo "*** Installing new modules"
	cp -aR $TEMP/lib/* /lib
	
	echo "Installing new uInitrd"
	K_VERSION=`ls $TEMP/boot/config-* | sed s/"-"/" "/g | awk '{printf $3}'`
	depmod -a
	cp $TEMP/boot/config-* /boot
	
	echo "*** Installing new boot.scr's"
	if [ "$BOARD" = "odroidxu" ]; then
		cp $TEMP/xu/* /boot/uboot
	elif [ "$BOARD" = "odroidx" ]; then
		cp $TEMP/x/*.scr /boot/uboot
	else
		cp $TEMP/x2u2/*.scr /boot/uboot
	fi
	

	if [ "$BOARD" != "odroidxu" ]; then
		linux_firmware_update
	fi
	
	if [ "$BOARD" != "odroidxu" ]; then
		echo "*** Fixing MFC firmware"
		cp /lib/firmware/s5p-mfc/* /lib/firmware
	fi
	
	if [ "$BOARD" = "odroidxu" ]; then
		echo "*** Updating Exynos5 HW Composer"
		axel -o $TEMP/hwc.tar -n 2 -a http://builder.mdrjr.net/tools/fedora19_hwcomposer.tar
		(cd /usr && tar xf $TEMP/hwc.tar)
		echo "*** HW Composer updated!"
	fi

	echo "*** Check /boot for new available boot.scr's!!!"
	warn_new_bootscrs
}


ubuntu_server_update() {
	echo "*** Starting Kernel Update for Ubuntu"
	kernel_download
	
	echo "*** Backing Up current kernel to /root/kernel-backup-$DATE.tar.gz"
	tar zcf /root/kernel-backup-$DATE.tar.gz /lib/modules /media/boot /boot
	
	echo "*** Unpacking new Kernel and Modules"
	tar -Jxf $TEMP/$BOARD.tar.xz
	
	echo "*** Starting kernel update"
	cd $TEMP
	tar xf boot.scr_ubuntu.tar
	
	echo "*** Clearing old kernel" 
	rm -rf /media/boot/* /lib/modules/3.8.13* /lib/modules/3.4*
	
	echo "*** Installing new zImage"
	cp $TEMP/boot/zImage /media/boot
	
	echo "*** Installing new modules"
	cp -aR $TEMP/lib/* /lib
	
	echo "Installing new uInitrd"
	K_VERSION=`ls $TEMP/boot/config-* | sed s/"-"/" "/g | awk '{printf $3}'`
	depmod -a
	cp $TEMP/boot/config-* /boot
	update-initramfs -c -k $K_VERSION
	mkimage -A arm -O linux -T ramdisk -C none -a 0 -e 0 -n "uInitrd $K_VERSION" -d /boot/initrd.img-$K_VERSION /boot/uInitrd-$K_VERSION
	cp /boot/uInitrd-$K_VERSION /media/boot/uInitrd
	
	
	echo "*** Installing new boot.scr's"
	if [ "$BOARD" = "odroidxu" ]; then
		cp $TEMP/xu/* /media/boot
	elif [ "$BOARD" = "odroidx" ]; then
		cp $TEMP/x/*.scr /media/boot
	else
		cp $TEMP/x2u2/*.scr /media/boot
	fi
	
	if [ "$BOARD" != "odroidxu" ]; then
		echo "*** Installing 720P60Hz HDMI default boot.scr"
		cp /media/boot/boot-auto.scr /media/boot/boot.scr
	fi

	if [ "$BOARD" != "odroidxu" ]; then
		linux_firmware_update
	fi
	
	if [ "$BOARD" != "odroidxu" ]; then
		echo "*** Fixing MFC firmware"
		cp /lib/firmware/s5p-mfc/* /lib/firmware
	fi

	if [ "$BOARD" = "odroidxu" ]; then
		echo "*** Updating Exynos5 HW Composer"
		axel -o $TEMP/hwc.tar -n 2 -a http://builder.mdrjr.net/tools/xubuntu_hwcomposer.tar
		(cd /usr && tar xf $TEMP/hwc.tar)
		echo "*** HW Composer updated!"
	fi

	echo "*** Check /boot for new available boot.scr's!!!"
	warn_new_bootscrs
}

ubuntu_update() { 
	echo "*** Starting Kernel Update for Ubuntu"
	kernel_download
	
	echo "*** Backing Up current kernel to /root/kernel-backup-$DATE.tar.gz"
	tar zcf /root/kernel-backup-$DATE.tar.gz /lib/modules /media/boot /boot
	
	echo "*** Unpacking new Kernel and Modules"
	tar -Jxf $TEMP/$BOARD.tar.xz
	
	echo "*** Starting kernel update"
	cd $TEMP
	tar xf boot.scr_ubuntu.tar
	
	echo "*** Clearing old kernel" 
	rm -rf /media/boot/* /lib/modules/3.8.13* /lib/modules/3.4
	
	echo "*** Installing new zImage"
	cp $TEMP/boot/zImage /media/boot
	
	echo "*** Installing new modules"
	cp -aR $TEMP/lib/* /lib
	
	echo "*** Patching Ubuntu's initramfs config"
	cat /etc/initramfs-tools/initramfs.conf | sed s/"MODULES=most"/"MODULES=dep"/g > /tmp/a.conf
	mv /tmp/a.conf /etc/initramfs-tools/initramfs.conf
	
	echo "Installing new uInitrd"
	K_VERSION=`ls $TEMP/boot/config-* | sed s/"-"/" "/g | awk '{printf $3}'`
	depmod -a
	cp $TEMP/boot/config-* /boot
	update-initramfs -c -k $K_VERSION
	mkimage -A arm -O linux -T ramdisk -C none -a 0 -e 0 -n "uInitrd $K_VERSION" -d /boot/initrd.img-$K_VERSION /boot/uInitrd-$K_VERSION
	cp /boot/uInitrd-$K_VERSION /media/boot/uInitrd	
	
	if [ "$BOARD" = "odroidxu" ]; then
		cp $TEMP/xu/* /media/boot
	elif [ "$BOARD" = "odroidx" ]; then
		echo "*** Installing new boot.scr's"
		cp $TEMP/x/*.scr /media/boot
	else
		echo "*** Installing new boot.scr's"
		cp $TEMP/x2u2/*.scr /media/boot
	fi

	if [ "$BOARD" != "odroidxu" ]; then
		echo "*** Trying to update xorg.conf to enable 24bpp"
		cat /etc/X11/xorg.conf | sed s/"DefaultDepth 16"/"DefaultDepth 24"/g > /tmp/20-fbdev.conf
		mv /tmp/20-fbdev.conf /etc/X11/xorg.conf
	fi
	
	if [ "$BOARD" != "odroidxu" ]; then
		echo "*** Installing 720P60Hz HDMI default boot.scr"
		cp /media/boot/boot-auto.scr /media/boot/boot.scr
	fi

	if [ "$BOARD" != "odroidxu" ]; then
		linux_firmware_update
	fi

	if [ "$BOARD" != "odroidxu" ]; then
		echo "*** Fixing MFC firmware"
		cp /lib/firmware/s5p-mfc/* /lib/firmware
	fi
	
	
	if [ "$BOARD" = "odroidxu" ]; then
		echo "*** Updating Exynos5 HW Composer"
		axel -o $TEMP/hwc.tar -n 2 -a http://builder.mdrjr.net/tools/xubuntu_hwcomposer.tar
		(cd /usr && tar xf $TEMP/hwc.tar)
		echo "*** HW Composer updated!"
	fi
		
	echo "*** Fixing flash_kernel script" 
	rm -rf /etc/initramfs/post-update.d/flash-kernel
	axel -o /etc/initramfs/post-update.d/flash-kernel -a http://builder.mdrjr.net/tools/flash_kernel_xubuntu
	chmod 777 /etc/initramfs/post-update.d/flash-kernel
	
	update_hwclock
		
	echo "*** Check /media/boot for new available boot.scr's!!!"
	warn_new_bootscrs
}

opensuse_update() { 
	echo "*** Starting Kernel Update for OpenSUSE"
	kernel_download
	
	echo "*** Backing Up Current Kernel to /root/kernel-backup-$DATE.tar.gz"
	tar -zcf /root/kernel-backup-$DATE.tar.gz /boot /lib/modules 

	echo "*** Updating OS Kernel"
	cd $TEMP
	tar xf boot.scr_opensuse.tar

	echo "*** Clearing /boot and /lib/modules/3.8.13*"
	rm -fr /lib/modules/3.8.13* /boot/*
	
	echo "*** Unpacking new Kernel and Modules"
	cd /
	tar -Jxf $TEMP/$BOARD.tar.xz
	
	echo "*** Installing new boot.scr's"
	if [ "$BOARD" = "odroidx" ]; then
		cp $TEMP/x/*.scr /boot
	else
		cp $TEMP/x2u2/*.scr /boot
	fi

	echo "*** Installing 720P60Hz HDMI default boot.scr"
	cp /boot/boot-hdmi-720p60hz.scr /boot/boot.scr

	echo "*** Trying to update xorg.conf to match 24Bpp Color Depth"
	cat /etc/X11/xorg.conf.d/20-fbdev.conf | sed  s/"DefaultDepth 16"/"DefaultDepth 24"/g > /tmp/20-fbdev.conf
	mv /tmp/20-fbdev.conf /etc/X11/xorg.conf.d/20-fbdev.conf

	echo "*** Check /boot for new available boot.scr's!!!"
	warn_new_bootscrs
}

linux_firmware_update() {

	echo "*** Installing Linux Firmware"
	case "$DISTRO" in
		"debian")
				axel -n 5 -a -o $TEMP/firmware.tar.xz $FIRMWARE_URL
			;;
		"ubuntu-server")
				axel -n 5 -a -o $TEMP/firmware.tar.xz $FIRMWARE_URL
			;;
		"ubuntu")
				axel -n 5 -a -o $TEMP/firmware.tar.xz $FIRMWARE_URL
			;;
		*)
			exit 0
			;;
	esac
	
	(cd /lib/firmware && tar -Jxf $TEMP/firmware.tar.xz)
	
	echo "*** Firmware Installed"
	
}

clean_up() {
	rm -rf $TEMP
	sync
}

update_hwclock() {
	mv /sbin/hwclock /sbin/hwclock.orig
	wget -O /sbin/hwclock http://builder.mdrjr.net/tools/hwclock
	chmod 0755 /sbin/hwclock
}

warn_new_bootscrs() {
	clean_up
	if [ "$BOARD" != "odroidxu" ]; then
		echo "*** There's a possibility to use DVI mode (disables SOUND-OVER-HDMI)"
		echo "*** This is for some screens that new this kind of compability mode"
		echo "*** There are also several frequencies supported now."
		echo "*** WARNING WARNING WARNING WARNING WARNING ***"
		echo "*** Mali GPU doesn't support all available combos."
		echo "*** If you find one that doesn't work, try another boot.scr."
	fi
}


start_up $1

