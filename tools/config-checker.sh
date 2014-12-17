#!/bin/sh -e

DIR=$PWD

config_enable () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "xy" ] ; then
		echo "Setting: ${config}=y"
		./scripts/config --enable ${config}
	fi
}

config_disable () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "xn" ] ; then
		echo "Setting: ${config}=n"
		./scripts/config --disable ${config}
	fi
}

config_module () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "xm" ] ; then
		echo "Setting: ${config}=m"
		./scripts/config --module ${config}
	fi
}

config_string () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "x${option}" ] ; then
		echo "Setting: ${config}=${option}"
		./scripts/config --set-str ${config} ${option}
	fi
}

config_value () {
	ret=$(./scripts/config --state ${config})
	if [ ! "x${ret}" = "x${option}" ] ; then
		echo "Setting: ${config}=${option}"
		./scripts/config --set-val ${config} ${option}
	fi
}

cd ${DIR}/KERNEL/

#start with debian config
#
# General setup
#
config="CONFIG_KERNEL_LZO" ; config_enable

#
# Timers subsystem
#
config="CONFIG_NO_HZ" ; config_enable

#
# RCU Subsystem
#
config="CONFIG_IKCONFIG" ; config_enable
config="CONFIG_IKCONFIG_PROC" ; config_enable
config="CONFIG_LOG_BUF_SHIFT" ; option=18 ; config_value

#
# Kernel Performance Events And Counters
#
config="CONFIG_OPROFILE" ; config_enable

#
# System Type
#
config="CONFIG_ARCH_MULTIPLATFORM" ; config_enable
config="CONFIG_ARCH_EXYNOS" ; config_disable

#
# CPU Core family selection
#
config="CONFIG_GPIO_PCA953X" ; config_enable

#
# OMAP Feature Selections
#
config="CONFIG_OMAP_RESET_CLOCKS" ; config_enable
config="CONFIG_OMAP_MUX_DEBUG" ; config_enable
config="CONFIG_SOC_OMAP5" ; config_enable
config="CONFIG_SOC_AM33XX" ; config_enable
config="CONFIG_SOC_AM43XX" ; config_enable
config="CONFIG_SOC_DRA7XX" ; config_enable
config="CONFIG_ARCH_OMAP2PLUS" ; config_enable

#
# TI OMAP2/3/4 Specific Features
#
config="CONFIG_SOC_HAS_OMAP2_SDRC" ; config_enable

#
# Processor Features
#
config="CONFIG_CACHE_L2X0" ; config_enable
config="CONFIG_PL310_ERRATA_588369" ; config_enable
config="CONFIG_PL310_ERRATA_727915" ; config_enable

#
# Bus support
#
config="CONFIG_PCI" ; config_disable

#
# Kernel Features
#
config="CONFIG_SMP" ; config_enable
config="CONFIG_NR_CPUS" ; option=2 ; config_value
config="CONFIG_PREEMPT" ; config_enable
config="CONFIG_HZ_100" ; config_enable
config="CONFIG_HZ_250" ; config_disable
config="CONFIG_HZ" ; option=100 ; config_value
config="CONFIG_CMA" ; config_enable
config="CONFIG_SECCOMP" ; config_enable
config="CONFIG_XEN" ; config_disable

#
# Boot options
#
config="CONFIG_ARM_APPENDED_DTB" ; config_disable

#
# CPU Frequency scaling
#
config="CONFIG_CPU_FREQ" ; config_enable
config="CONFIG_CPU_FREQ_STAT_DETAILS" ; config_enable
config="CONFIG_CPU_FREQ_GOV_POWERSAVE" ; config_enable
config="CONFIG_CPU_FREQ_GOV_USERSPACE" ; config_enable
config="CONFIG_CPU_FREQ_GOV_ONDEMAND" ; config_enable
config="CONFIG_CPU_FREQ_GOV_CONSERVATIVE" ; config_enable
config="CONFIG_GENERIC_CPUFREQ_CPU0" ; config_enable

#
# ARM CPU frequency scaling drivers
#
config="CONFIG_ARM_OMAP2PLUS_CPUFREQ" ; config_disable

#
# CPU Idle
#
config="CONFIG_CPU_IDLE" ; config_enable

#
# At least one emulation must be selected
#
config="CONFIG_KERNEL_MODE_NEON" ; config_enable

#
# Power management options
#
config="CONFIG_PM_AUTOSLEEP" ; config_enable
config="CONFIG_PM_WAKELOCKS" ; config_enable
config="CONFIG_PM_WAKELOCKS_GC" ; config_enable
config="CONFIG_PM_OPP" ; config_enable

#
# Networking options
#
config="CONFIG_IP_PNP" ; config_enable
config="CONFIG_IP_PNP_DHCP" ; config_enable
config="CONFIG_IP_PNP_BOOTP" ; config_enable
config="CONFIG_IP_PNP_RARP" ; config_enable

#
# CAN Device Drivers
#
config="CONFIG_CAN_TI_HECC" ; config_module
config="CONFIG_CAN_MCP251X" ; config_module
config="CONFIG_CAN_SJA1000" ; config_disable
config="CONFIG_CAN_C_CAN" ; config_module
config="CONFIG_CAN_C_CAN_PLATFORM" ; config_module

#
# Bluetooth device drivers
#
config="CONFIG_BT_HCIUART" ; config_module
config="CONFIG_BT_HCIUART_H4" ; config_enable
config="CONFIG_BT_HCIUART_BCSP" ; config_enable
config="CONFIG_BT_HCIUART_ATH3K" ; config_enable
config="CONFIG_BT_HCIUART_LL" ; config_enable
config="CONFIG_BT_HCIUART_3WIRE" ; config_enable
config="CONFIG_BT_HCIBCM203X" ; config_module
config="CONFIG_BT_HCIBPA10X" ; config_module
config="CONFIG_BT_HCIBFUSB" ; config_module
config="CONFIG_BT_HCIVHCI" ; config_module
config="CONFIG_BT_WILINK" ; config_module

#
# Generic Driver Options
#
config="CONFIG_DEVTMPFS_MOUNT" ; config_enable
config="CONFIG_FIRMWARE_IN_KERNEL" ; config_enable
config="CONFIG_DMA_CMA" ; config_enable
config="CONFIG_CMA_SIZE_MBYTES" ; option=24 ; config_value

#
# Bus devices
#
config="CONFIG_OMAP_OCP2SCP" ; config_enable
config="CONFIG_OMAP_INTERCONNECT" ; config_enable

#
# Misc devices
#
config="CONFIG_BMP085" ; config_enable
config="CONFIG_BMP085_I2C" ; config_module

#
# EEPROM support
#
config="CONFIG_EEPROM_AT24" ; config_enable
config="CONFIG_EEPROM_93CX6" ; config_enable

#
# Texas Instruments shared transport line discipline
#
config="CONFIG_TI_ST" ; config_enable
config="CONFIG_ST_HCI" ; config_enable

#
# Altera FPGA firmware download module
#
config="CONFIG_ALTERA_STAPL" ; config_disable

#
# Argus cape driver for beaglebone black
#
config="CONFIG_CAPE_BONE_ARGUS" ; config_enable
config="CONFIG_BEAGLEBONE_PINMUX_HELPER" ; config_enable

#
# SCSI support type (disk, tape, CD-ROM)
#
config="CONFIG_BLK_DEV_SD" ; config_enable

#
# SCSI Transports
#
config="CONFIG_ATA" ; config_enable

#
# Controllers with non-SFF native interface
#
config="CONFIG_SATA_AHCI_PLATFORM" ; config_enable
config="CONFIG_AHCI_IMX" ; config_disable

#
# SATA SFF controllers with BMDMA
#
config="CONFIG_SATA_HIGHBANK" ; config_disable
config="CONFIG_SATA_MV" ; config_disable

#
# PIO-only SFF controllers
#
config="CONFIG_PATA_PLATFORM" ; config_disable

#
# Generic fallback / legacy drivers
#
config="CONFIG_MII" ; config_enable

#
# Distributed Switch Architecture drivers
#
config="CONFIG_STMMAC_ETH" ; config_disable
config="CONFIG_TI_DAVINCI_MDIO" ; config_enable
config="CONFIG_TI_DAVINCI_CPDMA" ; config_enable
config="CONFIG_TI_CPSW_PHY_SEL" ; config_enable
config="CONFIG_TI_CPSW" ; config_enable
config="CONFIG_TI_CPTS" ; config_enable

#
# MII PHY device drivers
#
config="CONFIG_AT803X_PHY" ; config_enable
config="CONFIG_SMSC_PHY" ; config_enable

#
# Userland interfaces
#
config="CONFIG_INPUT_JOYDEV" ; config_enable
config="CONFIG_INPUT_EVDEV" ; config_enable

#
# Input Device Drivers
#
config="CONFIG_KEYBOARD_TWL4030" ; config_enable
config="CONFIG_TOUCHSCREEN_ATMEL_MXT" ; config_enable
config="CONFIG_TOUCHSCREEN_EDT_FT5X06" ; config_enable
config="CONFIG_TOUCHSCREEN_TI_AM335X_TSC" ; config_enable
config="CONFIG_INPUT_TWL4030_PWRBUTTON" ; config_enable
config="CONFIG_INPUT_PALMAS_PWRBUTTON" ; config_enable

#
# Character devices
#
config="CONFIG_DEVKMEM" ; config_enable

#
# Non-8250 serial port support
#
config="CONFIG_SERIAL_OMAP" ; config_enable
config="CONFIG_SERIAL_OMAP_CONSOLE" ; config_enable
config="CONFIG_HW_RANDOM" ; config_enable
config="CONFIG_HW_RANDOM_OMAP" ; config_enable
config="CONFIG_HW_RANDOM_TPM" ; config_module
config="CONFIG_TCG_TPM" ; config_module
config="CONFIG_TCG_TIS_I2C_ATMEL" ; config_module
config="CONFIG_I2C_CHARDEV" ; config_enable

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
config="CONFIG_I2C_GPIO" ; config_module

#
# SPI Master Controller Drivers
#
config="CONFIG_SPI_GPIO" ; config_module
config="CONFIG_SPI_OMAP24XX" ; config_enable
config="CONFIG_SPI_TI_QSPI" ; config_enable

#
# Pin controllers
#
config="CONFIG_PINMUX" ; config_enable
config="CONFIG_PINCONF" ; config_enable
config="CONFIG_GENERIC_PINCONF" ; config_enable
config="CONFIG_PINCTRL_SINGLE" ; config_enable
config="CONFIG_PINCTRL_PALMAS" ; config_enable
config="CONFIG_GPIO_SYSFS" ; config_enable

#
# I2C GPIO expanders:
#
config="CONFIG_GPIO_PCF857X" ; config_enable
config="CONFIG_GPIO_TWL4030" ; config_enable

#
# MODULbus GPIO expanders:
#
config="CONFIG_GPIO_PALMAS" ; config_enable

#
# 1-wire Slaves
#
config="CONFIG_POWER_RESET" ; config_disable
config="CONFIG_POWER_RESET_RESTART" ; config_disable
config="CONFIG_POWER_AVS" ; config_enable

#
# Native drivers
#
config="CONFIG_SENSORS_LM75" ; config_module
config="CONFIG_SENSORS_TMP102" ; config_enable

#
# Voltage Domain Framework Drivers
#
config="CONFIG_VOLTAGE_DOMAIN_OMAP" ; config_enable

#
# Native drivers
#
config="CONFIG_THERMAL_GOV_USER_SPACE" ; config_enable
config="CONFIG_CPU_THERMAL" ; config_enable

#
# Texas Instruments thermal drivers
#
config="CONFIG_TI_SOC_THERMAL" ; config_enable
config="CONFIG_TI_THERMAL" ; config_enable
config="CONFIG_OMAP5_THERMAL" ; config_enable
config="CONFIG_DRA752_THERMAL" ; config_enable

#
# Watchdog Device Drivers
#
config="CONFIG_OMAP_WATCHDOG" ; config_enable
config="CONFIG_TWL4030_WATCHDOG" ; config_enable

#
# Multifunction device drivers
#
config="CONFIG_MFD_TI_AM335X_TSCADC" ; config_enable
config="CONFIG_MFD_PALMAS" ; config_enable
config="CONFIG_MFD_TPS65217" ; config_enable
config="CONFIG_MFD_TPS65218" ; config_enable
config="CONFIG_MFD_TPS65910" ; config_enable
config="CONFIG_REGULATOR_GPIO" ; config_enable
config="CONFIG_REGULATOR_PALMAS" ; config_enable
config="CONFIG_REGULATOR_PBIAS" ; config_enable
config="CONFIG_REGULATOR_TI_ABB" ; config_enable
config="CONFIG_REGULATOR_TPS65023" ; config_enable
config="CONFIG_REGULATOR_TPS6507X" ; config_enable
config="CONFIG_REGULATOR_TPS65217" ; config_enable
config="CONFIG_REGULATOR_TPS65218" ; config_enable
config="CONFIG_REGULATOR_TPS65910" ; config_enable

#
# Multimedia core support
#
config="CONFIG_VIDEO_V4L2_SUBDEV_API" ; config_enable

#
# Webcam, TV (analog/digital) USB devices
#
config="CONFIG_VIDEO_AM437X_VPFE" ; config_module
config="CONFIG_VIDEO_TI_VIP" ; config_module

#
# Direct Rendering Manager
#
config="CONFIG_DRM" ; config_enable
config="CONFIG_DRM_I2C_NXP_TDA998X" ; config_enable
config="CONFIG_DRM_OMAP" ; config_enable
config="CONFIG_DRM_OMAP_NUM_CRTCS" ; option=2 ; config_value
config="CONFIG_DRM_TILCDC" ; config_enable
config="CONFIG_OMAP2_DSS" ; config_enable
config="CONFIG_OMAP5_DSS_HDMI" ; config_enable
config="CONFIG_OMAP2_DSS_SDI" ; config_enable
config="CONFIG_OMAP2_DSS_DSI" ; config_enable

#
# OMAP Display Device Drivers (new device model)
#
config="CONFIG_DISPLAY_ENCODER_TFP410" ; config_module
config="CONFIG_DISPLAY_ENCODER_TPD12S015" ; config_enable
config="CONFIG_DISPLAY_DRA7EVM_ENCODER_TPD12S015" ; config_enable
config="CONFIG_DISPLAY_ENCODER_SII9022" ; config_enable
config="CONFIG_DISPLAY_ENCODER_SII9022_AUDIO_CODEC" ; config_enable
config="CONFIG_DISPLAY_CONNECTOR_DVI" ; config_module
config="CONFIG_DISPLAY_CONNECTOR_HDMI" ; config_enable
config="CONFIG_BACKLIGHT_GENERIC" ; config_module
config="CONFIG_BACKLIGHT_PWM" ; config_enable
config="CONFIG_BACKLIGHT_GPIO" ; config_enable

#
# Console display driver support
#
config="CONFIG_LOGO" ; config_enable
config="CONFIG_LOGO_LINUX_MONO" ; config_enable
config="CONFIG_LOGO_LINUX_VGA16" ; config_enable
config="CONFIG_LOGO_LINUX_CLUT224" ; config_enable
config="CONFIG_SOUND" ; config_enable
config="CONFIG_SOUND_OSS_CORE_PRECLAIM" ; config_enable
config="CONFIG_SND" ; config_enable
config="CONFIG_SND_TIMER" ; config_enable
config="CONFIG_SND_PCM" ; config_enable
config="CONFIG_SND_DMAENGINE_PCM" ; config_enable

config="CONFIG_SND_SOC" ; config_enable
config="CONFIG_SND_SOC_GENERIC_DMAENGINE_PCM" ; config_enable
config="CONFIG_SND_EDMA_SOC" ; config_enable
config="CONFIG_SND_DAVINCI_SOC_MCASP" ; config_enable
config="CONFIG_SND_DAVINCI_SOC_GENERIC_EVM" ; config_enable
config="CONFIG_SND_AM33XX_SOC_EVM" ; config_module
config="CONFIG_SND_AM335X_SOC_NXPTDA_EVM" ; config_module
config="CONFIG_SND_OMAP_SOC" ; config_enable
config="CONFIG_SND_OMAP_SOC_MCBSP" ; config_module
config="CONFIG_SND_OMAP_SOC_HDMI_AUDIO" ; config_enable
config="CONFIG_SND_OMAP_SOC_DRA7EVM" ; config_enable
config="CONFIG_SND_OMAP_SOC_OMAP_TWL4030" ; config_module
config="CONFIG_SND_SOC_I2C_AND_SPI" ; config_enable

#
# CODEC drivers
#
config="CONFIG_SND_SOC_HDMI_CODEC" ; config_enable

#
# HID support
#
config="CONFIG_HID_BATTERY_STRENGTH" ; config_enable
config="CONFIG_UHID" ; config_enable
config="CONFIG_HID_GENERIC" ; config_enable

#
# Special HID drivers
#
config="CONFIG_HID_APPLEIR" ; config_module
config="CONFIG_HID_LOGITECH_DJ" ; config_enable

#
# Miscellaneous USB options
#
config="CONFIG_USB_OTG" ; config_enable

#
# USB Host Controller Drivers
#
config="CONFIG_USB_XHCI_HCD" ; config_enable
config="CONFIG_USB_EHCI_HCD" ; config_enable
config="CONFIG_USB_EHCI_HCD_OMAP" ; config_enable
config="CONFIG_USB_OHCI_HCD" ; config_disable

#
# also be needed; see USB_STORAGE Help for more info
#
config="CONFIG_USB_STORAGE" ; config_enable

#
# USB Imaging devices
#
config="CONFIG_USB_MUSB_HDRC" ; config_module
config="CONFIG_USB_MUSB_TUSB6010" ; config_disable
config="CONFIG_USB_MUSB_OMAP2PLUS" ; config_module
config="CONFIG_USB_INVENTRA_DMA" ; config_disable
config="CONFIG_USB_TI_CPPI41_DMA" ; config_enable
config="CONFIG_MUSB_PIO_ONLY" ; config_disable
config="CONFIG_USB_DWC3_DUAL_ROLE" ; config_enable

#
# Debugging features
#
config="CONFIG_USB_CHIPIDEA" ; config_disable

#
# USB Physical Layer drivers
#
config="CONFIG_AM335X_CONTROL_USB" ; config_enable
config="CONFIG_AM335X_PHY_USB" ; config_enable
config="CONFIG_TWL6030_USB" ; config_module
config="CONFIG_USB_GADGET_VBUS_DRAW" ; option=500 ; config_value

#
# USB Peripheral Controller
#
config="CONFIG_USB_ZERO" ; config_module
config="CONFIG_USB_AUDIO" ; config_module
config="CONFIG_USB_ETH_EEM" ; config_enable
config="CONFIG_USB_G_NCM" ; config_module
config="CONFIG_USB_FUNCTIONFS" ; config_module
config="CONFIG_USB_FUNCTIONFS_ETH" ; config_enable
config="CONFIG_USB_FUNCTIONFS_RNDIS" ; config_enable
config="CONFIG_USB_MASS_STORAGE" ; config_module
config="CONFIG_USB_G_SERIAL" ; config_module
config="CONFIG_USB_MIDI_GADGET" ; config_module
config="CONFIG_USB_G_PRINTER" ; config_module
config="CONFIG_USB_CDC_COMPOSITE" ; config_module
config="CONFIG_USB_G_ACM_MS" ; config_module
config="CONFIG_USB_G_MULTI" ; config_module
config="CONFIG_USB_G_MULTI_CDC" ; config_enable
config="CONFIG_USB_G_HID" ; config_module
config="CONFIG_USB_G_DBGP" ; config_module
config="CONFIG_USB_G_WEBCAM" ; config_module

config="CONFIG_MMC_UNSAFE_RESUME" ; config_enable

#
# MMC/SD/SDIO Card Drivers
#
config="CONFIG_MMC_BLOCK_MINORS" ; option=8 ; config_value

#
# MMC/SD/SDIO Host Controller Drivers
#
config="CONFIG_MMC_OMAP" ; config_enable
config="CONFIG_MMC_OMAP_HS" ; config_enable

#
# LED drivers
#
config="CONFIG_LEDS_GPIO" ; config_enable

#
# LED Triggers
#
config="CONFIG_LEDS_TRIGGER_TIMER" ; config_enable
config="CONFIG_LEDS_TRIGGER_ONESHOT" ; config_enable
config="CONFIG_LEDS_TRIGGER_HEARTBEAT" ; config_enable
config="CONFIG_LEDS_TRIGGER_BACKLIGHT" ; config_enable
config="CONFIG_LEDS_TRIGGER_GPIO" ; config_enable
config="CONFIG_LEDS_TRIGGER_DEFAULT_ON" ; config_enable

#
# I2C RTC drivers
#
config="CONFIG_RTC_DRV_DS1307" ; config_enable
config="CONFIG_RTC_DRV_PALMAS" ; config_enable

#
# on-CPU RTC drivers
#
config="CONFIG_RTC_DRV_OMAP" ; config_enable

#
# DMA Devices
#
config="CONFIG_TI_EDMA" ; config_enable
config="CONFIG_DMA_OMAP" ; config_enable

#
# Android
#
config="CONFIG_ANDROID" ; config_enable
config="CONFIG_ANDROID_BINDER_IPC" ; config_enable
config="CONFIG_ASHMEM" ; config_enable
config="CONFIG_ANDROID_LOGGER" ; config_module
config="CONFIG_ANDROID_TIMED_OUTPUT" ; config_enable
config="CONFIG_ANDROID_TIMED_GPIO" ; config_module
config="CONFIG_ANDROID_LOW_MEMORY_KILLER" ; config_disable
config="CONFIG_ANDROID_INTF_ALARM_DEV" ; config_enable
config="CONFIG_SYNC" ; config_enable
config="CONFIG_SW_SYNC" ; config_disable
config="CONFIG_ION" ; config_enable

#
# Common Clock Framework
#
config="CONFIG_HWSPINLOCK" ; config_enable
config="CONFIG_CLK_TWL6040" ; config_module

#
# Hardware Spinlock drivers
#
config="CONFIG_HWSPINLOCK_OMAP" ; config_enable
config="CONFIG_IOMMU_API" ; config_enable
config="CONFIG_OMAP_IOMMU" ; config_enable
config="CONFIG_OMAP_IOVMM" ; config_enable

#
# Remoteproc drivers
#
config="CONFIG_REMOTEPROC" ; config_enable
config="CONFIG_OMAP_REMOTEPROC" ; config_module
config="CONFIG_OMAP_REMOTEPROC_WATCHDOG" ; config_enable
config="CONFIG_PRUSS_REMOTEPROC" ; config_enable

#
# Rpmsg drivers
#
config="CONFIG_RPMSG_RPC" ; config_module
config="CONFIG_PM_DEVFREQ" ; config_enable

#
# DEVFREQ Governors
#
config="CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND" ; config_enable
config="CONFIG_DEVFREQ_GOV_PERFORMANCE" ; config_enable
config="CONFIG_DEVFREQ_GOV_POWERSAVE" ; config_enable
config="CONFIG_DEVFREQ_GOV_USERSPACE" ; config_enable

#
# DEVFREQ Drivers
#
config="CONFIG_EXTCON" ; config_enable

#
# Extcon Device Drivers
#
config="CONFIG_EXTCON_GPIO" ; config_enable
config="CONFIG_EXTCON_PALMAS" ; config_enable
config="CONFIG_MEMORY" ; config_enable
config="CONFIG_TI_EMIF" ; config_enable
config="CONFIG_IIO_BUFFER_CB" ; config_enable

#
# Temperature sensors
#
config="CONFIG_PWM_TIECAP" ; config_enable
config="CONFIG_PWM_TIEHRPWM" ; config_enable
config="CONFIG_PWM_TIPWMSS" ; config_enable
config="CONFIG_RESET_CONTROLLER" ; config_disable

#
# PHY Subsystem
#
config="CONFIG_OMAP_CONTROL_PHY" ; config_enable
config="CONFIG_OMAP_USB2" ; config_enable
config="CONFIG_TI_PIPE3" ; config_enable
config="CONFIG_TWL4030_USB" ; config_module

#
# File systems
#
config="CONFIG_EXT4_FS" ; config_enable
config="CONFIG_JBD2" ; config_enable
config="CONFIG_FS_MBCACHE" ; config_enable
config="CONFIG_XFS_FS" ; config_enable
config="CONFIG_BTRFS_FS" ; config_enable
config="CONFIG_FANOTIFY_ACCESS_PERMISSIONS" ; config_enable
config="CONFIG_AUTOFS4_FS" ; config_enable
config="CONFIG_FUSE_FS" ; config_enable

#
# DOS/FAT/NT Filesystems
#
config="CONFIG_FAT_FS" ; config_enable
config="CONFIG_MSDOS_FS" ; config_enable
config="CONFIG_VFAT_FS" ; config_enable
config="CONFIG_FAT_DEFAULT_IOCHARSET" ; option="iso8859-1" ; config_string

#
# Pseudo filesystems
#
config="CONFIG_CONFIGFS_FS" ; config_enable
config="CONFIG_F2FS_FS" ; config_enable
config="CONFIG_NFS_FS" ; config_enable
config="CONFIG_NFS_V2" ; config_enable
config="CONFIG_NFS_V3" ; config_enable
config="CONFIG_NFS_V4" ; config_enable
config="CONFIG_ROOT_NFS" ; config_enable

config="CONFIG_NLS_DEFAULT" ; option="iso8859-1" ; config_string
config="CONFIG_NLS_CODEPAGE_437" ; config_enable
config="CONFIG_NLS_ISO8859_1" ; config_enable

#
# printk and dmesg options
#
config="CONFIG_BOOT_PRINTK_DELAY" ; config_disable

#
# Debug Lockups and Hangs
#
config="CONFIG_SCHEDSTATS" ; config_enable

#
# Runtime Testing
#
config="CONFIG_ARM_UNWIND" ; config_disable

#
# Crypto core or helper
#
config="CONFIG_CRYPTO_MANAGER_DISABLE_TESTS" ; config_enable

#
# Digest
#
config="CONFIG_CRYPTO_SHA1_ARM" ; config_enable

#
# Ciphers
#
config="CONFIG_CRYPTO_AES_ARM" ; config_enable

#
# Random Number Generation
#
config="CONFIG_CRYPTO_DEV_OMAP_SHAM" ; config_enable
config="CONFIG_CRYPTO_DEV_OMAP_AES" ; config_enable
config="CONFIG_CRYPTO_DEV_OMAP_DES" ; config_enable

exit


#start with omap2plus_defconfig
##################################################
# TI SoCs supported by this release config options
#
# IMPORTANT NOTE: Always refer to the appropriate
# Release Note for accurate information on the
# specific SoC.
##################################################
# Supported ARM CPUs
CONFIG_ARCH_MULTI_V6=n
CONFIG_ARCH_MULTI_V7=y
CONFIG_ARCH_MULTI_V6_V7=n
CONFIG_CPU_V6=n

# Enable CONFIG_SMP
CONFIG_SMP=y

# Supported SoCs
CONFIG_ARCH_OMAP2=n
CONFIG_ARCH_OMAP3=n
CONFIG_ARCH_OMAP4=n
CONFIG_SOC_OMAP5=y
CONFIG_SOC_AM33XX=y
CONFIG_SOC_AM43XX=y
CONFIG_SOC_DRA7XX=y

##################################################

config="CONFIG_ARCH_MULTI_V6" ; config_disable
config="CONFIG_ARCH_MULTI_V6_V7" ; config_disable
config="CONFIG_ARCH_OMAP3" ; config_disable
config="CONFIG_ARCH_OMAP4" ; config_disable

exit

##################################################
#audio_display.cfg
##################################################
# TI Audio/Display config options
##################################################
CONFIG_BACKLIGHT_PWM=y

CONFIG_DRM=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_GEM_CMA_HELPER=y
CONFIG_DRM_KMS_CMA_HELPER=y
CONFIG_DRM_I2C_NXP_TDA998X=y
CONFIG_DRM_TILCDC=y
CONFIG_DRM_OMAP=y
CONFIG_DRM_OMAP_NUM_CRTCS=2

CONFIG_DISPLAY_PANEL_TLC59108=y
CONFIG_OMAP5_DSS_HDMI=y
CONFIG_DISPLAY_CONNECTOR_HDMI=y
CONFIG_DISPLAY_DRA7EVM_ENCODER_TPD12S015=y
CONFIG_DISPLAY_ENCODER_TPD12S015=y
CONFIG_DISPLAY_ENCODER_SII9022=y

CONFIG_CMA_SIZE_MBYTES=24

CONFIG_MEDIA_SUBDRV_AUTOSELECT=n
CONFIG_MEDIA_SUPPORT=m
CONFIG_MEDIA_CONTROLLER=y
CONFIG_V4L_PLATFORM_DRIVERS=y
CONFIG_V4L2_MEM2MEM_DEV=m
CONFIG_VIDEOBUF2_DMA_CONTIG=m
CONFIG_V4L_MEM2MEM_DRIVERS=y
CONFIG_VIDEO_V4L2_SUBDEV_API=y
CONFIG_VIDEO_TI_VPE=m
CONFIG_VIDEO_TI_VIP=m
CONFIG_VIDEO_OV2659=m
CONFIG_VIDEO_AM437X_VPFE=m

CONFIG_SOUND=y
CONFIG_SND=y
CONFIG_SND_SOC=y
CONFIG_SND_OMAP_SOC=y
CONFIG_SND_EDMA_SOC=y
CONFIG_SND_DAVINCI_SOC_MCASP=m
CONFIG_SND_AM335X_SOC_NXPTDA_EVM=m
CONFIG_SND_AM33XX_SOC_EVM=m
CONFIG_SND_SIMPLE_CARD=m
CONFIG_SND_OMAP_SOC_DRA7EVM=y
CONFIG_SND_SOC_TLV320AIC31XX=m
CONFIG_SND_SOC_TLV320AIC3X=m

CONFIG_OMAP2_DSS=y
CONFIG_OMAP2_DSS_INIT=y
##################################################
CONFIG_BACKLIGHT_PWM=m

config="CONFIG_BACKLIGHT_PWM" ; config_enable

CONFIG_DRM=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_GEM_CMA_HELPER=y
CONFIG_DRM_KMS_CMA_HELPER=y
CONFIG_DRM_I2C_NXP_TDA998X=y
CONFIG_DRM_TILCDC=y
CONFIG_DRM_OMAP=y
CONFIG_DRM_OMAP_NUM_CRTCS=2

config="CONFIG_DRM" ; config_enable
config="CONFIG_DRM_KMS_HELPER" ; config_enable
config="CONFIG_DRM_KMS_FB_HELPER" ; config_enable
config="CONFIG_DRM_GEM_CMA_HELPER" ; config_enable
config="CONFIG_DRM_KMS_CMA_HELPER" ; config_enable
config="CONFIG_DRM_I2C_NXP_TDA998X" ; config_enable
config="CONFIG_DRM_TILCDC" ; config_enable
config="CONFIG_DRM_OMAP" ; config_enable
config="CONFIG_DRM_OMAP_NUM_CRTCS" ; option="2" ; config_value

CONFIG_DISPLAY_PANEL_TLC59108=y
CONFIG_OMAP5_DSS_HDMI=y
CONFIG_DISPLAY_CONNECTOR_HDMI=y
CONFIG_DISPLAY_DRA7EVM_ENCODER_TPD12S015=y
CONFIG_DISPLAY_ENCODER_TPD12S015=y
CONFIG_DISPLAY_ENCODER_SII9022=y

config="CONFIG_DISPLAY_PANEL_TLC59108" ; config_enable
config="CONFIG_OMAP5_DSS_HDMI" ; config_enable
config="CONFIG_DISPLAY_CONNECTOR_HDMI" ; config_enable
config="CONFIG_DISPLAY_DRA7EVM_ENCODER_TPD12S015" ; config_enable
config="CONFIG_DISPLAY_ENCODER_TPD12S015" ; config_enable
config="CONFIG_DISPLAY_ENCODER_SII9022" ; config_enable

CONFIG_CMA_SIZE_MBYTES=24

config="CONFIG_CMA_SIZE_MBYTES" ; option="24" ; config_value

CONFIG_MEDIA_SUBDRV_AUTOSELECT=n
CONFIG_MEDIA_SUPPORT=m
CONFIG_MEDIA_CONTROLLER=y
CONFIG_V4L_PLATFORM_DRIVERS=y
CONFIG_V4L2_MEM2MEM_DEV=m
CONFIG_VIDEOBUF2_DMA_CONTIG=m
CONFIG_V4L_MEM2MEM_DRIVERS=y
CONFIG_VIDEO_V4L2_SUBDEV_API=y
CONFIG_VIDEO_TI_VPE=m
CONFIG_VIDEO_TI_VIP=m
CONFIG_VIDEO_OV2659=m
CONFIG_VIDEO_AM437X_VPFE=m

config="CONFIG_MEDIA_SUPPORT" ; config_module
config="CONFIG_MEDIA_CONTROLLER" ; config_enable
config="CONFIG_MEDIA_CAMERA_SUPPORT" ; config_enable
config="CONFIG_V4L_PLATFORM_DRIVERS" ; config_enable
config="CONFIG_V4L2_MEM2MEM_DEV" ; config_module
config="CONFIG_VIDEOBUF2_DMA_CONTIG" ; config_module
config="CONFIG_V4L_MEM2MEM_DRIVERS" ; config_enable
config="CONFIG_VIDEO_V4L2_SUBDEV_API" ; config_enable
config="CONFIG_VIDEO_TI_VPE" ; config_module
config="CONFIG_VIDEO_TI_VIP" ; config_module
config="CONFIG_VIDEO_OV2659" ; config_module
config="CONFIG_VIDEO_AM437X_VPFE" ; config_module

CONFIG_SOUND=y
CONFIG_SND=y
CONFIG_SND_SOC=y
CONFIG_SND_OMAP_SOC=y
CONFIG_SND_EDMA_SOC=y
CONFIG_SND_DAVINCI_SOC_MCASP=m
CONFIG_SND_AM335X_SOC_NXPTDA_EVM=m
CONFIG_SND_AM33XX_SOC_EVM=m
CONFIG_SND_SIMPLE_CARD=m
CONFIG_SND_OMAP_SOC_DRA7EVM=y
CONFIG_SND_SOC_TLV320AIC31XX=m
CONFIG_SND_SOC_TLV320AIC3X=m

config="CONFIG_SOUND" ; config_enable
config="CONFIG_SND" ; config_enable
config="CONFIG_SND_SOC" ; config_enable
config="CONFIG_SND_OMAP_SOC" ; config_enable
config="CONFIG_SND_EDMA_SOC" ; config_enable
config="CONFIG_SND_DAVINCI_SOC_MCASP" ; config_module
config="CONFIG_SND_AM335X_SOC_NXPTDA_EVM" ; config_module
config="CONFIG_SND_AM33XX_SOC_EVM" ; config_module
config="CONFIG_SND_SIMPLE_CARD" ; config_module
config="CONFIG_SND_OMAP_SOC_DRA7EVM" ; config_enable
config="CONFIG_SND_SOC_TLV320AIC31XX" ; config_module
config="CONFIG_SND_SOC_TLV320AIC3X" ; config_module

CONFIG_OMAP2_DSS=y
CONFIG_OMAP2_DSS_INIT=y

config="CONFIG_OMAP2_DSS" ; config_enable
config="CONFIG_OMAP2_DSS_INIT" ; config_enable
##################################################
#baseport.cfg
##################################################
# TI Baseport Config Options
##################################################
CONFIG_CGROUPS=y

CONFIG_REGULATOR_GPIO=y

# Crypto hardware accelerators
CONFIG_CRYPTO_DEV_OMAP_SHAM=y
CONFIG_CRYPTO_DEV_OMAP_AES=y
CONFIG_CRYPTO_DEV_OMAP_DES=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y

CONFIG_PREEMPT_VOLUNTARY=y

CONFIG_JUMP_LABEL=y

# Disable Extra debug options
CONFIG_SCHEDSTATS=n
CONFIG_TIMER_STATS=n
CONFIG_DEBUG_SPINLOCK=n
CONFIG_DEBUG_MUTEXES=n
CONFIG_DEBUG_LOCK_ALLOC=n
CONFIG_PROVE_LOCKING=n
CONFIG_LOCKDEP=n
CONFIG_STACKTRACE=n
CONFIG_SCHED_DEBUG=n
CONFIG_FTRACE=n
CONFIG_ARM_UNWIND=n
##################################################
config="CONFIG_CGROUPS" ; config_enable
config="CONFIG_REGULATOR_GPIO" ; config_enable

config="CONFIG_CRYPTO_DEV_OMAP_SHAM" ; config_enable
config="CONFIG_CRYPTO_DEV_OMAP_AES" ; config_enable
config="CONFIG_CRYPTO_DEV_OMAP_DES" ; config_enable
config="CONFIG_CRYPTO_USER_API_HASH" ; config_enable
config="CONFIG_CRYPTO_USER_API_SKCIPHER" ; config_enable

config="CONFIG_PREEMPT_NONE" ; config_disable
config="CONFIG_PREEMPT_VOLUNTARY" ; config_disable
config="CONFIG_PREEMPT" ; config_enable
##################################################
#connectivity.cfg
##################################################
# TI Connectivity Configs
##################################################
#PCIe RC
CONFIG_PCI=y
CONFIG_PCI_DRA7XX=y

#USB Host
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_XHCI_HCD=m
CONFIG_USB_TEST=m
# CONFIG_USB_DEBUG is not set

#USB MUSB support
CONFIG_USB_MUSB_HDRC=m
CONFIG_USB_MUSB_OMAP2PLUS=m
CONFIG_USB_MUSB_DSPS=m
CONFIG_TI_CPPI41=y
CONFIG_USB_TI_CPPI41_DMA=y
CONFIG_TWL6030_USB=m
CONFIG_TWL4030_USB=m

#USB gadgets
CONFIG_USB_AUDIO=m
CONFIG_USB_ETH=m
CONFIG_USB_G_NCM=m
CONFIG_USB_GADGETFS=m
CONFIG_USB_FUNCTIONFS=m
CONFIG_USB_FUNCTIONFS_ETH=y
CONFIG_USB_FUNCTIONFS_RNDIS=y
CONFIG_USB_FUNCTIONFS_GENERIC=y
CONFIG_USB_MASS_STORAGE=m
CONFIG_USB_G_SERIAL=m
CONFIG_USB_MIDI_GADGET=m
CONFIG_USB_G_PRINTER=m
CONFIG_USB_CDC_COMPOSITE=m
CONFIG_USB_G_ACM_MS=m
CONFIG_USB_G_MULTI=m
CONFIG_USB_G_MULTI_CDC=y
CONFIG_USB_G_HID=m
CONFIG_USB_G_DBGP=m
CONFIG_USB_G_WEBCAM=m

#USB Video
CONFIG_MEDIA_SUPPORT=m
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_VIDEO_DEV=m
CONFIG_VIDEO_V4L2=m
CONFIG_VIDEOBUF2_CORE=m
CONFIG_VIDEOBUF2_MEMOPS=m
CONFIG_VIDEOBUF2_VMALLOC=m
CONFIG_MEDIA_USB_SUPPORT=y
CONFIG_USB_VIDEO_CLASS=m
CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=y
CONFIG_USB_GSPCA=m

#USB device classes
CONFIG_USB_ACM=m
CONFIG_USB_SERIAL=m
CONFIG_USB_SERIAL_PL2303=m
CONFIG_USB_PRINTER=m

#SATA
CONFIG_ATA=y
CONFIG_SATA_AHCI_PLATFORM=y

#GPIO
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_PCA953X=y

#IIO and ADC
CONFIG_IIO=m
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_KFIFO_BUF=m
CONFIG_TI_AM335X_ADC=m

#PWM
CONFIG_PWM=y
CONFIG_PWM_TIECAP=y
CONFIG_PWM_TIEHRPWM=y

#Touchscreen
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_ADS7846=y
CONFIG_TOUCHSCREEN_ATMEL_MXT=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_TOUCHSCREEN_TI_AM335X_TSC=y
CONFIG_TOUCHSCREEN_PIXCIR=m

# Buttons
CONFIG_INPUT_PALMAS_PWRBUTTON=y

#RTC
CONFIG_RTC_DRV_PALMAS=y
CONFIG_RTC_DRV_DS1307=y

#Ethernet
CONFIG_TI_CPTS=y

#LED
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_GPIO=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y

#MTD
CONFIG_MTD_NAND_OMAP_BCH=y
CONFIG_MTD_TESTS=m

#SPI
CONFIG_SPI_SPIDEV=y

#QSPI
CONFIG_SPI_TI_QSPI=y
CONFIG_MTD_M25P80=m

#EXTCON
CONFIG_EXTCON_GPIO=y
##################################################
#PCIe RC
CONFIG_PCI=y
CONFIG_PCI_DRA7XX=y

#USB Host
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_XHCI_HCD=m
CONFIG_USB_TEST=m
# CONFIG_USB_DEBUG is not set

config="CONFIG_USB_EHCI_HCD" ; config_enable
config="CONFIG_USB_XHCI_HCD" ; config_enable
config="CONFIG_USB_TEST" ; config_module

#USB MUSB support
CONFIG_USB_MUSB_HDRC=m
CONFIG_USB_MUSB_OMAP2PLUS=m
CONFIG_USB_MUSB_DSPS=m
CONFIG_TI_CPPI41=y
CONFIG_USB_TI_CPPI41_DMA=y
CONFIG_TWL6030_USB=m
CONFIG_TWL4030_USB=m

config="CONFIG_USB_MUSB_HDRC" ; config_module
config="CONFIG_USB_MUSB_OMAP2PLUS" ; config_module
config="CONFIG_USB_MUSB_DSPS" ; config_module
config="CONFIG_TI_CPPI41" ; config_enable
config="CONFIG_USB_TI_CPPI41_DMA" ; config_enable
config="CONFIG_TWL6030_USB" ; config_module
config="CONFIG_TWL4030_USB" ; config_module

#USB gadgets
CONFIG_USB_AUDIO=m
CONFIG_USB_ETH=m
CONFIG_USB_G_NCM=m
CONFIG_USB_GADGETFS=m
CONFIG_USB_FUNCTIONFS=m
CONFIG_USB_FUNCTIONFS_ETH=y
CONFIG_USB_FUNCTIONFS_RNDIS=y
CONFIG_USB_FUNCTIONFS_GENERIC=y
CONFIG_USB_MASS_STORAGE=m
CONFIG_USB_G_SERIAL=m
CONFIG_USB_MIDI_GADGET=m
CONFIG_USB_G_PRINTER=m
CONFIG_USB_CDC_COMPOSITE=m
CONFIG_USB_G_ACM_MS=m
CONFIG_USB_G_MULTI=m
CONFIG_USB_G_MULTI_CDC=y
CONFIG_USB_G_HID=m
CONFIG_USB_G_DBGP=m
CONFIG_USB_G_WEBCAM=m

config="CONFIG_USB_AUDIO" ; config_module
config="CONFIG_USB_ETH" ; config_module
config="CONFIG_USB_G_NCM" ; config_module
config="CONFIG_USB_GADGETFS" ; config_module
config="CONFIG_USB_FUNCTIONFS" ; config_module
config="CONFIG_USB_FUNCTIONFS_ETH" ; config_enable
config="CONFIG_USB_FUNCTIONFS_RNDIS" ; config_enable
config="CONFIG_USB_FUNCTIONFS_GENERIC" ; config_enable
config="CONFIG_USB_MASS_STORAGE" ; config_module
config="CONFIG_USB_G_SERIAL" ; config_module
config="CONFIG_USB_MIDI_GADGET" ; config_module
config="CONFIG_USB_G_PRINTER" ; config_module
config="CONFIG_USB_CDC_COMPOSITE" ; config_module
config="CONFIG_USB_G_ACM_MS" ; config_module
config="CONFIG_USB_G_MULTI" ; config_module
config="CONFIG_USB_G_MULTI_CDC" ; config_enable
config="CONFIG_USB_G_HID" ; config_module
config="CONFIG_USB_G_DBGP" ; config_module
config="CONFIG_USB_G_WEBCAM" ; config_module

#USB Video
CONFIG_MEDIA_SUPPORT=m
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_VIDEO_DEV=m
CONFIG_VIDEO_V4L2=m
CONFIG_VIDEOBUF2_CORE=m
CONFIG_VIDEOBUF2_MEMOPS=m
CONFIG_VIDEOBUF2_VMALLOC=m
CONFIG_MEDIA_USB_SUPPORT=y
CONFIG_USB_VIDEO_CLASS=m
CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=y
CONFIG_USB_GSPCA=m

config="CONFIG_MEDIA_SUPPORT" ; config_module
config="CONFIG_MEDIA_CAMERA_SUPPORT" ; config_enable
config="CONFIG_VIDEO_DEV" ; config_module
config="CONFIG_VIDEO_V4L2" ; config_module
config="CONFIG_VIDEOBUF2_CORE" ; config_module
config="CONFIG_VIDEOBUF2_MEMOPS" ; config_module
config="CONFIG_VIDEOBUF2_VMALLOC" ; config_module
config="CONFIG_MEDIA_USB_SUPPORT" ; config_enable
config="CONFIG_USB_VIDEO_CLASS" ; config_module
config="CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV" ; config_enable
config="CONFIG_USB_GSPCA" ; config_module

#USB device classes
CONFIG_USB_ACM=m
CONFIG_USB_SERIAL=m
CONFIG_USB_SERIAL_PL2303=m
CONFIG_USB_PRINTER=m

config="CONFIG_USB_ACM" ; config_module
config="CONFIG_USB_SERIAL" ; config_module
config="CONFIG_USB_SERIAL_PL2303" ; config_module
config="CONFIG_USB_PRINTER" ; config_module

#SATA
CONFIG_ATA=y
CONFIG_SATA_AHCI_PLATFORM=y

config="CONFIG_ATA" ; config_enable
config="CONFIG_SATA_AHCI_PLATFORM" ; config_enable

#GPIO
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_PCA953X=y

config="CONFIG_GPIO_PCF857X" ; config_enable
config="CONFIG_GPIO_PCA953X" ; config_enable

#IIO and ADC
CONFIG_IIO=m
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_KFIFO_BUF=m
CONFIG_TI_AM335X_ADC=m

config="CONFIG_IIO" ; config_module
config="CONFIG_IIO_BUFFER" ; config_enable
config="CONFIG_IIO_BUFFER_CB" ; config_enable
config="CONFIG_IIO_KFIFO_BUF" ; config_module
config="CONFIG_TI_AM335X_ADC" ; config_module

#PWM
CONFIG_PWM=y
CONFIG_PWM_TIECAP=y
CONFIG_PWM_TIEHRPWM=y

config="CONFIG_PWM" ; config_enable
config="CONFIG_PWM_TIECAP" ; config_enable
config="CONFIG_PWM_TIEHRPWM" ; config_enable

#Touchscreen
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_ADS7846=y
CONFIG_TOUCHSCREEN_ATMEL_MXT=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_TOUCHSCREEN_TI_AM335X_TSC=y
CONFIG_TOUCHSCREEN_PIXCIR=m

config="CONFIG_INPUT_TOUCHSCREEN" ; config_enable
config="CONFIG_TOUCHSCREEN_ADS7846" ; config_enable
config="CONFIG_TOUCHSCREEN_ATMEL_MXT" ; config_enable
config="CONFIG_MFD_TI_AM335X_TSCADC" ; config_enable
config="CONFIG_TOUCHSCREEN_TI_AM335X_TSC" ; config_enable
config="CONFIG_TOUCHSCREEN_PIXCIR" ; config_module

# Buttons
CONFIG_INPUT_PALMAS_PWRBUTTON=y

config="CONFIG_INPUT_PALMAS_PWRBUTTON" ; config_enable

#RTC
CONFIG_RTC_DRV_PALMAS=y
CONFIG_RTC_DRV_DS1307=y

config="CONFIG_RTC_DRV_PALMAS" ; config_enable
config="CONFIG_RTC_DRV_DS1307" ; config_enable

#Ethernet
CONFIG_TI_CPTS=y

config="CONFIG_TI_CPTS" ; config_enable

#LED
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_GPIO=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y

config="CONFIG_LEDS_CLASS" ; config_enable
config="CONFIG_LEDS_GPIO" ; config_enable
config="CONFIG_LEDS_TRIGGERS" ; config_enable
config="CONFIG_LEDS_TRIGGER_TIMER" ; config_enable
config="CONFIG_LEDS_TRIGGER_ONESHOT" ; config_enable
config="CONFIG_LEDS_TRIGGER_HEARTBEAT" ; config_enable
config="CONFIG_LEDS_TRIGGER_BACKLIGHT" ; config_enable
config="CONFIG_LEDS_TRIGGER_CPU" ; config_enable
config="CONFIG_LEDS_TRIGGER_GPIO" ; config_enable
config="CONFIG_LEDS_TRIGGER_DEFAULT_ON" ; config_enable
config="CONFIG_LEDS_TRIGGER_TRANSIENT" ; config_enable
config="CONFIG_LEDS_TRIGGER_CAMERA" ; config_enable

#MTD
CONFIG_MTD_NAND_OMAP_BCH=y
CONFIG_MTD_TESTS=m

config="CONFIG_MTD_NAND_OMAP_BCH" ; config_enable
config="CONFIG_MTD_TESTS" ; config_module

#SPI
CONFIG_SPI_SPIDEV=y

config="CONFIG_SPI_SPIDEV" ; config_enable

#QSPI
CONFIG_SPI_TI_QSPI=y
CONFIG_MTD_M25P80=m

config="CONFIG_SPI_TI_QSPI" ; config_enable
config="CONFIG_MTD_M25P80" ; config_module

#EXTCON
CONFIG_EXTCON_GPIO=y

config="CONFIG_EXTCON_GPIO" ; config_enable
##################################################
#ipc.cfg
##################################################
# TI IPC config options
##################################################
# HwSpinLock
CONFIG_HWSPINLOCK_OMAP=y

# Mailbox
CONFIG_OMAP2PLUS_MBOX=y

# IOMMU
CONFIG_OMAP_IOMMU=y
CONFIG_OMAP_IOVMM=y
CONFIG_OMAP_IOMMU_DEBUG=y

# Remoteproc
CONFIG_OMAP_REMOTEPROC=m
CONFIG_OMAP_REMOTEPROC_WATCHDOG=y

# RPMsg
CONFIG_RPMSG_RPC=m
##################################################
# HwSpinLock
CONFIG_HWSPINLOCK_OMAP=y

config="CONFIG_HWSPINLOCK_OMAP" ; config_enable

# Mailbox
CONFIG_OMAP2PLUS_MBOX=y

config="CONFIG_OMAP2PLUS_MBOX" ; config_enable

# IOMMU
CONFIG_OMAP_IOMMU=y
CONFIG_OMAP_IOVMM=y
CONFIG_OMAP_IOMMU_DEBUG=y

config="CONFIG_OMAP_IOMMU" ; config_enable
config="CONFIG_OMAP_IOVMM" ; config_enable

# Remoteproc
CONFIG_OMAP_REMOTEPROC=m
CONFIG_OMAP_REMOTEPROC_WATCHDOG=y

config="CONFIG_OMAP_REMOTEPROC" ; config_module
config="CONFIG_OMAP_REMOTEPROC_WATCHDOG" ; config_enable

# RPMsg
CONFIG_RPMSG_RPC=m

config="CONFIG_RPMSG_RPC" ; config_module
##################################################
#power.cfg
##################################################
# TI Power config options
##################################################
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_STAT=y
CONFIG_CPU_FREQ_STAT_DETAILS=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=m
CONFIG_CPU_FREQ_GOV_USERSPACE=m
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=m
# CONFIG_ARM_OMAP2PLUS_CPUFREQ is not set
CONFIG_CPU_THERMAL=y
# CONFIG_IMX_THERMAL is not set
CONFIG_TI_THERMAL=y
CONFIG_GENERIC_CPUFREQ_CPU0=y
CONFIG_VOLTAGE_DOMAIN_OMAP=y

CONFIG_SENSORS_TMP102=y
##################################################
config="CONFIG_CPU_FREQ" ; config_enable
config="CONFIG_CPU_FREQ_STAT" ; config_enable
config="CONFIG_CPU_FREQ_STAT_DETAILS" ; config_enable

config="CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE" ; config_enable

config="CONFIG_CPU_FREQ_GOV_PERFORMANCE" ; config_enable
config="CONFIG_CPU_FREQ_GOV_POWERSAVE" ; config_enable
config="CONFIG_CPU_FREQ_GOV_USERSPACE" ; config_enable
config="CONFIG_CPU_FREQ_GOV_ONDEMAND" ; config_enable
config="CONFIG_CPU_FREQ_GOV_CONSERVATIVE" ; config_enable

config="CONFIG_CPU_THERMAL" ; config_enable
config="CONFIG_TI_THERMAL" ; config_enable

config="CONFIG_GENERIC_CPUFREQ_CPU0" ; config_enable
config="CONFIG_VOLTAGE_DOMAIN_OMAP" ; config_enable

config="CONFIG_SENSORS_TMP102" ; config_enable
##################################################
#system_test.cfg
##################################################
# TI System Test config options
##################################################
CONFIG_DEBUG_KMEMLEAK=y
CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE=4000
CONFIG_DEBUG_KMEMLEAK_TEST=n
CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF=n
CONFIG_DEBUG_INFO=y
CONFIG_RTC_DEBUG=y
CONFIG_TIGON3=m

# Enable Devfreq for co-processor driver testing
CONFIG_PM_DEVFREQ=y
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=y
##################################################
config="CONFIG_PM_DEVFREQ" ; config_enable
config="CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND" ; config_enable
config="CONFIG_DEVFREQ_GOV_PERFORMANCE" ; config_enable
config="CONFIG_DEVFREQ_GOV_POWERSAVE" ; config_enable
config="CONFIG_DEVFREQ_GOV_USERSPACE" ; config_enable
##################################################
# TI WLCORE config options
##################################################
CONFIG_CFG80211=n
CONFIG_MAC80211=n
CONFIG_WL_TI=n
CONFIG_WL12XX=n
CONFIG_WL18XX=n
CONFIG_WLCORE=n
CONFIG_WLCORE_SDIO=n


CONFIG_NL80211_TESTMODE=y
CONFIG_RFKILL=y
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_CCM=y


CONFIG_NF_CONNTRACK=y
CONFIG_NF_CONNTRACK_IPV4=y
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_FILTER=y
CONFIG_NF_NAT_IPV4=y
CONFIG_IP_NF_TARGET_MASQUERADE=y
##################################################

config="CONFIG_RFKILL" ; config_module

config="CONFIG_NF_CONNTRACK" ; config_enable
config="CONFIG_NF_CONNTRACK_IPV4" ; config_enable
config="CONFIG_IP_NF_IPTABLES" ; config_enable
config="CONFIG_IP_NF_FILTER" ; config_enable
config="CONFIG_NF_NAT_IPV4" ; config_enable
config="CONFIG_IP_NF_TARGET_MASQUERADE" ; config_enable
##################################################

#
# General setup
#
config="CONFIG_LOCALVERSION_AUTO" ; config_disable
config="CONFIG_KERNEL_GZIP" ; config_disable
config="CONFIG_KERNEL_LZO" ; config_enable
config="CONFIG_FHANDLE" ; config_enable

#
# RCU Subsystem
#
config="CONFIG_LOG_BUF_SHIFT" ; option="18" ; config_value
config="CONFIG_CGROUP_SCHED" ; config_enable
config="CONFIG_FAIR_GROUP_SCHED" ; config_enable

#
# Kernel Performance Events And Counters
#
config="CONFIG_SECCOMP_FILTER" ; config_enable
config="CONFIG_CC_STACKPROTECTOR" ; config_enable
config="CONFIG_CC_STACKPROTECTOR_NONE" ; config_disable
config="CONFIG_CC_STACKPROTECTOR_REGULAR" ; config_enable

#
# GCOV-based kernel profiling
#
config="CONFIG_MODULE_SRCVERSION_ALL" ; config_disable
config="CONFIG_BLK_DEV_BSG" ; config_enable

#
# Kernel Features
#
config="CONFIG_ZSMALLOC" ; config_enable
config="CONFIG_SECCOMP" ; config_enable

#
# Boot options
#
config="CONFIG_ARM_APPENDED_DTB" ; config_disable

#
# ARM CPU frequency scaling drivers
#
config="CONFIG_ARM_OMAP2PLUS_CPUFREQ" ; config_disable

#
# At least one emulation must be selected
#
config="CONFIG_KERNEL_MODE_NEON" ; config_enable

#
# Power management options
#
config="CONFIG_PM_AUTOSLEEP" ; config_enable
config="CONFIG_PM_WAKELOCKS" ; config_enable

#
# Networking options
#
config="CONFIG_PACKET_DIAG" ; config_module
config="CONFIG_UNIX_DIAG" ; config_module
config="CONFIG_XFRM_ALGO" ; config_module
config="CONFIG_XFRM_USER" ; config_module
config="CONFIG_XFRM_SUB_POLICY" ; config_enable
config="CONFIG_XFRM_IPCOMP" ; config_module
config="CONFIG_NET_KEY" ; config_module
config="CONFIG_IP_ADVANCED_ROUTER" ; config_enable
config="CONFIG_IP_FIB_TRIE_STATS" ; config_enable
config="CONFIG_IP_MULTIPLE_TABLES" ; config_enable
config="CONFIG_IP_ROUTE_MULTIPATH" ; config_enable
config="CONFIG_IP_ROUTE_VERBOSE" ; config_enable
config="CONFIG_IP_ROUTE_CLASSID" ; config_enable
config="CONFIG_NET_IPIP" ; config_module
config="CONFIG_NET_IPGRE_DEMUX" ; config_module
config="CONFIG_NET_IP_TUNNEL" ; config_module
config="CONFIG_NET_IPGRE" ; config_module
config="CONFIG_NET_IPGRE_BROADCAST" ; config_enable
config="CONFIG_IP_MROUTE" ; config_enable
config="CONFIG_IP_MROUTE_MULTIPLE_TABLES" ; config_enable
config="CONFIG_IP_PIMSM_V1" ; config_enable
config="CONFIG_IP_PIMSM_V2" ; config_enable
config="CONFIG_SYN_COOKIES" ; config_enable
config="CONFIG_NET_IPVTI" ; config_module
config="CONFIG_INET_AH" ; config_module
config="CONFIG_INET_ESP" ; config_module
config="CONFIG_INET_IPCOMP" ; config_module
config="CONFIG_INET_XFRM_TUNNEL" ; config_module
config="CONFIG_INET_TUNNEL" ; config_module
config="CONFIG_INET_XFRM_MODE_TRANSPORT" ; config_module
config="CONFIG_INET_XFRM_MODE_TUNNEL" ; config_module
config="CONFIG_INET_XFRM_MODE_BEET" ; config_module
config="CONFIG_INET_LRO" ; config_module
config="CONFIG_INET_DIAG" ; config_module
config="CONFIG_INET_TCP_DIAG" ; config_module
config="CONFIG_INET_UDP_DIAG" ; config_module
config="CONFIG_TCP_CONG_ADVANCED" ; config_enable
config="CONFIG_TCP_CONG_BIC" ; config_module
config="CONFIG_TCP_CONG_WESTWOOD" ; config_module
config="CONFIG_TCP_CONG_HTCP" ; config_module
config="CONFIG_TCP_CONG_HSTCP" ; config_module
config="CONFIG_TCP_CONG_HYBLA" ; config_module
config="CONFIG_TCP_CONG_VEGAS" ; config_module
config="CONFIG_TCP_CONG_SCALABLE" ; config_module
config="CONFIG_TCP_CONG_LP" ; config_module
config="CONFIG_TCP_CONG_VENO" ; config_module
config="CONFIG_TCP_CONG_YEAH" ; config_module
config="CONFIG_TCP_CONG_ILLINOIS" ; config_module
config="CONFIG_DEFAULT_CUBIC" ; config_enable
config="CONFIG_TCP_MD5SIG" ; config_enable
config="CONFIG_IPV6" ; config_enable
config="CONFIG_IPV6_ROUTER_PREF" ; config_enable
config="CONFIG_IPV6_ROUTE_INFO" ; config_enable
config="CONFIG_IPV6_OPTIMISTIC_DAD" ; config_enable
config="CONFIG_INET6_AH" ; config_module
config="CONFIG_INET6_ESP" ; config_module
config="CONFIG_INET6_IPCOMP" ; config_module
config="CONFIG_IPV6_MIP6" ; config_enable
config="CONFIG_INET6_XFRM_TUNNEL" ; config_module
config="CONFIG_INET6_TUNNEL" ; config_module
config="CONFIG_INET6_XFRM_MODE_TRANSPORT" ; config_module
config="CONFIG_INET6_XFRM_MODE_TUNNEL" ; config_module
config="CONFIG_INET6_XFRM_MODE_BEET" ; config_module
config="CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION" ; config_module
config="CONFIG_IPV6_VTI" ; config_module
config="CONFIG_IPV6_SIT" ; config_module
config="CONFIG_IPV6_SIT_6RD" ; config_enable
config="CONFIG_IPV6_NDISC_NODETYPE" ; config_enable
config="CONFIG_IPV6_TUNNEL" ; config_module
config="CONFIG_IPV6_GRE" ; config_module
config="CONFIG_IPV6_MULTIPLE_TABLES" ; config_enable
config="CONFIG_IPV6_SUBTREES" ; config_enable
config="CONFIG_IPV6_MROUTE" ; config_enable
config="CONFIG_IPV6_MROUTE_MULTIPLE_TABLES" ; config_enable
config="CONFIG_IPV6_PIMSM_V2" ; config_enable
config="CONFIG_NETWORK_SECMARK" ; config_enable
config="CONFIG_BRIDGE_NETFILTER" ; config_enable

#
# Core Netfilter Configuration
#
config="CONFIG_NETFILTER_NETLINK" ; config_module
config="CONFIG_NETFILTER_NETLINK_ACCT" ; config_module
config="CONFIG_NETFILTER_NETLINK_QUEUE" ; config_module
config="CONFIG_NETFILTER_NETLINK_LOG" ; config_module
config="CONFIG_NF_CONNTRACK" ; config_enable
config="CONFIG_NF_CONNTRACK_MARK" ; config_enable
config="CONFIG_NF_CONNTRACK_SECMARK" ; config_enable
config="CONFIG_NF_CONNTRACK_ZONES" ; config_enable
config="CONFIG_NF_CONNTRACK_PROCFS" ; config_enable
config="CONFIG_NF_CONNTRACK_EVENTS" ; config_enable
config="CONFIG_NF_CONNTRACK_TIMEOUT" ; config_enable
config="CONFIG_NF_CONNTRACK_TIMESTAMP" ; config_enable
config="CONFIG_NF_CONNTRACK_LABELS" ; config_enable
config="CONFIG_NF_CT_PROTO_DCCP" ; config_module
config="CONFIG_NF_CT_PROTO_GRE" ; config_module
config="CONFIG_NF_CT_PROTO_SCTP" ; config_module
config="CONFIG_NF_CT_PROTO_UDPLITE" ; config_module
config="CONFIG_NF_CONNTRACK_AMANDA" ; config_module
config="CONFIG_NF_CONNTRACK_FTP" ; config_module
config="CONFIG_NF_CONNTRACK_H323" ; config_module
config="CONFIG_NF_CONNTRACK_IRC" ; config_module
config="CONFIG_NF_CONNTRACK_BROADCAST" ; config_module
config="CONFIG_NF_CONNTRACK_NETBIOS_NS" ; config_module
config="CONFIG_NF_CONNTRACK_SNMP" ; config_module
config="CONFIG_NF_CONNTRACK_PPTP" ; config_module
config="CONFIG_NF_CONNTRACK_SANE" ; config_module
config="CONFIG_NF_CONNTRACK_SIP" ; config_module
config="CONFIG_NF_CONNTRACK_TFTP" ; config_module
config="CONFIG_NF_CT_NETLINK" ; config_module
config="CONFIG_NF_CT_NETLINK_TIMEOUT" ; config_module
config="CONFIG_NF_CT_NETLINK_HELPER" ; config_module
config="CONFIG_NETFILTER_NETLINK_QUEUE_CT" ; config_enable
config="CONFIG_NF_NAT" ; config_enable
config="CONFIG_NF_NAT_NEEDED" ; config_enable
config="CONFIG_NF_NAT_PROTO_DCCP" ; config_module
config="CONFIG_NF_NAT_PROTO_UDPLITE" ; config_module
config="CONFIG_NF_NAT_PROTO_SCTP" ; config_module
config="CONFIG_NF_NAT_AMANDA" ; config_module
config="CONFIG_NF_NAT_FTP" ; config_module
config="CONFIG_NF_NAT_IRC" ; config_module
config="CONFIG_NF_NAT_SIP" ; config_module
config="CONFIG_NF_NAT_TFTP" ; config_module
config="CONFIG_NETFILTER_SYNPROXY" ; config_module
config="CONFIG_NF_TABLES" ; config_module
config="CONFIG_NF_TABLES_INET" ; config_module
config="CONFIG_NFT_EXTHDR" ; config_module
config="CONFIG_NFT_META" ; config_module
config="CONFIG_NFT_CT" ; config_module
config="CONFIG_NFT_RBTREE" ; config_module
config="CONFIG_NFT_HASH" ; config_module
config="CONFIG_NFT_COUNTER" ; config_module
config="CONFIG_NFT_LOG" ; config_module
config="CONFIG_NFT_LIMIT" ; config_module
config="CONFIG_NFT_NAT" ; config_module
config="CONFIG_NFT_QUEUE" ; config_module
config="CONFIG_NFT_REJECT" ; config_module
config="CONFIG_NFT_REJECT_INET" ; config_module
config="CONFIG_NFT_COMPAT" ; config_module

#
# Xtables combined modules
#
config="CONFIG_NETFILTER_XT_MARK" ; config_module
config="CONFIG_NETFILTER_XT_CONNMARK" ; config_module
config="CONFIG_NETFILTER_XT_SET" ; config_module

#
# Xtables targets
#
config="CONFIG_NETFILTER_XT_TARGET_CHECKSUM" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_CLASSIFY" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_CONNMARK" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_CONNSECMARK" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_CT" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_DSCP" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_HL" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_HMARK" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_IDLETIMER" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_LED" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_LOG" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_MARK" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_NETMAP" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_NFLOG" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_NFQUEUE" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_RATEEST" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_REDIRECT" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_TEE" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_TPROXY" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_TRACE" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_SECMARK" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_TCPMSS" ; config_module
config="CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP" ; config_module

#
# Xtables matches
#
config="CONFIG_NETFILTER_XT_MATCH_ADDRTYPE" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_BPF" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_CGROUP" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_CLUSTER" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_COMMENT" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_CONNBYTES" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_CONNLABEL" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_CONNLIMIT" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_CONNMARK" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_CONNTRACK" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_CPU" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_DCCP" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_DEVGROUP" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_DSCP" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_ECN" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_ESP" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_HASHLIMIT" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_HELPER" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_HL" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_IPCOMP" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_IPRANGE" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_IPVS" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_L2TP" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_LENGTH" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_LIMIT" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_MAC" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_MARK" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_MULTIPORT" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_NFACCT" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_OSF" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_OWNER" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_POLICY" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_PHYSDEV" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_PKTTYPE" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_QUOTA" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_RATEEST" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_REALM" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_RECENT" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_SCTP" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_SOCKET" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_STATE" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_STATISTIC" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_STRING" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_TCPMSS" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_TIME" ; config_module
config="CONFIG_NETFILTER_XT_MATCH_U32" ; config_module
config="CONFIG_IP_SET" ; config_module
config="CONFIG_IP_SET_BITMAP_IP" ; config_module
config="CONFIG_IP_SET_BITMAP_IPMAC" ; config_module
config="CONFIG_IP_SET_BITMAP_PORT" ; config_module
config="CONFIG_IP_SET_HASH_IP" ; config_module
config="CONFIG_IP_SET_HASH_IPPORT" ; config_module
config="CONFIG_IP_SET_HASH_IPPORTIP" ; config_module
config="CONFIG_IP_SET_HASH_IPPORTNET" ; config_module
config="CONFIG_IP_SET_HASH_NETPORTNET" ; config_module
config="CONFIG_IP_SET_HASH_NET" ; config_module
config="CONFIG_IP_SET_HASH_NETNET" ; config_module
config="CONFIG_IP_SET_HASH_NETPORT" ; config_module
config="CONFIG_IP_SET_HASH_NETIFACE" ; config_module
config="CONFIG_IP_SET_LIST_SET" ; config_module
config="CONFIG_IP_VS" ; config_module
config="CONFIG_IP_VS_IPV6" ; config_enable

#
# IPVS transport protocol load balancing support
#
config="CONFIG_IP_VS_PROTO_TCP" ; config_enable
config="CONFIG_IP_VS_PROTO_UDP" ; config_enable
config="CONFIG_IP_VS_PROTO_AH_ESP" ; config_enable
config="CONFIG_IP_VS_PROTO_ESP" ; config_enable
config="CONFIG_IP_VS_PROTO_AH" ; config_enable
config="CONFIG_IP_VS_PROTO_SCTP" ; config_enable

#
# IPVS scheduler
#
config="CONFIG_IP_VS_RR" ; config_module
config="CONFIG_IP_VS_WRR" ; config_module
config="CONFIG_IP_VS_LC" ; config_module
config="CONFIG_IP_VS_WLC" ; config_module
config="CONFIG_IP_VS_LBLC" ; config_module
config="CONFIG_IP_VS_LBLCR" ; config_module
config="CONFIG_IP_VS_DH" ; config_module
config="CONFIG_IP_VS_SH" ; config_module
config="CONFIG_IP_VS_SED" ; config_module
config="CONFIG_IP_VS_NQ" ; config_module

#
# IPVS application helper
#
config="CONFIG_IP_VS_FTP" ; config_module
config="CONFIG_IP_VS_NFCT" ; config_enable
config="CONFIG_IP_VS_PE_SIP" ; config_module

#
# IP: Netfilter configuration
#
config="CONFIG_NFT_CHAIN_ROUTE_IPV4" ; config_module
config="CONFIG_NFT_CHAIN_NAT_IPV4" ; config_module
config="CONFIG_NF_TABLES_ARP" ; config_module
config="CONFIG_IP_NF_MATCH_AH" ; config_module
config="CONFIG_IP_NF_MATCH_RPFILTER" ; config_module
config="CONFIG_IP_NF_TARGET_REJECT" ; config_module
config="CONFIG_IP_NF_TARGET_SYNPROXY" ; config_module
config="CONFIG_IP_NF_TARGET_ULOG" ; config_module
config="CONFIG_IP_NF_MANGLE" ; config_module
config="CONFIG_IP_NF_TARGET_CLUSTERIP" ; config_module
config="CONFIG_IP_NF_TARGET_ECN" ; config_module
config="CONFIG_IP_NF_RAW" ; config_module
config="CONFIG_IP_NF_SECURITY" ; config_module
config="CONFIG_IP_NF_ARPTABLES" ; config_module
config="CONFIG_IP_NF_ARPFILTER" ; config_module
config="CONFIG_IP_NF_ARP_MANGLE" ; config_module

#
# IPv6: Netfilter configuration
#
config="CONFIG_NF_CONNTRACK_IPV6" ; config_module
config="CONFIG_NFT_CHAIN_ROUTE_IPV6" ; config_module
config="CONFIG_NFT_CHAIN_NAT_IPV6" ; config_module
config="CONFIG_IP6_NF_MATCH_AH" ; config_module
config="CONFIG_IP6_NF_MATCH_EUI64" ; config_module
config="CONFIG_IP6_NF_MATCH_FRAG" ; config_module
config="CONFIG_IP6_NF_MATCH_OPTS" ; config_module
config="CONFIG_IP6_NF_MATCH_IPV6HEADER" ; config_module
config="CONFIG_IP6_NF_MATCH_MH" ; config_module
config="CONFIG_IP6_NF_MATCH_RPFILTER" ; config_module
config="CONFIG_IP6_NF_MATCH_RT" ; config_module
config="CONFIG_IP6_NF_FILTER" ; config_module
config="CONFIG_IP6_NF_TARGET_REJECT" ; config_module
config="CONFIG_IP6_NF_TARGET_SYNPROXY" ; config_module
config="CONFIG_IP6_NF_MANGLE" ; config_module
config="CONFIG_IP6_NF_RAW" ; config_module
config="CONFIG_IP6_NF_SECURITY" ; config_module
config="CONFIG_NF_NAT_IPV6" ; config_module
config="CONFIG_IP6_NF_TARGET_MASQUERADE" ; config_module
config="CONFIG_IP6_NF_TARGET_NPT" ; config_module
config="CONFIG_NF_TABLES_BRIDGE" ; config_module
config="CONFIG_BRIDGE_NF_EBTABLES" ; config_module
config="CONFIG_BRIDGE_EBT_BROUTE" ; config_module
config="CONFIG_BRIDGE_EBT_T_FILTER" ; config_module
config="CONFIG_BRIDGE_EBT_T_NAT" ; config_module
config="CONFIG_BRIDGE_EBT_802_3" ; config_module
config="CONFIG_BRIDGE_EBT_AMONG" ; config_module
config="CONFIG_BRIDGE_EBT_ARP" ; config_module
config="CONFIG_BRIDGE_EBT_IP" ; config_module
config="CONFIG_BRIDGE_EBT_IP6" ; config_module
config="CONFIG_BRIDGE_EBT_LIMIT" ; config_module
config="CONFIG_BRIDGE_EBT_MARK" ; config_module
config="CONFIG_BRIDGE_EBT_PKTTYPE" ; config_module
config="CONFIG_BRIDGE_EBT_STP" ; config_module
config="CONFIG_BRIDGE_EBT_VLAN" ; config_module
config="CONFIG_BRIDGE_EBT_ARPREPLY" ; config_module
config="CONFIG_BRIDGE_EBT_DNAT" ; config_module
config="CONFIG_BRIDGE_EBT_MARK_T" ; config_module
config="CONFIG_BRIDGE_EBT_REDIRECT" ; config_module
config="CONFIG_BRIDGE_EBT_SNAT" ; config_module
config="CONFIG_BRIDGE_EBT_LOG" ; config_module
config="CONFIG_BRIDGE_EBT_ULOG" ; config_module
config="CONFIG_BRIDGE_EBT_NFLOG" ; config_module
config="CONFIG_IP_DCCP" ; config_module
config="CONFIG_INET_DCCP_DIAG" ; config_module

#
# DCCP CCIDs configuration
#
config="CONFIG_IP_DCCP_CCID3" ; config_enable
config="CONFIG_IP_DCCP_TFRC_LIB" ; config_enable

#
# DCCP Kernel Hacking
#
config="CONFIG_NET_DCCPPROBE" ; config_module
config="CONFIG_IP_SCTP" ; config_module
config="CONFIG_NET_SCTPPROBE" ; config_module
config="CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5" ; config_enable
config="CONFIG_SCTP_COOKIE_HMAC_MD5" ; config_enable
config="CONFIG_SCTP_COOKIE_HMAC_SHA1" ; config_enable
config="CONFIG_RDS" ; config_module
config="CONFIG_RDS_TCP" ; config_module
config="CONFIG_TIPC" ; config_module
config="CONFIG_ATM" ; config_module
config="CONFIG_ATM_CLIP" ; config_module
config="CONFIG_ATM_LANE" ; config_module
config="CONFIG_ATM_MPOA" ; config_module
config="CONFIG_ATM_BR2684" ; config_module
config="CONFIG_L2TP" ; config_module
config="CONFIG_L2TP_DEBUGFS" ; config_module
config="CONFIG_L2TP_V3" ; config_enable
config="CONFIG_L2TP_IP" ; config_module
config="CONFIG_L2TP_ETH" ; config_module
config="CONFIG_STP" ; config_module
config="CONFIG_GARP" ; config_module
config="CONFIG_MRP" ; config_module
config="CONFIG_BRIDGE" ; config_module
config="CONFIG_BRIDGE_IGMP_SNOOPING" ; config_enable
config="CONFIG_BRIDGE_VLAN_FILTERING" ; config_enable
config="CONFIG_VLAN_8021Q" ; config_module
config="CONFIG_VLAN_8021Q_GVRP" ; config_enable
config="CONFIG_VLAN_8021Q_MVRP" ; config_enable
config="CONFIG_LLC" ; config_module
config="CONFIG_LLC2" ; config_module
config="CONFIG_ATALK" ; config_module
config="CONFIG_DEV_APPLETALK" ; config_module
config="CONFIG_IPDDP" ; config_module
config="CONFIG_IPDDP_ENCAP" ; config_enable
config="CONFIG_PHONET" ; config_module
config="CONFIG_IEEE802154" ; config_module
config="CONFIG_IEEE802154_6LOWPAN" ; config_module
config="CONFIG_NET_SCHED" ; config_enable

#
# Queueing/Scheduling
#
config="CONFIG_NET_SCH_CBQ" ; config_module
config="CONFIG_NET_SCH_HTB" ; config_module
config="CONFIG_NET_SCH_HFSC" ; config_module
config="CONFIG_NET_SCH_ATM" ; config_module
config="CONFIG_NET_SCH_PRIO" ; config_module
config="CONFIG_NET_SCH_MULTIQ" ; config_module
config="CONFIG_NET_SCH_RED" ; config_module
config="CONFIG_NET_SCH_SFB" ; config_module
config="CONFIG_NET_SCH_SFQ" ; config_module
config="CONFIG_NET_SCH_TEQL" ; config_module
config="CONFIG_NET_SCH_TBF" ; config_module
config="CONFIG_NET_SCH_GRED" ; config_module
config="CONFIG_NET_SCH_DSMARK" ; config_module
config="CONFIG_NET_SCH_NETEM" ; config_module
config="CONFIG_NET_SCH_DRR" ; config_module
config="CONFIG_NET_SCH_MQPRIO" ; config_module
config="CONFIG_NET_SCH_CHOKE" ; config_module
config="CONFIG_NET_SCH_QFQ" ; config_module
config="CONFIG_NET_SCH_CODEL" ; config_module
config="CONFIG_NET_SCH_FQ_CODEL" ; config_module
config="CONFIG_NET_SCH_FQ" ; config_module
config="CONFIG_NET_SCH_HHF" ; config_module
config="CONFIG_NET_SCH_PIE" ; config_module
config="CONFIG_NET_SCH_INGRESS" ; config_module
config="CONFIG_NET_SCH_PLUG" ; config_module

#
# Classification
#
config="CONFIG_NET_CLS" ; config_enable
config="CONFIG_NET_CLS_BASIC" ; config_module
config="CONFIG_NET_CLS_TCINDEX" ; config_module
config="CONFIG_NET_CLS_ROUTE4" ; config_module
config="CONFIG_NET_CLS_FW" ; config_module
config="CONFIG_NET_CLS_U32" ; config_module
config="CONFIG_CLS_U32_PERF" ; config_enable
config="CONFIG_CLS_U32_MARK" ; config_enable
config="CONFIG_NET_CLS_RSVP" ; config_module
config="CONFIG_NET_CLS_RSVP6" ; config_module
config="CONFIG_NET_CLS_FLOW" ; config_module
config="CONFIG_NET_CLS_CGROUP" ; config_module
config="CONFIG_NET_CLS_BPF" ; config_module
config="CONFIG_NET_EMATCH" ; config_enable
config="CONFIG_NET_EMATCH_CMP" ; config_module
config="CONFIG_NET_EMATCH_NBYTE" ; config_module
config="CONFIG_NET_EMATCH_U32" ; config_module
config="CONFIG_NET_EMATCH_META" ; config_module
config="CONFIG_NET_EMATCH_TEXT" ; config_module
config="CONFIG_NET_EMATCH_CANID" ; config_module
config="CONFIG_NET_EMATCH_IPSET" ; config_module
config="CONFIG_NET_CLS_ACT" ; config_enable
config="CONFIG_NET_ACT_POLICE" ; config_module
config="CONFIG_NET_ACT_GACT" ; config_module
config="CONFIG_GACT_PROB" ; config_enable
config="CONFIG_NET_ACT_MIRRED" ; config_module
config="CONFIG_NET_ACT_IPT" ; config_module
config="CONFIG_NET_ACT_NAT" ; config_module
config="CONFIG_NET_ACT_PEDIT" ; config_module
config="CONFIG_NET_ACT_SIMP" ; config_module
config="CONFIG_NET_ACT_SKBEDIT" ; config_module
config="CONFIG_NET_ACT_CSUM" ; config_module
config="CONFIG_NET_CLS_IND" ; config_enable
config="CONFIG_NET_SCH_FIFO" ; config_enable
config="CONFIG_DCB" ; config_enable
config="CONFIG_BATMAN_ADV" ; config_module
config="CONFIG_BATMAN_ADV_BLA" ; config_enable
config="CONFIG_BATMAN_ADV_DAT" ; config_enable
config="CONFIG_BATMAN_ADV_NC" ; config_enable
config="CONFIG_OPENVSWITCH" ; config_module
config="CONFIG_OPENVSWITCH_GRE" ; config_enable
config="CONFIG_NETLINK_MMAP" ; config_enable
config="CONFIG_NETLINK_DIAG" ; config_module
config="CONFIG_NET_MPLS_GSO" ; config_enable
config="CONFIG_CGROUP_NET_PRIO" ; config_module
config="CONFIG_BPF_JIT" ; config_enable

#
# CAN Device Drivers
#
config="CONFIG_CAN_VCAN" ; config_module
config="CONFIG_CAN_SLCAN" ; config_module
config="CONFIG_CAN_TI_HECC" ; config_module
config="CONFIG_CAN_MCP251X" ; config_module

#
# CAN USB interfaces
#
config="CONFIG_CAN_EMS_USB" ; config_module
config="CONFIG_CAN_ESD_USB2" ; config_module
config="CONFIG_CAN_KVASER_USB" ; config_module
config="CONFIG_CAN_PEAK_USB" ; config_module
config="CONFIG_CAN_8DEV_USB" ; config_module
config="CONFIG_BT_RFCOMM" ; config_module
config="CONFIG_BT_RFCOMM_TTY" ; config_enable
config="CONFIG_BT_BNEP" ; config_module
config="CONFIG_BT_BNEP_MC_FILTER" ; config_enable
config="CONFIG_BT_BNEP_PROTO_FILTER" ; config_enable
config="CONFIG_BT_HIDP" ; config_module


#
# Bluetooth device drivers
#
config="CONFIG_BT_HCIBTUSB" ; config_module
config="CONFIG_BT_HCIBTSDIO" ; config_module
config="CONFIG_BT_HCIUART_ATH3K" ; config_enable
config="CONFIG_BT_HCIUART_3WIRE" ; config_enable
config="CONFIG_BT_HCIBFUSB" ; config_module
config="CONFIG_BT_HCIVHCI" ; config_module
config="CONFIG_BT_MRVL" ; config_module
config="CONFIG_BT_MRVL_SDIO" ; config_module
config="CONFIG_BT_ATH3K" ; config_module
config="CONFIG_AF_RXRPC" ; config_module
config="CONFIG_CFG80211_WEXT" ; config_enable
config="CONFIG_RFKILL_LEDS" ; config_enable
config="CONFIG_RFKILL_INPUT" ; config_enable
config="CONFIG_CEPH_LIB" ; config_module

#
# Generic Driver Options
#
config="CONFIG_UEVENT_HELPER_PATH" ; option="" ; config_string

config="CONFIG_EXTRA_FIRMWARE"
option="am335x-pm-firmware.elf am335x-bone-scale-data.bin am335x-evm-scale-data.bin am43x-evm-scale-data.bin"
config_string

config="CONFIG_EXTRA_FIRMWARE_DIR" ; option="firmware" ; config_string
config="CONFIG_FW_LOADER_USER_HELPER" ; config_disable

#
# Device Tree and Open Firmware support
#
config="CONFIG_ZRAM" ; config_module

#
# EEPROM support
#
config="CONFIG_EEPROM_AT24" ; config_enable

#
# Argus cape driver for beaglebone black
#
config="CONFIG_CAPE_BONE_ARGUS" ; config_enable
config="CONFIG_BEAGLEBONE_PINMUX_HELPER" ; config_enable

#
# Controllers with non-SFF native interface
#
config="CONFIG_BLK_DEV_MD" ; config_module
config="CONFIG_BCACHE" ; config_module
config="CONFIG_BLK_DEV_DM_BUILTIN" ; config_enable
config="CONFIG_BLK_DEV_DM" ; config_module

#
# Generic fallback / legacy drivers
#
config="CONFIG_TUN" ; config_module

#
# USB Network Adapters
#
config="CONFIG_AT76C50X_USB" ; config_module
config="CONFIG_USB_ZD1201" ; config_module
config="CONFIG_RTL8187" ; config_module
config="CONFIG_RTL8187_LEDS" ; config_enable
config="CONFIG_ATH_COMMON" ; config_module
config="CONFIG_ATH_CARDS" ; config_module
config="CONFIG_ATH9K_HW" ; config_module
config="CONFIG_ATH9K_COMMON" ; config_module
config="CONFIG_ATH9K_BTCOEX_SUPPORT" ; config_enable
config="CONFIG_ATH9K_HTC" ; config_module
config="CONFIG_CARL9170" ; config_module
config="CONFIG_CARL9170_LEDS" ; config_enable
config="CONFIG_CARL9170_WPC" ; config_enable
config="CONFIG_AR5523" ; config_module
config="CONFIG_ATH10K" ; config_module
config="CONFIG_WCN36XX" ; config_module

config="CONFIG_P54_COMMON" ; config_module
config="CONFIG_P54_USB" ; config_module
config="CONFIG_P54_LEDS" ; config_enable
config="CONFIG_RT2X00" ; config_module
config="CONFIG_RT2500USB" ; config_module
config="CONFIG_RT73USB" ; config_module
config="CONFIG_RT2800USB" ; config_module
config="CONFIG_RT2800USB_RT33XX" ; config_enable
config="CONFIG_RT2800USB_RT35XX" ; config_enable
config="CONFIG_RT2800USB_RT3573" ; config_enable
config="CONFIG_RT2800USB_RT53XX" ; config_enable
config="CONFIG_RT2800USB_RT55XX" ; config_enable
config="CONFIG_RT2800_LIB" ; config_module
config="CONFIG_RT2X00_LIB_USB" ; config_module
config="CONFIG_RT2X00_LIB" ; config_module
config="CONFIG_RT2X00_LIB_FIRMWARE" ; config_enable
config="CONFIG_RT2X00_LIB_CRYPTO" ; config_enable
config="CONFIG_RT2X00_LIB_LEDS" ; config_enable
config="CONFIG_RTL8192CU" ; config_module
config="CONFIG_RTLWIFI" ; config_module
config="CONFIG_RTLWIFI_USB" ; config_module
config="CONFIG_RTLWIFI_DEBUG" ; config_disable
config="CONFIG_RTL8192C_COMMON" ; config_module
config="CONFIG_ZD1211RW" ; config_module

#
# Input Device Drivers
#

#EDT_FT5X06 didn't work as a module...
config="CONFIG_TOUCHSCREEN_EDT_FT5X06" ; config_enable

#
# Non-8250 serial port support
#
config="CONFIG_HW_RANDOM_TPM" ; config_module
config="CONFIG_TCG_TPM" ; config_module
config="CONFIG_TCG_TIS_I2C_ATMEL" ; config_module

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
config="CONFIG_I2C_GPIO" ; config_module

#
# SPI Master Controller Drivers
#
config="CONFIG_SPI_BITBANG" ; config_module
config="CONFIG_SPI_GPIO" ; config_module

#
# Pin controllers
#
config="CONFIG_PINCTRL_PALMAS" ; config_enable
config="CONFIG_DEBUG_GPIO" ; config_disable
config="CONFIG_GPIO_OF_HELPER" ; config_enable

#
# MODULbus GPIO expanders:
#
config="CONFIG_GPIO_PALMAS" ; config_enable

#
# Multimedia core support
#
config="CONFIG_MEDIA_ANALOG_TV_SUPPORT" ; config_enable
config="CONFIG_MEDIA_DIGITAL_TV_SUPPORT" ; config_enable
config="CONFIG_MEDIA_RADIO_SUPPORT" ; config_enable
config="CONFIG_MEDIA_RC_SUPPORT" ; config_enable

#
# Media drivers
#
config="CONFIG_LIRC" ; config_module
config="CONFIG_IR_LIRC_CODEC" ; config_module
config="CONFIG_RC_DEVICES" ; config_enable
config="CONFIG_RC_ATI_REMOTE" ; config_module
config="CONFIG_IR_IMON" ; config_module
config="CONFIG_IR_MCEUSB" ; config_module
config="CONFIG_IR_REDRAT3" ; config_module
config="CONFIG_IR_STREAMZAP" ; config_module
config="CONFIG_IR_IGUANA" ; config_module
config="CONFIG_IR_TTUSBIR" ; config_module
config="CONFIG_RC_LOOPBACK" ; config_module
config="CONFIG_IR_GPIO_CIR" ; config_module

#
# Webcam devices
#

config="CONFIG_USB_M5602" ; config_module
config="CONFIG_USB_STV06XX" ; config_module
config="CONFIG_USB_GL860" ; config_module
config="CONFIG_USB_GSPCA_BENQ" ; config_module
config="CONFIG_USB_GSPCA_CONEX" ; config_module
config="CONFIG_USB_GSPCA_CPIA1" ; config_module
config="CONFIG_USB_GSPCA_ETOMS" ; config_module
config="CONFIG_USB_GSPCA_FINEPIX" ; config_module
config="CONFIG_USB_GSPCA_JEILINJ" ; config_module
config="CONFIG_USB_GSPCA_JL2005BCD" ; config_module
config="CONFIG_USB_GSPCA_KINECT" ; config_module
config="CONFIG_USB_GSPCA_KONICA" ; config_module
config="CONFIG_USB_GSPCA_MARS" ; config_module
config="CONFIG_USB_GSPCA_MR97310A" ; config_module
config="CONFIG_USB_GSPCA_NW80X" ; config_module
config="CONFIG_USB_GSPCA_OV519" ; config_module
config="CONFIG_USB_GSPCA_OV534" ; config_module
config="CONFIG_USB_GSPCA_OV534_9" ; config_module
config="CONFIG_USB_GSPCA_PAC207" ; config_module
config="CONFIG_USB_GSPCA_PAC7302" ; config_module
config="CONFIG_USB_GSPCA_PAC7311" ; config_module
config="CONFIG_USB_GSPCA_SE401" ; config_module
config="CONFIG_USB_GSPCA_SN9C2028" ; config_module
config="CONFIG_USB_GSPCA_SN9C20X" ; config_module
config="CONFIG_USB_GSPCA_SONIXB" ; config_module
config="CONFIG_USB_GSPCA_SONIXJ" ; config_module
config="CONFIG_USB_GSPCA_SPCA500" ; config_module
config="CONFIG_USB_GSPCA_SPCA501" ; config_module
config="CONFIG_USB_GSPCA_SPCA505" ; config_module
config="CONFIG_USB_GSPCA_SPCA506" ; config_module
config="CONFIG_USB_GSPCA_SPCA508" ; config_module
config="CONFIG_USB_GSPCA_SPCA561" ; config_module
config="CONFIG_USB_GSPCA_SPCA1528" ; config_module
config="CONFIG_USB_GSPCA_SQ905" ; config_module
config="CONFIG_USB_GSPCA_SQ905C" ; config_module
config="CONFIG_USB_GSPCA_SQ930X" ; config_module
config="CONFIG_USB_GSPCA_STK014" ; config_module
config="CONFIG_USB_GSPCA_STK1135" ; config_module
config="CONFIG_USB_GSPCA_STV0680" ; config_module
config="CONFIG_USB_GSPCA_SUNPLUS" ; config_module
config="CONFIG_USB_GSPCA_T613" ; config_module
config="CONFIG_USB_GSPCA_TOPRO" ; config_module
config="CONFIG_USB_GSPCA_TV8532" ; config_module
config="CONFIG_USB_GSPCA_VC032X" ; config_module
config="CONFIG_USB_GSPCA_VICAM" ; config_module
config="CONFIG_USB_GSPCA_XIRLINK_CIT" ; config_module
config="CONFIG_USB_GSPCA_ZC3XX" ; config_module
config="CONFIG_USB_PWC" ; config_module
config="CONFIG_USB_PWC_INPUT_EVDEV" ; config_enable
config="CONFIG_VIDEO_CPIA2" ; config_module
config="CONFIG_USB_ZR364XX" ; config_module
config="CONFIG_USB_STKWEBCAM" ; config_module
config="CONFIG_USB_S2255" ; config_module
config="CONFIG_VIDEO_USBTV" ; config_module

#
# Analog TV USB devices
#
config="CONFIG_VIDEO_PVRUSB2" ; config_module
config="CONFIG_VIDEO_PVRUSB2_SYSFS" ; config_enable
config="CONFIG_VIDEO_PVRUSB2_DVB" ; config_enable
config="CONFIG_VIDEO_HDPVR" ; config_module
config="CONFIG_VIDEO_TLG2300" ; config_module
config="CONFIG_VIDEO_USBVISION" ; config_module
config="CONFIG_VIDEO_STK1160_COMMON" ; config_module
config="CONFIG_VIDEO_STK1160_AC97" ; config_enable
config="CONFIG_VIDEO_STK1160" ; config_module

#
# Analog/digital TV USB devices
#
config="CONFIG_VIDEO_AU0828" ; config_module
config="CONFIG_VIDEO_AU0828_V4L2" ; config_enable
config="CONFIG_VIDEO_CX231XX" ; config_module
config="CONFIG_VIDEO_CX231XX_RC" ; config_enable
config="CONFIG_VIDEO_CX231XX_ALSA" ; config_module
config="CONFIG_VIDEO_CX231XX_DVB" ; config_module
config="CONFIG_VIDEO_TM6000" ; config_module
config="CONFIG_VIDEO_TM6000_ALSA" ; config_module
config="CONFIG_VIDEO_TM6000_DVB" ; config_module

#
# Digital TV USB devices
#
config="CONFIG_DVB_USB" ; config_module
config="CONFIG_DVB_USB_A800" ; config_module
config="CONFIG_DVB_USB_DIBUSB_MB" ; config_module
config="CONFIG_DVB_USB_DIBUSB_MC" ; config_module
config="CONFIG_DVB_USB_DIB0700" ; config_module
config="CONFIG_DVB_USB_UMT_010" ; config_module
config="CONFIG_DVB_USB_CXUSB" ; config_module
config="CONFIG_DVB_USB_M920X" ; config_module
config="CONFIG_DVB_USB_DIGITV" ; config_module
config="CONFIG_DVB_USB_VP7045" ; config_module
config="CONFIG_DVB_USB_VP702X" ; config_module
config="CONFIG_DVB_USB_GP8PSK" ; config_module
config="CONFIG_DVB_USB_NOVA_T_USB2" ; config_module
config="CONFIG_DVB_USB_TTUSB2" ; config_module
config="CONFIG_DVB_USB_DTT200U" ; config_module
config="CONFIG_DVB_USB_OPERA1" ; config_module
config="CONFIG_DVB_USB_AF9005" ; config_module
config="CONFIG_DVB_USB_AF9005_REMOTE" ; config_module
config="CONFIG_DVB_USB_PCTV452E" ; config_module
config="CONFIG_DVB_USB_DW2102" ; config_module
config="CONFIG_DVB_USB_CINERGY_T2" ; config_module
config="CONFIG_DVB_USB_DTV5100" ; config_module
config="CONFIG_DVB_USB_FRIIO" ; config_module
config="CONFIG_DVB_USB_AZ6027" ; config_module
config="CONFIG_DVB_USB_TECHNISAT_USB2" ; config_module

config="CONFIG_DVB_USB_V2" ; config_module
config="CONFIG_DVB_USB_AF9015" ; config_module
config="CONFIG_DVB_USB_AF9035" ; config_module
config="CONFIG_DVB_USB_ANYSEE" ; config_module
config="CONFIG_DVB_USB_AU6610" ; config_module
config="CONFIG_DVB_USB_AZ6007" ; config_module
config="CONFIG_DVB_USB_CE6230" ; config_module
config="CONFIG_DVB_USB_EC168" ; config_module
config="CONFIG_DVB_USB_GL861" ; config_module
config="CONFIG_DVB_USB_IT913X" ; config_module
config="CONFIG_DVB_USB_LME2510" ; config_module
config="CONFIG_DVB_USB_MXL111SF" ; config_module
config="CONFIG_DVB_USB_RTL28XXU" ; config_module
config="CONFIG_SMS_USB_DRV" ; config_module
config="CONFIG_DVB_B2C2_FLEXCOP_USB" ; config_module

#
# Webcam, TV (analog/digital) USB devices
#
config="CONFIG_VIDEO_EM28XX" ; config_module
config="CONFIG_VIDEO_EM28XX_V4L2" ; config_module
config="CONFIG_VIDEO_EM28XX_ALSA" ; config_module
config="CONFIG_VIDEO_EM28XX_DVB" ; config_module
config="CONFIG_VIDEO_EM28XX_RC" ; config_module

#
# Supported MMC/SDIO adapters
#
config="CONFIG_RADIO_TEA575X" ; config_module
config="CONFIG_RADIO_SI470X" ; config_enable
config="CONFIG_USB_SI470X" ; config_module
config="CONFIG_I2C_SI470X" ; config_module
config="CONFIG_RADIO_SI4713" ; config_module
config="CONFIG_USB_SI4713" ; config_module
config="CONFIG_PLATFORM_SI4713" ; config_module
config="CONFIG_I2C_SI4713" ; config_module
config="CONFIG_USB_MR800" ; config_module
config="CONFIG_USB_DSBR" ; config_module
config="CONFIG_RADIO_SHARK" ; config_module
config="CONFIG_RADIO_SHARK2" ; config_module
config="CONFIG_USB_KEENE" ; config_module
config="CONFIG_USB_RAREMONO" ; config_module
config="CONFIG_USB_MA901" ; config_module
config="CONFIG_RADIO_TEA5764" ; config_module
config="CONFIG_RADIO_SAA7706H" ; config_module
config="CONFIG_RADIO_TEF6862" ; config_module

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
config="CONFIG_MEDIA_SUBDRV_AUTOSELECT" ; config_disable

#
# Direct Rendering Manager
#
config="CONFIG_FB_OMAP2" ; config_disable
config="CONFIG_BACKLIGHT_CLASS_DEVICE" ; config_enable
config="CONFIG_BACKLIGHT_GPIO" ; config_enable


#
# Console display driver support
#
config="CONFIG_SND_USB_UA101" ; config_module
config="CONFIG_SND_USB_CAIAQ" ; config_module
config="CONFIG_SND_USB_CAIAQ_INPUT" ; config_enable
config="CONFIG_SND_USB_6FIRE" ; config_module
config="CONFIG_SND_USB_HIFACE" ; config_module

#
# HID support
#
config="CONFIG_HID_BATTERY_STRENGTH" ; config_enable
config="CONFIG_HIDRAW" ; config_enable
config="CONFIG_UHID" ; config_enable

#
# Special HID drivers
#
config="CONFIG_HID_A4TECH" ; config_enable
config="CONFIG_HID_ACRUX" ; config_module
config="CONFIG_HID_ACRUX_FF" ; config_enable
config="CONFIG_HID_APPLE" ; config_enable
config="CONFIG_HID_APPLEIR" ; config_module
config="CONFIG_HID_AUREAL" ; config_module
config="CONFIG_HID_BELKIN" ; config_enable
config="CONFIG_HID_CHERRY" ; config_enable
config="CONFIG_HID_CHICONY" ; config_enable
config="CONFIG_HID_PRODIKEYS" ; config_module
config="CONFIG_HID_CYPRESS" ; config_enable
config="CONFIG_HID_DRAGONRISE" ; config_module
config="CONFIG_DRAGONRISE_FF" ; config_enable
config="CONFIG_HID_EMS_FF" ; config_module
config="CONFIG_HID_ELECOM" ; config_module
config="CONFIG_HID_ELO" ; config_module
config="CONFIG_HID_EZKEY" ; config_enable
config="CONFIG_HID_HOLTEK" ; config_module
config="CONFIG_HOLTEK_FF" ; config_enable
config="CONFIG_HID_HUION" ; config_module
config="CONFIG_HID_KEYTOUCH" ; config_module
config="CONFIG_HID_KYE" ; config_module
config="CONFIG_HID_UCLOGIC" ; config_module
config="CONFIG_HID_WALTOP" ; config_module
config="CONFIG_HID_GYRATION" ; config_module
config="CONFIG_HID_ICADE" ; config_module
config="CONFIG_HID_TWINHAN" ; config_module
config="CONFIG_HID_KENSINGTON" ; config_enable
config="CONFIG_HID_LCPOWER" ; config_module
config="CONFIG_HID_LOGITECH" ; config_enable
config="CONFIG_HID_LOGITECH_DJ" ; config_module
config="CONFIG_LOGITECH_FF" ; config_enable
config="CONFIG_LOGIRUMBLEPAD2_FF" ; config_enable
config="CONFIG_LOGIG940_FF" ; config_enable
config="CONFIG_LOGIWHEELS_FF" ; config_enable
config="CONFIG_HID_MAGICMOUSE" ; config_module
config="CONFIG_HID_MICROSOFT" ; config_enable
config="CONFIG_HID_MONTEREY" ; config_enable
config="CONFIG_HID_MULTITOUCH" ; config_module
config="CONFIG_HID_NTRIG" ; config_module
config="CONFIG_HID_ORTEK" ; config_module
config="CONFIG_HID_PANTHERLORD" ; config_module
config="CONFIG_PANTHERLORD_FF" ; config_enable
config="CONFIG_HID_PETALYNX" ; config_module
config="CONFIG_HID_PICOLCD" ; config_module
config="CONFIG_HID_PICOLCD_FB" ; config_enable
config="CONFIG_HID_PICOLCD_BACKLIGHT" ; config_enable
config="CONFIG_HID_PICOLCD_LEDS" ; config_enable
config="CONFIG_HID_PRIMAX" ; config_module
config="CONFIG_HID_ROCCAT" ; config_module
config="CONFIG_HID_SAITEK" ; config_module
config="CONFIG_HID_SAMSUNG" ; config_module
config="CONFIG_HID_SONY" ; config_module
config="CONFIG_SONY_FF" ; config_enable
config="CONFIG_HID_SPEEDLINK" ; config_module
config="CONFIG_HID_STEELSERIES" ; config_module
config="CONFIG_HID_SUNPLUS" ; config_module
config="CONFIG_HID_GREENASIA" ; config_module
config="CONFIG_GREENASIA_FF" ; config_enable
config="CONFIG_HID_SMARTJOYPLUS" ; config_module
config="CONFIG_SMARTJOYPLUS_FF" ; config_enable
config="CONFIG_HID_TIVO" ; config_module
config="CONFIG_HID_TOPSEED" ; config_module
config="CONFIG_HID_THINGM" ; config_module
config="CONFIG_HID_THRUSTMASTER" ; config_module
config="CONFIG_THRUSTMASTER_FF" ; config_enable
config="CONFIG_HID_WACOM" ; config_module
config="CONFIG_HID_WIIMOTE" ; config_module
config="CONFIG_HID_XINMO" ; config_module
config="CONFIG_HID_ZEROPLUS" ; config_module
config="CONFIG_ZEROPLUS_FF" ; config_enable
config="CONFIG_HID_ZYDACRON" ; config_module
config="CONFIG_HID_SENSOR_HUB" ; config_module

#
# USB HID support
#
config="CONFIG_HID_PID" ; config_enable
config="CONFIG_USB_HIDDEV" ; config_enable

#
# I2C HID support
#
config="CONFIG_USB_DEBUG" ; config_disable

#
# Miscellaneous USB options
#
config="CONFIG_USB_DYNAMIC_MINORS" ; config_enable
config="CONFIG_USB_OTG" ; config_enable

#
# USB Physical Layer drivers
#
config="CONFIG_USB_GADGET_DEBUG" ; config_disable
config="CONFIG_USB_GADGET_DEBUG_FILES" ; config_disable
config="CONFIG_USB_GADGET_DEBUG_FS" ; config_disable

config="CONFIG_USB_GADGET_VBUS_DRAW" ; option="500" ; config_value

#
# USB Peripheral Controller
#
config="CONFIG_USB_F_EEM" ; config_module
config="CONFIG_USB_ETH_EEM" ; config_enable
config="CONFIG_USB_G_WEBCAM" ; config_module

#
# STAGING
#
config="CONFIG_STAGING" ; config_enable

#
# Android
#
config="CONFIG_ANDROID" ; config_enable
config="CONFIG_ANDROID_BINDER_IPC" ; config_enable
config="CONFIG_ASHMEM" ; config_enable
config="CONFIG_ANDROID_LOGGER" ; config_module
config="CONFIG_ANDROID_TIMED_GPIO" ; config_module
config="CONFIG_ANDROID_INTF_ALARM_DEV" ; config_enable
config="CONFIG_SYNC" ; config_enable
config="CONFIG_SW_SYNC" ; config_disable

config="CONFIG_ION" ; config_enable

#
# Remoteproc drivers
#
config="CONFIG_PRUSS_REMOTEPROC" ; config_enable

#
# Rpmsg drivers
#
config="CONFIG_PM_DEVFREQ" ; config_enable

#
# Extcon Device Drivers
#
config="CONFIG_MEMORY" ; config_enable
config="CONFIG_TI_EMIF" ; config_enable

#
# File systems
#
config="CONFIG_EXT2_FS" ; config_disable
config="CONFIG_EXT3_FS" ; config_disable
config="CONFIG_EXT4_USE_FOR_EXT23" ; config_enable
config="CONFIG_EXT4_FS_POSIX_ACL" ; config_enable
config="CONFIG_EXT4_FS_SECURITY" ; config_enable
config="CONFIG_REISERFS_FS" ; config_module
config="CONFIG_REISERFS_FS_XATTR" ; config_enable
config="CONFIG_REISERFS_FS_POSIX_ACL" ; config_enable
config="CONFIG_REISERFS_FS_SECURITY" ; config_enable
config="CONFIG_JFS_FS" ; config_module
config="CONFIG_JFS_POSIX_ACL" ; config_enable
config="CONFIG_JFS_SECURITY" ; config_enable
config="CONFIG_XFS_FS" ; config_enable
config="CONFIG_XFS_QUOTA" ; config_enable
config="CONFIG_XFS_POSIX_ACL" ; config_enable
config="CONFIG_XFS_RT" ; config_enable
config="CONFIG_GFS2_FS" ; config_module
config="CONFIG_OCFS2_FS" ; config_module
config="CONFIG_OCFS2_FS_O2CB" ; config_module
config="CONFIG_OCFS2_FS_STATS" ; config_enable
config="CONFIG_OCFS2_DEBUG_MASKLOG" ; config_enable
config="CONFIG_BTRFS_FS" ; config_enable
config="CONFIG_BTRFS_FS_POSIX_ACL" ; config_enable
config="CONFIG_NILFS2_FS" ; config_module
config="CONFIG_FANOTIFY" ; config_enable
config="CONFIG_FANOTIFY_ACCESS_PERMISSIONS" ; config_enable
config="CONFIG_QUOTA_NETLINK_INTERFACE" ; config_enable
config="CONFIG_QUOTA_TREE" ; config_module
config="CONFIG_QFMT_V1" ; config_module
config="CONFIG_QFMT_V2" ; config_module
config="CONFIG_AUTOFS4_FS" ; config_enable
config="CONFIG_FUSE_FS" ; config_enable
config="CONFIG_CUSE" ; config_module

#
# Caches
#
config="CONFIG_FSCACHE" ; config_module
config="CONFIG_FSCACHE_STATS" ; config_enable
config="CONFIG_CACHEFILES" ; config_module

#
# DOS/FAT/NT Filesystems
#
config="CONFIG_NTFS_FS" ; config_module
config="CONFIG_NTFS_DEBUG" ; config_disable
config="CONFIG_NTFS_RW" ; config_enable

#
# Pseudo filesystems
#
config="CONFIG_TMPFS_POSIX_ACL" ; config_enable
config="CONFIG_TMPFS_XATTR" ; config_enable
config="CONFIG_CONFIGFS_FS" ; config_enable
config="CONFIG_ECRYPT_FS" ; config_module

config="CONFIG_LOGFS" ; config_module
config="CONFIG_CRAMFS" ; config_module
config="CONFIG_SQUASHFS" ; config_module
config="CONFIG_SQUASHFS_FILE_CACHE" ; config_enable
config="CONFIG_SQUASHFS_DECOMP_SINGLE" ; config_enable
config="CONFIG_SQUASHFS_XATTR" ; config_enable
config="CONFIG_SQUASHFS_ZLIB" ; config_enable
config="CONFIG_SQUASHFS_LZO" ; config_enable
config="CONFIG_SQUASHFS_XZ" ; config_enable
config="CONFIG_VXFS_FS" ; config_module
config="CONFIG_MINIX_FS" ; config_module
config="CONFIG_OMFS_FS" ; config_module
config="CONFIG_QNX4FS_FS" ; config_module
config="CONFIG_QNX6FS_FS" ; config_module
config="CONFIG_ROMFS_FS" ; config_module
config="CONFIG_ROMFS_BACKED_BY_BOTH" ; config_enable
config="CONFIG_ROMFS_ON_BLOCK" ; config_enable
config="CONFIG_ROMFS_ON_MTD" ; config_enable
config="CONFIG_SYSV_FS" ; config_module
config="CONFIG_UFS_FS" ; config_module

config="CONFIG_F2FS_FS" ; config_enable
config="CONFIG_F2FS_STAT_FS" ; config_enable
config="CONFIG_F2FS_FS_XATTR" ; config_enable
config="CONFIG_F2FS_FS_POSIX_ACL" ; config_enable
config="CONFIG_F2FS_FS_SECURITY" ; config_enable

config="CONFIG_NFS_SWAP" ; config_enable

config="CONFIG_SUNRPC_SWAP" ; config_enable
config="CONFIG_SUNRPC_DEBUG" ; config_enable

config="CONFIG_CEPH_FS" ; config_module
config="CONFIG_CEPH_FS_POSIX_ACL" ; config_enable

config="CONFIG_NCP_FS" ; config_module
config="CONFIG_NCPFS_PACKET_SIGNING" ; config_enable
config="CONFIG_NCPFS_IOCTL_LOCKING" ; config_enable
config="CONFIG_NCPFS_STRONG" ; config_enable
config="CONFIG_NCPFS_NFS_NS" ; config_enable
config="CONFIG_NCPFS_OS2_NS" ; config_enable
config="CONFIG_NCPFS_NLS" ; config_enable
config="CONFIG_NCPFS_EXTRAS" ; config_enable
config="CONFIG_CODA_FS" ; config_module
config="CONFIG_AFS_FS" ; config_module
config="CONFIG_AFS_FSCACHE" ; config_enable

config="CONFIG_CIFS" ; config_module
config="CONFIG_CIFS_WEAK_PW_HASH" ; config_enable
config="CONFIG_CIFS_UPCALL" ; config_enable
config="CONFIG_CIFS_XATTR" ; config_enable
config="CONFIG_CIFS_POSIX" ; config_enable
config="CONFIG_CIFS_ACL" ; config_enable
config="CONFIG_CIFS_DEBUG" ; config_enable
config="CONFIG_CIFS_DFS_UPCALL" ; config_enable
config="CONFIG_CIFS_SMB2" ; config_enable
config="CONFIG_CIFS_FSCACHE" ; config_enable
config="CONFIG_NLS_UTF8" ; config_module

#
# printk and dmesg options
#
config="CONFIG_DYNAMIC_DEBUG" ; config_enable

#
# Compile-time checks and compiler options
#
config="CONFIG_DEBUG_INFO" ; config_disable

#
# Runtime Testing
#
config="CONFIG_ARM_UNWIND" ; config_disable

#
