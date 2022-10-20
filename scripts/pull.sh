#!/bin/bash

DIR=$PWD

. "${DIR}/version.sh"

echo "syncing with:https://git.beagleboard.org/RobertCNelson/ti-linux-kernel-dev.git ${branch_prefix}${KERNEL_REL}${branch_postfix}"
git pull --no-edit https://git.beagleboard.org/RobertCNelson/ti-linux-kernel-dev.git ${branch_prefix}${KERNEL_REL}${branch_postfix}
