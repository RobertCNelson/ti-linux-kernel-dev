#!/bin/sh -e

DIR=$PWD
repo="https://github.com/RobertCNelson/ti-linux-kernel/compare"

if [ -e ${DIR}/version.sh ]; then
	unset BRANCH
	unset KERNEL_SHA
	. ${DIR}/version.sh

	if [ ! "${BRANCH}" ] ; then
		BRANCH="master"
	fi

	git commit -a -m "merge ti: ${repo}/${ti_git_pre}...${ti_git_post}" -s
	git push origin ${BRANCH}
fi

