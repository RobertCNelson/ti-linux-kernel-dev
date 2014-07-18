#!/bin/sh -e

DIR=$PWD

check_config_value () {
	unset test_config
	test_config=$(grep "${config}=" ${DIR}/patches/defconfig || true)
	if [ "x${test_config}" = "x" ] ; then
		echo "echo ${config}=${value} >> ./KERNEL/.config"
	else
		if [ ! "x${test_config}" = "x${config}=${value}" ] ; then
			echo "sed -i -e 's:${test_config}:${config}=${value}:g' ./KERNEL/.config"
		fi
	fi
}

check_config_builtin () {
	unset test_config
	test_config=$(grep "${config}=y" ${DIR}/patches/defconfig || true)
	if [ "x${test_config}" = "x" ] ; then
		echo "echo ${config}=y >> ./KERNEL/.config"
	fi
}

check_config_module () {
	unset test_config
	test_config=$(grep "${config}=y" ${DIR}/patches/defconfig || true)
	if [ "x${test_config}" = "x${config}=y" ] ; then
		echo "sed -i -e 's:${config}=y:${config}=m:g' ./KERNEL/.config"
	else
		unset test_config
		test_config=$(grep "${config}=" ${DIR}/patches/defconfig || true)
		if [ "x${test_config}" = "x" ] ; then
			echo "echo ${config}=m >> ./KERNEL/.config"
		fi
	fi
}

check_config () {
	unset test_config
	test_config=$(grep "${config}=" ${DIR}/patches/defconfig || true)
	if [ "x${test_config}" = "x" ] ; then
		echo "echo ${config}=y >> ./KERNEL/.config"
		echo "echo ${config}=m >> ./KERNEL/.config"
	fi
}

check_config_disable () {
	unset test_config
	test_config=$(grep "${config} is not set" ${DIR}/patches/defconfig || true)
	if [ "x${test_config}" = "x" ] ; then
		unset test_config
		test_config=$(grep "${config}=y" ${DIR}/patches/defconfig || true)
		if [ "x${test_config}" = "x${config}=y" ] ; then
			echo "sed -i -e 's:${config}=y:# ${config} is not set:g' ./KERNEL/.config"
		else
			echo "sed -i -e 's:${config}=m:# ${config} is not set:g' ./KERNEL/.config"
		fi
	fi
}

check_if_set_then_set_module () {
	unset test_config
	test_config=$(grep "${if_config}=y" ${DIR}/patches/defconfig || true)
	if [ "x${test_config}" = "x${if_config}=y" ] ; then
		check_config_module
	fi
}

check_if_set_then_set () {
	unset test_config
	test_config=$(grep "${if_config}=y" ${DIR}/patches/defconfig || true)
	if [ "x${test_config}" = "x${if_config}=y" ] ; then
		check_config_builtin
	fi
}

check_if_set_then_disable () {
	unset test_config
	test_config=$(grep "${if_config}=y" ${DIR}/patches/defconfig || true)
	if [ "x${test_config}" = "x${if_config}=y" ] ; then
		check_config_disable
	fi
}

#TI:
#audio_display.cfg
##################################################
# TI Audio/Display config options
##################################################
CONFIG_BACKLIGHT_PWM=m

config="CONFIG_BACKLIGHT_PWM"
check_config_module

#baseport.cfg
##################################################
# TI Baseport Config Options
##################################################
CONFIG_CGROUPS=y

config="CONFIG_CGROUPS"
check_config_builtin

#connectivity.cfg
##################################################
# TI Connectivity Configs
##################################################
#USB Host
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_XHCI_HCD=m
CONFIG_USB_TEST=m
# CONFIG_USB_DEBUG is not set

config="CONFIG_USB_EHCI_HCD"
check_config_builtin
config="CONFIG_USB_XHCI_HCD"
check_config_builtin

##USB MUSB support
CONFIG_USB_MUSB_HDRC=m
CONFIG_USB_MUSB_OMAP2PLUS=m
CONFIG_USB_MUSB_DSPS=m
CONFIG_TI_CPPI41=y
CONFIG_USB_TI_CPPI41_DMA=y
CONFIG_TWL6030_USB=m
CONFIG_TWL4030_USB=m

##USB gadgets
#CONFIG_USB_AUDIO=m
#CONFIG_USB_ETH=m
#CONFIG_USB_G_NCM=m
#CONFIG_USB_GADGETFS=m
#CONFIG_USB_FUNCTIONFS=m
#CONFIG_USB_FUNCTIONFS_ETH=y
#CONFIG_USB_FUNCTIONFS_RNDIS=y
#CONFIG_USB_FUNCTIONFS_GENERIC=y
#CONFIG_USB_MASS_STORAGE=m
#CONFIG_USB_G_SERIAL=m
#CONFIG_USB_MIDI_GADGET=m
#CONFIG_USB_G_PRINTER=m
#CONFIG_USB_CDC_COMPOSITE=m
#CONFIG_USB_G_ACM_MS=m
#CONFIG_USB_G_MULTI=m
#CONFIG_USB_G_MULTI_CDC=y
#CONFIG_USB_G_HID=m
#CONFIG_USB_G_DBGP=m
#CONFIG_USB_G_WEBCAM=m

##USB Video
#CONFIG_MEDIA_SUPPORT=m
#CONFIG_MEDIA_CAMERA_SUPPORT=y
#CONFIG_VIDEO_DEV=m
#CONFIG_VIDEO_V4L2=m
#CONFIG_VIDEOBUF2_CORE=m
#CONFIG_VIDEOBUF2_MEMOPS=m
#CONFIG_VIDEOBUF2_VMALLOC=m
#CONFIG_MEDIA_USB_SUPPORT=y
#CONFIG_USB_VIDEO_CLASS=m
#CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=y
#CONFIG_USB_GSPCA=m

#USB device classes
CONFIG_USB_ACM=m
CONFIG_USB_SERIAL=m
CONFIG_USB_SERIAL_PL2303=m
CONFIG_USB_PRINTER=m

#SATA
CONFIG_ATA=y
CONFIG_SATA_AHCI_PLATFORM=y

config="CONFIG_ATA"
check_config_builtin
config="CONFIG_SATA_AHCI_PLATFORM"
check_config_builtin

#GPIO
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_PCA953X=y

config="CONFIG_GPIO_PCF857X"
check_config_builtin
config="CONFIG_GPIO_PCA953X"
check_config_builtin

#IIO and ADC
CONFIG_IIO=m
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_KFIFO_BUF=m
CONFIG_TI_AM335X_ADC=m

config="CONFIG_IIO"
check_config_module
config="CONFIG_IIO_BUFFER"
check_config_builtin
config="CONFIG_IIO_BUFFER_CB"
check_config_builtin
config="CONFIG_IIO_KFIFO_BUF"
check_config_module
config="CONFIG_TI_AM335X_ADC"
check_config_module

#PWM
CONFIG_PWM=y
CONFIG_PWM_TIECAP=y
CONFIG_PWM_TIEHRPWM=y

config="CONFIG_PWM"
check_config_builtin
config="CONFIG_PWM_TIECAP"
check_config_builtin
config="CONFIG_PWM_TIEHRPWM"
check_config_builtin

#Touchscreen
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_ADS7846=y
CONFIG_TOUCHSCREEN_ATMEL_MXT=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_TOUCHSCREEN_TI_AM335X_TSC=y
CONFIG_TOUCHSCREEN_PIXCIR=m

config="CONFIG_INPUT_TOUCHSCREEN"
check_config_builtin
config="CONFIG_TOUCHSCREEN_ADS7846"
check_config_builtin
config="CONFIG_TOUCHSCREEN_ATMEL_MXT"
check_config_builtin
config="CONFIG_MFD_TI_AM335X_TSCADC"
check_config_builtin
config="CONFIG_TOUCHSCREEN_TI_AM335X_TSC"
check_config_builtin
config="CONFIG_TOUCHSCREEN_PIXCIR"
check_config_module

#RTC
CONFIG_RTC_DRV_PALMAS=y

config="CONFIG_RTC_DRV_PALMAS"
check_config_builtin

#Ethernet
CONFIG_TI_CPTS=y

config="CONFIG_TI_CPTS"
check_config_builtin

#LED
CONFIG_LEDS_CLASS=y

config="CONFIG_LEDS_CLASS"
check_config_builtin

#MTD
CONFIG_MTD_NAND_OMAP_BCH=y
CONFIG_MTD_TESTS=m

#SPI
CONFIG_SPI_SPIDEV=y

config="CONFIG_SPI_SPIDEV"
check_config_builtin

#ipc.cfg
##################################################
# TI IPC config options
##################################################


#power.cfg
##################################################
# TI Power config options
##################################################
#CONFIG_CPU_FREQ=y
#CONFIG_CPU_FREQ_STAT=y
## CONFIG_CPU_FREQ_STAT_DETAILS is not set
## CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
## CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
## CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
#CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
## CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
#CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
## CONFIG_CPU_FREQ_GOV_POWERSAVE is not set
## CONFIG_CPU_FREQ_GOV_USERSPACE is not set
## CONFIG_CPU_FREQ_GOV_CONSERVATIVE is not set
## CONFIG_ARM_OMAP2PLUS_CPUFREQ is not set
#CONFIG_CPU_THERMAL=y
## CONFIG_IMX_THERMAL is not set
#CONFIG_TI_THERMAL=y
#CONFIG_GENERIC_CPUFREQ_CPU0=y
#CONFIG_VOLTAGE_DOMAIN_OMAP=y

config="CONFIG_CPU_FREQ"
check_config_builtin
config="CONFIG_CPU_FREQ_STAT"
check_config_builtin
config="CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND"
check_config_builtin
config="CONFIG_CPU_FREQ_GOV_PERFORMANCE"
check_config_builtin
config="CONFIG_CPU_THERMAL"
check_config_builtin
config="CONFIG_TI_THERMAL"
check_config_builtin
config="CONFIG_GENERIC_CPUFREQ_CPU0"
check_config_builtin
config="CONFIG_VOLTAGE_DOMAIN_OMAP"
check_config_builtin

#system_test.cfg
##################################################
# TI System Test config options
##################################################
#CONFIG_DEBUG_KMEMLEAK=y
#CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE=4000
#CONFIG_DEBUG_KMEMLEAK_TEST=n
#CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF=n
#CONFIG_DEBUG_INFO=y
#CONFIG_RTC_DEBUG=y
#CONFIG_TIGON3=m

#
# General setup
#
#config="CONFIG_LOCALVERSION_AUTO"
#check_config_disable
config="CONFIG_KERNEL_GZIP"
check_config_disable
config="CONFIG_KERNEL_LZO"
check_config_builtin
config="CONFIG_FHANDLE"
check_config_builtin

#
# RCU Subsystem
#
config="CONFIG_LOG_BUF_SHIFT"
value="18"
check_config_value
config="CONFIG_CGROUPS"
check_config_builtin
config="CONFIG_CGROUP_SCHED"
check_config_builtin
config="CONFIG_FAIR_GROUP_SCHED"
check_config_builtin

#
# Kernel Performance Events And Counters
#
config="CONFIG_SECCOMP_FILTER"
check_config_builtin
config="CONFIG_CC_STACKPROTECTOR"
check_config_builtin
config="CONFIG_CC_STACKPROTECTOR_NONE"
check_config_disable
config="CONFIG_CC_STACKPROTECTOR_REGULAR"
check_config_builtin

#
# GCOV-based kernel profiling
#
config="CONFIG_MODULE_SRCVERSION_ALL"
check_config_disable
config="CONFIG_BLK_DEV_BSG"
check_config_builtin

#
# CPU Core family selection
#
config="CONFIG_ARCH_MULTI_V6"
check_config_disable

#
# OMAP Legacy Platform Data Board Type
#
config="CONFIG_MACH_OMAP3_BEAGLE"
check_config_disable
config="CONFIG_MACH_DEVKIT8000"
check_config_disable
config="CONFIG_MACH_OMAP_LDP"
check_config_disable
config="CONFIG_MACH_OMAP3530_LV_SOM"
check_config_disable
config="CONFIG_MACH_OMAP3_TORPEDO"
check_config_disable
config="CONFIG_MACH_OVERO"
check_config_disable
config="CONFIG_MACH_OMAP3517EVM"
check_config_disable
config="CONFIG_MACH_OMAP3_PANDORA"
check_config_disable
config="CONFIG_MACH_TOUCHBOOK"
check_config_disable
config="CONFIG_MACH_OMAP_3430SDP"
check_config_disable
config="CONFIG_MACH_NOKIA_RX51"
check_config_disable
config="CONFIG_MACH_CM_T35"
check_config_disable
config="CONFIG_MACH_CM_T3517"
check_config_disable
config="CONFIG_MACH_SBC3530"
check_config_disable
config="CONFIG_MACH_TI8168EVM"
check_config_disable
config="CONFIG_MACH_TI8148EVM"
check_config_disable

#
# Kernel Features
#
config="CONFIG_ZSMALLOC"
check_config_builtin
config="CONFIG_SECCOMP"
check_config_builtin

#
# Boot options
#
config="CONFIG_ARM_APPENDED_DTB"
check_config_disable

#
# At least one emulation must be selected
#
config="CONFIG_KERNEL_MODE_NEON"
check_config_builtin

#
# Power management options
#
config="CONFIG_PM_AUTOSLEEP"
check_config_builtin
config="CONFIG_PM_WAKELOCKS"
check_config_builtin

#
# Networking options
#
config="CONFIG_IPV6"
check_config_builtin

#
# Device Tree and Open Firmware support
#
config="CONFIG_ZRAM"
check_config_module

#
# EEPROM support
#
config="CONFIG_EEPROM_AT24"
check_config_builtin

#
# SPI Protocol Masters
#
config="CONFIG_SPI_SPIDEV"
check_config_builtin

#
# Direct Rendering Manager
#
config="CONFIG_DRM"
check_config_builtin
config="CONFIG_DRM_I2C_NXP_TDA998X"
check_config_builtin
config="CONFIG_DRM_OMAP"
check_config_builtin
config="CONFIG_DRM_TILCDC"
check_config_builtin

#
# Frame buffer hardware drivers
#
config="CONFIG_OMAP2_DSS"
check_config_builtin

#
# OMAP Display Device Drivers (new device model)
#
config="CONFIG_DISPLAY_ENCODER_TFP410"
check_config_builtin
config="CONFIG_DISPLAY_ENCODER_TPD12S015"
check_config_builtin
config="CONFIG_DISPLAY_CONNECTOR_DVI"
check_config_builtin
config="CONFIG_DISPLAY_CONNECTOR_HDMI"
check_config_builtin
config="CONFIG_DISPLAY_PANEL_DPI"
check_config_builtin

#
# I2C HID support
#
config="CONFIG_USB_DEBUG"
check_config_disable

#
# Miscellaneous USB options
#
config="CONFIG_USB_DYNAMIC_MINORS"
check_config_builtin
config="CONFIG_USB_OTG"
check_config_builtin

#
# USB Imaging devices
#
config="CONFIG_USB_MUSB_HDRC"
check_config_builtin
config="CONFIG_USB_MUSB_HOST"
check_config_disable
config="CONFIG_USB_MUSB_GADGET"
check_config_disable
config="CONFIG_USB_MUSB_DUAL_ROLE"
check_config_builtin
config="CONFIG_USB_MUSB_TUSB6010"
check_config_disable
config="CONFIG_USB_MUSB_OMAP2PLUS"
check_config_disable
config="CONFIG_USB_MUSB_AM35X"
check_config_disable
config="CONFIG_USB_MUSB_DSPS"
check_config_builtin
config="CONFIG_USB_MUSB_UX500"
check_config_disable
config="CONFIG_USB_MUSB_AM335X_CHILD"
check_config_builtin
config="CONFIG_USB_TI_CPPI41_DMA"
check_config_disable
config="CONFIG_MUSB_PIO_ONLY"
check_config_builtin

#
# USB Physical Layer drivers
#
config="CONFIG_USB_GADGET_DEBUG"
check_config_disable
config="CONFIG_USB_GADGET_DEBUG_FILES"
check_config_disable
config="CONFIG_USB_GADGET_DEBUG_FS"
check_config_disable
config="CONFIG_USB_GADGET_VBUS_DRAW"
value="500"
check_config_value

#
# USB Peripheral Controller
#
config="CONFIG_USB_ZERO_HNPTEST"
check_config_builtin
config="CONFIG_USB_AUDIO"
check_config_module
config="CONFIG_GADGET_UAC1"
check_config_disable
config="CONFIG_USB_ETH"
check_config_module
config="CONFIG_USB_ETH_RNDIS"
check_config_builtin
config="CONFIG_USB_ETH_EEM"
check_config_builtin
config="CONFIG_USB_G_NCM"
check_config_module
config="CONFIG_USB_GADGETFS"
check_config_module
config="CONFIG_USB_FUNCTIONFS"
check_config_module
config="CONFIG_USB_FUNCTIONFS_ETH"
check_config_builtin
config="CONFIG_USB_FUNCTIONFS_RNDIS"
check_config_builtin
config="CONFIG_USB_FUNCTIONFS_GENERIC"
check_config_builtin
config="CONFIG_USB_MASS_STORAGE"
check_config_module
config="CONFIG_USB_G_SERIAL"
check_config_module
config="CONFIG_USB_MIDI_GADGET"
check_config_module
config="CONFIG_USB_G_PRINTER"
check_config_module
config="CONFIG_USB_CDC_COMPOSITE"
check_config_module
config="CONFIG_USB_G_ACM_MS"
check_config_module
config="CONFIG_USB_G_MULTI"
check_config_module
config="CONFIG_USB_G_MULTI_RNDIS"
check_config_builtin
config="CONFIG_USB_G_MULTI_CDC"
check_config_builtin
config="CONFIG_USB_G_HID"
check_config_module
config="CONFIG_USB_G_DBGP"
check_config_module
config="CONFIG_USB_G_DBGP_PRINTK"
check_config_disable
config="CONFIG_USB_G_DBGP_SERIAL"
check_config_builtin

#
# MMC/SD/SDIO Host Controller Drivers
#
config="CONFIG_LEDS_CLASS"
check_config_builtin

#
# LED drivers
#
config="CONFIG_LEDS_GPIO"
check_config_builtin

#
# LED Triggers
#
config="CONFIG_LEDS_TRIGGERS"
check_config_builtin
config="CONFIG_LEDS_TRIGGER_TIMER"
check_config_builtin
config="CONFIG_LEDS_TRIGGER_ONESHOT"
check_config_builtin
config="CONFIG_LEDS_TRIGGER_HEARTBEAT"
check_config_builtin
config="CONFIG_LEDS_TRIGGER_BACKLIGHT"
check_config_builtin
config="CONFIG_LEDS_TRIGGER_CPU"
check_config_builtin
config="CONFIG_LEDS_TRIGGER_GPIO"
check_config_builtin
config="CONFIG_LEDS_TRIGGER_DEFAULT_ON"
check_config_builtin

#
# File systems
#
config="CONFIG_EXT2_FS"
check_config_disable
config="CONFIG_EXT3_FS"
check_config_disable
config="CONFIG_EXT4_USE_FOR_EXT23"
check_config_builtin
config="CONFIG_XFS_FS"
check_config_builtin
config="CONFIG_BTRFS_FS"
check_config_builtin
config="CONFIG_AUTOFS4_FS"
check_config_builtin

#
# Pseudo filesystems
#
config="CONFIG_TMPFS_POSIX_ACL"
check_config_builtin
config="CONFIG_TMPFS_XATTR"
check_config_builtin

# Udev will fail to work with the legacy layout:
config="CONFIG_SYSFS_DEPRECATED"
check_config_disable

#        Legacy hotplug slows down the system and confuses udev:
#         CONFIG_UEVENT_HELPER_PATH=""

#        Userspace firmware loading is deprecated, will go away, and
#        sometimes causes problems:
#          CONFIG_FW_LOADER_USER_HELPER=n

#        Some udev rules and virtualization detection relies on it:
#config="CONFIG_DMIID"
#check_config_builtin


#        Required for PrivateNetwork in service units:
config="CONFIG_NET_NS"
check_config_builtin

#make sure...
config="CONFIG_DEVTMPFS"
check_config_builtin
config="CONFIG_INOTIFY_USER"
check_config_builtin
config="CONFIG_SIGNALFD"
check_config_builtin
config="CONFIG_TIMERFD"
check_config_builtin
config="CONFIG_EPOLL"
check_config_builtin
config="CONFIG_NET"
check_config_builtin
config="CONFIG_SYSFS"
check_config_builtin
config="CONFIG_PROC_FS"
check_config_builtin

config="CONFIG_SCHEDSTATS"
check_config_builtin
config="CONFIG_SCHED_DEBUG"
check_config_builtin

#other....

#debian netinstall
config="CONFIG_NLS_CODEPAGE_437"
check_config_builtin
config="CONFIG_NLS_ISO8859_1"
check_config_builtin

#
