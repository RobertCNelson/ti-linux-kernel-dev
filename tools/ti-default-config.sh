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
CONFIG_BACKLIGHT_PWM=y

config="CONFIG_BACKLIGHT_PWM"
check_config_builtin

CONFIG_DRM=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_GEM_CMA_HELPER=y
CONFIG_DRM_KMS_CMA_HELPER=y
CONFIG_DRM_I2C_NXP_TDA998X=y
CONFIG_DRM_TILCDC=y
CONFIG_DRM_OMAP=y
CONFIG_DRM_OMAP_NUM_CRTCS=2

config="CONFIG_DRM"
check_config_builtin
config="CONFIG_DRM_KMS_HELPER"
check_config_builtin
config="CONFIG_DRM_KMS_FB_HELPER"
check_config_builtin
config="CONFIG_DRM_GEM_CMA_HELPER"
check_config_builtin
config="CONFIG_DRM_KMS_CMA_HELPER"
check_config_builtin
config="CONFIG_DRM_I2C_NXP_TDA998X"
check_config_builtin
config="CONFIG_DRM_TILCDC"
check_config_builtin
config="CONFIG_DRM_OMAP"
check_config_builtin
config="CONFIG_DRM_OMAP_NUM_CRTCS"
value="2"
check_config_value

CONFIG_DISPLAY_PANEL_TLC59108=y
CONFIG_OMAP5_DSS_HDMI=y
CONFIG_DISPLAY_CONNECTOR_HDMI=y
CONFIG_DISPLAY_DRA7EVM_ENCODER_TPD12S015=y
CONFIG_DISPLAY_ENCODER_TPD12S015=y
CONFIG_DISPLAY_ENCODER_SII9022=y

config="CONFIG_DISPLAY_PANEL_TLC59108"
check_config_builtin
config="CONFIG_OMAP5_DSS_HDMI"
check_config_builtin
config="CONFIG_DISPLAY_CONNECTOR_HDMI"
check_config_builtin
config="CONFIG_DISPLAY_DRA7EVM_ENCODER_TPD12S015"
check_config_builtin
config="CONFIG_DISPLAY_ENCODER_TPD12S015"
check_config_builtin
config="CONFIG_DISPLAY_ENCODER_SII9022"
check_config_builtin

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
check_config_builtin
config="CONFIG_SND"
check_config_builtin
config="CONFIG_SND_SOC"
check_config_builtin
config="CONFIG_SND_OMAP_SOC"
check_config_builtin
config="CONFIG_SND_EDMA_SOC"
check_config_builtin
config="CONFIG_SND_DAVINCI_SOC_MCASP"
check_config_module
config="CONFIG_SND_AM335X_SOC_NXPTDA_EVM"
check_config_module
config="CONFIG_SND_AM33XX_SOC_EVM"
check_config_module
config="CONFIG_SND_SIMPLE_CARD"
check_config_module
config="CONFIG_SND_OMAP_SOC_DRA7EVM"
check_config_builtin
config="CONFIG_SND_SOC_TLV320AIC31XX"
check_config_module
config="CONFIG_SND_SOC_TLV320AIC3X"
check_config_module

CONFIG_OMAP2_DSS=y
CONFIG_OMAP2_DSS_INIT=y

config="CONFIG_OMAP2_DSS"
check_config_builtin
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

#config="CONFIG_PREEMPT_NONE"
#check_config_disable
config="CONFIG_PREEMPT_VOLUNTARY"
check_config_builtin
#config="CONFIG_PREEMPT"
#check_config_builtin

config="CONFIG_JUMP_LABEL"
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

config="CONFIG_PCI"
check_config_builtin
config="CONFIG_PCI_DRA7XX"
check_config_builtin

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
config="CONFIG_OMAP_IOMMU_DEBUG"
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
config="CONFIG_CPU_FREQ_GOV_POWERSAVE"
check_config_module
config="CONFIG_CPU_FREQ_GOV_USERSPACE"
check_config_module
config="CONFIG_CPU_FREQ_GOV_CONSERVATIVE"
check_config_module

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
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=n
CONFIG_CRYPTO_TEST=m
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

CONFIG_NL80211_TESTMODE=y
CONFIG_RFKILL=y
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_CCM=y

config="CONFIG_NL80211_TESTMODE"
check_config_builtin
config="CONFIG_RFKILL"
check_config_builtin
config="CONFIG_CRYPTO_TEST"
check_config_module
config="CONFIG_CRYPTO_ECB"
check_config_builtin
config="CONFIG_CRYPTO_ARC4"
check_config_builtin
config="CONFIG_CRYPTO_CCM"
check_config_builtin

CONFIG_NF_CONNTRACK=y
CONFIG_NF_CONNTRACK_IPV4=y
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_FILTER=y
CONFIG_NF_NAT_IPV4=y
CONFIG_IP_NF_TARGET_MASQUERADE=y

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
