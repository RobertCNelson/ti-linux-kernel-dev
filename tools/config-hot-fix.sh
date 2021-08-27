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

config_enable_special () {
	test_module=$(cat .config | grep ${config} || true)
	if [ "x${test_module}" = "x# ${config} is not set" ] ; then
		echo "Setting: ${config}=y"
		sed -i -e 's:# '$config' is not set:'$config'=y:g' .config
	fi
	if [ "x${test_module}" = "x${config}=m" ] ; then
		echo "Setting: ${config}=y"
		sed -i -e 's:'$config'=m:'$config'=y:g' .config
	fi
}

config_module_special () {
	test_module=$(cat .config | grep ${config} || true)
	if [ "x${test_module}" = "x# ${config} is not set" ] ; then
		echo "Setting: ${config}=m"
		sed -i -e 's:# '$config' is not set:'$config'=m:g' .config
	else
		echo "$config=m" >> .config
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

#Docker.io
config="CONFIG_NETFILTER_XT_MATCH_IPVS"; config_enable
config="CONFIG_CGROUP_BPF"; config_enable

config="CONFIG_BLK_DEV_THROTTLING"; config_enable
config="CONFIG_NET_CLS_CGROUP"; config_enable
config="CONFIG_CGROUP_NET_PRIO"; config_enable
config="CONFIG_IP_NF_TARGET_REDIRECT"; config_enable
config="CONFIG_IP_VS"; config_enable
config="CONFIG_IP_VS_NFCT"; config_enable
config="CONFIG_IP_VS_PROTO_TCP"; config_enable
config="CONFIG_IP_VS_PROTO_UDP"; config_enable
config="CONFIG_IP_VS_RR"; config_enable
config="CONFIG_SECURITY_SELINUX"; config_enable
config="CONFIG_SECURITY_APPARMOR"; config_enable
config="CONFIG_VXLAN"; config_enable
config="CONFIG_IPVLAN"; config_enable
config="CONFIG_DUMMY"; config_enable
config="CONFIG_NF_NAT_FTP"; config_enable
config="CONFIG_NF_CONNTRACK_FTP"; config_enable
config="CONFIG_NF_NAT_TFTP"; config_enable
config="CONFIG_NF_CONNTRACK_TFTP"; config_enable
config="CONFIG_DM_THIN_PROVISIONING"; config_enable

#abi="5.13.0-trunk"
#kernel="5.13.9-1~exp2"
config="CONFIG_BPF_UNPRIV_DEFAULT_OFF" ; config_enable
config="CONFIG_CGROUP_MISC" ; config_enable
config="CONFIG_RESET_ATTACK_MITIGATION" ; config_enable

#LIBCOMPOSITE built-in finally works... ;)
config="CONFIG_USB_LIBCOMPOSITE" ; config_enable
config="CONFIG_USB_F_ACM" ; config_enable
config="CONFIG_USB_F_SS_LB" ; config_enable
config="CONFIG_USB_U_SERIAL" ; config_enable
config="CONFIG_USB_U_ETHER" ; config_enable
config="CONFIG_USB_U_AUDIO" ; config_enable
config="CONFIG_USB_F_SERIAL" ; config_enable
config="CONFIG_USB_F_OBEX" ; config_enable
config="CONFIG_USB_F_NCM" ; config_enable
config="CONFIG_USB_F_ECM" ; config_enable
config="CONFIG_USB_F_PHONET" ; config_module
config="CONFIG_USB_F_EEM" ; config_enable
config="CONFIG_USB_F_SUBSET" ; config_enable
config="CONFIG_USB_F_RNDIS" ; config_enable
config="CONFIG_USB_F_MASS_STORAGE" ; config_enable
config="CONFIG_USB_F_FS" ; config_enable
config="CONFIG_USB_F_UAC1" ; config_enable
config="CONFIG_USB_F_UAC2" ; config_enable
config="CONFIG_USB_F_UVC" ; config_module
config="CONFIG_USB_F_MIDI" ; config_enable
config="CONFIG_USB_F_HID" ; config_enable
config="CONFIG_USB_F_PRINTER" ; config_enable
config="CONFIG_USB_F_TCM" ; config_module
config="CONFIG_USB_CONFIGFS" ; config_enable
config="CONFIG_USB_CONFIGFS_SERIAL" ; config_enable
config="CONFIG_USB_CONFIGFS_ACM" ; config_enable
config="CONFIG_USB_CONFIGFS_OBEX" ; config_enable
config="CONFIG_USB_CONFIGFS_NCM" ; config_enable
config="CONFIG_USB_CONFIGFS_ECM" ; config_enable
config="CONFIG_USB_CONFIGFS_ECM_SUBSET" ; config_enable
config="CONFIG_USB_CONFIGFS_RNDIS" ; config_enable
config="CONFIG_USB_CONFIGFS_EEM" ; config_enable
config="CONFIG_USB_CONFIGFS_PHONET" ; config_enable
config="CONFIG_USB_CONFIGFS_MASS_STORAGE" ; config_enable
config="CONFIG_USB_CONFIGFS_F_LB_SS" ; config_enable
config="CONFIG_USB_CONFIGFS_F_FS" ; config_enable
config="CONFIG_USB_CONFIGFS_F_UAC1" ; config_enable
config="CONFIG_USB_CONFIGFS_F_UAC2" ; config_enable
config="CONFIG_USB_CONFIGFS_F_MIDI" ; config_enable
config="CONFIG_USB_CONFIGFS_F_HID" ; config_enable
config="CONFIG_USB_CONFIGFS_F_UVC" ; config_enable
config="CONFIG_USB_CONFIGFS_F_PRINTER" ; config_enable

cd ${DIR}/
