Cypress Wifi Linux FMAC Driver Package - README
===============================================

Package Version
---------------
v4.14.52-2018_0928


Release Date
------------
2018-09-28


Description
-----------
This is Cypress's Linux brcmfmac driver and firmware support package.
Brcmfmac is an open-source driver project.

Files in this release:
* Backports package (cypress-backports-v4.14.52-2018_0928-module-src.tar.gz)
* Firmware/clm_blob files (cypress-firmware-v4.14.52-2018_0928.tar.gz)
* Cypress fmac patch files (cypress-patch-v4.14.52-2018_0928.tar.gz)
* Device tree files (cypress-devicetree-2018_0928.tar.gz)
* hostapd/wpa_supplicant patch (cypress-hostap_2_6-2018_0928.tar.gz)
* README

For more information about the Linux brcmfmac project, see:

[brcm80211 Wireless Wiki](https://wireless.wiki.kernel.org/en/users/drivers/brcm80211)

For more information about Linux backports project, see:

[Linux Backports Project](https://backports.wiki.kernel.org/index.php/Main_Page)


Supported Features
-----------------
* Concurrent APSTA
* P2P
* Out-of-band (OOB) interrupt
* CLM download (43455/4343w/4354/4356/43012)
* Wake on Wireless LAN
* Voice enterprise (43455)
* PMF
* WPA3-personal (43455/43012)
* VSDB (43012)
* RSDB (89342/89359)

Test Environment
----------------
* ARM (MCIMX6SX-SDB)
   * Linux v4.9.88 (NXP imx_4.9.88_2.0.0_ga)
   * backports
* x86
   * Linux v4.12
   * backports


Firmware Versions
-----------------
| Chip      | FW Version    |
|-----------|---------------|
| 43455     | 7.45.173      |
| 4343W     | 7.45.98.65    |
| 4356-pcie | 7.35.180.190  |
| 4356-sdio | 7.35.349.62   |
| 4354      | 7.35.349.62   |
| 4339      | 6.37.39.92    |
| 43340     | 6.10.190.72   |
| 43362     | 5.90.247      |
| 89342     | 9.40.97       |
| 89359     | 9.40.94.1     |
| 43012     | 13.10.271.138 |


Instructions
------------
The patch files in this package are based on Linux v4.14.52, so older kernels
need use backports package. Below are examples of how to use this package
with an older kernel or linux-stable v4.14.52.

### Using backports with an older kernel (v3.1+)

Linux kernel image and cypress driver modules need to be built separately.
Below is the example of using with iMX Linux v4.9.88:

#### Build the kernel image
```bash
#1. Have the BSP kernel source available
   git clone https://source.codeaurora.org/external/imx/linux-imx
   cd linux-imx
   git checkout imx_4.9.88_2.0.0_ga
#2. Set up build environment and kernel configuration
   source /opt/poky/1.8/environment-setup-cortexa7hf-vfp-neon-poky-linux-gnueabi
   make imx_v7_defconfig
#3. Edit .config and build cfg80211 as module
#     CONFIG_CFG80211=m
#     CONFIG_BCMDHD=n
#4. Build the Linux kernel image
   make oldconfig
   make zImage -j 8
#5. The kernel image is available here
   arch/arm/boot/zImage
```

#### Build the cypress driver/backports modules
```bash
#1. Untar the Cypress backports package
    tar zxvf cypress-backports-*.tar.gz
    cd v4.14.52-backports
#2. (Native) compile local tools and generate .config (in a new terminal
#   without sourcing Yoctol toolchain settings)
    bash
    MY_KERNEL=<the 4.9.88 kernel path>
    make KLIB=$MY_KERNEL KLIB_BUILD=$MY_KERNEL defconfig-brcmfmac
#3. (Cross) compile kernel modules
    source /opt/poky/1.8/environment-setup-cortexa7hf-vfp-neon-poky-linux-gnueabi
    make KLIB=$MY_KERNEL KLIB_BUILD=$MY_KERNEL modules
#4. The kernel modules are available here
#      compat/compat.ko
#      net/wireless/cfg80211.ko
#      drivers/net/wireless/broadcom/brcm80211/brcmutil/brcmutil.ko
#      drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko
```

#### Device tree
```bash
#1. Untar the cypress devicetree package
    tar zxvf cypress-devicetree-*.tar.gz
#2. Find your board's dtb file, for example
#      cypress-devicetree/iMX6SX/4.9.88/imx6sx-sdb-btwifi-fmac.dtb
```
Note: If your board's dtb is not available in the cypress devicetree
      package, please refer to the available dts/dtsi files and create
      them for your board, then compile them for the dtb file. iMX dts
      files are located in linux-imx/arch/arm/boot/dts/ folder of the
      Linux kernel tree. Below command compiles a dtb file
```bash
    make ARCH=arm <devicetree name>.dtb
```

#### Load the cypress wifi driver
```bash
#1. Copy your boards's zImage and dtb files to the target board
    bash
    TARGET_IP=<target board IP>
    scp <dtb file> root@$TARGET_IP:/run/media/mmcblk1p1/cy.dtb
    scp <zImage file> root@$TARGET_IP:/run/media/mmcblk1p1/zImage_cy
#2. Copy firmware files to the target board
    tar zxvf cypress-firmware*.tar.gz
    scp firmware/* root@$TARGET_IP:/lib/firmware/brcm
#3. Copy your nvram file (from board vendor) to the target board and rename it
    scp <nvram file> root@$TARGET_IP:/lib/firmware/brcm/<fw name>.txt
#      (fw name is your chip's *.bin file name in the cypress firmware package)
#4. Copy cypress kernel modules to the target board
    scp <module files> root@$TARGET_IP:/lib/modules/4.9.88
#5. (iMX console) Press ctrl-c after target boot to enter u-boot and configure it
#   for the new zImage/dtb files
   env print image fdt_file
   setenv image zImage_cy
   setenv fdt_file cy.dtb
   saveenv
   env print image fdt_file
   reset
#6. (iMX console) Boot up the target board with the above zImage and insmod cypress modules
    insmod /lib/modules/4.9.88/compat.ko
    insmod /lib/modules/4.9.88/cfg80211.ko
    insmod /lib/modules/4.9.88/brcmutil.ko
    insmod /lib/modules/4.9.88/brcmfmac.ko
```
Note: More on fmac driver [firmware/nvram install](https://wireless.wiki.kernel.org/en/users/drivers/brcm80211#firmware_installation1)

### Using Linux Stable v4.14.52
```bash
#1. Download Linux stable kernel source
    wget https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/snapshot/linux-stable-4.14.52.tar.gz
    tar zxvf linux-stable-4.14.52.tar.gz
#2. In Linux root folder, untar/apply cypress patches with below bash commands
    cd linux-stable-4.14.52
    tar zxvf cypress-patch*.tar.gz
    for i in cypress-patch/*.patch; do patch -p1 < $i; done
#3. Set kernel .config and enable below options, then compile kernel image
#      CONFIG_BRCMUTIL=y
#      CONFIG_BRCMFMAC=y
#      CONFIG_BRCMFMAC_SDIO=y
#      CONFIG_BRCMFMAC_PROTO_BCDC=y
#      CONFIG_BRCMFMAC_PCIE=y
#      CONFIG_BRCMFMAC_PROTO_MSGBUF=y
#4. (optional) Backup original firmware files
    cp /lib/firmware/brcm /lib/firmware/brcm-bak -r
#5. Update firmware files in /lib/firmware/brcm
    tar zxvf cypress-firmware*.tar.gz
    cp firmware/* /lib/firmware/brcm
#6. Boot the system with the new kernel image
```



Cypress Wifi Linux FMAC Driver Package - Release Notes
======================================================

FMAC Driver Changes
-------------------
* CLM download support/fix (0001, 0009, 0032-0033)
* 4373 support (0002, 0041, 0056, 0059, 0067-0069, 0071, 0074)
* device tree related changes (0003)
* bug fixes (0004, 0006, 0010, 0045, 0066)
* 43012 support (0005, 0007, 0012-0013, 0017, 0043, 0058)
* 43455 support (0008)
* throughput enhancement (0011, 0019, 0025-0026, 0030, 0044, 0072)
* Fast roaming support (0014, 0028, 0051-0054)
* 43428 support (0015)
* AP isolation support (0016)
* Wake on Wireless LAN fix (0018, 0021-0022, 0070, 0076)
* EAP restriction setting (0020)
* 89342 support (0023)
* fcmode 2 support (0024, 0027)
* General bug fixes (0029, 0031, 0036-0038)
* WFA certification fixes (0034-0035, 0039-0040, 0042, 0057)
* RSDB (0045-0049)
* 89342/89359 support (0050, 0073)
* 4356 support (0060)
* WPA3-personal (0061-0065, 0077)
* Power saving changes (0075)


FMAC Driver Patch List
----------------------
* 0001-brcmfmac-add-CLM-download-support.patch [v4.15-rc1]
* 0002-brcmfmac-Set-F2-blksz-and-Watermark-to-256-for-4373.patch [x]
* 0003-brcmfmac-Add-sg-parameters-dts-parsing.patch
* 0004-brcmfmac-return-EPERM-when-getting-error-in-vendor-c.patch [v4.16-rc1]
* 0005-brcmfmac-Add-support-for-CYW43012-SDIO-chipset.patch
* 0006-brcmfmac-set-apsta-to-0-when-AP-starts-on-primary-in.patch
* 0007-brcmfmac-Saverestore-support-changes-for-43012.patch
* 0008-brcmfmac-Support-43455-save-restore-SR-feature-if-FW.patch [v4.16-rc1]
* 0009-brcmfmac-fix-CLM-load-error-for-legacy-chips-when-us.patch [x]
* 0010-brcmfmac-enlarge-buffer-size-of-caps-to-512-bytes.patch [v4.16-rc1]
* 0011-brcmfmac-calling-skb_orphan-before-sending-skb-to-SD.patch
* 0012-brcmfmac-43012-Update-F2-Watermark-to-0x60-to-fix-DM.patch [x]
* 0013-brcmfmac-DS1-Exit-should-re-download-the-firmware.patch
* 0014-brcmfmac-add-FT-based-AKMs-in-brcmf_set_key_mgmt-for.patch
* 0015-brcmfmac-Add-support-for-43428-SDIO-device-ID.patch [4.18-rc1]
* 0016-brcmfmac-support-AP-isolation.patch
* 0017-brcmfmac-do-not-print-ulp_sdioctrl-get-error.patch
* 0018-brcmfmac-fix-system-warning-message-during-wowl-susp.patch
* 0019-brcmfmac-add-a-module-parameter-to-set-scheduling-pr.patch [x]
* 0020-brcmfmac-make-firmware-eap_restrict-a-module-paramet.patch
* 0021-brcmfmac-Support-wake-on-ping-packet.patch
* 0022-brcmfmac-Remove-WOWL-configuration-in-disconnect-sta.patch
* 0023-brcmfmac-add-CYW89342-PCIE-device.patch
* 0024-brcmfmac-handle-compressed-tx-status-signal.patch
* 0025-revert-brcmfmac-add-a-module-parameter-to-set-schedu.patch [x]
* 0026-brcmfmac-make-setting-SDIO-workqueue-WQ_HIGHPRI-a-mo.patch [x]
* 0027-brcmfmac-add-credit-map-updating-support.patch
* 0028-brcmfmac-add-4-way-handshake-offload-detection-for-F.patch
* 0029-brcmfmac-remove-arp_hostip_clear-from-brcmf_netdev_s.patch
* 0030-brcmfmac-fix-unused-variable-building-warning-messag.patch
* 0031-brcmfmac-disable-command-decode-in-sdio_aos-for-4339.patch
* 0032-Revert-brcmfmac-fix-CLM-load-error-for-legacy-chips-.patch [x]
* 0033-brcmfmac-fix-CLM-load-error-for-legacy-chips-when-us.patch [v4.15-rc9]
* 0034-brcmfmac-set-WIPHY_FLAG_HAVE_AP_SME-flag.patch [v4.18-rc1]
* 0035-brcmfmac-P2P-CERT-6.1.9-Support-GOUT-handling-P2P-Pr.patch
* 0036-brcmfmac-only-generate-random-p2p-address-when-neede.patch
* 0037-brcmfmac-disable-command-decode-in-sdio_aos-for-4354.patch
* 0038-brcmfmac-increase-max-hanger-slots-from-1K-to-3K-in-.patch
* 0039-brcmfmac-reduce-timeout-for-action-frame-scan.patch
* 0040-brcmfmac-fix-full-timeout-waiting-for-action-frame-o.patch
* 0041-brcmfmac-4373-save-restore-support.patch
* 0042-brcmfmac-map-802.1d-priority-to-precedence-level-bas.patch
* 0043-brcmfmac-allow-GCI-core-enumuration.patch
* 0044-brcmfmac-make-firmware-frameburst-mode-a-module-para.patch
* 0045-brcmfmac-set-state-of-hanger-slot-to-FREE-when-flush.patch
* 0046-brcmfmac-add-creating-station-interface-support.patch
* 0047-brcmfmac-add-RSDB-condition-when-setting-interface-c.patch
* 0048-brcmfmac-not-set-mbss-in-vif-if-firmware-does-not-su.patch
* 0049-brcmfmac-support-the-second-p2p-connection.patch
* 0050-brcmfmac-Add-support-for-BCM4359-SDIO-chipset.patch
* 0051-cfg80211-nl80211-add-a-port-authorized-event.patch [4.15-rc1]
* 0052-nl80211-add-NL80211_ATTR_IFINDEX-to-port-authorized-.patch
* 0053-brcmfmac-send-port-authorized-event-for-802.1X-4-way.patch
* 0054-brcmfmac-send-port-authorized-event-for-FT-802.1X.patch
* 0055-brcmfmac-Support-DS1-TX-Exit-in-FMAC.patch
* 0056-brcmfmac-disable-command-decode-in-sdio_aos-for-4373.patch
* 0057-brcmfmac-add-vendor-ie-for-association-responses.patch
* 0058-brcmfmac-fix-43012-insmod-after-rmmod-in-DS1-failure.patch
* 0059-brcmfmac-Set-SDIO-F1-MesBusyCtrl-for-CYW4373.patch
* 0060-brcmfmac-add-4354-raw-pcie-device-id.patch
* 0061-nl80211-Allow-SAE-Authentication-for-NL80211_CMD_CON.patch [4.17-rc1]
* 0062-non-upstream-update-enum-nl80211_attrs-and-nl80211_e.patch [x]
* 0063-nl80211-add-WPA3-definition-for-SAE-authentication.patch
* 0064-cfg80211-add-support-for-SAE-authentication-offload.patch
* 0065-brcmfmac-add-support-for-SAE-authentication-offload.patch
* 0066-brcmfmac-fix-4339-CRC-error-under-SDIO-3.0-SDR104-mo.patch
* 0067-brcmfmac-fix-the-incorrect-return-value-in-brcmf_inf.patch
* 0068-brcmfmac-Fix-double-freeing-in-the-fmac-usb-data-pat.patch
* 0069-brcmfmac-Fix-driver-crash-on-USB-control-transfer-ti.patch
* 0070-brcmfmac-avoid-network-disconnection-during-suspend-.patch
* 0071-brcmfmac-Allow-credit-borrowing-for-all-access-categ.patch
* 0072-non-upstream-Changes-to-improve-USB-Tx-throughput.patch [x]
* 0073-non-upstream-reset-two-D11-cores-if-chip-has-two-D11.patch [x]
* 0074-brcmfmac-reset-PMU-backplane-all-cores-in-CYW4373-du.patch
* 0075-brcmfmac-introduce-module-parameter-to-configure-def.patch
* 0076-brcmfmac-configure-wowl-parameters-in-suspend-functi.patch
* 0077-brcmfmac-discard-user-space-RSNE-for-SAE-authenticat.patch

Note: [*] is the upstream tag containing the patch
      [x] means no plan to upstream


Firmware Changes
----------------
* 43455
   * --- 7.45.173 ---
   * WPA3-personal support
   * Firmware crash fix
   * Low Tx duty cycle support
   * SoftAP association fix
   * WIFI-BT coex throughput improvement
   * MFP bug fix
   * Roam time enhancement
   * --- 7.45.165 ---

* 4343W
   * --- 7.45.98.65 ---
   * Firmware crash fix
   * wowlpf feature enabled 
   * Excessive current consumption fix together operation of WLAN/BT
   * Various throughput fixes
   * --- 7.45.98.52 ---

* 4356-pcie
   * --- 7.35.180.190 ---
   * Firmware crash fix
   * MFP bug fix
   * --- 7.35.180.187 ---

* 4356-sdio
   * --- 7.35.349.62 ---

* 4354
   * --- 7.35.349.62 ---
   * Enable amsdu RX
   * RSSI computation fix
   * WIFI-BT coex throughput improvement
   * Firmware crash fix
   * --- 7.35.349.49 ---

* 4339
   * --- 6.37.39.92 ---

* 43340
   * --- 6.10.190.72 ---

* 43362
   * --- 5.90.247 ---
   * Firmware crash fix
   * --- 5.90.244 ---

* 89342
   * --- 9.40.97 ---
   * Throughput issue fix
   * AP/STA connection/ping fix
   * Fast roaming security fix
   * Firmware crash fix
   * Low Tx duty cycle support
   * RSDB extended IE fix
   * WFA 11n/11ac certification fix
   * WPS fix
   * --- 9.40.87 ---

* 89359
   * --- 9.40.94.1 ---

* 43012
   * --- 13.10.271.138 ---
   * WPA3 Personal support for 43012
   * Firmware crash fix
   * WOWLPF feature enabled
   * Qualified EXT GPIO for link loss
   * Qualified beacon loss, deauth, disassoc, net pattern with/without supplicant
   * Qualified GTKOE using both internal/external supplicant
   * Qualified ARP and DHCP lease time renewal offload
   * Added GO+STA VSDB Support
   * Added updated algorithm for beacon window
   * Added BT to WLAN wake up programming
   * Added SWDIV Enhanced by Beacon Aligned swapping
   * Updated FCREF/WLCSP nvram settings for TX board limits based on PVT results
   * Added Service DurationFix(StartFlex) request when a both_flex request is already scheduled in the current timeslot
   * Multiple Current Optimizations
   * --- 13.10.271.107 ---


Known Issues
------------
* 4354 low throughput in 5G 40/80Mhz
* 4343w/43455 softap low throughput with iMX6UL
* 89342 rate drop in 5G 80Mhz
* 4343w/43012/43362 zero stalls while running UDP bidirectional tests
* 89342 low throughput in AP+STA, STA+AP, AP+AP RSDB modes
* 43012 single 11N WMM cert issue open
