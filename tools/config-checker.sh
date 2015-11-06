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
		echo "Setting: ${config}=\"${option}\""
		./scripts/config --set-str ${config} "${option}"
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

#start with: cp patches/debian-armmp KERNEL/.config
echo "Pull In TI Defaults:"

##################################################
#TI Defaults
##################################################
#ti_config_fragments/audio_display.cfg
#ti_config_fragments/baseport.cfg
#ti_config_fragments/connectivity.cfg
#ti_config_fragments/debug_options.cfg
#ti_config_fragments/ipc.cfg
#ti_config_fragments/system_test.cfg
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

# Supported ARM CPUs
CONFIG_ARCH_MULTI_V6=n
CONFIG_ARCH_MULTI_V7=y
CONFIG_ARCH_MULTI_V6_V7=n
CONFIG_CPU_V6=n

config="CONFIG_ARCH_MULTI_V6" ; config_disable
config="CONFIG_ARCH_MULTI_V7" ; config_enable
config="CONFIG_ARCH_MULTI_V6_V7" ; config_disable
config="CONFIG_CPU_V6" ; config_disable

# Enable CONFIG_SMP
CONFIG_SMP=y

config="CONFIG_SMP" ; config_enable

# Supported SoCs
CONFIG_ARCH_OMAP2=n
CONFIG_ARCH_OMAP3=n
CONFIG_ARCH_OMAP4=n
CONFIG_SOC_OMAP5=y
CONFIG_SOC_AM33XX=y
CONFIG_SOC_AM43XX=y
CONFIG_SOC_DRA7XX=y

config="CONFIG_ARCH_OMAP2" ; config_disable
config="CONFIG_ARCH_OMAP3" ; config_disable
config="CONFIG_ARCH_OMAP4" ; config_disable
config="CONFIG_SOC_OMAP5" ; config_enable
config="CONFIG_SOC_AM33XX" ; config_enable
config="CONFIG_SOC_AM43XX" ; config_enable
config="CONFIG_SOC_DRA7XX" ; config_enable
config="CONFIG_OMAP5_ERRATA_801819" ; config_enable

##################################################
# TI Audio/Display config options
##################################################

CONFIG_LEDS_CLASS=y
CONFIG_LEDS_TLC591XX=y

config="CONFIG_LEDS_CLASS" ; config_enable
config="CONFIG_LEDS_TLC591XX" ; config_enable

CONFIG_BACKLIGHT_PWM=y
CONFIG_BACKLIGHT_GPIO=y
CONFIG_BACKLIGHT_LED=y

config="CONFIG_BACKLIGHT_PWM" ; config_enable
config="CONFIG_BACKLIGHT_GPIO" ; config_enable
config="CONFIG_BACKLIGHT_LED" ; config_enable

CONFIG_DRM=y
CONFIG_DRM_I2C_NXP_TDA998X=y
CONFIG_DRM_TILCDC=y
CONFIG_DRM_OMAP=y
CONFIG_DRM_OMAP_NUM_CRTCS=2

config="CONFIG_DRM" ; config_enable

#config="CONFIG_DRM_I2C_NXP_TDA998X" ; config_enable
#config="CONFIG_DRM_TILCDC" ; config_enable

#needs to be a module for loading *.dtbo's...
config="CONFIG_DRM_I2C_ADIHDMI" ; config_module
config="CONFIG_DRM_I2C_NXP_TDA998X" ; config_module
config="CONFIG_DRM_TILCDC" ; config_module
config="CONFIG_DRM_TILCDC_SLAVE_COMPAT" ; config_enable

config="CONFIG_DRM_OMAP" ; config_enable
config="CONFIG_DRM_OMAP_NUM_CRTCS" ; option="2" ; config_value

CONFIG_OMAP2_DSS=y
CONFIG_OMAP5_DSS_HDMI=y

config="CONFIG_OMAP2_DSS" ; config_enable
config="CONFIG_OMAP5_DSS_HDMI" ; config_enable

CONFIG_DISPLAY_PANEL_DPI=y
CONFIG_DISPLAY_PANEL_TLC59108=y
CONFIG_DISPLAY_CONNECTOR_HDMI=y
CONFIG_DISPLAY_DRA7EVM_ENCODER_TPD12S015=y
CONFIG_DISPLAY_ENCODER_TPD12S015=y
CONFIG_DISPLAY_ENCODER_SII9022=y
CONFIG_DISPLAY_ENCODER_TC358768=y

config="CONFIG_DISPLAY_PANEL_DPI" ; config_enable
config="CONFIG_DISPLAY_PANEL_TLC59108" ; config_enable
config="CONFIG_DISPLAY_CONNECTOR_HDMI" ; config_enable
config="CONFIG_DISPLAY_DRA7EVM_ENCODER_TPD12S015" ; config_enable
config="CONFIG_DISPLAY_ENCODER_TPD12S015" ; config_enable
config="CONFIG_DISPLAY_ENCODER_SII9022" ; config_enable
config="CONFIG_DISPLAY_ENCODER_TC358768" ; config_enable

CONFIG_CMA_SIZE_MBYTES=24

config="CONFIG_CMA" ; config_enable
config="CONFIG_CMA_DEBUG" ; config_disable
config="CONFIG_DMA_CMA" ; config_enable
config="CONFIG_CMA_SIZE_MBYTES" ; option="24" ; config_value

CONFIG_MEDIA_SUPPORT=m
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_CONTROLLER=y
CONFIG_VIDEO_V4L2_SUBDEV_API=y

config="CONFIG_MEDIA_SUPPORT" ; config_module
config="CONFIG_MEDIA_CAMERA_SUPPORT" ; config_enable
config="CONFIG_MEDIA_CONTROLLER" ; config_enable
config="CONFIG_VIDEO_V4L2_SUBDEV_API" ; config_enable

CONFIG_V4L_PLATFORM_DRIVERS=y
CONFIG_VIDEO_AM437X_VPFE=m
CONFIG_VIDEO_TI_CAL=m
CONFIG_VIDEO_TI_VIP=m

config="CONFIG_V4L_PLATFORM_DRIVERS" ; config_enable
config="CONFIG_VIDEO_AM437X_VPFE" ; config_module
config="CONFIG_VIDEO_TI_CAL" ; config_module
config="CONFIG_VIDEO_TI_VIP" ; config_module

CONFIG_V4L_MEM2MEM_DRIVERS=y
CONFIG_VIDEO_TI_VPE=m

config="CONFIG_V4L2_MEM2MEM_DEV" ; config_enable
config="CONFIG_VIDEO_TI_VPE" ; config_module

CONFIG_MEDIA_SUBDRV_AUTOSELECT=n
CONFIG_VIDEO_OV2659=m
CONFIG_VIDEO_OV1063X=m
CONFIG_VIDEO_MT9T11X=m

config="CONFIG_MEDIA_SUBDRV_AUTOSELECT" ; config_disable
config="CONFIG_VIDEO_OV2659" ; config_module
config="CONFIG_VIDEO_OV1063X" ; config_module
config="CONFIG_VIDEO_MT9T11X" ; config_module

CONFIG_SOUND=y
CONFIG_SND=y
CONFIG_SND_SOC=y
CONFIG_SND_OMAP_SOC=y
CONFIG_SND_EDMA_SOC=y
CONFIG_SND_DAVINCI_SOC_MCASP=y
CONFIG_SND_AM335X_SOC_NXPTDA_EVM=m
CONFIG_SND_AM33XX_SOC_EVM=m
CONFIG_SND_SIMPLE_CARD=m
CONFIG_SND_OMAP_SOC_DRA7EVM=y
CONFIG_SND_SOC_TLV320AIC31XX=m
CONFIG_SND_SOC_TLV320AIC3X=m
CONFIG_SND_SOC_HDMI_CODEC=m
CONFIG_SND_OMAP_SOC_HDMI_AUDIO=m

config="CONFIG_SOUND" ; config_enable
config="CONFIG_SND" ; config_enable
config="CONFIG_SND_SOC" ; config_enable
config="CONFIG_SND_OMAP_SOC" ; config_enable
config="CONFIG_SND_EDMA_SOC" ; config_enable
config="CONFIG_SND_DAVINCI_SOC_MCASP" ; config_enable
config="CONFIG_SND_AM335X_SOC_NXPTDA_EVM" ; config_module
config="CONFIG_SND_AM33XX_SOC_EVM" ; config_module
config="CONFIG_SND_SIMPLE_CARD" ; config_module
config="CONFIG_SND_OMAP_SOC_DRA7EVM" ; config_enable
config="CONFIG_SND_SOC_TLV320AIC31XX" ; config_module
config="CONFIG_SND_SOC_TLV320AIC3X" ; config_module
config="CONFIG_SND_SOC_HDMI_CODEC" ; config_module
config="CONFIG_SND_OMAP_SOC_HDMI_AUDIO" ; config_module

##################################################
# TI Baseport Config Options
##################################################

# Serial
CONFIG_SERIAL_8250_OMAP=y
CONFIG_SERIAL_8250_OMAP_TTYO_FIXUP=y
CONFIG_SERIAL_8250_RUNTIME_UARTS=10
CONFIG_SERIAL_8250_DMA=n
CONFIG_SERIAL_OMAP=n

config="CONFIG_SERIAL_8250_OMAP" ; config_enable
config="CONFIG_SERIAL_8250_OMAP_TTYO_FIXUP" ; config_enable
config="CONFIG_SERIAL_8250_NR_UARTS" ; option="6" ; config_value
config="CONFIG_SERIAL_8250_RUNTIME_UARTS" ; option="6" ; config_value
config="CONFIG_SERIAL_8250_DMA" ; config_disable
config="CONFIG_SERIAL_OMAP" ; config_disable

CONFIG_JUMP_LABEL=y
config="CONFIG_JUMP_LABEL" ; config_enable

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

CONFIG_PREEMPT=y
CONFIG_DEBUG_FS=y

config="CONFIG_PREEMPT" ; config_enable
config="CONFIG_DEBUG_FS" ; config_enable

# Crypto Modules
CONFIG_CRYPTO_DEV_OMAP_SHAM=y
CONFIG_CRYPTO_DEV_OMAP_AES=y
CONFIG_CRYPTO_DEV_OMAP_DES=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y

config="CONFIG_CRYPTO_DEV_OMAP_SHAM" ; config_enable
config="CONFIG_CRYPTO_DEV_OMAP_AES" ; config_enable
config="CONFIG_CRYPTO_DEV_OMAP_DES" ; config_enable
config="CONFIG_CRYPTO_USER_API_HASH" ; config_enable
config="CONFIG_CRYPTO_USER_API_SKCIPHER" ; config_enable

# Firmware Loading from rootfs
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y

# AMx3 Power Config Options
CONFIG_MAILBOX=y
CONFIG_OMAP2PLUS_MBOX=y
CONFIG_WKUP_M3_RPROC=y
CONFIG_SOC_TI=y
CONFIG_WKUP_M3_IPC=y
CONFIG_TI_EMIF_SRAM=y
CONFIG_AMX3_PM=y

config="CONFIG_MAILBOX" ; config_enable
config="CONFIG_OMAP2PLUS_MBOX" ; config_enable
config="CONFIG_WKUP_M3_RPROC" ; config_enable
config="CONFIG_SOC_TI" ; config_enable
config="CONFIG_WKUP_M3_IPC" ; config_enable
config="CONFIG_TI_EMIF_SRAM" ; config_enable
config="CONFIG_AMX3_PM" ; config_enable

# Voltagedomain/cpufreq config
CONFIG_VOLTAGE_DOMAIN_OMAP=y
CONFIG_CPUFREQ_VOLTDM=y

config="CONFIG_VOLTAGE_DOMAIN_OMAP" ; config_enable
config="CONFIG_CPUFREQ_VOLTDM" ; config_enable

##################################################
# TI Connectivity Configs
##################################################

# I2C GPIO expanders
CONFIG_GPIO_PCF857X=y

config="CONFIG_GPIO_PCF857X" ; config_enable

#PCIe
CONFIG_PCI=y
CONFIG_PCI_DRA7XX=y
CONFIG_PHY_TI_KEYSTONE_SERDES=y
#These drivers have been used with DRA7x/AM57x PCIe RC with some success
CONFIG_NET_VENDOR_BROADCOM=y
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_NET_VENDOR_INTEL=y
CONFIG_TIGON3=m
CONFIG_SKGE=m
CONFIG_E1000=m
CONFIG_E1000E=m
CONFIG_IWLWIFI=m
CONFIG_IWLDVM=m

#SATA
CONFIG_AHCI=m
CONFIG_SATA_AHCI_PLATFORM=m

# Networking
CONFIG_NF_CONNTRACK=m
CONFIG_NF_CONNTRACK_IPV4=m
CONFIG_IP_NF_IPTABLES=m
CONFIG_IP_NF_FILTER=m
CONFIG_NF_NAT_IPV4=m
CONFIG_IP_NF_TARGET_MASQUERADE=m
CONFIG_BRIDGE=m

#MMC
CONFIG_MMC=y
CONFIG_MMC_OMAP_HS=y

config="CONFIG_MMC_OMAP" ; config_enable
config="CONFIG_MMC_OMAP_HS" ; config_enable

#CAN
CONFIG_CAN=m
CONFIG_CAN_C_CAN=m
CONFIG_CAN_C_CAN_PLATFORM=m

config="CONFIG_CAN" ; config_module
config="CONFIG_CAN_C_CAN" ; config_module
config="CONFIG_CAN_C_CAN_PLATFORM" ; config_module

#USB MUSB DMA
CONFIG_TI_CPPI41=y
CONFIG_USB_TI_CPPI41_DMA=y

config="CONFIG_TI_CPPI41" ; config_enable
config="CONFIG_USB_TI_CPPI41_DMA" ; config_enable

##################################################
# TI RPMsg/IPC Config Options
##################################################
# HwSpinLock
CONFIG_HWSPINLOCK_OMAP=y

config="CONFIG_HWSPINLOCK_OMAP" ; config_enable

# Mailbox
CONFIG_OMAP2PLUS_MBOX=y

config="CONFIG_OMAP2PLUS_MBOX" ; config_enable

# IOMMU
CONFIG_IOMMU_SUPPORT=y
CONFIG_OMAP_IOMMU=y
CONFIG_OMAP_IOMMU_DEBUG=y

config="CONFIG_IOMMU_SUPPORT" ; config_enable
config="CONFIG_OMAP_IOMMU" ; config_enable
config="CONFIG_OMAP_IOMMU_DEBUG" ; config_enable

# Remoteproc
CONFIG_OMAP_REMOTEPROC=m
CONFIG_OMAP_REMOTEPROC_WATCHDOG=y

config="CONFIG_OMAP_REMOTEPROC" ; config_module
config="CONFIG_OMAP_REMOTEPROC_WATCHDOG" ; config_enable

# RPMsg
CONFIG_RPMSG_RPC=m

config="CONFIG_RPMSG_RPC" ; config_module


#exit
echo "our defaults"

#
# General setup
#
config="CONFIG_KERNEL_LZO" ; config_enable
config="CONFIG_USELIB" ; config_enable

#
# RCU Subsystem
#
config="CONFIG_IKCONFIG" ; config_enable
config="CONFIG_IKCONFIG_PROC" ; config_enable
config="CONFIG_LOG_BUF_SHIFT" ; option="18" ; config_value
config="CONFIG_SYSFS_SYSCALL" ; config_enable
config="CONFIG_SYSCTL_SYSCALL" ; config_enable
config="CONFIG_KALLSYMS_ALL" ; config_enable
config="CONFIG_BPF_SYSCALL" ; config_enable
config="CONFIG_EMBEDDED" ; config_enable

#
# Kernel Performance Events And Counters
#
config="CONFIG_OPROFILE" ; config_enable
config="CONFIG_SECCOMP_FILTER" ; config_enable

#
# CPU Core family selection
#
config="CONFIG_ARCH_VIRT" ; config_disable
config="CONFIG_ARCH_MVEBU" ; config_disable
config="CONFIG_ARCH_HIGHBANK" ; config_disable
config="CONFIG_ARCH_MXC" ; config_disable

#
# OMAP Feature Selections
#
config="CONFIG_OMAP_MUX_DEBUG" ; config_enable

#
# OMAP Legacy Platform Data Board Type
#
config="CONFIG_ARCH_SOCFPGA" ; config_disable
config="CONFIG_ARCH_EXYNOS" ; config_disable
config="CONFIG_ARCH_SUNXI" ; config_disable
config="CONFIG_ARCH_TEGRA" ; config_disable
config="CONFIG_ARCH_VEXPRESS" ; config_disable
config="CONFIG_ARCH_WM8850" ; config_disable

#
# Processor Features
#
config="CONFIG_PL310_ERRATA_753970" ; config_disable
config="CONFIG_PL310_ERRATA_769419" ; config_disable
config="CONFIG_ARM_ERRATA_430973" ; config_disable
config="CONFIG_ARM_ERRATA_643719" ; config_disable
config="CONFIG_ARM_ERRATA_754327" ; config_disable
config="CONFIG_ARM_ERRATA_764369" ; config_disable
config="CONFIG_ARM_ERRATA_773022" ; config_disable

config="CONFIG_PL310_ERRATA_753970" ; config_disable
config="CONFIG_ARM_ERRATA_754327" ; config_disable
config="CONFIG_ARM_ERRATA_773022" ; config_disable

#
# Bus support
#
#first check..
#config="CONFIG_PCI" ; config_disable
#config="CONFIG_PCI_SYSCALL" ; config_disable
#exit

#PCIe
CONFIG_PCI=y
CONFIG_PCI_DRA7XX=y
config="CONFIG_PCI" ; config_enable
config="CONFIG_PCI_DRA7XX" ; config_enable
#These drivers have been used with DRA7x/AM57x PCIe RC with some success
config="CONFIG_NET_VENDOR_BROADCOM" ; config_enable
config="CONFIG_NET_VENDOR_MARVELL" ; config_enable
config="CONFIG_NET_VENDOR_INTEL" ; config_enable
config="CONFIG_TIGON3" ; config_module
config="CONFIG_SKGE" ; config_module
config="CONFIG_E1000" ; config_module
config="CONFIG_E1000E" ; config_module
config="CONFIG_IWLWIFI" ; config_module
config="CONFIG_IWLDVM" ; config_module

#
# Kernel Features
#
config="CONFIG_NR_CPUS" ; option="2" ; config_value
#config="CONFIG_PREEMPT" ; config_enable
config="CONFIG_HZ_100" ; config_enable
config="CONFIG_HZ_250" ; config_disable
config="CONFIG_HZ" ; option="100" ; config_value
#config="CONFIG_THUMB2_KERNEL" ; config_enable
#config="CONFIG_CMA" ; config_enable
#config="CONFIG_CMA_DEBUG" ; config_disable
config="CONFIG_SECCOMP" ; config_enable
config="CONFIG_XEN" ; config_disable

#
# Boot options
#
config="CONFIG_ARM_APPENDED_DTB" ; config_disable

#
# CPU Frequency scaling
#
config="CONFIG_CPU_FREQ_STAT" ; config_enable
config="CONFIG_CPU_FREQ_STAT_DETAILS" ; config_enable
config="CONFIG_CPU_FREQ_GOV_POWERSAVE" ; config_enable
config="CONFIG_CPU_FREQ_GOV_USERSPACE" ; config_enable
config="CONFIG_CPU_FREQ_GOV_ONDEMAND" ; config_enable
config="CONFIG_CPU_FREQ_GOV_CONSERVATIVE" ; config_enable

#
# CPU frequency scaling drivers
#
config="CONFIG_CPUFREQ_DT" ; config_enable
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
config="CONFIG_PM_WAKELOCKS_GC" ; config_enable

#
# Networking options
#
config="CONFIG_IP_PNP" ; config_enable
config="CONFIG_IP_PNP_DHCP" ; config_enable
config="CONFIG_IP_PNP_BOOTP" ; config_enable
config="CONFIG_IP_PNP_RARP" ; config_enable
config="CONFIG_NETLABEL" ; config_enable

#
# CAN Device Drivers
#
#config="CONFIG_CAN_C_CAN" ; config_module
#config="CONFIG_CAN_C_CAN_PLATFORM" ; config_module

#
# CAN SPI interfaces
#
config="CONFIG_CAN_MCP251X" ; config_module

#
# Bluetooth device drivers
#
config="CONFIG_BT_HCIUART" ; config_module
config="CONFIG_BT_HCIUART_H4" ; config_enable
config="CONFIG_BT_HCIUART_BCSP" ; config_enable
config="CONFIG_BT_HCIUART_ATH3K" ; config_enable
config="CONFIG_BT_HCIUART_LL" ; config_enable
config="CONFIG_BT_HCIUART_3WIRE" ; config_enable
config="CONFIG_BT_HCIUART_BCM" ; config_enable
config="CONFIG_BT_HCIBCM203X" ; config_module
config="CONFIG_BT_HCIBPA10X" ; config_module
config="CONFIG_BT_HCIBFUSB" ; config_module

#
# Generic Driver Options
#
config="CONFIG_UEVENT_HELPER" ; config_enable
config="CONFIG_DEVTMPFS_MOUNT" ; config_enable

config="CONFIG_FIRMWARE_IN_KERNEL" ; config_enable
config="CONFIG_EXTRA_FIRMWARE" ; option="am335x-pm-firmware.elf am335x-bone-scale-data.bin am335x-evm-scale-data.bin am43x-evm-scale-data.bin" ; config_string
config="CONFIG_EXTRA_FIRMWARE_DIR" ; option="firmware" ; config_string

#config="CONFIG_DMA_CMA" ; config_enable
#config="CONFIG_CMA_SIZE_MBYTES" ; option="24" ; config_value

#
# Bus devices
#
config="CONFIG_OMAP_OCP2SCP" ; config_enable

#
# Device Tree and Open Firmware support
#
config="CONFIG_OF_OVERLAY" ; config_enable
config="CONFIG_OF_CONFIGFS" ; config_enable

#
# Misc devices
#
config="CONFIG_BONE_CAPEMGR" ; config_enable
config="CONFIG_TIEQEP" ; config_module

#
# EEPROM support
#
config="CONFIG_EEPROM_AT24" ; config_enable

config="CONFIG_BEAGLEBONE_PINMUX_HELPER" ; config_enable

#
# SCSI device support
#
config="CONFIG_SCSI_MOD" ; config_enable
config="CONFIG_SCSI" ; config_enable
config="CONFIG_SCSI_PROC_FS" ; config_enable

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
config="CONFIG_NET_CADENCE" ; config_disable
config="CONFIG_NET_VENDOR_BROADCOM" ; config_disable
config="CONFIG_NET_VENDOR_CIRRUS" ; config_disable
config="CONFIG_NET_VENDOR_FARADAY" ; config_disable
config="CONFIG_NET_VENDOR_HISILICON" ; config_disable
config="CONFIG_NET_VENDOR_INTEL" ; config_disable
config="CONFIG_NET_VENDOR_MARVELL" ; config_disable
config="CONFIG_NET_VENDOR_NETSEMI" ; config_disable
config="CONFIG_NET_VENDOR_8390" ; config_disable
config="CONFIG_NET_VENDOR_QUALCOMM" ; config_disable
config="CONFIG_NET_VENDOR_ROCKER" ; config_disable
config="CONFIG_NET_VENDOR_SAMSUNG" ; config_disable
config="CONFIG_NET_VENDOR_STMICRO" ; config_disable
config="CONFIG_NET_VENDOR_VIA" ; config_disable

config="CONFIG_SMC91X" ; config_enable
config="CONFIG_SMC911X" ; config_enable
config="CONFIG_SMSC911X" ; config_enable

config="CONFIG_TI_DAVINCI_MDIO" ; config_enable
config="CONFIG_TI_DAVINCI_CPDMA" ; config_enable
config="CONFIG_TI_CPSW_ALE" ; config_enable
config="CONFIG_TI_CPSW" ; config_enable
config="CONFIG_TI_CPTS" ; config_enable

#
# MII PHY device drivers
#
config="CONFIG_AT803X_PHY" ; config_enable
config="CONFIG_AMD_PHY" ; config_enable
config="CONFIG_MARVELL_PHY" ; config_enable
config="CONFIG_DAVICOM_PHY" ; config_enable
config="CONFIG_QSEMI_PHY" ; config_enable
config="CONFIG_LXT_PHY" ; config_enable
config="CONFIG_CICADA_PHY" ; config_enable
config="CONFIG_VITESSE_PHY" ; config_enable

config="CONFIG_SMSC_PHY" ; config_enable

config="CONFIG_BROADCOM_PHY" ; config_enable
config="CONFIG_BCM7XXX_PHY" ; config_enable
config="CONFIG_BCM87XX_PHY" ; config_enable
config="CONFIG_ICPLUS_PHY" ; config_enable
config="CONFIG_REALTEK_PHY" ; config_enable
config="CONFIG_NATIONAL_PHY" ; config_enable
config="CONFIG_STE10XP" ; config_enable
config="CONFIG_LSI_ET1011C_PHY" ; config_enable

config="CONFIG_MICREL_PHY" ; config_enable

config="CONFIG_USB_PEGASUS" ; config_enable
config="CONFIG_USB_RTL8150" ; config_enable
config="CONFIG_USB_RTL8152" ; config_enable
config="CONFIG_USB_USBNET" ; config_enable

config="CONFIG_WL_MEDIATEK" ; config_enable
config="CONFIG_MT7601U" ; config_module

#
# Userland interfaces
#
config="CONFIG_INPUT_JOYDEV" ; config_enable
config="CONFIG_INPUT_EVDEV" ; config_enable

#
# Input Device Drivers
#
config="CONFIG_TOUCHSCREEN_EDT_FT5X06" ; config_enable

#
# Character devices
#
config="CONFIG_DEVKMEM" ; config_enable

#
# Serial drivers
#
#config="CONFIG_SERIAL_8250_DMA" ; config_disable
#config="CONFIG_SERIAL_8250_NR_UARTS" ; option="6" ; config_value
#config="CONFIG_SERIAL_8250_RUNTIME_UARTS" ; option="6" ; config_value
#config="CONFIG_SERIAL_8250_OMAP" ; config_enable
#config="CONFIG_SERIAL_8250_OMAP_TTYO_FIXUP" ; config_enable

#
# Non-8250 serial port support
#
config="CONFIG_CONSOLE_POLL" ; config_enable
#config="CONFIG_SERIAL_OMAP" ; config_disable

config="CONFIG_SERIAL_ARC" ; config_disable
config="CONFIG_TCG_TPM" ; config_module
config="CONFIG_TCG_TIS_I2C_ATMEL" ; config_module

#
# I2C support
#
config="CONFIG_I2C_CHARDEV" ; config_enable

#
# PPS clients support
#
config="CONFIG_PPS_CLIENT_GPIO" ; config_module

#
# Pin controllers
#
config="CONFIG_PINCTRL_TI_IODELAY" ; config_enable
config="CONFIG_GPIO_OF_HELPER" ; config_enable

#
# 1-wire Bus Masters
#
config="CONFIG_W1_MASTER_GPIO" ; config_module

#
# 1-wire Slaves
#
config="CONFIG_POWER_RESET" ; config_disable
config="CONFIG_POWER_AVS" ; config_enable

#
# Native drivers
#
config="CONFIG_SENSORS_GPIO_FAN" ; config_enable
config="CONFIG_SENSORS_LM75" ; config_module
config="CONFIG_SENSORS_TMP102" ; config_enable

#
# Texas Instruments thermal drivers
#
config="CONFIG_TI_SOC_THERMAL" ; config_enable
config="CONFIG_DRA752_THERMAL" ; config_enable

#
# Watchdog Device Drivers
#
config="CONFIG_OMAP_WATCHDOG" ; config_enable

#
# Multifunction device drivers
#
config="CONFIG_MFD_TPS65217" ; config_enable
config="CONFIG_MFD_TPS65218" ; config_enable
config="CONFIG_MFD_TPS65910" ; config_enable

config="CONFIG_REGULATOR_GPIO" ; config_enable
config="CONFIG_REGULATOR_PBIAS" ; config_enable
config="CONFIG_REGULATOR_PWM" ; config_enable
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
config="CONFIG_VIDEOBUF2_CORE" ; config_enable
config="CONFIG_VIDEOBUF2_MEMOPS" ; config_enable
config="CONFIG_VIDEOBUF2_DMA_CONTIG" ; config_enable

#
# Software defined radio USB devices
#
config="CONFIG_VIDEO_OMAP3" ; config_module
config="CONFIG_VIDEO_OMAP3_DEBUG" ; config_disable
config="CONFIG_SOC_CAMERA" ; config_module
config="CONFIG_SOC_CAMERA_PLATFORM" ; config_module
config="CONFIG_VIDEO_AM437X_VPFE" ; config_module
config="CONFIG_VIDEO_MEM2MEM_DEINTERLACE" ; config_module

#
# Graphics support
#
config="CONFIG_IMX_IPUV3_CORE" ; config_disable

#
# Direct Rendering Manager
#
#config="CONFIG_DRM" ; config_enable

#...Drivers... (these will enable other defaults..)
config="CONFIG_DRM_DW_HDMI" ; config_disable
config="CONFIG_DRM_VGEM" ; config_disable
config="CONFIG_DRM_UDL" ; config_enable
#config="CONFIG_DRM_OMAP" ; config_enable
#config="CONFIG_DRM_TILCDC" ; config_enable
config="CONFIG_DRM_IMX" ; config_disable

#
# I2C encoder or helper chips
#
#config="CONFIG_DRM_I2C_NXP_TDA998X" ; config_enable
#config="CONFIG_DRM_IMX_FB_HELPER" ; config_enable
#config="CONFIG_DRM_IMX_PARALLEL_DISPLAY" ; config_enable
#config="CONFIG_DRM_IMX_TVE" ; config_enable
#config="CONFIG_DRM_IMX_LDB" ; config_enable
#config="CONFIG_DRM_IMX_HDMI" ; config_enable

#
# Frame buffer hardware drivers
#
config="CONFIG_FB_MX3" ; config_disable
#config="CONFIG_OMAP2_DSS" ; config_enable
#config="CONFIG_OMAP5_DSS_HDMI" ; config_enable
config="CONFIG_OMAP2_DSS_SDI" ; config_disable

#
# OMAP Display Device Drivers (new device model)
#
config="CONFIG_DISPLAY_ENCODER_OPA362" ; config_enable

#bug in tilcd/tfp410 slave..
#config="CONFIG_DISPLAY_ENCODER_TFP410" ; config_enable
config="CONFIG_DISPLAY_ENCODER_TFP410" ; config_disable

#config="CONFIG_DISPLAY_ENCODER_TPD12S015" ; config_enable
config="CONFIG_DISPLAY_CONNECTOR_DVI" ; config_enable
#config="CONFIG_DISPLAY_CONNECTOR_HDMI" ; config_enable
#config="CONFIG_DISPLAY_PANEL_DPI" ; config_enable

config="CONFIG_FB_SSD1307" ; config_enable
#config="CONFIG_BACKLIGHT_PWM" ; config_enable
#config="CONFIG_BACKLIGHT_GPIO" ; config_enable

#
# Console display driver support
#
config="CONFIG_LOGO" ; config_enable
config="CONFIG_LOGO_LINUX_MONO" ; config_enable
config="CONFIG_LOGO_LINUX_VGA16" ; config_enable
config="CONFIG_LOGO_LINUX_CLUT224" ; config_enable

#
# HD-Audio
#
config="CONFIG_SND_EDMA_SOC" ; config_module
config="CONFIG_SND_DAVINCI_SOC_MCASP" ; config_module
config="CONFIG_SND_DAVINCI_SOC_GENERIC_EVM" ; config_module
config="CONFIG_SND_AM33XX_SOC_EVM" ; config_module

#
# SoC Audio support for Freescale i.MX boards:
#
config="CONFIG_SND_OMAP_SOC_HDMI_AUDIO" ; config_module

#
# CODEC drivers
#
config="CONFIG_SND_SOC_HDMI_CODEC" ; config_module
config="CONFIG_SND_SOC_TLV320AIC31XX" ; config_module

#
# HID support
#
config="CONFIG_UHID" ; config_enable
config="CONFIG_HID_GENERIC" ; config_enable

#
# Special HID drivers
#
config="CONFIG_HID_APPLEIR" ; config_module
config="CONFIG_HID_BETOP_FF" ; config_module
config="CONFIG_HID_GT683R" ; config_module
config="CONFIG_HID_LOGITECH_DJ" ; config_enable
config="CONFIG_HID_LOGITECH_HIDPP" ; config_enable
config="CONFIG_HID_PLANTRONICS" ; config_module
config="CONFIG_HID_SENSOR_CUSTOM_SENSOR" ; config_module

#
# Miscellaneous USB options
#
config="CONFIG_USB_OTG" ; config_enable

#
# USB Host Controller Drivers
#
config="CONFIG_USB_XHCI_HCD" ; config_enable
config="CONFIG_USB_XHCI_PLATFORM" ; config_enable
config="CONFIG_USB_EHCI_HCD" ; config_enable
config="CONFIG_USB_EHCI_HCD_OMAP" ; config_enable
config="CONFIG_USB_EHCI_HCD_PLATFORM" ; config_enable
config="CONFIG_USB_OHCI_HCD" ; config_disable

#
# USB Imaging devices
#
config="CONFIG_USBIP_CORE" ; config_module
config="CONFIG_USBIP_VHCI_HCD" ; config_module
config="CONFIG_USBIP_HOST" ; config_module
config="CONFIG_USBIP_DEBUG" ; config_disable

#
# Platform Glue Layer
#
config="CONFIG_USB_MUSB_TUSB6010" ; config_disable
config="CONFIG_USB_MUSB_OMAP2PLUS" ; config_disable
config="CONFIG_USB_MUSB_AM35X" ; config_disable
config="CONFIG_USB_MUSB_DSPS" ; config_enable
config="CONFIG_USB_MUSB_AM335X_CHILD" ; config_enable
config="CONFIG_USB_DWC3" ; config_enable
config="CONFIG_USB_DWC3_DUAL_ROLE" ; config_enable

#
# Platform Glue Driver Support
#
config="CONFIG_USB_DWC3_OMAP" ; config_enable
config="CONFIG_USB_DWC3_PCI" ; config_enable

#
# Debugging features
#
config="CONFIG_USB_CHIPIDEA" ; config_enable
config="CONFIG_USB_CHIPIDEA_DEBUG" ; config_disable

#
# USB Miscellaneous drivers
#
config="CONFIG_USB_CHAOSKEY" ; config_module

#
# USB Physical Layer drivers
#
config="CONFIG_AM335X_CONTROL_USB" ; config_enable
config="CONFIG_AM335X_PHY_USB" ; config_enable
config="CONFIG_TWL6030_USB" ; config_enable
config="CONFIG_USB_GPIO_VBUS" ; config_enable
config="CONFIG_USB_GADGET_VBUS_DRAW" ; option="500" ; config_value

#
# USB Peripheral Controller
#
config="CONFIG_USB_LIBCOMPOSITE" ; config_module
config="CONFIG_USB_F_ACM" ; config_module
config="CONFIG_USB_F_SS_LB" ; config_module
config="CONFIG_USB_U_SERIAL" ; config_module
config="CONFIG_USB_U_ETHER" ; config_module
config="CONFIG_USB_F_SERIAL" ; config_module
config="CONFIG_USB_F_OBEX" ; config_module
config="CONFIG_USB_F_NCM" ; config_module
config="CONFIG_USB_F_ECM" ; config_module
config="CONFIG_USB_F_PHONET" ; config_module
config="CONFIG_USB_F_SUBSET" ; config_module
config="CONFIG_USB_F_RNDIS" ; config_module
config="CONFIG_USB_F_MASS_STORAGE" ; config_module
config="CONFIG_USB_F_FS" ; config_module
config="CONFIG_USB_CONFIGFS" ; config_module
config="CONFIG_USB_CONFIGFS_SERIAL" ; config_enable
config="CONFIG_USB_CONFIGFS_ACM" ; config_enable
config="CONFIG_USB_CONFIGFS_OBEX" ; config_enable
config="CONFIG_USB_CONFIGFS_NCM" ; config_enable
config="CONFIG_USB_CONFIGFS_ECM" ; config_enable
config="CONFIG_USB_CONFIGFS_ECM_SUBSET" ; config_enable
config="CONFIG_USB_CONFIGFS_RNDIS" ; config_enable
config="CONFIG_USB_CONFIGFS_PHONET" ; config_disable
config="CONFIG_USB_CONFIGFS_MASS_STORAGE" ; config_disable
config="CONFIG_USB_CONFIGFS_F_LB_SS" ; config_disable
config="CONFIG_USB_CONFIGFS_F_FS" ; config_disable
config="CONFIG_USB_ZERO" ; config_module
config="CONFIG_USB_AUDIO" ; config_module
config="CONFIG_GADGET_UAC1" ; config_disable
config="CONFIG_USB_ETH" ; config_module
config="CONFIG_USB_ETH_RNDIS" ; config_enable
config="CONFIG_USB_ETH_EEM" ; config_disable
config="CONFIG_USB_G_NCM" ; config_module
config="CONFIG_USB_GADGETFS" ; config_module
config="CONFIG_USB_FUNCTIONFS" ; config_module
config="CONFIG_USB_FUNCTIONFS_ETH" ; config_enable
config="CONFIG_USB_FUNCTIONFS_RNDIS" ; config_enable
config="CONFIG_USB_FUNCTIONFS_GENERIC" ; config_enable
config="CONFIG_USB_MASS_STORAGE" ; config_module
config="CONFIG_USB_GADGET_TARGET" ; config_disable
config="CONFIG_USB_G_SERIAL" ; config_module
config="CONFIG_USB_MIDI_GADGET" ; config_module
config="CONFIG_USB_G_PRINTER" ; config_module
config="CONFIG_USB_CDC_COMPOSITE" ; config_module
config="CONFIG_USB_G_NOKIA" ; config_module
config="CONFIG_USB_G_ACM_MS" ; config_module
config="CONFIG_USB_G_MULTI" ; config_module
config="CONFIG_USB_G_MULTI_RNDIS" ; config_enable
config="CONFIG_USB_G_MULTI_CDC" ; config_disable
config="CONFIG_USB_G_HID" ; config_module
config="CONFIG_USB_G_DBGP" ; config_module
config="CONFIG_USB_G_DBGP_PRINTK" ; config_disable
config="CONFIG_USB_G_DBGP_SERIAL" ; config_enable
config="CONFIG_USB_G_WEBCAM" ; config_disable

#
# MMC/SD/SDIO Card Drivers
#
config="CONFIG_MMC_BLOCK_MINORS" ; option="8" ; config_value

#
# MMC/SD/SDIO Host Controller Drivers
#
#config="CONFIG_MMC_OMAP" ; config_enable
#config="CONFIG_MMC_OMAP_HS" ; config_enable
config="CONFIG_MEMSTICK" ; config_disable

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
config="CONFIG_RTC_DRV_DS1374" ; config_module
config="CONFIG_RTC_DRV_DS1374_WDT" ; config_enable
config="CONFIG_RTC_DRV_DS1672" ; config_module
config="CONFIG_RTC_DRV_DS3232" ; config_module
config="CONFIG_RTC_DRV_HYM8563" ; config_module
config="CONFIG_RTC_DRV_MAX6900" ; config_module
config="CONFIG_RTC_DRV_RS5C372" ; config_module
config="CONFIG_RTC_DRV_ISL1208" ; config_module
config="CONFIG_RTC_DRV_ISL12022" ; config_module
config="CONFIG_RTC_DRV_X1205" ; config_module
config="CONFIG_RTC_DRV_PCF2127" ; config_module
config="CONFIG_RTC_DRV_PCF8563" ; config_module
config="CONFIG_RTC_DRV_PCF85063" ; config_module
config="CONFIG_RTC_DRV_PCF8583" ; config_module
config="CONFIG_RTC_DRV_M41T80" ; config_module
config="CONFIG_RTC_DRV_M41T80_WDT" ; config_enable
config="CONFIG_RTC_DRV_BQ32K" ; config_module
config="CONFIG_RTC_DRV_TPS65910" ; config_module
config="CONFIG_RTC_DRV_S35390A" ; config_module
config="CONFIG_RTC_DRV_FM3130" ; config_module
config="CONFIG_RTC_DRV_RX8581" ; config_module
config="CONFIG_RTC_DRV_RX8025" ; config_module
config="CONFIG_RTC_DRV_EM3027" ; config_module
config="CONFIG_RTC_DRV_RV3029C2" ; config_module

#
# SPI RTC drivers
#
config="CONFIG_RTC_DRV_M41T93" ; config_module
config="CONFIG_RTC_DRV_M41T94" ; config_module
config="CONFIG_RTC_DRV_DS1305" ; config_module
config="CONFIG_RTC_DRV_DS1343" ; config_module
config="CONFIG_RTC_DRV_DS1347" ; config_module
config="CONFIG_RTC_DRV_DS1390" ; config_module
config="CONFIG_RTC_DRV_MAX6902" ; config_module
config="CONFIG_RTC_DRV_R9701" ; config_module
config="CONFIG_RTC_DRV_RS5C348" ; config_module
config="CONFIG_RTC_DRV_DS3234" ; config_module
config="CONFIG_RTC_DRV_PCF2123" ; config_module
config="CONFIG_RTC_DRV_RX4581" ; config_module
config="CONFIG_RTC_DRV_MCP795" ; config_module

#
# Platform RTC drivers
#
config="CONFIG_RTC_DRV_DS1286" ; config_module
config="CONFIG_RTC_DRV_DS1511" ; config_module
config="CONFIG_RTC_DRV_DS1553" ; config_module
config="CONFIG_RTC_DRV_DS1685_FAMILY" ; config_module
config="CONFIG_RTC_DRV_DS1742" ; config_module
config="CONFIG_RTC_DRV_DA9055" ; config_module
config="CONFIG_RTC_DRV_DA9063" ; config_module
config="CONFIG_RTC_DRV_STK17TA8" ; config_module
config="CONFIG_RTC_DRV_M48T86" ; config_module
config="CONFIG_RTC_DRV_M48T35" ; config_module
config="CONFIG_RTC_DRV_M48T59" ; config_module
config="CONFIG_RTC_DRV_MSM6242" ; config_module
config="CONFIG_RTC_DRV_BQ4802" ; config_module
config="CONFIG_RTC_DRV_RP5C01" ; config_module
config="CONFIG_RTC_DRV_V3020" ; config_module
config="CONFIG_RTC_DRV_DS2404" ; config_module

#
# HID Sensor RTC drivers
#
config="CONFIG_RTC_DRV_HID_SENSOR_TIME" ; config_module

#
# DMA Devices
#
config="CONFIG_DW_DMAC_CORE" ; config_enable
config="CONFIG_DW_DMAC" ; config_enable
config="CONFIG_TI_CPPI41" ; config_enable


#
# DMA Clients
#
config="CONFIG_UIO_PDRV_GENIRQ" ; config_module
config="CONFIG_UIO_DMEM_GENIRQ" ; config_module
config="CONFIG_UIO_PRUSS" ; config_module

#
# Android
#
config="CONFIG_ASHMEM" ; config_enable
config="CONFIG_ANDROID_TIMED_GPIO" ; config_module
config="CONFIG_SYNC" ; config_enable
config="CONFIG_SW_SYNC" ; config_disable
config="CONFIG_ION" ; config_enable

#
# Common Clock Framework
#
config="CONFIG_COMMON_CLK_PALMAS" ; config_enable
config="CONFIG_HWSPINLOCK" ; config_enable

#
# Hardware Spinlock drivers
#
#config="CONFIG_HWSPINLOCK_OMAP" ; config_enable

#
# Remoteproc drivers
#
config="CONFIG_REMOTEPROC" ; config_enable
config="CONFIG_OMAP_REMOTEPROC" ; config_module
config="CONFIG_OMAP_REMOTEPROC_WATCHDOG" ; config_enable
config="CONFIG_WKUP_M3_RPROC" ; config_enable
config="CONFIG_PRUSS_REMOTEPROC" ; config_module

#
# Rpmsg drivers
#
config="CONFIG_RPMSG" ; config_module
config="CONFIG_RPMSG_RPC" ; config_module

#
# SOC (System On Chip) specific Drivers
#
config="CONFIG_SOC_TI" ; config_enable

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
config="CONFIG_EXTCON_USB_GPIO" ; config_enable
config="CONFIG_TI_EMIF" ; config_enable

#
# Triggers - standalone
#
config="CONFIG_IIO_INTERRUPT_TRIGGER" ; config_module
config="CONFIG_IIO_SYSFS_TRIGGER" ; config_module

#
# Temperature sensors
#
config="CONFIG_RESET_CONTROLLER" ; config_disable

#
# PHY Subsystem
#
config="CONFIG_OMAP_CONTROL_PHY" ; config_enable
config="CONFIG_OMAP_USB2" ; config_enable
config="CONFIG_TI_PIPE3" ; config_enable

#
# Android
#
config="CONFIG_ANDROID" ; config_enable
config="CONFIG_ANDROID_BINDER_IPC" ; config_enable
config="CONFIG_ANDROID_BINDER_IPC_32BIT" ; config_enable
config="CONFIG_NVMEM" ; config_enable

#
# File systems
#
config="CONFIG_EXT4_FS" ; config_enable
config="CONFIG_EXT4_ENCRYPTION" ; config_enable
config="CONFIG_JBD2" ; config_enable
config="CONFIG_FS_MBCACHE" ; config_enable
config="CONFIG_XFS_FS" ; config_enable
config="CONFIG_BTRFS_FS" ; config_enable
config="CONFIG_F2FS_FS" ; config_enable
config="CONFIG_FANOTIFY_ACCESS_PERMISSIONS" ; config_enable
config="CONFIG_AUTOFS4_FS" ; config_enable
config="CONFIG_FUSE_FS" ; config_enable
config="CONFIG_OVERLAY_FS" ; config_enable

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
config="CONFIG_SQUASHFS_LZ4" ; config_enable
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
config="CONFIG_SCHED_STACK_END_CHECK" ; config_enable

#
# Runtime Testing
#
config="CONFIG_KGDB" ; config_enable
config="CONFIG_KGDB_SERIAL_CONSOLE" ; config_enable
config="CONFIG_KGDB_TESTS" ; config_disable
config="CONFIG_KGDB_KDB" ; config_enable
config="CONFIG_KDB_KEYBOARD" ; config_enable

#
# Crypto core or helper
#
config="CONFIG_CRYPTO_MANAGER_DISABLE_TESTS" ; config_enable

#
# Random Number Generation
#
config="CONFIG_ARM_CRYPTO" ; config_enable
config="CONFIG_CRYPTO_SHA1_ARM" ; config_module
config="CONFIG_CRYPTO_SHA1_ARM_NEON" ; config_module
config="CONFIG_CRYPTO_SHA256_ARM" ; config_module
config="CONFIG_CRYPTO_SHA512_ARM_NEON" ; config_module
config="CONFIG_CRYPTO_AES_ARM" ; config_module
config="CONFIG_CRYPTO_AES_ARM_BS" ; config_module

#debian changes
# * Disable CRAMFS; it was obsoleted by squashfs and initramfs
config="CONFIG_CRAMFS" ; config_disable
#* mm: Change ZBUD back to built-in, as it's not really useful as a module
config="CONFIG_ZBUD" ; config_enable

#user resquests
config="CONFIG_I2C_MUX_PCA954x" ; config_enable
config="CONFIG_SND_SEQUENCER_OSS" ; config_enable
config="CONFIG_SND_DUMMY" ; config_module
#
