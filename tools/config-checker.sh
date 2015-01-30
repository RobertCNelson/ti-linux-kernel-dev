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

echo "Basic Defaults:"

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
config="CONFIG_RCU_FAST_NO_HZ" ; config_enable
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
config="CONFIG_ARM_ERRATA_764369" ; config_disable

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
config="CONFIG_CPU_FREQ_STAT" ; config_enable
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

#config="CONFIG_EXTRA_FIRMWARE_DIR" ; option="firmware" ; config_string

#config="CONFIG_EXTRA_FIRMWARE"
#option="am335x-pm-firmware.elf am335x-bone-scale-data.bin am335x-evm-scale-data.bin am43x-evm-scale-data.bin"
#config_value

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
config="CONFIG_NET_VENDOR_ARC" ; config_disable
config="CONFIG_NET_CADENCE" ; config_disable
config="CONFIG_NET_VENDOR_BROADCOM" ; config_disable
config="CONFIG_NET_CALXEDA_XGMAC" ; config_disable
config="CONFIG_NET_VENDOR_CIRRUS" ; config_disable
config="CONFIG_NET_VENDOR_FARADAY" ; config_disable
config="CONFIG_NET_VENDOR_INTEL" ; config_disable
config="CONFIG_NET_VENDOR_MARVELL" ; config_disable
config="CONFIG_KS8851" ; config_enable
config="CONFIG_KS8851_MLL" ; config_enable
config="CONFIG_ENC28J60" ; config_enable
config="CONFIG_NET_VENDOR_NATSEMI" ; config_disable
config="CONFIG_NET_VENDOR_SEEQ" ; config_disable
config="CONFIG_SMC91X" ; config_enable
config="CONFIG_SMC911X" ; config_disable
config="CONFIG_SMSC911X" ; config_enable
config="CONFIG_NET_VENDOR_STMICRO" ; config_disable
config="CONFIG_TI_DAVINCI_MDIO" ; config_enable
config="CONFIG_TI_DAVINCI_CPDMA" ; config_enable
config="CONFIG_TI_CPSW_PHY_SEL" ; config_enable
config="CONFIG_TI_CPSW" ; config_enable
config="CONFIG_TI_CPTS" ; config_enable
config="CONFIG_NET_VENDOR_VIA" ; config_disable

#
# MII PHY device drivers
#
config="CONFIG_AT803X_PHY" ; config_enable
config="CONFIG_AMD_PHY" ; config_disable
config="CONFIG_MARVELL_PHY" ; config_disable
config="CONFIG_DAVICOM_PHY" ; config_disable
config="CONFIG_QSEMI_PHY" ; config_disable
config="CONFIG_LXT_PHY" ; config_disable
config="CONFIG_CICADA_PHY" ; config_disable
config="CONFIG_VITESSE_PHY" ; config_disable
config="CONFIG_SMSC_PHY" ; config_enable
config="CONFIG_BROADCOM_PHY" ; config_disable
config="CONFIG_BCM87XX_PHY" ; config_disable
config="CONFIG_ICPLUS_PHY" ; config_disable
config="CONFIG_REALTEK_PHY" ; config_disable
config="CONFIG_NATIONAL_PHY" ; config_disable
config="CONFIG_STE10XP" ; config_disable
config="CONFIG_LSI_ET1011C_PHY" ; config_disable
config="CONFIG_MICREL_PHY" ; config_disable

#
# Userland interfaces
#
config="CONFIG_INPUT_JOYDEV" ; config_enable
config="CONFIG_INPUT_EVDEV" ; config_enable

#
# Input Device Drivers
#
config="CONFIG_KEYBOARD_GPIO" ; config_enable
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
config="CONFIG_SERIAL_ARC" ; config_disable
config="CONFIG_HW_RANDOM" ; config_enable
config="CONFIG_HW_RANDOM_OMAP" ; config_enable
config="CONFIG_HW_RANDOM_EXYNOS" ; config_disable
config="CONFIG_HW_RANDOM_TPM" ; config_module
config="CONFIG_TCG_TPM" ; config_module
config="CONFIG_TCG_TIS_I2C_ATMEL" ; config_module
config="CONFIG_I2C_CHARDEV" ; config_enable


#
# Multiplexer I2C Chip support
#
config="CONFIG_I2C_ARB_GPIO_CHALLENGE" ; config_module

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
config="CONFIG_I2C_GPIO" ; config_module
config="CONFIG_I2C_OCORES" ; config_disable
config="CONFIG_I2C_PCA_PLATFORM" ; config_disable
config="CONFIG_I2C_SIMTEC" ; config_disable

#
# SPI Master Controller Drivers
#
config="CONFIG_SPI_BITBANG" ; config_module
config="CONFIG_SPI_BUTTERFLY" ; config_disable
config="CONFIG_SPI_LM70_LLP" ; config_disable
config="CONFIG_SPI_GPIO" ; config_module
config="CONFIG_SPI_OMAP24XX" ; config_enable
config="CONFIG_SPI_TI_QSPI" ; config_enable

#
# SPI Protocol Masters
#
config="CONFIG_HSI" ; config_disable

#
# PPS clients support
#
config="CONFIG_PPS_CLIENT_GPIO" ; config_module

#
# Pin controllers
#
config="CONFIG_PINMUX" ; config_enable
config="CONFIG_PINCONF" ; config_enable
config="CONFIG_GENERIC_PINCONF" ; config_enable
config="CONFIG_PINCTRL_TI_IODELAY" ; config_enable
config="CONFIG_PINCTRL_SINGLE" ; config_enable
config="CONFIG_PINCTRL_PALMAS" ; config_enable
config="CONFIG_GPIO_SYSFS" ; config_enable

#
# Memory mapped GPIO drivers:
#
config="CONFIG_GPIO_GENERIC_PLATFORM" ; config_enable

#
# I2C GPIO expanders:
#
config="CONFIG_GPIO_PCF857X" ; config_enable
config="CONFIG_GPIO_TWL4030" ; config_enable
config="CONFIG_GPIO_TWL6040" ; config_enable

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
config="CONFIG_MFD_DA9052_SPI" ; config_disable
config="CONFIG_MFD_DA9052_I2C" ; config_disable
config="CONFIG_MFD_MC13XXX_SPI" ; config_disable
config="CONFIG_MFD_MC13XXX_I2C" ; config_disable
config="CONFIG_MFD_VIPERBOARD" ; config_disable
config="CONFIG_MFD_SEC_CORE" ; config_disable
config="CONFIG_MFD_TI_AM335X_TSCADC" ; config_enable
config="CONFIG_MFD_PALMAS" ; config_enable
config="CONFIG_MFD_TPS65217" ; config_enable
config="CONFIG_MFD_TPS65218" ; config_enable
config="CONFIG_MFD_TPS65910" ; config_enable
config="CONFIG_REGULATOR_ANATOP" ; config_disable
config="CONFIG_VEXPRESS_CONFIG" ; config_disable
config="CONFIG_REGULATOR_GPIO" ; config_enable
config="CONFIG_REGULATOR_PALMAS" ; config_enable
config="CONFIG_REGULATOR_PBIAS" ; config_enable
config="CONFIG_REGULATOR_S2MPS11" ; config_disable
config="CONFIG_REGULATOR_S5M8767" ; config_disable
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
# Texas Instruments WL128x FM driver (ST based)
#
config="CONFIG_RADIO_WL128X" ; config_module

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
config="CONFIG_USB_EHCI_ROOT_HUB_TT" ; config_disable
config="CONFIG_USB_EHCI_HCD_OMAP" ; config_enable
config="CONFIG_USB_EHCI_HCD_PLATFORM" ; config_disable
config="CONFIG_USB_OHCI_HCD" ; config_disable
config="CONFIG_USB_U132_HCD" ; config_disable

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
config="CONFIG_USB_ETH_EEM" ; config_disable
config="CONFIG_USB_G_NCM" ; config_module
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

config="CONFIG_MMC_UNSAFE_RESUME" ; config_enable

#
# MMC/SD/SDIO Card Drivers
#
config="CONFIG_MMC_BLOCK_MINORS" ; option=8 ; config_value
config="CONFIG_SDIO_UART" ; config_enable

#
# MMC/SD/SDIO Host Controller Drivers
#
config="CONFIG_MMC_SDHCI" ; config_disable
config="CONFIG_MMC_OMAP" ; config_enable
config="CONFIG_MMC_OMAP_HS" ; config_enable
config="CONFIG_MMC_DW" ; config_disable
config="CONFIG_MMC_VUB300" ; config_disable
config="CONFIG_MMC_USHC" ; config_disable
config="CONFIG_MEMSTICK" ; config_disable

#
# LED drivers
#
config="CONFIG_LEDS_GPIO" ; config_enable
config="CONFIG_LEDS_LT3593" ; config_module

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
config="CONFIG_RTC_DRV_S5M" ; config_disable

#
# on-CPU RTC drivers
#
config="CONFIG_RTC_DRV_OMAP" ; config_enable
config="CONFIG_RTC_DRV_SNVS" ; config_disable

#
# DMA Devices
#
config="CONFIG_TI_EDMA" ; config_enable
config="CONFIG_DMA_OMAP" ; config_enable

#
# DMA Clients
#
config="CONFIG_ASYNC_TX_DMA" ; config_enable
config="CONFIG_UIO" ; config_module
config="CONFIG_VIRT_DRIVERS" ; config_enable

#
# Microsoft Hyper-V guest support
#
config="CONFIG_R8712U" ; config_module
config="CONFIG_R8188EU" ; config_module

#
# Accelerometers
#
config="CONFIG_LIS3L02DQ" ; config_module

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
config="CONFIG_COMMON_CLK_S2MPS11" ; config_disable
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
config="CONFIG_CRYPTO_PCRYPT" ; config_module

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

echo "TI: Defaults"

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
#config="CONFIG_ARCH_MULTI_V6_V7" ; config_disable
config="CONFIG_ARCH_OMAP3" ; config_disable
config="CONFIG_ARCH_OMAP4" ; config_disable
config="CONFIG_SOC_OMAP5" ; config_enable
config="CONFIG_SOC_AM33XX" ; config_enable
config="CONFIG_SOC_AM43XX" ; config_enable
config="CONFIG_SOC_DRA7XX" ; config_enable

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

##################################################

#
# General setup
#
config="CONFIG_LOCALVERSION_AUTO" ; config_disable

#
