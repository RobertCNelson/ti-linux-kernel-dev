#!/bin/sh -e

cat_files () {
	if [ -f ./patches/git/AUFS ] ; then
		cat ./patches/git/AUFS >> /tmp/git_msg
	fi

	if [ -f ./patches/git/BBDTBS ] ; then
		cat ./patches/git/BBDTBS >> /tmp/git_msg
	fi

	if [ -f ./patches/git/CAN-ISOTP ] ; then
		cat ./patches/git/CAN-ISOTP >> /tmp/git_msg
	fi

	if [ -f ./patches/git/RT ] ; then
		cat ./patches/git/RT >> /tmp/git_msg
	fi

	if [ -f ./patches/git/TI_AMX3_CM3 ] ; then
		cat ./patches/git/TI_AMX3_CM3 >> /tmp/git_msg
	fi

	if [ -f ./patches/git/WIREGUARD ] ; then
		cat ./patches/git/WIREGUARD >> /tmp/git_msg
	fi
}

DIR=$PWD
git_bin=$(which git)

if [ -e ${DIR}/version.sh ]; then
	unset BRANCH
	unset KERNEL_TAG
	. ${DIR}/version.sh

	if [ ! "${BRANCH}" ] ; then
		BRANCH="master"
	fi

	if [ ! "${KERNEL_TAG}" ] ; then
		echo 'KERNEL_TAG undefined'
		exit
	fi

	echo "kernel v${KERNEL_TAG} rebase with rt: v${KERNEL_REL}${kernel_rt} aufs/wireguard/etc" > /tmp/git_msg
	cat_files

	${git_bin} commit -a -F /tmp/git_msg -s
	echo "log: git push origin ${BRANCH}"
	${git_bin} push origin ${BRANCH}
fi

