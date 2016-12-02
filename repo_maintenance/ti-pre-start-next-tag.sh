#!/bin/sh -e

ti_git_old_release=$(cat version.sh | grep ti_git_old_release | awk -F"\"" '{print $2}')
        ti_git_pre=$(cat version.sh | grep ti_git_pre | awk -F"\"" '{print $2}')
       ti_git_post=$(cat version.sh | grep ti_git_post | awk -F"\"" '{print $2}')

sed -i -e 's:'${ti_git_old_release}':'${ti_git_post}':g' version.sh
sed -i -e 's:'${ti_git_pre}':'${ti_git_post}':g' version.sh

