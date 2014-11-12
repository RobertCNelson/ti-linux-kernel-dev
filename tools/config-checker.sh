#!/bin/sh -e

DIR=$PWD

check_config_value () {
	unset test_config
	test_config=$(grep "${config}=" ${DIR}/patches/defconfig || true)
	if [ "x${test_config}" = "x" ] ; then
		echo "echo ${config}=${value} >> ./KERNEL/.config"
	else
		if [ ! "x${test_config}" = "x${config}=${value}" ] ; then
			if [ ! "x${test_config}" = "x${config}=\"${value}\"" ] ; then
				echo "sed -i -e 's:${test_config}:${config}=${value}:g' ./KERNEL/.config"
			fi
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
CONFIG_CMA_SIZE_MBYTES=16
check_if_set_then_disable () {
	unset test_config
	test_config=$(grep "${if_config}=y" ${DIR}/patches/defconfig || true)
	if [ "x${test_config}" = "x${if_config}=y" ] ; then
		check_config_disable
	fi
}

#start with omap2plus_defconfig
##################################################
##################################################
# TI AM33XX specific config options
##################################################

# Disable Socs other than AM33xx
CONFIG_ARCH_OMAP2=n
CONFIG_ARCH_OMAP3=n
CONFIG_ARCH_OMAP4=n
CONFIG_SOC_OMAP5=n
CONFIG_SOC_AM43XX=n
CONFIG_SOC_DRA7XX=n

#Disable CONFIG_SMP
CONFIG_SMP=n
##################################################
##################################################
# TI AM43XX specific config options
##################################################

# Disable Socs other than AM43xx
CONFIG_ARCH_OMAP2=n
CONFIG_ARCH_OMAP3=n
CONFIG_ARCH_OMAP4=n
CONFIG_SOC_OMAP5=n
CONFIG_SOC_AM33XX=n
CONFIG_SOC_DRA7XX=n

#Disable CONFIG_SMP
CONFIG_SMP=n
##################################################

#Cortex-Ax only:
config="CONFIG_ARCH_MULTI_V6"
check_config_disable

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

config="CONFIG_BACKLIGHT_PWM"
check_config_builtin

CONFIG_DRM=m
CONFIG_DRM_KMS_HELPER=m
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_GEM_CMA_HELPER=y
CONFIG_DRM_KMS_CMA_HELPER=y
CONFIG_DRM_I2C_NXP_TDA998X=m
CONFIG_DRM_TILCDC=m
CONFIG_DRM_OMAP=y
CONFIG_DRM_OMAP_NUM_CRTCS=2

config="CONFIG_DRM"
check_config_builtin
config="CONFIG_DRM_KMS_HELPER"
check_config_module
config="CONFIG_DRM_KMS_FB_HELPER"
check_config_builtin
config="CONFIG_DRM_GEM_CMA_HELPER"
check_config_builtin
config="CONFIG_DRM_KMS_CMA_HELPER"
check_config_builtin
config="CONFIG_DRM_I2C_NXP_TDA998X"
check_config_module
config="CONFIG_DRM_TILCDC"
check_config_module
config="CONFIG_DRM_OMAP"
check_config_module
config="CONFIG_DRM_OMAP_NUM_CRTCS"
value="2"
check_config_value

CONFIG_DISPLAY_PANEL_TLC59108=m
CONFIG_OMAP5_DSS_HDMI=y
CONFIG_DISPLAY_CONNECTOR_HDMI=m
CONFIG_DISPLAY_DRA7EVM_ENCODER_TPD12S015=m
CONFIG_DISPLAY_ENCODER_SII9022=m

config="CONFIG_DISPLAY_PANEL_TLC59108"
check_config_module
config="CONFIG_OMAP5_DSS_HDMI"
check_config_builtin
config="CONFIG_DISPLAY_CONNECTOR_HDMI"
check_config_module
config="CONFIG_DISPLAY_DRA7EVM_ENCODER_TPD12S015"
check_config_module
config="CONFIG_DISPLAY_ENCODER_SII9022"
check_config_module

CONFIG_CMA_SIZE_MBYTES=24

config="CONFIG_CMA_SIZE_MBYTES"
value="24"
check_config_value

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

config="CONFIG_MEDIA_SUPPORT"
check_config_module
config="CONFIG_MEDIA_CONTROLLER"
check_config_builtin
config="CONFIG_MEDIA_CAMERA_SUPPORT"
check_config_builtin
config="CONFIG_V4L_PLATFORM_DRIVERS"
check_config_builtin
config="CONFIG_V4L2_MEM2MEM_DEV"
check_config_module
config="CONFIG_VIDEOBUF2_DMA_CONTIG"
check_config_module
config="CONFIG_V4L_MEM2MEM_DRIVERS"
check_config_builtin
config="CONFIG_VIDEO_V4L2_SUBDEV_API"
check_config_builtin
config="CONFIG_VIDEO_TI_VPE"
check_config_module
config="CONFIG_VIDEO_TI_VIP"
check_config_module
config="CONFIG_VIDEO_OV2659"
check_config_module
config="CONFIG_VIDEO_AM437X_VPFE"
check_config_module

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

config="CONFIG_SOUND"
check_config_module
config="CONFIG_SND"
check_config_module
config="CONFIG_SND_SOC"
check_config_module
config="CONFIG_SND_OMAP_SOC"
check_config_module
config="CONFIG_SND_EDMA_SOC"
check_config_module
config="CONFIG_SND_DAVINCI_SOC_MCASP"
check_config_module
config="CONFIG_SND_AM335X_SOC_NXPTDA_EVM"
check_config_module
config="CONFIG_SND_AM33XX_SOC_EVM"
check_config_module
config="CONFIG_SND_SIMPLE_CARD"
check_config_module
config="CONFIG_SND_SOC_TLV320AIC31XX"
check_config_module
config="CONFIG_SND_SOC_TLV320AIC3X"
check_config_module

config="CONFIG_SND_OMAP_SOC_DRA7EVM"
check_config_module

CONFIG_OMAP2_DSS=y
CONFIG_OMAP2_DSS_INIT=y

config="CONFIG_OMAP2_DSS"
check_config_module
config="CONFIG_OMAP2_DSS_INIT"
check_config_builtin
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
config="CONFIG_CGROUPS"
check_config_builtin
config="CONFIG_REGULATOR_GPIO"
check_config_builtin

config="CONFIG_CRYPTO_DEV_OMAP_SHAM"
check_config_builtin
config="CONFIG_CRYPTO_DEV_OMAP_AES"
check_config_builtin
config="CONFIG_CRYPTO_DEV_OMAP_DES"
check_config_builtin
config="CONFIG_CRYPTO_USER_API_HASH"
check_config_builtin
config="CONFIG_CRYPTO_USER_API_SKCIPHER"
check_config_builtin

config="CONFIG_PREEMPT_NONE"
check_config_disable
config="CONFIG_PREEMPT_VOLUNTARY"
check_config_disable
config="CONFIG_PREEMPT"
check_config_builtin
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

config="CONFIG_USB_EHCI_HCD"
check_config_builtin
config="CONFIG_USB_XHCI_HCD"
check_config_builtin
config="CONFIG_USB_TEST"
check_config_module

#USB MUSB support
CONFIG_USB_MUSB_HDRC=m
CONFIG_USB_MUSB_OMAP2PLUS=m
CONFIG_USB_MUSB_DSPS=m
CONFIG_TI_CPPI41=y
CONFIG_USB_TI_CPPI41_DMA=y
CONFIG_TWL6030_USB=m
CONFIG_TWL4030_USB=m

config="CONFIG_USB_MUSB_HDRC"
check_config_module
config="CONFIG_USB_MUSB_OMAP2PLUS"
check_config_module
config="CONFIG_USB_MUSB_DSPS"
check_config_module
config="CONFIG_TI_CPPI41"
check_config_builtin
config="CONFIG_USB_TI_CPPI41_DMA"
check_config_builtin
config="CONFIG_TWL6030_USB"
check_config_module
config="CONFIG_TWL4030_USB"
check_config_module

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

config="CONFIG_USB_AUDIO"
check_config_module
config="CONFIG_USB_ETH"
check_config_module
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
config="CONFIG_USB_G_MULTI_CDC"
check_config_builtin
config="CONFIG_USB_G_HID"
check_config_module
config="CONFIG_USB_G_DBGP"
check_config_module
config="CONFIG_USB_G_WEBCAM"
check_config_module

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

config="CONFIG_MEDIA_SUPPORT"
check_config_module
config="CONFIG_MEDIA_CAMERA_SUPPORT"
check_config_builtin
config="CONFIG_VIDEO_DEV"
check_config_module
config="CONFIG_VIDEO_V4L2"
check_config_module
config="CONFIG_VIDEOBUF2_CORE"
check_config_module
config="CONFIG_VIDEOBUF2_MEMOPS"
check_config_module
config="CONFIG_VIDEOBUF2_VMALLOC"
check_config_module
config="CONFIG_MEDIA_USB_SUPPORT"
check_config_builtin
config="CONFIG_USB_VIDEO_CLASS"
check_config_module
config="CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV"
check_config_builtin
config="CONFIG_USB_GSPCA"
check_config_module

#USB device classes
CONFIG_USB_ACM=m
CONFIG_USB_SERIAL=m
CONFIG_USB_SERIAL_PL2303=m
CONFIG_USB_PRINTER=m

config="CONFIG_USB_ACM"
check_config_module
config="CONFIG_USB_SERIAL"
check_config_module
config="CONFIG_USB_SERIAL_PL2303"
check_config_module
config="CONFIG_USB_PRINTER"
check_config_module

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

# Buttons
CONFIG_INPUT_PALMAS_PWRBUTTON=y

config="CONFIG_INPUT_PALMAS_PWRBUTTON"
check_config_builtin

#RTC
CONFIG_RTC_DRV_PALMAS=y
CONFIG_RTC_DRV_DS1307=y

config="CONFIG_RTC_DRV_PALMAS"
check_config_builtin
config="CONFIG_RTC_DRV_DS1307"
check_config_builtin

#Ethernet
CONFIG_TI_CPTS=y

config="CONFIG_TI_CPTS"
check_config_builtin

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

config="CONFIG_LEDS_CLASS"
check_config_builtin
config="CONFIG_LEDS_GPIO"
check_config_builtin
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
config="CONFIG_LEDS_TRIGGER_TRANSIENT"
check_config_builtin
config="CONFIG_LEDS_TRIGGER_CAMERA"
check_config_builtin

#MTD
CONFIG_MTD_NAND_OMAP_BCH=y
CONFIG_MTD_TESTS=m

config="CONFIG_MTD_NAND_OMAP_BCH"
check_config_builtin
config="CONFIG_MTD_TESTS"
check_config_module

#SPI
CONFIG_SPI_SPIDEV=y

config="CONFIG_SPI_SPIDEV"
check_config_builtin

#QSPI
CONFIG_SPI_TI_QSPI=y
CONFIG_MTD_M25P80=m

config="CONFIG_SPI_TI_QSPI"
check_config_builtin
config="CONFIG_MTD_M25P80"
check_config_module

#EXTCON
CONFIG_EXTCON_GPIO=y

config="CONFIG_EXTCON_GPIO"
check_config_builtin
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

config="CONFIG_HWSPINLOCK_OMAP"
check_config_builtin

# Mailbox
CONFIG_OMAP2PLUS_MBOX=y

config="CONFIG_OMAP2PLUS_MBOX"
check_config_builtin

# IOMMU
CONFIG_OMAP_IOMMU=y
CONFIG_OMAP_IOVMM=y
CONFIG_OMAP_IOMMU_DEBUG=y

config="CONFIG_OMAP_IOMMU"
check_config_builtin
config="CONFIG_OMAP_IOVMM"
check_config_builtin

# Remoteproc
CONFIG_OMAP_REMOTEPROC=m
CONFIG_OMAP_REMOTEPROC_WATCHDOG=y

config="CONFIG_OMAP_REMOTEPROC"
check_config_module
config="CONFIG_OMAP_REMOTEPROC_WATCHDOG"
check_config_builtin

# RPMsg
CONFIG_RPMSG_RPC=m

config="CONFIG_RPMSG_RPC"
check_config_module
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
config="CONFIG_CPU_FREQ"
check_config_builtin
config="CONFIG_CPU_FREQ_STAT"
check_config_builtin
config="CONFIG_CPU_FREQ_STAT_DETAILS"
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

config="CONFIG_SENSORS_TMP102"
check_config_builtin
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
config="CONFIG_PM_DEVFREQ"
check_config_builtin
config="CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND"
check_config_builtin
config="CONFIG_DEVFREQ_GOV_PERFORMANCE"
check_config_builtin
config="CONFIG_DEVFREQ_GOV_POWERSAVE"
check_config_builtin
config="CONFIG_DEVFREQ_GOV_USERSPACE"
check_config_builtin
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

config="CONFIG_RFKILL"
check_config_module

config="CONFIG_NF_CONNTRACK"
check_config_builtin
config="CONFIG_NF_CONNTRACK_IPV4"
check_config_builtin
config="CONFIG_IP_NF_IPTABLES"
check_config_builtin
config="CONFIG_IP_NF_FILTER"
check_config_builtin
config="CONFIG_NF_NAT_IPV4"
check_config_builtin
config="CONFIG_IP_NF_TARGET_MASQUERADE"
check_config_builtin
##################################################

#
# General setup
#
config="CONFIG_LOCALVERSION_AUTO"
check_config_disable
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
# CPU Frequency scaling
#
config="CONFIG_CPU_FREQ_GOV_POWERSAVE"
check_config_builtin
config="CONFIG_CPU_FREQ_GOV_USERSPACE"
check_config_builtin
config="CONFIG_CPU_FREQ_GOV_CONSERVATIVE"
check_config_builtin

#
# ARM CPU frequency scaling drivers
#
config="CONFIG_ARM_OMAP2PLUS_CPUFREQ"
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
config="CONFIG_PACKET_DIAG"
check_config_module
config="CONFIG_UNIX_DIAG"
check_config_module
config="CONFIG_XFRM_ALGO"
check_config_module
config="CONFIG_XFRM_USER"
check_config_module
config="CONFIG_XFRM_SUB_POLICY"
check_config_builtin
config="CONFIG_XFRM_IPCOMP"
check_config_module
config="CONFIG_NET_KEY"
check_config_module
config="CONFIG_IP_ADVANCED_ROUTER"
check_config_builtin
config="CONFIG_IP_FIB_TRIE_STATS"
check_config_builtin
config="CONFIG_IP_MULTIPLE_TABLES"
check_config_builtin
config="CONFIG_IP_ROUTE_MULTIPATH"
check_config_builtin
config="CONFIG_IP_ROUTE_VERBOSE"
check_config_builtin
config="CONFIG_IP_ROUTE_CLASSID"
check_config_builtin
config="CONFIG_NET_IPIP"
check_config_module
config="CONFIG_NET_IPGRE_DEMUX"
check_config_module
config="CONFIG_NET_IP_TUNNEL"
check_config_module
config="CONFIG_NET_IPGRE"
check_config_module
config="CONFIG_NET_IPGRE_BROADCAST"
check_config_builtin
config="CONFIG_IP_MROUTE"
check_config_builtin
config="CONFIG_IP_MROUTE_MULTIPLE_TABLES"
check_config_builtin
config="CONFIG_IP_PIMSM_V1"
check_config_builtin
config="CONFIG_IP_PIMSM_V2"
check_config_builtin
config="CONFIG_SYN_COOKIES"
check_config_builtin
config="CONFIG_NET_IPVTI"
check_config_module
config="CONFIG_INET_AH"
check_config_module
config="CONFIG_INET_ESP"
check_config_module
config="CONFIG_INET_IPCOMP"
check_config_module
config="CONFIG_INET_XFRM_TUNNEL"
check_config_module
config="CONFIG_INET_TUNNEL"
check_config_module
config="CONFIG_INET_XFRM_MODE_TRANSPORT"
check_config_module
config="CONFIG_INET_XFRM_MODE_TUNNEL"
check_config_module
config="CONFIG_INET_XFRM_MODE_BEET"
check_config_module
config="CONFIG_INET_LRO"
check_config_module
config="CONFIG_INET_DIAG"
check_config_module
config="CONFIG_INET_TCP_DIAG"
check_config_module
config="CONFIG_INET_UDP_DIAG"
check_config_module
config="CONFIG_TCP_CONG_ADVANCED"
check_config_builtin
config="CONFIG_TCP_CONG_BIC"
check_config_module
config="CONFIG_TCP_CONG_WESTWOOD"
check_config_module
config="CONFIG_TCP_CONG_HTCP"
check_config_module
config="CONFIG_TCP_CONG_HSTCP"
check_config_module
config="CONFIG_TCP_CONG_HYBLA"
check_config_module
config="CONFIG_TCP_CONG_VEGAS"
check_config_module
config="CONFIG_TCP_CONG_SCALABLE"
check_config_module
config="CONFIG_TCP_CONG_LP"
check_config_module
config="CONFIG_TCP_CONG_VENO"
check_config_module
config="CONFIG_TCP_CONG_YEAH"
check_config_module
config="CONFIG_TCP_CONG_ILLINOIS"
check_config_module
config="CONFIG_DEFAULT_CUBIC"
check_config_builtin
config="CONFIG_TCP_MD5SIG"
check_config_builtin
config="CONFIG_IPV6"
check_config_builtin
config="CONFIG_IPV6_ROUTER_PREF"
check_config_builtin
config="CONFIG_IPV6_ROUTE_INFO"
check_config_builtin
config="CONFIG_IPV6_OPTIMISTIC_DAD"
check_config_builtin
config="CONFIG_INET6_AH"
check_config_module
config="CONFIG_INET6_ESP"
check_config_module
config="CONFIG_INET6_IPCOMP"
check_config_module
config="CONFIG_IPV6_MIP6"
check_config_builtin
config="CONFIG_INET6_XFRM_TUNNEL"
check_config_module
config="CONFIG_INET6_TUNNEL"
check_config_module
config="CONFIG_INET6_XFRM_MODE_TRANSPORT"
check_config_module
config="CONFIG_INET6_XFRM_MODE_TUNNEL"
check_config_module
config="CONFIG_INET6_XFRM_MODE_BEET"
check_config_module
config="CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION"
check_config_module
config="CONFIG_IPV6_VTI"
check_config_module
config="CONFIG_IPV6_SIT"
check_config_module
config="CONFIG_IPV6_SIT_6RD"
check_config_builtin
config="CONFIG_IPV6_NDISC_NODETYPE"
check_config_builtin
config="CONFIG_IPV6_TUNNEL"
check_config_module
config="CONFIG_IPV6_GRE"
check_config_module
config="CONFIG_IPV6_MULTIPLE_TABLES"
check_config_builtin
config="CONFIG_IPV6_SUBTREES"
check_config_builtin
config="CONFIG_IPV6_MROUTE"
check_config_builtin
config="CONFIG_IPV6_MROUTE_MULTIPLE_TABLES"
check_config_builtin
config="CONFIG_IPV6_PIMSM_V2"
check_config_builtin
config="CONFIG_NETWORK_SECMARK"
check_config_builtin
config="CONFIG_BRIDGE_NETFILTER"
check_config_builtin

#
# Core Netfilter Configuration
#
config="CONFIG_NETFILTER_NETLINK"
check_config_module
config="CONFIG_NETFILTER_NETLINK_ACCT"
check_config_module
config="CONFIG_NETFILTER_NETLINK_QUEUE"
check_config_module
config="CONFIG_NETFILTER_NETLINK_LOG"
check_config_module
config="CONFIG_NF_CONNTRACK"
check_config_builtin
config="CONFIG_NF_CONNTRACK_MARK"
check_config_builtin
config="CONFIG_NF_CONNTRACK_SECMARK"
check_config_builtin
config="CONFIG_NF_CONNTRACK_ZONES"
check_config_builtin
config="CONFIG_NF_CONNTRACK_PROCFS"
check_config_builtin
config="CONFIG_NF_CONNTRACK_EVENTS"
check_config_builtin
config="CONFIG_NF_CONNTRACK_TIMEOUT"
check_config_builtin
config="CONFIG_NF_CONNTRACK_TIMESTAMP"
check_config_builtin
config="CONFIG_NF_CONNTRACK_LABELS"
check_config_builtin
config="CONFIG_NF_CT_PROTO_DCCP"
check_config_module
config="CONFIG_NF_CT_PROTO_GRE"
check_config_module
config="CONFIG_NF_CT_PROTO_SCTP"
check_config_module
config="CONFIG_NF_CT_PROTO_UDPLITE"
check_config_module
config="CONFIG_NF_CONNTRACK_AMANDA"
check_config_module
config="CONFIG_NF_CONNTRACK_FTP"
check_config_module
config="CONFIG_NF_CONNTRACK_H323"
check_config_module
config="CONFIG_NF_CONNTRACK_IRC"
check_config_module
config="CONFIG_NF_CONNTRACK_BROADCAST"
check_config_module
config="CONFIG_NF_CONNTRACK_NETBIOS_NS"
check_config_module
config="CONFIG_NF_CONNTRACK_SNMP"
check_config_module
config="CONFIG_NF_CONNTRACK_PPTP"
check_config_module
config="CONFIG_NF_CONNTRACK_SANE"
check_config_module
config="CONFIG_NF_CONNTRACK_SIP"
check_config_module
config="CONFIG_NF_CONNTRACK_TFTP"
check_config_module
config="CONFIG_NF_CT_NETLINK"
check_config_module
config="CONFIG_NF_CT_NETLINK_TIMEOUT"
check_config_module
config="CONFIG_NF_CT_NETLINK_HELPER"
check_config_module
config="CONFIG_NETFILTER_NETLINK_QUEUE_CT"
check_config_builtin
config="CONFIG_NF_NAT"
check_config_builtin
config="CONFIG_NF_NAT_NEEDED"
check_config_builtin
config="CONFIG_NF_NAT_PROTO_DCCP"
check_config_module
config="CONFIG_NF_NAT_PROTO_UDPLITE"
check_config_module
config="CONFIG_NF_NAT_PROTO_SCTP"
check_config_module
config="CONFIG_NF_NAT_AMANDA"
check_config_module
config="CONFIG_NF_NAT_FTP"
check_config_module
config="CONFIG_NF_NAT_IRC"
check_config_module
config="CONFIG_NF_NAT_SIP"
check_config_module
config="CONFIG_NF_NAT_TFTP"
check_config_module
config="CONFIG_NETFILTER_SYNPROXY"
check_config_module
config="CONFIG_NF_TABLES"
check_config_module
config="CONFIG_NF_TABLES_INET"
check_config_module
config="CONFIG_NFT_EXTHDR"
check_config_module
config="CONFIG_NFT_META"
check_config_module
config="CONFIG_NFT_CT"
check_config_module
config="CONFIG_NFT_RBTREE"
check_config_module
config="CONFIG_NFT_HASH"
check_config_module
config="CONFIG_NFT_COUNTER"
check_config_module
config="CONFIG_NFT_LOG"
check_config_module
config="CONFIG_NFT_LIMIT"
check_config_module
config="CONFIG_NFT_NAT"
check_config_module
config="CONFIG_NFT_QUEUE"
check_config_module
config="CONFIG_NFT_REJECT"
check_config_module
config="CONFIG_NFT_REJECT_INET"
check_config_module
config="CONFIG_NFT_COMPAT"
check_config_module

#
# Xtables combined modules
#
config="CONFIG_NETFILTER_XT_MARK"
check_config_module
config="CONFIG_NETFILTER_XT_CONNMARK"
check_config_module
config="CONFIG_NETFILTER_XT_SET"
check_config_module

#
# Xtables targets
#
config="CONFIG_NETFILTER_XT_TARGET_CHECKSUM"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_CLASSIFY"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_CONNMARK"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_CONNSECMARK"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_CT"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_DSCP"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_HL"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_HMARK"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_IDLETIMER"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_LED"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_LOG"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_MARK"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_NETMAP"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_NFLOG"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_NFQUEUE"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_RATEEST"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_REDIRECT"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_TEE"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_TPROXY"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_TRACE"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_SECMARK"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_TCPMSS"
check_config_module
config="CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP"
check_config_module

#
# Xtables matches
#
config="CONFIG_NETFILTER_XT_MATCH_ADDRTYPE"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_BPF"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_CGROUP"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_CLUSTER"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_COMMENT"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_CONNBYTES"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_CONNLABEL"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_CONNLIMIT"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_CONNMARK"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_CONNTRACK"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_CPU"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_DCCP"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_DEVGROUP"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_DSCP"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_ECN"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_ESP"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_HASHLIMIT"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_HELPER"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_HL"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_IPCOMP"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_IPRANGE"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_IPVS"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_L2TP"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_LENGTH"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_LIMIT"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_MAC"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_MARK"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_MULTIPORT"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_NFACCT"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_OSF"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_OWNER"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_POLICY"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_PHYSDEV"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_PKTTYPE"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_QUOTA"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_RATEEST"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_REALM"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_RECENT"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_SCTP"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_SOCKET"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_STATE"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_STATISTIC"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_STRING"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_TCPMSS"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_TIME"
check_config_module
config="CONFIG_NETFILTER_XT_MATCH_U32"
check_config_module
config="CONFIG_IP_SET"
check_config_module
config="CONFIG_IP_SET_BITMAP_IP"
check_config_module
config="CONFIG_IP_SET_BITMAP_IPMAC"
check_config_module
config="CONFIG_IP_SET_BITMAP_PORT"
check_config_module
config="CONFIG_IP_SET_HASH_IP"
check_config_module
config="CONFIG_IP_SET_HASH_IPPORT"
check_config_module
config="CONFIG_IP_SET_HASH_IPPORTIP"
check_config_module
config="CONFIG_IP_SET_HASH_IPPORTNET"
check_config_module
config="CONFIG_IP_SET_HASH_NETPORTNET"
check_config_module
config="CONFIG_IP_SET_HASH_NET"
check_config_module
config="CONFIG_IP_SET_HASH_NETNET"
check_config_module
config="CONFIG_IP_SET_HASH_NETPORT"
check_config_module
config="CONFIG_IP_SET_HASH_NETIFACE"
check_config_module
config="CONFIG_IP_SET_LIST_SET"
check_config_module
config="CONFIG_IP_VS"
check_config_module
config="CONFIG_IP_VS_IPV6"
check_config_builtin

#
# IPVS transport protocol load balancing support
#
config="CONFIG_IP_VS_PROTO_TCP"
check_config_builtin
config="CONFIG_IP_VS_PROTO_UDP"
check_config_builtin
config="CONFIG_IP_VS_PROTO_AH_ESP"
check_config_builtin
config="CONFIG_IP_VS_PROTO_ESP"
check_config_builtin
config="CONFIG_IP_VS_PROTO_AH"
check_config_builtin
config="CONFIG_IP_VS_PROTO_SCTP"
check_config_builtin

#
# IPVS scheduler
#
config="CONFIG_IP_VS_RR"
check_config_module
config="CONFIG_IP_VS_WRR"
check_config_module
config="CONFIG_IP_VS_LC"
check_config_module
config="CONFIG_IP_VS_WLC"
check_config_module
config="CONFIG_IP_VS_LBLC"
check_config_module
config="CONFIG_IP_VS_LBLCR"
check_config_module
config="CONFIG_IP_VS_DH"
check_config_module
config="CONFIG_IP_VS_SH"
check_config_module
config="CONFIG_IP_VS_SED"
check_config_module
config="CONFIG_IP_VS_NQ"
check_config_module

#
# IPVS application helper
#
config="CONFIG_IP_VS_FTP"
check_config_module
config="CONFIG_IP_VS_NFCT"
check_config_builtin
config="CONFIG_IP_VS_PE_SIP"
check_config_module

#
# IP: Netfilter configuration
#
config="CONFIG_NFT_CHAIN_ROUTE_IPV4"
check_config_module
config="CONFIG_NFT_CHAIN_NAT_IPV4"
check_config_module
config="CONFIG_NF_TABLES_ARP"
check_config_module
config="CONFIG_IP_NF_MATCH_AH"
check_config_module
config="CONFIG_IP_NF_MATCH_RPFILTER"
check_config_module
config="CONFIG_IP_NF_TARGET_REJECT"
check_config_module
config="CONFIG_IP_NF_TARGET_SYNPROXY"
check_config_module
config="CONFIG_IP_NF_TARGET_ULOG"
check_config_module
config="CONFIG_IP_NF_MANGLE"
check_config_module
config="CONFIG_IP_NF_TARGET_CLUSTERIP"
check_config_module
config="CONFIG_IP_NF_TARGET_ECN"
check_config_module
config="CONFIG_IP_NF_RAW"
check_config_module
config="CONFIG_IP_NF_SECURITY"
check_config_module
config="CONFIG_IP_NF_ARPTABLES"
check_config_module
config="CONFIG_IP_NF_ARPFILTER"
check_config_module
config="CONFIG_IP_NF_ARP_MANGLE"
check_config_module

#
# IPv6: Netfilter configuration
#
config="CONFIG_NF_CONNTRACK_IPV6"
check_config_module
config="CONFIG_NFT_CHAIN_ROUTE_IPV6"
check_config_module
config="CONFIG_NFT_CHAIN_NAT_IPV6"
check_config_module
config="CONFIG_IP6_NF_MATCH_AH"
check_config_module
config="CONFIG_IP6_NF_MATCH_EUI64"
check_config_module
config="CONFIG_IP6_NF_MATCH_FRAG"
check_config_module
config="CONFIG_IP6_NF_MATCH_OPTS"
check_config_module
config="CONFIG_IP6_NF_MATCH_IPV6HEADER"
check_config_module
config="CONFIG_IP6_NF_MATCH_MH"
check_config_module
config="CONFIG_IP6_NF_MATCH_RPFILTER"
check_config_module
config="CONFIG_IP6_NF_MATCH_RT"
check_config_module
config="CONFIG_IP6_NF_FILTER"
check_config_module
config="CONFIG_IP6_NF_TARGET_REJECT"
check_config_module
config="CONFIG_IP6_NF_TARGET_SYNPROXY"
check_config_module
config="CONFIG_IP6_NF_MANGLE"
check_config_module
config="CONFIG_IP6_NF_RAW"
check_config_module
config="CONFIG_IP6_NF_SECURITY"
check_config_module
config="CONFIG_NF_NAT_IPV6"
check_config_module
config="CONFIG_IP6_NF_TARGET_MASQUERADE"
check_config_module
config="CONFIG_IP6_NF_TARGET_NPT"
check_config_module
config="CONFIG_NF_TABLES_BRIDGE"
check_config_module
config="CONFIG_BRIDGE_NF_EBTABLES"
check_config_module
config="CONFIG_BRIDGE_EBT_BROUTE"
check_config_module
config="CONFIG_BRIDGE_EBT_T_FILTER"
check_config_module
config="CONFIG_BRIDGE_EBT_T_NAT"
check_config_module
config="CONFIG_BRIDGE_EBT_802_3"
check_config_module
config="CONFIG_BRIDGE_EBT_AMONG"
check_config_module
config="CONFIG_BRIDGE_EBT_ARP"
check_config_module
config="CONFIG_BRIDGE_EBT_IP"
check_config_module
config="CONFIG_BRIDGE_EBT_IP6"
check_config_module
config="CONFIG_BRIDGE_EBT_LIMIT"
check_config_module
config="CONFIG_BRIDGE_EBT_MARK"
check_config_module
config="CONFIG_BRIDGE_EBT_PKTTYPE"
check_config_module
config="CONFIG_BRIDGE_EBT_STP"
check_config_module
config="CONFIG_BRIDGE_EBT_VLAN"
check_config_module
config="CONFIG_BRIDGE_EBT_ARPREPLY"
check_config_module
config="CONFIG_BRIDGE_EBT_DNAT"
check_config_module
config="CONFIG_BRIDGE_EBT_MARK_T"
check_config_module
config="CONFIG_BRIDGE_EBT_REDIRECT"
check_config_module
config="CONFIG_BRIDGE_EBT_SNAT"
check_config_module
config="CONFIG_BRIDGE_EBT_LOG"
check_config_module
config="CONFIG_BRIDGE_EBT_ULOG"
check_config_module
config="CONFIG_BRIDGE_EBT_NFLOG"
check_config_module
config="CONFIG_IP_DCCP"
check_config_module
config="CONFIG_INET_DCCP_DIAG"
check_config_module

#
# DCCP CCIDs configuration
#
config="CONFIG_IP_DCCP_CCID3"
check_config_builtin
config="CONFIG_IP_DCCP_TFRC_LIB"
check_config_builtin

#
# DCCP Kernel Hacking
#
config="CONFIG_NET_DCCPPROBE"
check_config_module
config="CONFIG_IP_SCTP"
check_config_module
config="CONFIG_NET_SCTPPROBE"
check_config_module
config="CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5"
check_config_builtin
config="CONFIG_SCTP_COOKIE_HMAC_MD5"
check_config_builtin
config="CONFIG_SCTP_COOKIE_HMAC_SHA1"
check_config_builtin
config="CONFIG_RDS"
check_config_module
config="CONFIG_RDS_TCP"
check_config_module
config="CONFIG_TIPC"
check_config_module
config="CONFIG_ATM"
check_config_module
config="CONFIG_ATM_CLIP"
check_config_module
config="CONFIG_ATM_LANE"
check_config_module
config="CONFIG_ATM_MPOA"
check_config_module
config="CONFIG_ATM_BR2684"
check_config_module
config="CONFIG_L2TP"
check_config_module
config="CONFIG_L2TP_DEBUGFS"
check_config_module
config="CONFIG_L2TP_V3"
check_config_builtin
config="CONFIG_L2TP_IP"
check_config_module
config="CONFIG_L2TP_ETH"
check_config_module
config="CONFIG_STP"
check_config_module
config="CONFIG_GARP"
check_config_module
config="CONFIG_MRP"
check_config_module
config="CONFIG_BRIDGE"
check_config_module
config="CONFIG_BRIDGE_IGMP_SNOOPING"
check_config_builtin
config="CONFIG_BRIDGE_VLAN_FILTERING"
check_config_builtin
config="CONFIG_VLAN_8021Q"
check_config_module
config="CONFIG_VLAN_8021Q_GVRP"
check_config_builtin
config="CONFIG_VLAN_8021Q_MVRP"
check_config_builtin
config="CONFIG_LLC"
check_config_module
config="CONFIG_LLC2"
check_config_module
config="CONFIG_ATALK"
check_config_module
config="CONFIG_DEV_APPLETALK"
check_config_module
config="CONFIG_IPDDP"
check_config_module
config="CONFIG_IPDDP_ENCAP"
check_config_builtin
config="CONFIG_PHONET"
check_config_module
config="CONFIG_IEEE802154"
check_config_module
config="CONFIG_IEEE802154_6LOWPAN"
check_config_module
config="CONFIG_NET_SCHED"
check_config_builtin

#
# Queueing/Scheduling
#
config="CONFIG_NET_SCH_CBQ"
check_config_module
config="CONFIG_NET_SCH_HTB"
check_config_module
config="CONFIG_NET_SCH_HFSC"
check_config_module
config="CONFIG_NET_SCH_ATM"
check_config_module
config="CONFIG_NET_SCH_PRIO"
check_config_module
config="CONFIG_NET_SCH_MULTIQ"
check_config_module
config="CONFIG_NET_SCH_RED"
check_config_module
config="CONFIG_NET_SCH_SFB"
check_config_module
config="CONFIG_NET_SCH_SFQ"
check_config_module
config="CONFIG_NET_SCH_TEQL"
check_config_module
config="CONFIG_NET_SCH_TBF"
check_config_module
config="CONFIG_NET_SCH_GRED"
check_config_module
config="CONFIG_NET_SCH_DSMARK"
check_config_module
config="CONFIG_NET_SCH_NETEM"
check_config_module
config="CONFIG_NET_SCH_DRR"
check_config_module
config="CONFIG_NET_SCH_MQPRIO"
check_config_module
config="CONFIG_NET_SCH_CHOKE"
check_config_module
config="CONFIG_NET_SCH_QFQ"
check_config_module
config="CONFIG_NET_SCH_CODEL"
check_config_module
config="CONFIG_NET_SCH_FQ_CODEL"
check_config_module
config="CONFIG_NET_SCH_FQ"
check_config_module
config="CONFIG_NET_SCH_HHF"
check_config_module
config="CONFIG_NET_SCH_PIE"
check_config_module
config="CONFIG_NET_SCH_INGRESS"
check_config_module
config="CONFIG_NET_SCH_PLUG"
check_config_module

#
# Classification
#
config="CONFIG_NET_CLS"
check_config_builtin
config="CONFIG_NET_CLS_BASIC"
check_config_module
config="CONFIG_NET_CLS_TCINDEX"
check_config_module
config="CONFIG_NET_CLS_ROUTE4"
check_config_module
config="CONFIG_NET_CLS_FW"
check_config_module
config="CONFIG_NET_CLS_U32"
check_config_module
config="CONFIG_CLS_U32_PERF"
check_config_builtin
config="CONFIG_CLS_U32_MARK"
check_config_builtin
config="CONFIG_NET_CLS_RSVP"
check_config_module
config="CONFIG_NET_CLS_RSVP6"
check_config_module
config="CONFIG_NET_CLS_FLOW"
check_config_module
config="CONFIG_NET_CLS_CGROUP"
check_config_module
config="CONFIG_NET_CLS_BPF"
check_config_module
config="CONFIG_NET_EMATCH"
check_config_builtin
config="CONFIG_NET_EMATCH_CMP"
check_config_module
config="CONFIG_NET_EMATCH_NBYTE"
check_config_module
config="CONFIG_NET_EMATCH_U32"
check_config_module
config="CONFIG_NET_EMATCH_META"
check_config_module
config="CONFIG_NET_EMATCH_TEXT"
check_config_module
config="CONFIG_NET_EMATCH_CANID"
check_config_module
config="CONFIG_NET_EMATCH_IPSET"
check_config_module
config="CONFIG_NET_CLS_ACT"
check_config_builtin
config="CONFIG_NET_ACT_POLICE"
check_config_module
config="CONFIG_NET_ACT_GACT"
check_config_module
config="CONFIG_GACT_PROB"
check_config_builtin
config="CONFIG_NET_ACT_MIRRED"
check_config_module
config="CONFIG_NET_ACT_IPT"
check_config_module
config="CONFIG_NET_ACT_NAT"
check_config_module
config="CONFIG_NET_ACT_PEDIT"
check_config_module
config="CONFIG_NET_ACT_SIMP"
check_config_module
config="CONFIG_NET_ACT_SKBEDIT"
check_config_module
config="CONFIG_NET_ACT_CSUM"
check_config_module
config="CONFIG_NET_CLS_IND"
check_config_builtin
config="CONFIG_NET_SCH_FIFO"
check_config_builtin
config="CONFIG_DCB"
check_config_builtin
config="CONFIG_BATMAN_ADV"
check_config_module
config="CONFIG_BATMAN_ADV_BLA"
check_config_builtin
config="CONFIG_BATMAN_ADV_DAT"
check_config_builtin
config="CONFIG_BATMAN_ADV_NC"
check_config_builtin
config="CONFIG_OPENVSWITCH"
check_config_module
config="CONFIG_OPENVSWITCH_GRE"
check_config_builtin
config="CONFIG_NETLINK_MMAP"
check_config_builtin
config="CONFIG_NETLINK_DIAG"
check_config_module
config="CONFIG_NET_MPLS_GSO"
check_config_builtin
config="CONFIG_CGROUP_NET_PRIO"
check_config_module
config="CONFIG_BPF_JIT"
check_config_builtin

#
# CAN Device Drivers
#
config="CONFIG_CAN_VCAN"
check_config_module
config="CONFIG_CAN_SLCAN"
check_config_module
config="CONFIG_CAN_TI_HECC"
check_config_module
config="CONFIG_CAN_MCP251X"
check_config_module

#
# CAN USB interfaces
#
config="CONFIG_CAN_EMS_USB"
check_config_module
config="CONFIG_CAN_ESD_USB2"
check_config_module
config="CONFIG_CAN_KVASER_USB"
check_config_module
config="CONFIG_CAN_PEAK_USB"
check_config_module
config="CONFIG_CAN_8DEV_USB"
check_config_module

#
# Bluetooth device drivers
#
config="CONFIG_AF_RXRPC"
check_config_module
config="CONFIG_RFKILL_LEDS"
check_config_builtin
config="CONFIG_CEPH_LIB"
check_config_module

#
# Generic Driver Options
#
config="CONFIG_UEVENT_HELPER_PATH"
value=""
check_config_value

config="CONFIG_EXTRA_FIRMWARE"
value="\"am335x-pm-firmware.elf am335x-bone-scale-data.bin am335x-evm-scale-data.bin am43x-evm-scale-data.bin\""
check_config_value

config="CONFIG_EXTRA_FIRMWARE_DIR"
value="\"firmware\""
check_config_value

config="CONFIG_FW_LOADER_USER_HELPER"
check_config_disable

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
# Argus cape driver for beaglebone black
#
config="CONFIG_CAPE_BONE_ARGUS"
check_config_builtin
config="CONFIG_BEAGLEBONE_PINMUX_HELPER"
check_config_builtin

#
# Controllers with non-SFF native interface
#
config="CONFIG_BLK_DEV_MD"
check_config_module
config="CONFIG_BCACHE"
check_config_module
config="CONFIG_BLK_DEV_DM_BUILTIN"
check_config_builtin
config="CONFIG_BLK_DEV_DM"
check_config_module

#
# USB Network Adapters
#
config="CONFIG_AT76C50X_USB"
check_config_module
config="CONFIG_USB_ZD1201"
check_config_module
config="CONFIG_RTL8187"
check_config_module
config="CONFIG_RTL8187_LEDS"
check_config_builtin
config="CONFIG_ATH_COMMON"
check_config_module
config="CONFIG_ATH_CARDS"
check_config_module
config="CONFIG_ATH9K_HW"
check_config_module
config="CONFIG_ATH9K_COMMON"
check_config_module
config="CONFIG_ATH9K_BTCOEX_SUPPORT"
check_config_builtin
config="CONFIG_ATH9K_HTC"
check_config_module
config="CONFIG_CARL9170"
check_config_module
config="CONFIG_CARL9170_LEDS"
check_config_builtin
config="CONFIG_CARL9170_WPC"
check_config_builtin
config="CONFIG_AR5523"
check_config_module
config="CONFIG_ATH10K"
check_config_module
config="CONFIG_WCN36XX"
check_config_module

config="CONFIG_P54_COMMON"
check_config_module
config="CONFIG_P54_USB"
check_config_module
config="CONFIG_P54_LEDS"
check_config_builtin
config="CONFIG_RT2X00"
check_config_module
config="CONFIG_RT2500USB"
check_config_module
config="CONFIG_RT73USB"
check_config_module
config="CONFIG_RT2800USB"
check_config_module
config="CONFIG_RT2800USB_RT33XX"
check_config_builtin
config="CONFIG_RT2800USB_RT35XX"
check_config_builtin
config="CONFIG_RT2800USB_RT3573"
check_config_builtin
config="CONFIG_RT2800USB_RT53XX"
check_config_builtin
config="CONFIG_RT2800USB_RT55XX"
check_config_builtin
config="CONFIG_RT2800_LIB"
check_config_module
config="CONFIG_RT2X00_LIB_USB"
check_config_module
config="CONFIG_RT2X00_LIB"
check_config_module
config="CONFIG_RT2X00_LIB_FIRMWARE"
check_config_builtin
config="CONFIG_RT2X00_LIB_CRYPTO"
check_config_builtin
config="CONFIG_RT2X00_LIB_LEDS"
check_config_builtin
config="CONFIG_RTL8192CU"
check_config_module
config="CONFIG_RTLWIFI"
check_config_module
config="CONFIG_RTLWIFI_USB"
check_config_module
config="CONFIG_RTLWIFI_DEBUG"
check_config_disable
config="CONFIG_RTL8192C_COMMON"
check_config_module
config="CONFIG_ZD1211RW"
check_config_module

#
# Input Device Drivers
#

#EDT_FT5X06 didn't work as a module...
config="CONFIG_TOUCHSCREEN_EDT_FT5X06"
check_config_builtin

#
# Non-8250 serial port support
#
config="CONFIG_HW_RANDOM_TPM"
check_config_module
config="CONFIG_TCG_TPM"
check_config_module
config="CONFIG_TCG_TIS_I2C_ATMEL"
check_config_module

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
config="CONFIG_I2C_GPIO"
check_config_module

#
# SPI Master Controller Drivers
#
config="CONFIG_SPI_BITBANG"
check_config_module
config="CONFIG_SPI_GPIO"
check_config_module

#
# Pin controllers
#
config="CONFIG_PINCTRL_PALMAS"
check_config_builtin
config="CONFIG_DEBUG_GPIO"
check_config_disable

#
# MODULbus GPIO expanders:
#
config="CONFIG_GPIO_PALMAS"
check_config_builtin

#
# Multimedia core support
#
config="CONFIG_MEDIA_ANALOG_TV_SUPPORT"
check_config_builtin
config="CONFIG_MEDIA_DIGITAL_TV_SUPPORT"
check_config_builtin
config="CONFIG_MEDIA_RADIO_SUPPORT"
check_config_builtin
config="CONFIG_MEDIA_RC_SUPPORT"
check_config_builtin

#
# Media drivers
#
config="CONFIG_LIRC"
check_config_module
config="CONFIG_IR_LIRC_CODEC"
check_config_module
config="CONFIG_RC_DEVICES"
check_config_builtin
config="CONFIG_RC_ATI_REMOTE"
check_config_module
config="CONFIG_IR_IMON"
check_config_module
config="CONFIG_IR_MCEUSB"
check_config_module
config="CONFIG_IR_REDRAT3"
check_config_module
config="CONFIG_IR_STREAMZAP"
check_config_module
config="CONFIG_IR_IGUANA"
check_config_module
config="CONFIG_IR_TTUSBIR"
check_config_module
config="CONFIG_RC_LOOPBACK"
check_config_module
config="CONFIG_IR_GPIO_CIR"
check_config_module

#
# Webcam devices
#

config="CONFIG_USB_M5602"
check_config_module
config="CONFIG_USB_STV06XX"
check_config_module
config="CONFIG_USB_GL860"
check_config_module
config="CONFIG_USB_GSPCA_BENQ"
check_config_module
config="CONFIG_USB_GSPCA_CONEX"
check_config_module
config="CONFIG_USB_GSPCA_CPIA1"
check_config_module
config="CONFIG_USB_GSPCA_ETOMS"
check_config_module
config="CONFIG_USB_GSPCA_FINEPIX"
check_config_module
config="CONFIG_USB_GSPCA_JEILINJ"
check_config_module
config="CONFIG_USB_GSPCA_JL2005BCD"
check_config_module
config="CONFIG_USB_GSPCA_KINECT"
check_config_module
config="CONFIG_USB_GSPCA_KONICA"
check_config_module
config="CONFIG_USB_GSPCA_MARS"
check_config_module
config="CONFIG_USB_GSPCA_MR97310A"
check_config_module
config="CONFIG_USB_GSPCA_NW80X"
check_config_module
config="CONFIG_USB_GSPCA_OV519"
check_config_module
config="CONFIG_USB_GSPCA_OV534"
check_config_module
config="CONFIG_USB_GSPCA_OV534_9"
check_config_module
config="CONFIG_USB_GSPCA_PAC207"
check_config_module
config="CONFIG_USB_GSPCA_PAC7302"
check_config_module
config="CONFIG_USB_GSPCA_PAC7311"
check_config_module
config="CONFIG_USB_GSPCA_SE401"
check_config_module
config="CONFIG_USB_GSPCA_SN9C2028"
check_config_module
config="CONFIG_USB_GSPCA_SN9C20X"
check_config_module
config="CONFIG_USB_GSPCA_SONIXB"
check_config_module
config="CONFIG_USB_GSPCA_SONIXJ"
check_config_module
config="CONFIG_USB_GSPCA_SPCA500"
check_config_module
config="CONFIG_USB_GSPCA_SPCA501"
check_config_module
config="CONFIG_USB_GSPCA_SPCA505"
check_config_module
config="CONFIG_USB_GSPCA_SPCA506"
check_config_module
config="CONFIG_USB_GSPCA_SPCA508"
check_config_module
config="CONFIG_USB_GSPCA_SPCA561"
check_config_module
config="CONFIG_USB_GSPCA_SPCA1528"
check_config_module
config="CONFIG_USB_GSPCA_SQ905"
check_config_module
config="CONFIG_USB_GSPCA_SQ905C"
check_config_module
config="CONFIG_USB_GSPCA_SQ930X"
check_config_module
config="CONFIG_USB_GSPCA_STK014"
check_config_module
config="CONFIG_USB_GSPCA_STK1135"
check_config_module
config="CONFIG_USB_GSPCA_STV0680"
check_config_module
config="CONFIG_USB_GSPCA_SUNPLUS"
check_config_module
config="CONFIG_USB_GSPCA_T613"
check_config_module
config="CONFIG_USB_GSPCA_TOPRO"
check_config_module
config="CONFIG_USB_GSPCA_TV8532"
check_config_module
config="CONFIG_USB_GSPCA_VC032X"
check_config_module
config="CONFIG_USB_GSPCA_VICAM"
check_config_module
config="CONFIG_USB_GSPCA_XIRLINK_CIT"
check_config_module
config="CONFIG_USB_GSPCA_ZC3XX"
check_config_module
config="CONFIG_USB_PWC"
check_config_module
config="CONFIG_USB_PWC_INPUT_EVDEV"
check_config_builtin
config="CONFIG_VIDEO_CPIA2"
check_config_module
config="CONFIG_USB_ZR364XX"
check_config_module
config="CONFIG_USB_STKWEBCAM"
check_config_module
config="CONFIG_USB_S2255"
check_config_module
config="CONFIG_VIDEO_USBTV"
check_config_module

#
# Analog TV USB devices
#
config="CONFIG_VIDEO_PVRUSB2"
check_config_module
config="CONFIG_VIDEO_PVRUSB2_SYSFS"
check_config_builtin
config="CONFIG_VIDEO_PVRUSB2_DVB"
check_config_builtin
config="CONFIG_VIDEO_HDPVR"
check_config_module
config="CONFIG_VIDEO_TLG2300"
check_config_module
config="CONFIG_VIDEO_USBVISION"
check_config_module
config="CONFIG_VIDEO_STK1160_COMMON"
check_config_module
config="CONFIG_VIDEO_STK1160_AC97"
check_config_builtin
config="CONFIG_VIDEO_STK1160"
check_config_module

#
# Analog/digital TV USB devices
#
config="CONFIG_VIDEO_AU0828"
check_config_module
config="CONFIG_VIDEO_AU0828_V4L2"
check_config_builtin
config="CONFIG_VIDEO_CX231XX"
check_config_module
config="CONFIG_VIDEO_CX231XX_RC"
check_config_builtin
config="CONFIG_VIDEO_CX231XX_ALSA"
check_config_module
config="CONFIG_VIDEO_CX231XX_DVB"
check_config_module
config="CONFIG_VIDEO_TM6000"
check_config_module
config="CONFIG_VIDEO_TM6000_ALSA"
check_config_module
config="CONFIG_VIDEO_TM6000_DVB"
check_config_module

#
# Digital TV USB devices
#
config="CONFIG_DVB_USB"
check_config_module
config="CONFIG_DVB_USB_A800"
check_config_module
config="CONFIG_DVB_USB_DIBUSB_MB"
check_config_module
config="CONFIG_DVB_USB_DIBUSB_MC"
check_config_module
config="CONFIG_DVB_USB_DIB0700"
check_config_module
config="CONFIG_DVB_USB_UMT_010"
check_config_module
config="CONFIG_DVB_USB_CXUSB"
check_config_module
config="CONFIG_DVB_USB_M920X"
check_config_module
config="CONFIG_DVB_USB_DIGITV"
check_config_module
config="CONFIG_DVB_USB_VP7045"
check_config_module
config="CONFIG_DVB_USB_VP702X"
check_config_module
config="CONFIG_DVB_USB_GP8PSK"
check_config_module
config="CONFIG_DVB_USB_NOVA_T_USB2"
check_config_module
config="CONFIG_DVB_USB_TTUSB2"
check_config_module
config="CONFIG_DVB_USB_DTT200U"
check_config_module
config="CONFIG_DVB_USB_OPERA1"
check_config_module
config="CONFIG_DVB_USB_AF9005"
check_config_module
config="CONFIG_DVB_USB_AF9005_REMOTE"
check_config_module
config="CONFIG_DVB_USB_PCTV452E"
check_config_module
config="CONFIG_DVB_USB_DW2102"
check_config_module
config="CONFIG_DVB_USB_CINERGY_T2"
check_config_module
config="CONFIG_DVB_USB_DTV5100"
check_config_module
config="CONFIG_DVB_USB_FRIIO"
check_config_module
config="CONFIG_DVB_USB_AZ6027"
check_config_module
config="CONFIG_DVB_USB_TECHNISAT_USB2"
check_config_module

config="CONFIG_DVB_USB_V2"
check_config_module
config="CONFIG_DVB_USB_AF9015"
check_config_module
config="CONFIG_DVB_USB_AF9035"
check_config_module
config="CONFIG_DVB_USB_ANYSEE"
check_config_module
config="CONFIG_DVB_USB_AU6610"
check_config_module
config="CONFIG_DVB_USB_AZ6007"
check_config_module
config="CONFIG_DVB_USB_CE6230"
check_config_module
config="CONFIG_DVB_USB_EC168"
check_config_module
config="CONFIG_DVB_USB_GL861"
check_config_module
config="CONFIG_DVB_USB_IT913X"
check_config_module
config="CONFIG_DVB_USB_LME2510"
check_config_module
config="CONFIG_DVB_USB_MXL111SF"
check_config_module
config="CONFIG_DVB_USB_RTL28XXU"
check_config_module
config="CONFIG_SMS_USB_DRV"
check_config_module
config="CONFIG_DVB_B2C2_FLEXCOP_USB"
check_config_module

#
# Webcam, TV (analog/digital) USB devices
#
config="CONFIG_VIDEO_EM28XX"
check_config_module
config="CONFIG_VIDEO_EM28XX_V4L2"
check_config_module
config="CONFIG_VIDEO_EM28XX_ALSA"
check_config_module
config="CONFIG_VIDEO_EM28XX_DVB"
check_config_module
config="CONFIG_VIDEO_EM28XX_RC"
check_config_module

#
# Supported MMC/SDIO adapters
#
config="CONFIG_RADIO_TEA575X"
check_config_module
config="CONFIG_RADIO_SI470X"
check_config_builtin
config="CONFIG_USB_SI470X"
check_config_module
config="CONFIG_I2C_SI470X"
check_config_module
config="CONFIG_RADIO_SI4713"
check_config_module
config="CONFIG_USB_SI4713"
check_config_module
config="CONFIG_PLATFORM_SI4713"
check_config_module
config="CONFIG_I2C_SI4713"
check_config_module
config="CONFIG_USB_MR800"
check_config_module
config="CONFIG_USB_DSBR"
check_config_module
config="CONFIG_RADIO_SHARK"
check_config_module
config="CONFIG_RADIO_SHARK2"
check_config_module
config="CONFIG_USB_KEENE"
check_config_module
config="CONFIG_USB_RAREMONO"
check_config_module
config="CONFIG_USB_MA901"
check_config_module
config="CONFIG_RADIO_TEA5764"
check_config_module
config="CONFIG_RADIO_SAA7706H"
check_config_module
config="CONFIG_RADIO_TEF6862"
check_config_module

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
config="CONFIG_MEDIA_SUBDRV_AUTOSELECT"
check_config_disable

#
# Direct Rendering Manager
#
config="CONFIG_FB_OMAP2"
check_config_disable
config="CONFIG_BACKLIGHT_CLASS_DEVICE"
check_config_builtin
config="CONFIG_BACKLIGHT_GPIO"
check_config_builtin


#
# Console display driver support
#
config="CONFIG_SND_USB_UA101"
check_config_module
config="CONFIG_SND_USB_CAIAQ"
check_config_module
config="CONFIG_SND_USB_CAIAQ_INPUT"
check_config_builtin
config="CONFIG_SND_USB_6FIRE"
check_config_module
config="CONFIG_SND_USB_HIFACE"
check_config_module

#
# HID support
#
config="CONFIG_HID_BATTERY_STRENGTH"
check_config_builtin
config="CONFIG_HIDRAW"
check_config_builtin
config="CONFIG_UHID"
check_config_builtin

#
# Special HID drivers
#
config="CONFIG_HID_A4TECH"
check_config_builtin
config="CONFIG_HID_ACRUX"
check_config_module
config="CONFIG_HID_ACRUX_FF"
check_config_builtin
config="CONFIG_HID_APPLE"
check_config_builtin
config="CONFIG_HID_APPLEIR"
check_config_module
config="CONFIG_HID_AUREAL"
check_config_module
config="CONFIG_HID_BELKIN"
check_config_builtin
config="CONFIG_HID_CHERRY"
check_config_builtin
config="CONFIG_HID_CHICONY"
check_config_builtin
config="CONFIG_HID_PRODIKEYS"
check_config_module
config="CONFIG_HID_CYPRESS"
check_config_builtin
config="CONFIG_HID_DRAGONRISE"
check_config_module
config="CONFIG_DRAGONRISE_FF"
check_config_builtin
config="CONFIG_HID_EMS_FF"
check_config_module
config="CONFIG_HID_ELECOM"
check_config_module
config="CONFIG_HID_ELO"
check_config_module
config="CONFIG_HID_EZKEY"
check_config_builtin
config="CONFIG_HID_HOLTEK"
check_config_module
config="CONFIG_HOLTEK_FF"
check_config_builtin
config="CONFIG_HID_HUION"
check_config_module
config="CONFIG_HID_KEYTOUCH"
check_config_module
config="CONFIG_HID_KYE"
check_config_module
config="CONFIG_HID_UCLOGIC"
check_config_module
config="CONFIG_HID_WALTOP"
check_config_module
config="CONFIG_HID_GYRATION"
check_config_module
config="CONFIG_HID_ICADE"
check_config_module
config="CONFIG_HID_TWINHAN"
check_config_module
config="CONFIG_HID_KENSINGTON"
check_config_builtin
config="CONFIG_HID_LCPOWER"
check_config_module
config="CONFIG_HID_LOGITECH"
check_config_builtin
config="CONFIG_HID_LOGITECH_DJ"
check_config_module
config="CONFIG_LOGITECH_FF"
check_config_builtin
config="CONFIG_LOGIRUMBLEPAD2_FF"
check_config_builtin
config="CONFIG_LOGIG940_FF"
check_config_builtin
config="CONFIG_LOGIWHEELS_FF"
check_config_builtin
config="CONFIG_HID_MAGICMOUSE"
check_config_module
config="CONFIG_HID_MICROSOFT"
check_config_builtin
config="CONFIG_HID_MONTEREY"
check_config_builtin
config="CONFIG_HID_MULTITOUCH"
check_config_module
config="CONFIG_HID_NTRIG"
check_config_module
config="CONFIG_HID_ORTEK"
check_config_module
config="CONFIG_HID_PANTHERLORD"
check_config_module
config="CONFIG_PANTHERLORD_FF"
check_config_builtin
config="CONFIG_HID_PETALYNX"
check_config_module
config="CONFIG_HID_PICOLCD"
check_config_module
config="CONFIG_HID_PICOLCD_FB"
check_config_builtin
config="CONFIG_HID_PICOLCD_BACKLIGHT"
check_config_builtin
config="CONFIG_HID_PICOLCD_LEDS"
check_config_builtin
config="CONFIG_HID_PRIMAX"
check_config_module
config="CONFIG_HID_ROCCAT"
check_config_module
config="CONFIG_HID_SAITEK"
check_config_module
config="CONFIG_HID_SAMSUNG"
check_config_module
config="CONFIG_HID_SONY"
check_config_module
config="CONFIG_SONY_FF"
check_config_builtin
config="CONFIG_HID_SPEEDLINK"
check_config_module
config="CONFIG_HID_STEELSERIES"
check_config_module
config="CONFIG_HID_SUNPLUS"
check_config_module
config="CONFIG_HID_GREENASIA"
check_config_module
config="CONFIG_GREENASIA_FF"
check_config_builtin
config="CONFIG_HID_SMARTJOYPLUS"
check_config_module
config="CONFIG_SMARTJOYPLUS_FF"
check_config_builtin
config="CONFIG_HID_TIVO"
check_config_module
config="CONFIG_HID_TOPSEED"
check_config_module
config="CONFIG_HID_THINGM"
check_config_module
config="CONFIG_HID_THRUSTMASTER"
check_config_module
config="CONFIG_THRUSTMASTER_FF"
check_config_builtin
config="CONFIG_HID_WACOM"
check_config_module
config="CONFIG_HID_WIIMOTE"
check_config_module
config="CONFIG_HID_XINMO"
check_config_module
config="CONFIG_HID_ZEROPLUS"
check_config_module
config="CONFIG_ZEROPLUS_FF"
check_config_builtin
config="CONFIG_HID_ZYDACRON"
check_config_module
config="CONFIG_HID_SENSOR_HUB"
check_config_module

#
# USB HID support
#
config="CONFIG_HID_PID"
check_config_builtin
config="CONFIG_USB_HIDDEV"
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
config="CONFIG_USB_F_EEM"
check_config_module
config="CONFIG_USB_ETH_EEM"
check_config_builtin
config="CONFIG_USB_G_WEBCAM"
check_config_module

#
# STAGING
#
config="CONFIG_STAGING"
check_config_builtin

#
# Android
#
config="CONFIG_ANDROID"
check_config_builtin
config="CONFIG_ANDROID_BINDER_IPC"
check_config_builtin
config="CONFIG_ASHMEM"
check_config_builtin
config="CONFIG_ANDROID_LOGGER"
check_config_module
config="CONFIG_ANDROID_TIMED_GPIO"
check_config_module
config="CONFIG_ANDROID_INTF_ALARM_DEV"
check_config_builtin
config="CONFIG_SYNC"
check_config_builtin
config="CONFIG_SW_SYNC"
check_config_disable

config="CONFIG_ION"
check_config_builtin

#
# Remoteproc drivers
#
config="CONFIG_PRUSS_REMOTEPROC"
check_config_builtin

#
# Rpmsg drivers
#
config="CONFIG_PM_DEVFREQ"
check_config_builtin

#
# Extcon Device Drivers
#
config="CONFIG_MEMORY"
check_config_builtin
config="CONFIG_TI_EMIF"
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
config="CONFIG_EXT4_FS_POSIX_ACL"
check_config_builtin
config="CONFIG_EXT4_FS_SECURITY"
check_config_builtin
config="CONFIG_REISERFS_FS"
check_config_module
config="CONFIG_REISERFS_FS_XATTR"
check_config_builtin
config="CONFIG_REISERFS_FS_POSIX_ACL"
check_config_builtin
config="CONFIG_REISERFS_FS_SECURITY"
check_config_builtin
config="CONFIG_JFS_FS"
check_config_module
config="CONFIG_JFS_POSIX_ACL"
check_config_builtin
config="CONFIG_JFS_SECURITY"
check_config_builtin
config="CONFIG_XFS_FS"
check_config_builtin
config="CONFIG_XFS_QUOTA"
check_config_builtin
config="CONFIG_XFS_POSIX_ACL"
check_config_builtin
config="CONFIG_XFS_RT"
check_config_builtin
config="CONFIG_GFS2_FS"
check_config_module
config="CONFIG_OCFS2_FS"
check_config_module
config="CONFIG_OCFS2_FS_O2CB"
check_config_module
config="CONFIG_OCFS2_FS_STATS"
check_config_builtin
config="CONFIG_OCFS2_DEBUG_MASKLOG"
check_config_builtin
config="CONFIG_BTRFS_FS"
check_config_builtin
config="CONFIG_BTRFS_FS_POSIX_ACL"
check_config_builtin
config="CONFIG_NILFS2_FS"
check_config_module
config="CONFIG_FANOTIFY"
check_config_builtin
config="CONFIG_FANOTIFY_ACCESS_PERMISSIONS"
check_config_builtin
config="CONFIG_QUOTA_NETLINK_INTERFACE"
check_config_builtin
config="CONFIG_QUOTA_TREE"
check_config_module
config="CONFIG_QFMT_V1"
check_config_module
config="CONFIG_QFMT_V2"
check_config_module
config="CONFIG_AUTOFS4_FS"
check_config_builtin
config="CONFIG_FUSE_FS"
check_config_builtin
config="CONFIG_CUSE"
check_config_module

#
# Caches
#
config="CONFIG_FSCACHE"
check_config_module
config="CONFIG_FSCACHE_STATS"
check_config_builtin
config="CONFIG_CACHEFILES"
check_config_module

#
# DOS/FAT/NT Filesystems
#
config="CONFIG_NTFS_FS"
check_config_module
config="CONFIG_NTFS_DEBUG"
check_config_disable
config="CONFIG_NTFS_RW"
check_config_builtin

#
# Pseudo filesystems
#
config="CONFIG_TMPFS_POSIX_ACL"
check_config_builtin
config="CONFIG_TMPFS_XATTR"
check_config_builtin
config="CONFIG_CONFIGFS_FS"
check_config_builtin
config="CONFIG_ECRYPT_FS"
check_config_module

config="CONFIG_LOGFS"
check_config_module
config="CONFIG_CRAMFS"
check_config_module
config="CONFIG_SQUASHFS"
check_config_module
config="CONFIG_SQUASHFS_FILE_CACHE"
check_config_builtin
config="CONFIG_SQUASHFS_DECOMP_SINGLE"
check_config_builtin
config="CONFIG_SQUASHFS_XATTR"
check_config_builtin
config="CONFIG_SQUASHFS_ZLIB"
check_config_builtin
config="CONFIG_SQUASHFS_LZO"
check_config_builtin
config="CONFIG_SQUASHFS_XZ"
check_config_builtin
config="CONFIG_VXFS_FS"
check_config_module
config="CONFIG_MINIX_FS"
check_config_module
config="CONFIG_OMFS_FS"
check_config_module
config="CONFIG_QNX4FS_FS"
check_config_module
config="CONFIG_QNX6FS_FS"
check_config_module
config="CONFIG_ROMFS_FS"
check_config_module
config="CONFIG_ROMFS_BACKED_BY_BOTH"
check_config_builtin
config="CONFIG_ROMFS_ON_BLOCK"
check_config_builtin
config="CONFIG_ROMFS_ON_MTD"
check_config_builtin
config="CONFIG_SYSV_FS"
check_config_module
config="CONFIG_UFS_FS"
check_config_module

config="CONFIG_F2FS_FS"
check_config_builtin
config="CONFIG_F2FS_STAT_FS"
check_config_builtin
config="CONFIG_F2FS_FS_XATTR"
check_config_builtin
config="CONFIG_F2FS_FS_POSIX_ACL"
check_config_builtin
config="CONFIG_F2FS_FS_SECURITY"
check_config_builtin

config="CONFIG_NFS_SWAP"
check_config_builtin

config="CONFIG_SUNRPC_SWAP"
check_config_builtin
config="CONFIG_SUNRPC_DEBUG"
check_config_builtin

config="CONFIG_CEPH_FS"
check_config_module
config="CONFIG_CEPH_FS_POSIX_ACL"
check_config_builtin

config="CONFIG_NCP_FS"
check_config_module
config="CONFIG_NCPFS_PACKET_SIGNING"
check_config_builtin
config="CONFIG_NCPFS_IOCTL_LOCKING"
check_config_builtin
config="CONFIG_NCPFS_STRONG"
check_config_builtin
config="CONFIG_NCPFS_NFS_NS"
check_config_builtin
config="CONFIG_NCPFS_OS2_NS"
check_config_builtin
config="CONFIG_NCPFS_NLS"
check_config_builtin
config="CONFIG_NCPFS_EXTRAS"
check_config_builtin
config="CONFIG_CODA_FS"
check_config_module
config="CONFIG_AFS_FS"
check_config_module
config="CONFIG_AFS_FSCACHE"
check_config_builtin

config="CONFIG_CIFS"
check_config_module
config="CONFIG_CIFS_WEAK_PW_HASH"
check_config_builtin
config="CONFIG_CIFS_UPCALL"
check_config_builtin
config="CONFIG_CIFS_XATTR"
check_config_builtin
config="CONFIG_CIFS_POSIX"
check_config_builtin
config="CONFIG_CIFS_ACL"
check_config_builtin
config="CONFIG_CIFS_DEBUG"
check_config_builtin
config="CONFIG_CIFS_DFS_UPCALL"
check_config_builtin
config="CONFIG_CIFS_SMB2"
check_config_builtin
config="CONFIG_CIFS_FSCACHE"
check_config_builtin
config="CONFIG_NLS_UTF8"
check_config_module

#
# printk and dmesg options
#
config="CONFIG_DYNAMIC_DEBUG"
check_config_builtin

#
# Compile-time checks and compiler options
#
config="CONFIG_DEBUG_INFO"
check_config_disable

#
# Runtime Testing
#
config="CONFIG_ARM_UNWIND"
check_config_disable

#
