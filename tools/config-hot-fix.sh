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

cd ${DIR}/
