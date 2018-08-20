#!/bin/bash -e
#
# Copyright (c) 2009-2018 Robert Nelson <robertcnelson@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Split out, so build_kernel.sh and build_deb.sh can share..

shopt -s nullglob

. ${DIR}/version.sh
if [ -f ${DIR}/system.sh ] ; then
	. ${DIR}/system.sh
fi
git_bin=$(which git)
#git hard requirements:
#git: --no-edit

git="${git_bin} am"
#git_patchset="git://git.ti.com/ti-linux-kernel/ti-linux-kernel.git"
git_patchset="https://github.com/RobertCNelson/ti-linux-kernel.git"
#git_opts

if [ "${RUN_BISECT}" ] ; then
	git="${git_bin} apply"
fi

echo "Starting patch.sh"

git_add () {
	${git_bin} add .
	${git_bin} commit -a -m 'testing patchset'
}

start_cleanup () {
	git="${git_bin} am --whitespace=fix"
}

cleanup () {
	if [ "${number}" ] ; then
		if [ "x${wdir}" = "x" ] ; then
			${git_bin} format-patch -${number} -o ${DIR}/patches/
		else
			if [ ! -d ${DIR}/patches/${wdir}/ ] ; then
				mkdir -p ${DIR}/patches/${wdir}/
			fi
			${git_bin} format-patch -${number} -o ${DIR}/patches/${wdir}/
			unset wdir
		fi
	fi
	exit 2
}

dir () {
	wdir="$1"
	if [ -d "${DIR}/patches/$wdir" ]; then
		echo "dir: $wdir"

		if [ "x${regenerate}" = "xenable" ] ; then
			start_cleanup
		fi

		number=
		for p in "${DIR}/patches/$wdir/"*.patch; do
			${git} "$p"
			number=$(( $number + 1 ))
		done

		if [ "x${regenerate}" = "xenable" ] ; then
			cleanup
		fi
	fi
	unset wdir
}

cherrypick () {
	if [ ! -d ../patches/${cherrypick_dir} ] ; then
		mkdir -p ../patches/${cherrypick_dir}
	fi
	${git_bin} format-patch -1 ${SHA} --start-number ${num} -o ../patches/${cherrypick_dir}
	num=$(($num+1))
}

external_git () {
	git_tag="ti-linux-${KERNEL_REL}.y"
	echo "pulling: [${git_patchset} ${git_tag}]"
	${git_bin} pull --no-edit ${git_patchset} ${git_tag}
	top_of_branch=$(${git_bin} describe)
	if [ ! "x${ti_git_post}" = "x" ] ; then
		${git_bin} checkout master -f
		test_for_branch=$(${git_bin} branch --list "v${KERNEL_TAG}${BUILD}")
		if [ "x${test_for_branch}" != "x" ] ; then
			${git_bin} branch "v${KERNEL_TAG}${BUILD}" -D
		fi
		${git_bin} checkout ${ti_git_post} -b v${KERNEL_TAG}${BUILD} -f
		current_git=$(${git_bin} describe)
		echo "${current_git}"

		if [ ! "x${top_of_branch}" = "x${current_git}" ] ; then
			echo "INFO: external git repo has updates..."
		fi
	else
		echo "${top_of_branch}"
	fi
}

aufs_fail () {
	echo "aufs4 failed"
	exit 2
}

aufs4 () {
	echo "dir: aufs4"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		wget https://raw.githubusercontent.com/sfjro/aufs4-standalone/aufs${KERNEL_REL}/aufs4-kbuild.patch
		patch -p1 < aufs4-kbuild.patch || aufs_fail
		rm -rf aufs4-kbuild.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs4-kbuild' -s

		wget https://raw.githubusercontent.com/sfjro/aufs4-standalone/aufs${KERNEL_REL}/aufs4-base.patch
		patch -p1 < aufs4-base.patch || aufs_fail
		rm -rf aufs4-base.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs4-base' -s

		wget https://raw.githubusercontent.com/sfjro/aufs4-standalone/aufs${KERNEL_REL}/aufs4-mmap.patch
		patch -p1 < aufs4-mmap.patch || aufs_fail
		rm -rf aufs4-mmap.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs4-mmap' -s

		wget https://raw.githubusercontent.com/sfjro/aufs4-standalone/aufs${KERNEL_REL}/aufs4-standalone.patch
		patch -p1 < aufs4-standalone.patch || aufs_fail
		rm -rf aufs4-standalone.patch
		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs4-standalone' -s

		${git_bin} format-patch -4 -o ../patches/aufs4/

		cd ../
		if [ ! -d ./aufs4-standalone ] ; then
			${git_bin} clone -b aufs${KERNEL_REL} https://github.com/sfjro/aufs4-standalone --depth=1
		else
			rm -rf ./aufs4-standalone || true
			${git_bin} clone -b aufs${KERNEL_REL} https://github.com/sfjro/aufs4-standalone --depth=1
		fi
		cd ./KERNEL/

		cp -v ../aufs4-standalone/Documentation/ABI/testing/*aufs ./Documentation/ABI/testing/
		mkdir -p ./Documentation/filesystems/aufs/
		cp -rv ../aufs4-standalone/Documentation/filesystems/aufs/* ./Documentation/filesystems/aufs/
		mkdir -p ./fs/aufs/
		cp -v ../aufs4-standalone/fs/aufs/* ./fs/aufs/
		cp -v ../aufs4-standalone/include/uapi/linux/aufs_type.h ./include/uapi/linux/

		${git_bin} add .
		${git_bin} commit -a -m 'merge: aufs4' -s
		${git_bin} format-patch -5 -o ../patches/aufs4/

		rm -rf ../aufs4-standalone/ || true

		${git_bin} reset --hard HEAD~5

		start_cleanup

		${git} "${DIR}/patches/aufs4/0001-merge-aufs4-kbuild.patch"
		${git} "${DIR}/patches/aufs4/0002-merge-aufs4-base.patch"
		${git} "${DIR}/patches/aufs4/0003-merge-aufs4-mmap.patch"
		${git} "${DIR}/patches/aufs4/0004-merge-aufs4-standalone.patch"
		${git} "${DIR}/patches/aufs4/0005-merge-aufs4.patch"

		wdir="aufs4"
		number=5
		cleanup
	fi

	${git} "${DIR}/patches/aufs4/0001-merge-aufs4-kbuild.patch"
	${git} "${DIR}/patches/aufs4/0002-merge-aufs4-base.patch"
	${git} "${DIR}/patches/aufs4/0003-merge-aufs4-mmap.patch"
	${git} "${DIR}/patches/aufs4/0004-merge-aufs4-standalone.patch"
	${git} "${DIR}/patches/aufs4/0005-merge-aufs4.patch"
}

rt_cleanup () {
	echo "rt: needs fixup"
	exit 2
}

rt () {
	echo "dir: rt"
	rt_patch="${KERNEL_REL}${kernel_rt}"

	#revert this from ti's branch...
	${git_bin} revert --no-edit 2f6872da466b6f35b3c0a94aa01629da7ae9b72b

	#v4.14.63
	${git_bin} revert --no-edit 3eb86ff32eb54c4345b723ae8dd03bd7487d35bd
	${git_bin} revert --no-edit b7722f4ac3533d48dc5996a4f7e5d847934179b0

	#v4.14.62
	${git_bin} revert --no-edit 2d898915ccf4838c04531c51a598469e921a5eb5

	#v4.14.60
	${git_bin} revert --no-edit da2b62c740def7d1e9d7ce4506e8b1b7a2514e89
	${git_bin} revert --no-edit c06f5a018f710ff24ef7c1b922d2b6704c35dd8c

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		wget -c https://www.kernel.org/pub/linux/kernel/projects/rt/${KERNEL_REL}/patch-${rt_patch}.patch.xz
		xzcat patch-${rt_patch}.patch.xz | patch -p1 || rt_cleanup
		rm -f patch-${rt_patch}.patch.xz
		rm -f localversion-rt
		${git_bin} add .
		${git_bin} commit -a -m 'merge: CONFIG_PREEMPT_RT Patch Set' -s
		${git_bin} format-patch -1 -o ../patches/rt/

		exit 2
	fi

	${git} "${DIR}/patches/rt/0001-merge-CONFIG_PREEMPT_RT-Patch-Set.patch"
}

rt_testing () {
#	${git} "${DIR}/patches/rt-patchset/

	${git} "${DIR}/patches/rt-patchset/0001-rtmutex-Make-rt_mutex_futex_unlock-safe-for-irq-off-.patch"
	${git} "${DIR}/patches/rt-patchset/0002-rcu-Suppress-lockdep-false-positive-boost_mtx-compla.patch"
	${git} "${DIR}/patches/rt-patchset/0003-brd-remove-unused-brd_mutex.patch"
	${git} "${DIR}/patches/rt-patchset/0004-KVM-arm-arm64-Remove-redundant-preemptible-checks.patch"
	${git} "${DIR}/patches/rt-patchset/0005-iommu-amd-Use-raw-locks-on-atomic-context-paths.patch"
	${git} "${DIR}/patches/rt-patchset/0006-iommu-amd-Don-t-use-dev_data-in-irte_ga_set_affinity.patch"
	${git} "${DIR}/patches/rt-patchset/0007-iommu-amd-Avoid-locking-get_irq_table-from-atomic-co.patch"
	${git} "${DIR}/patches/rt-patchset/0008-iommu-amd-Turn-dev_data_list-into-a-lock-less-list.patch"
	${git} "${DIR}/patches/rt-patchset/0009-iommu-amd-Split-domain-id-out-of-amd_iommu_devtable_.patch"
	${git} "${DIR}/patches/rt-patchset/0010-iommu-amd-Split-irq_lookup_table-out-of-the-amd_iomm.patch"
	${git} "${DIR}/patches/rt-patchset/0011-iommu-amd-Remove-the-special-case-from-alloc_irq_tab.patch"
	${git} "${DIR}/patches/rt-patchset/0012-iommu-amd-Use-table-instead-irt-as-variable-name-in-.patch"
	${git} "${DIR}/patches/rt-patchset/0013-iommu-amd-Factor-out-setting-the-remap-table-for-a-d.patch"
	${git} "${DIR}/patches/rt-patchset/0014-iommu-amd-Drop-the-lock-while-allocating-new-irq-rem.patch"
	${git} "${DIR}/patches/rt-patchset/0015-iommu-amd-Make-amd_iommu_devtable_lock-a-spin_lock.patch"
	${git} "${DIR}/patches/rt-patchset/0016-iommu-amd-Return-proper-error-code-in-irq_remapping_.patch"
	${git} "${DIR}/patches/rt-patchset/0017-timers-Use-static-keys-for-migrate_enable-nohz_activ.patch"
	${git} "${DIR}/patches/rt-patchset/0018-hrtimer-Correct-blantanly-wrong-comment.patch"
	${git} "${DIR}/patches/rt-patchset/0019-hrtimer-Fix-kerneldoc-for-struct-hrtimer_cpu_base.patch"
	${git} "${DIR}/patches/rt-patchset/0020-hrtimer-Cleanup-clock-argument-in-schedule_hrtimeout.patch"
	${git} "${DIR}/patches/rt-patchset/0021-hrtimer-Fix-hrtimer-function-description.patch"
	${git} "${DIR}/patches/rt-patchset/0022-hrtimer-Cleanup-hrtimer_mode-enum.patch"
	${git} "${DIR}/patches/rt-patchset/0023-tracing-hrtimer-Print-hrtimer-mode-in-hrtimer_start-.patch"
	${git} "${DIR}/patches/rt-patchset/0024-hrtimer-Switch-for-loop-to-_ffs-evaluation.patch"
	${git} "${DIR}/patches/rt-patchset/0025-hrtimer-Store-running-timer-in-hrtimer_clock_base.patch"
	${git} "${DIR}/patches/rt-patchset/0026-hrtimer-Make-room-in-struct-hrtimer_cpu_base.patch"
	${git} "${DIR}/patches/rt-patchset/0027-hrtimer-Reduce-conditional-code-hres_active.patch"
	${git} "${DIR}/patches/rt-patchset/0028-hrtimer-Use-accesor-functions-instead-of-direct-acce.patch"
	${git} "${DIR}/patches/rt-patchset/0029-hrtimer-Make-the-remote-enqueue-check-unconditional.patch"
	${git} "${DIR}/patches/rt-patchset/0030-hrtimer-Make-hrtimer_cpu_base.next_timer-handling-un.patch"
	${git} "${DIR}/patches/rt-patchset/0031-hrtimer-Make-hrtimer_reprogramm-unconditional.patch"
	${git} "${DIR}/patches/rt-patchset/0032-hrtimer-Make-hrtimer_force_reprogramm-unconditionall.patch"
	${git} "${DIR}/patches/rt-patchset/0033-hrtimer-Unify-handling-of-hrtimer-remove.patch"
	${git} "${DIR}/patches/rt-patchset/0034-hrtimer-Unify-handling-of-remote-enqueue.patch"
	${git} "${DIR}/patches/rt-patchset/0035-hrtimer-Make-remote-enqueue-decision-less-restrictiv.patch"
	${git} "${DIR}/patches/rt-patchset/0036-hrtimer-Remove-base-argument-from-hrtimer_reprogram.patch"
	${git} "${DIR}/patches/rt-patchset/0037-hrtimer-Split-hrtimer_start_range_ns.patch"
	${git} "${DIR}/patches/rt-patchset/0038-hrtimer-Split-__hrtimer_get_next_event.patch"
	${git} "${DIR}/patches/rt-patchset/0039-hrtimer-Use-irqsave-irqrestore-around-__run_hrtimer.patch"
	${git} "${DIR}/patches/rt-patchset/0040-hrtimer-Add-clock-bases-and-hrtimer-mode-for-soft-ir.patch"
	${git} "${DIR}/patches/rt-patchset/0041-hrtimer-Prepare-handling-of-hard-and-softirq-based-h.patch"
	${git} "${DIR}/patches/rt-patchset/0042-hrtimer-Implement-support-for-softirq-based-hrtimers.patch"
	${git} "${DIR}/patches/rt-patchset/0043-hrtimer-Implement-SOFT-HARD-clock-base-selection.patch"
	${git} "${DIR}/patches/rt-patchset/0044-can-bcm-Replace-hrtimer_tasklet-with-softirq-based-h.patch"
	${git} "${DIR}/patches/rt-patchset/0045-mac80211_hwsim-Replace-hrtimer-tasklet-with-softirq-.patch"
	${git} "${DIR}/patches/rt-patchset/0046-xfrm-Replace-hrtimer-tasklet-with-softirq-hrtimer.patch"
	${git} "${DIR}/patches/rt-patchset/0047-softirq-Remove-tasklet_hrtimer.patch"
	${git} "${DIR}/patches/rt-patchset/0048-ALSA-dummy-Replace-tasklet-with-softirq-hrtimer.patch"
	${git} "${DIR}/patches/rt-patchset/0049-usb-gadget-NCM-Replace-tasklet-with-softirq-hrtimer.patch"
	${git} "${DIR}/patches/rt-patchset/0050-net-mvpp2-Replace-tasklet-with-softirq-hrtimer.patch"
	${git} "${DIR}/patches/rt-patchset/0051-arm-at91-do-not-disable-enable-clocks-in-a-row.patch"
	${git} "${DIR}/patches/rt-patchset/0052-ARM-smp-Move-clear_tasks_mm_cpumask-call-to-__cpu_di.patch"
	${git} "${DIR}/patches/rt-patchset/0053-rtmutex-Handle-non-enqueued-waiters-gracefully.patch"
	${git} "${DIR}/patches/rt-patchset/0054-rbtree-include-rcu.h-because-we-use-it.patch"
	${git} "${DIR}/patches/rt-patchset/0055-rxrpc-remove-unused-static-variables.patch"
	${git} "${DIR}/patches/rt-patchset/0056-mfd-syscon-atmel-smc-include-string.h.patch"
	${git} "${DIR}/patches/rt-patchset/0057-sched-swait-include-wait.h.patch"
	${git} "${DIR}/patches/rt-patchset/0058-NFSv4-replace-seqcount_t-with-a-seqlock_t.patch"
	${git} "${DIR}/patches/rt-patchset/0059-Bluetooth-avoid-recursive-locking-in-hci_send_to_cha.patch"
	${git} "${DIR}/patches/rt-patchset/0060-iommu-iova-Use-raw_cpu_ptr-instead-of-get_cpu_ptr-fo.patch"
	${git} "${DIR}/patches/rt-patchset/0061-greybus-audio-don-t-inclide-rwlock.h-directly.patch"
	${git} "${DIR}/patches/rt-patchset/0062-xen-9pfs-don-t-inclide-rwlock.h-directly.patch"
	${git} "${DIR}/patches/rt-patchset/0063-drm-i915-properly-init-lockdep-class.patch"
	${git} "${DIR}/patches/rt-patchset/0064-timerqueue-Document-return-values-of-timerqueue_add-.patch"
	${git} "${DIR}/patches/rt-patchset/0065-sparc64-use-generic-rwsem-spinlocks-rt.patch"
	${git} "${DIR}/patches/rt-patchset/0066-kernel-SRCU-provide-a-static-initializer.patch"
	${git} "${DIR}/patches/rt-patchset/0067-target-drop-spin_lock_assert-irqs_disabled-combo-che.patch"
	${git} "${DIR}/patches/rt-patchset/0068-kernel-sched-Provide-a-pointer-to-the-valid-CPU-mask.patch"
	${git} "${DIR}/patches/rt-patchset/0069-kernel-sched-core-add-migrate_disable.patch"
	${git} "${DIR}/patches/rt-patchset/0070-tracing-Reverse-the-order-of-trace_types_lock-and-ev.patch"
	${git} "${DIR}/patches/rt-patchset/0071-ring-buffer-Rewrite-trace_recursive_-un-lock-to-be-s.patch"
	${git} "${DIR}/patches/rt-patchset/0072-tracing-Remove-lookups-from-tracing_map-hitcount.patch"
	${git} "${DIR}/patches/rt-patchset/0073-tracing-Increase-tracing-map-KEYS_MAX-size.patch"
	${git} "${DIR}/patches/rt-patchset/0074-tracing-Make-traceprobe-parsing-code-reusable.patch"
	${git} "${DIR}/patches/rt-patchset/0075-tracing-Clean-up-hist_field_flags-enum.patch"
	${git} "${DIR}/patches/rt-patchset/0076-tracing-Add-hist_field_name-accessor.patch"
	${git} "${DIR}/patches/rt-patchset/0077-tracing-Reimplement-log2.patch"
	${git} "${DIR}/patches/rt-patchset/0078-tracing-Move-hist-trigger-Documentation-to-histogram.patch"
	${git} "${DIR}/patches/rt-patchset/0079-tracing-Add-Documentation-for-log2-modifier.patch"
	${git} "${DIR}/patches/rt-patchset/0080-tracing-Add-support-to-detect-and-avoid-duplicates.patch"
	${git} "${DIR}/patches/rt-patchset/0081-tracing-Remove-code-which-merges-duplicates.patch"
	${git} "${DIR}/patches/rt-patchset/0082-ring-buffer-Add-interface-for-setting-absolute-time-.patch"
	${git} "${DIR}/patches/rt-patchset/0083-ring-buffer-Redefine-the-unimplemented-RINGBUF_TYPE_.patch"
	${git} "${DIR}/patches/rt-patchset/0084-tracing-Add-timestamp_mode-trace-file.patch"
	${git} "${DIR}/patches/rt-patchset/0085-tracing-Give-event-triggers-access-to-ring_buffer_ev.patch"
	${git} "${DIR}/patches/rt-patchset/0086-tracing-Add-ring-buffer-event-param-to-hist-field-fu.patch"
	${git} "${DIR}/patches/rt-patchset/0087-tracing-Break-out-hist-trigger-assignment-parsing.patch"
	${git} "${DIR}/patches/rt-patchset/0088-tracing-Add-hist-trigger-timestamp-support.patch"
	${git} "${DIR}/patches/rt-patchset/0089-tracing-Add-per-element-variable-support-to-tracing_.patch"
	${git} "${DIR}/patches/rt-patchset/0090-tracing-Add-hist_data-member-to-hist_field.patch"
	${git} "${DIR}/patches/rt-patchset/0091-tracing-Add-usecs-modifier-for-hist-trigger-timestam.patch"
	${git} "${DIR}/patches/rt-patchset/0092-tracing-Add-variable-support-to-hist-triggers.patch"
	${git} "${DIR}/patches/rt-patchset/0093-tracing-Account-for-variables-in-named-trigger-compa.patch"
	${git} "${DIR}/patches/rt-patchset/0094-tracing-Move-get_hist_field_flags.patch"
	${git} "${DIR}/patches/rt-patchset/0095-tracing-Add-simple-expression-support-to-hist-trigge.patch"
	${git} "${DIR}/patches/rt-patchset/0096-tracing-Generalize-per-element-hist-trigger-data.patch"
	${git} "${DIR}/patches/rt-patchset/0097-tracing-Pass-tracing_map_elt-to-hist_field-accessor-.patch"
	${git} "${DIR}/patches/rt-patchset/0098-tracing-Add-hist_field-type-field.patch"
	${git} "${DIR}/patches/rt-patchset/0099-tracing-Add-variable-reference-handling-to-hist-trig.patch"
	${git} "${DIR}/patches/rt-patchset/0100-tracing-Add-hist-trigger-action-hook.patch"
	${git} "${DIR}/patches/rt-patchset/0101-tracing-Add-support-for-synthetic-events.patch"
	${git} "${DIR}/patches/rt-patchset/0102-tracing-Add-support-for-field-variables.patch"
	${git} "${DIR}/patches/rt-patchset/0103-tracing-Add-onmatch-hist-trigger-action-support.patch"
	${git} "${DIR}/patches/rt-patchset/0104-tracing-Add-onmax-hist-trigger-action-support.patch"
	${git} "${DIR}/patches/rt-patchset/0105-tracing-Allow-whitespace-to-surround-hist-trigger-fi.patch"
	${git} "${DIR}/patches/rt-patchset/0106-tracing-Add-cpu-field-for-hist-triggers.patch"
	${git} "${DIR}/patches/rt-patchset/0107-tracing-Add-hist-trigger-support-for-variable-refere.patch"
	${git} "${DIR}/patches/rt-patchset/0108-tracing-Add-last-error-error-facility-for-hist-trigg.patch"
	${git} "${DIR}/patches/rt-patchset/0109-tracing-Add-inter-event-hist-trigger-Documentation.patch"
	${git} "${DIR}/patches/rt-patchset/0110-tracing-Make-tracing_set_clock-non-static.patch"
	${git} "${DIR}/patches/rt-patchset/0111-tracing-Add-a-clock-attribute-for-hist-triggers.patch"
	${git} "${DIR}/patches/rt-patchset/0112-ring-buffer-Bring-back-context-level-recursive-check.patch"
	${git} "${DIR}/patches/rt-patchset/0113-ring-buffer-Fix-duplicate-results-in-mapping-context.patch"
	${git} "${DIR}/patches/rt-patchset/0114-ring-buffer-Add-nesting-for-adding-events-within-eve.patch"
	${git} "${DIR}/patches/rt-patchset/0115-tracing-Use-the-ring-buffer-nesting-to-allow-synthet.patch"
	${git} "${DIR}/patches/rt-patchset/0116-tracing-Add-inter-event-blurb-to-HIST_TRIGGERS-confi.patch"
	${git} "${DIR}/patches/rt-patchset/0117-selftests-ftrace-Add-inter-event-hist-triggers-testc.patch"
	${git} "${DIR}/patches/rt-patchset/0118-tracing-Fix-display-of-hist-trigger-expressions-cont.patch"
	${git} "${DIR}/patches/rt-patchset/0119-tracing-Don-t-add-flag-strings-when-displaying-varia.patch"
	${git} "${DIR}/patches/rt-patchset/0120-tracing-Add-action-comparisons-when-testing-matching.patch"
	${git} "${DIR}/patches/rt-patchset/0121-tracing-Make-sure-variable-string-fields-are-NULL-te.patch"
	${git} "${DIR}/patches/rt-patchset/0122-block-Shorten-interrupt-disabled-regions.patch"
	${git} "${DIR}/patches/rt-patchset/0123-timekeeping-Split-jiffies-seqlock.patch"
	${git} "${DIR}/patches/rt-patchset/0124-tracing-Account-for-preempt-off-in-preempt_schedule.patch"
	${git} "${DIR}/patches/rt-patchset/0125-signal-Revert-ptrace-preempt-magic.patch"
	${git} "${DIR}/patches/rt-patchset/0126-arm-Convert-arm-boot_lock-to-raw.patch"
	${git} "${DIR}/patches/rt-patchset/0127-arm-kprobe-replace-patch_lock-to-raw-lock.patch"
	${git} "${DIR}/patches/rt-patchset/0128-posix-timers-Prevent-broadcast-signals.patch"
	${git} "${DIR}/patches/rt-patchset/0129-signals-Allow-rt-tasks-to-cache-one-sigqueue-struct.patch"
	${git} "${DIR}/patches/rt-patchset/0130-drivers-random-Reduce-preempt-disabled-region.patch"
	${git} "${DIR}/patches/rt-patchset/0131-ARM-AT91-PIT-Remove-irq-handler-when-clock-event-is-.patch"
	${git} "${DIR}/patches/rt-patchset/0132-clockevents-drivers-timer-atmel-pit-fix-double-free_.patch"
	${git} "${DIR}/patches/rt-patchset/0133-clocksource-TCLIB-Allow-higher-clock-rates-for-clock.patch"
	${git} "${DIR}/patches/rt-patchset/0134-suspend-Prevent-might-sleep-splats.patch"
	${git} "${DIR}/patches/rt-patchset/0135-net-flip-lock-dep-thingy.patch.patch"
	${git} "${DIR}/patches/rt-patchset/0136-net-sched-Use-msleep-instead-of-yield.patch"
	${git} "${DIR}/patches/rt-patchset/0137-net-core-disable-NET_RX_BUSY_POLL.patch"
	${git} "${DIR}/patches/rt-patchset/0138-x86-ioapic-Do-not-unmask-io_apic-when-interrupt-is-i.patch"
	${git} "${DIR}/patches/rt-patchset/0139-rcu-segcblist-include-rcupdate.h.patch"
	${git} "${DIR}/patches/rt-patchset/0140-printk-Add-a-printk-kill-switch.patch"
	${git} "${DIR}/patches/rt-patchset/0141-printk-Add-force_early_printk-boot-param-to-help-wit.patch"
	${git} "${DIR}/patches/rt-patchset/0142-rt-Provide-PREEMPT_RT_BASE-config-switch.patch"
	${git} "${DIR}/patches/rt-patchset/0143-kconfig-Disable-config-options-which-are-not-RT-comp.patch"
	${git} "${DIR}/patches/rt-patchset/0144-kconfig-Add-PREEMPT_RT_FULL.patch"
	${git} "${DIR}/patches/rt-patchset/0145-bug-BUG_ON-WARN_ON-variants-dependend-on-RT-RT.patch"
	${git} "${DIR}/patches/rt-patchset/0146-iommu-amd-Use-WARN_ON_NORT-in-__attach_device.patch"
	${git} "${DIR}/patches/rt-patchset/0147-rt-local_irq_-variants-depending-on-RT-RT.patch"
	${git} "${DIR}/patches/rt-patchset/0148-preempt-Provide-preempt_-_-no-rt-variants.patch"
	${git} "${DIR}/patches/rt-patchset/0149-futex-workaround-migrate_disable-enable-in-different.patch"
	${git} "${DIR}/patches/rt-patchset/0150-rt-Add-local-irq-locks.patch"
	${git} "${DIR}/patches/rt-patchset/0151-ata-Do-not-disable-interrupts-in-ide-code-for-preemp.patch"
	${git} "${DIR}/patches/rt-patchset/0152-ide-Do-not-disable-interrupts-for-PREEMPT-RT.patch"
	${git} "${DIR}/patches/rt-patchset/0153-infiniband-Mellanox-IB-driver-patch-use-_nort-primit.patch"
	${git} "${DIR}/patches/rt-patchset/0154-input-gameport-Do-not-disable-interrupts-on-PREEMPT_.patch"
	${git} "${DIR}/patches/rt-patchset/0155-core-Do-not-disable-interrupts-on-RT-in-kernel-users.patch"
	${git} "${DIR}/patches/rt-patchset/0156-usb-Use-_nort-in-giveback-function.patch"
	${git} "${DIR}/patches/rt-patchset/0157-mm-scatterlist-Do-not-disable-irqs-on-RT.patch"
	${git} "${DIR}/patches/rt-patchset/0158-mm-workingset-Do-not-protect-workingset_shadow_nodes.patch"
	${git} "${DIR}/patches/rt-patchset/0159-signal-Make-__lock_task_sighand-RT-aware.patch"
	${git} "${DIR}/patches/rt-patchset/0160-signal-x86-Delay-calling-signals-in-atomic.patch"
	${git} "${DIR}/patches/rt-patchset/0161-x86-signal-delay-calling-signals-on-32bit.patch"
	${git} "${DIR}/patches/rt-patchset/0162-net-wireless-Use-WARN_ON_NORT.patch"
	${git} "${DIR}/patches/rt-patchset/0163-buffer_head-Replace-bh_uptodate_lock-for-rt.patch"
	${git} "${DIR}/patches/rt-patchset/0164-fs-jbd-jbd2-Make-state-lock-and-journal-head-lock-rt.patch"
	${git} "${DIR}/patches/rt-patchset/0165-list_bl-Make-list-head-locking-RT-safe.patch"
	${git} "${DIR}/patches/rt-patchset/0166-list_bl-fixup-bogus-lockdep-warning.patch"
	${git} "${DIR}/patches/rt-patchset/0167-genirq-Disable-irqpoll-on-rt.patch"
	${git} "${DIR}/patches/rt-patchset/0168-genirq-Force-interrupt-thread-on-RT.patch"
	${git} "${DIR}/patches/rt-patchset/0169-drivers-net-vortex-fix-locking-issues.patch"
	${git} "${DIR}/patches/rt-patchset/0170-delayacct-use-raw_spinlocks.patch"
	${git} "${DIR}/patches/rt-patchset/0171-mm-page_alloc-rt-friendly-per-cpu-pages.patch"
	${git} "${DIR}/patches/rt-patchset/0172-mm-page_alloc-Reduce-lock-sections-further.patch"
	${git} "${DIR}/patches/rt-patchset/0173-mm-swap-Convert-to-percpu-locked.patch"
	${git} "${DIR}/patches/rt-patchset/0174-mm-perform-lru_add_drain_all-remotely.patch"
	${git} "${DIR}/patches/rt-patchset/0175-mm-vmstat-Protect-per-cpu-variables-with-preempt-dis.patch"
	${git} "${DIR}/patches/rt-patchset/0176-ARM-Initialize-split-page-table-locks-for-vector-pag.patch"
	${git} "${DIR}/patches/rt-patchset/0177-mm-bounce-Use-local_irq_save_nort.patch"
	${git} "${DIR}/patches/rt-patchset/0178-mm-Allow-only-slub-on-RT.patch"
	${git} "${DIR}/patches/rt-patchset/0179-mm-Enable-SLUB-for-RT.patch"
	${git} "${DIR}/patches/rt-patchset/0180-mm-slub-close-possible-memory-leak-in-kmem_cache_all.patch"
	${git} "${DIR}/patches/rt-patchset/0181-slub-Enable-irqs-for-__GFP_WAIT.patch"
	${git} "${DIR}/patches/rt-patchset/0182-slub-Disable-SLUB_CPU_PARTIAL.patch"
	${git} "${DIR}/patches/rt-patchset/0183-mm-page_alloc-Use-local_lock_on-instead-of-plain-spi.patch"
	${git} "${DIR}/patches/rt-patchset/0184-mm-memcontrol-Don-t-call-schedule_work_on-in-preempt.patch"
	${git} "${DIR}/patches/rt-patchset/0185-mm-memcontrol-Replace-local_irq_disable-with-local-l.patch"
	${git} "${DIR}/patches/rt-patchset/0186-mm-backing-dev-don-t-disable-IRQs-in-wb_congested_pu.patch"
	${git} "${DIR}/patches/rt-patchset/0187-mm-zsmalloc-copy-with-get_cpu_var-and-locking.patch"
	${git} "${DIR}/patches/rt-patchset/0188-radix-tree-use-local-locks.patch"
	${git} "${DIR}/patches/rt-patchset/0189-panic-skip-get_random_bytes-for-RT_FULL-in-init_oops.patch"
	${git} "${DIR}/patches/rt-patchset/0190-timers-Prepare-for-full-preemption.patch"
	${git} "${DIR}/patches/rt-patchset/0191-timer-delay-waking-softirqs-from-the-jiffy-tick.patch"
	${git} "${DIR}/patches/rt-patchset/0192-nohz-Prevent-erroneous-tick-stop-invocations.patch"
	${git} "${DIR}/patches/rt-patchset/0193-x86-kvm-Require-const-tsc-for-RT.patch"
	${git} "${DIR}/patches/rt-patchset/0194-wait.h-include-atomic.h.patch"
	${git} "${DIR}/patches/rt-patchset/0195-work-simple-Simple-work-queue-implemenation.patch"
	${git} "${DIR}/patches/rt-patchset/0196-completion-Use-simple-wait-queues.patch"
	${git} "${DIR}/patches/rt-patchset/0197-fs-aio-simple-simple-work.patch"
	${git} "${DIR}/patches/rt-patchset/0198-genirq-Do-not-invoke-the-affinity-callback-via-a-wor.patch"
	${git} "${DIR}/patches/rt-patchset/0199-time-hrtimer-avoid-schedule_work-with-interrupts-dis.patch"
	${git} "${DIR}/patches/rt-patchset/0200-hrtimer-consolidate-hrtimer_init-hrtimer_init_sleepe.patch"
	${git} "${DIR}/patches/rt-patchset/0201-hrtimers-Prepare-full-preemption.patch"
	${git} "${DIR}/patches/rt-patchset/0202-hrtimer-by-timers-by-default-into-the-softirq-contex.patch"
	${git} "${DIR}/patches/rt-patchset/0203-alarmtimer-Prevent-live-lock-in-alarm_cancel.patch"
	${git} "${DIR}/patches/rt-patchset/0204-posix-timers-user-proper-timer-while-waiting-for-ala.patch"
	${git} "${DIR}/patches/rt-patchset/0205-posix-timers-move-the-rcu-head-out-of-the-union.patch"
	${git} "${DIR}/patches/rt-patchset/0206-hrtimer-Move-schedule_work-call-to-helper-thread.patch"
	${git} "${DIR}/patches/rt-patchset/0207-timer-fd-Prevent-live-lock.patch"
	${git} "${DIR}/patches/rt-patchset/0208-posix-timers-Thread-posix-cpu-timers-on-rt.patch"
	${git} "${DIR}/patches/rt-patchset/0209-sched-Move-task_struct-cleanup-to-RCU.patch"
	${git} "${DIR}/patches/rt-patchset/0210-sched-Limit-the-number-of-task-migrations-per-batch.patch"
	${git} "${DIR}/patches/rt-patchset/0211-sched-Move-mmdrop-to-RCU-on-RT.patch"
	${git} "${DIR}/patches/rt-patchset/0212-kernel-sched-move-stack-kprobe-clean-up-to-__put_tas.patch"
	${git} "${DIR}/patches/rt-patchset/0213-sched-Add-saved_state-for-tasks-blocked-on-sleeping-.patch"
	${git} "${DIR}/patches/rt-patchset/0214-sched-Prevent-task-state-corruption-by-spurious-lock.patch"
	${git} "${DIR}/patches/rt-patchset/0215-sched-Remove-TASK_ALL.patch"
	${git} "${DIR}/patches/rt-patchset/0216-sched-Do-not-account-rcu_preempt_depth-on-RT-in-migh.patch"
	${git} "${DIR}/patches/rt-patchset/0217-sched-Take-RT-softirq-semantics-into-account-in-cond.patch"
	${git} "${DIR}/patches/rt-patchset/0218-sched-Use-the-proper-LOCK_OFFSET-for-cond_resched.patch"
	${git} "${DIR}/patches/rt-patchset/0219-sched-Disable-TTWU_QUEUE-on-RT.patch"
	${git} "${DIR}/patches/rt-patchset/0220-sched-Disable-CONFIG_RT_GROUP_SCHED-on-RT.patch"
	${git} "${DIR}/patches/rt-patchset/0221-sched-ttwu-Return-success-when-only-changing-the-sav.patch"
	${git} "${DIR}/patches/rt-patchset/0222-sched-workqueue-Only-wake-up-idle-workers-if-not-blo.patch"
	${git} "${DIR}/patches/rt-patchset/0223-rt-Increase-decrease-the-nr-of-migratory-tasks-when-.patch"
	${git} "${DIR}/patches/rt-patchset/0224-stop_machine-convert-stop_machine_run-to-PREEMPT_RT.patch"
	${git} "${DIR}/patches/rt-patchset/0225-stop_machine-Use-raw-spinlocks.patch"
	${git} "${DIR}/patches/rt-patchset/0226-hotplug-Lightweight-get-online-cpus.patch"
	${git} "${DIR}/patches/rt-patchset/0227-trace-Add-migrate-disabled-counter-to-tracing-output.patch"
	${git} "${DIR}/patches/rt-patchset/0228-lockdep-Make-it-RT-aware.patch"
	${git} "${DIR}/patches/rt-patchset/0229-lockdep-disable-self-test.patch"
	${git} "${DIR}/patches/rt-patchset/0230-locking-Disable-spin-on-owner-for-RT.patch"
	${git} "${DIR}/patches/rt-patchset/0231-tasklet-Prevent-tasklets-from-going-into-infinite-sp.patch"
	${git} "${DIR}/patches/rt-patchset/0232-softirq-Check-preemption-after-reenabling-interrupts.patch"
	${git} "${DIR}/patches/rt-patchset/0233-softirq-Disable-softirq-stacks-for-RT.patch"
	${git} "${DIR}/patches/rt-patchset/0234-softirq-Split-softirq-locks.patch"
	${git} "${DIR}/patches/rt-patchset/0235-kernel-softirq-unlock-with-irqs-on.patch"
	${git} "${DIR}/patches/rt-patchset/0236-genirq-Allow-disabling-of-softirq-processing-in-irq-.patch"
	${git} "${DIR}/patches/rt-patchset/0237-softirq-split-timer-softirqs-out-of-ksoftirqd.patch"
	${git} "${DIR}/patches/rt-patchset/0238-softirq-wake-the-timer-softirq-if-needed.patch"
	${git} "${DIR}/patches/rt-patchset/0239-rtmutex-trylock-is-okay-on-RT.patch"
	${git} "${DIR}/patches/rt-patchset/0240-fs-nfs-turn-rmdir_sem-into-a-semaphore.patch"
	${git} "${DIR}/patches/rt-patchset/0241-rtmutex-Handle-the-various-new-futex-race-conditions.patch"
	${git} "${DIR}/patches/rt-patchset/0242-futex-Fix-bug-on-when-a-requeued-RT-task-times-out.patch"
	${git} "${DIR}/patches/rt-patchset/0243-locking-rtmutex-don-t-drop-the-wait_lock-twice.patch"
	${git} "${DIR}/patches/rt-patchset/0244-futex-Ensure-lock-unlock-symetry-versus-pi_lock-and-.patch"
	${git} "${DIR}/patches/rt-patchset/0245-pid.h-include-atomic.h.patch"
	${git} "${DIR}/patches/rt-patchset/0246-arm-include-definition-for-cpumask_t.patch"
	${git} "${DIR}/patches/rt-patchset/0247-locking-locktorture-Do-NOT-include-rwlock.h-directly.patch"
	${git} "${DIR}/patches/rt-patchset/0248-rtmutex-Add-rtmutex_lock_killable.patch"
	${git} "${DIR}/patches/rt-patchset/0249-rtmutex-Make-lock_killable-work.patch"
	${git} "${DIR}/patches/rt-patchset/0250-spinlock-Split-the-lock-types-header.patch"
}

wireguard_fail () {
	echo "WireGuard failed"
	exit 2
}

wireguard () {
	echo "dir: WireGuard"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cd ../
		if [ ! -d ./WireGuard ] ; then
			${git_bin} clone https://git.zx2c4.com/WireGuard --depth=1
		else
			rm -rf ./WireGuard || true
			${git_bin} clone https://git.zx2c4.com/WireGuard --depth=1
		fi
		cd ./KERNEL/

		../WireGuard/contrib/kernel-tree/create-patch.sh | patch -p1 || wireguard_fail

		${git_bin} add .
		${git_bin} commit -a -m 'merge: WireGuard' -s
		${git_bin} format-patch -1 -o ../patches/WireGuard/

		rm -rf ../WireGuard/ || true

		${git_bin} reset --hard HEAD^

		start_cleanup

		${git} "${DIR}/patches/WireGuard/0001-merge-WireGuard.patch"

		wdir="WireGuard"
		number=1
		cleanup
	fi

	${git} "${DIR}/patches/WireGuard/0001-merge-WireGuard.patch"
}

ti_pm_firmware () {
	#http://git.ti.com/gitweb/?p=processor-firmware/ti-amx3-cm3-pm-firmware.git;a=shortlog;h=refs/heads/ti-v4.1.y-next
	echo "dir: drivers/ti/firmware"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then

		cd ../
		if [ ! -d ./ti-amx3-cm3-pm-firmware ] ; then
			${git_bin} clone -b ti-v4.1.y-next git://git.ti.com/processor-firmware/ti-amx3-cm3-pm-firmware.git --depth=1
		else
			rm -rf ./ti-amx3-cm3-pm-firmware || true
			${git_bin} clone -b ti-v4.1.y-next git://git.ti.com/processor-firmware/ti-amx3-cm3-pm-firmware.git --depth=1
		fi
		cd ./KERNEL/

		cp -v ../ti-amx3-cm3-pm-firmware/bin/am* ./firmware/

		${git_bin} add -f ./firmware/am*
		${git_bin} commit -a -m 'add am33x firmware' -s
		${git_bin} format-patch -1 -o ../patches/drivers/ti/firmware/

		rm -rf ../ti-amx3-cm3-pm-firmware/ || true

		${git_bin} reset --hard HEAD^

		start_cleanup

		${git} "${DIR}/patches/drivers/ti/firmware/0001-add-am33x-firmware.patch"

		wdir="drivers/ti/firmware"
		number=1
		cleanup
	fi

	${git} "${DIR}/patches/drivers/ti/firmware/0001-add-am33x-firmware.patch"
}

local_patch () {
	echo "dir: dir"
	${git} "${DIR}/patches/dir/0001-patch.patch"
}

external_git
aufs4
rt
#wireguard
ti_pm_firmware
#local_patch

pre_backports () {
	echo "dir: backports/${subsystem}"

	cd ~/linux-src/
	${git_bin} pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git master
	${git_bin} pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git master --tags
	${git_bin} pull --no-edit https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master --tags
	if [ ! "x${backport_tag}" = "x" ] ; then
		${git_bin} checkout ${backport_tag} -b tmp
	fi
	cd -
}

post_backports () {
	if [ ! "x${backport_tag}" = "x" ] ; then
		cd ~/linux-src/
		${git_bin} checkout master -f ; ${git_bin} branch -D tmp
		cd -
	fi

	${git_bin} add .
	${git_bin} commit -a -m "backports: ${subsystem}: from: linux.git" -s
	if [ ! -d ../patches/backports/${subsystem}/ ] ; then
		mkdir -p ../patches/backports/${subsystem}/
	fi
	${git_bin} format-patch -1 -o ../patches/backports/${subsystem}/
}

patch_backports (){
	echo "dir: backports/${subsystem}"
	${git} "${DIR}/patches/backports/${subsystem}/0001-backports-${subsystem}-from-linux.git.patch"
}

backports () {
	backport_tag="v4.x-y"

	subsystem="xyz"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		pre_backports

		mkdir -p ./x/
		cp -v ~/linux-src/x/* ./x/

		post_backports
		exit 2
	else
		patch_backports
	fi
}

reverts () {
	echo "dir: reverts"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	#https://github.com/torvalds/linux/commit/00f0ea70d2b82b7d7afeb1bdedc9169eb8ea6675
	#
	#Causes bone_capemgr to get stuck on slot 1 and just eventually exit "without" checking slot2/3/4...
	#
	#[    5.406775] bone_capemgr bone_capemgr: Baseboard: 'A335BNLT,00C0,2516BBBK2626'
	#[    5.414178] bone_capemgr bone_capemgr: compatible-baseboard=ti,beaglebone-black - #slots=4
	#[    5.422573] bone_capemgr bone_capemgr: Failed to add slot #1

	${git} "${DIR}/patches/reverts/0001-Revert-eeprom-at24-check-if-the-chip-is-functional-i.patch"
	${git} "${DIR}/patches/reverts/0002-Revert-tis-overlay-setup.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="reverts"
		number=2
		cleanup
	fi
}

drivers () {
	dir 'drivers/ar1021_i2c'
	dir 'drivers/btrfs'
	dir 'drivers/pwm'
	dir 'drivers/snd_pwmsp'
	dir 'drivers/spi'
	dir 'drivers/ssd1306'
	dir 'drivers/tsl2550'
	dir 'drivers/tps65217'
	dir 'drivers/opp'
	dir 'drivers/wiznet'

	#https://github.com/pantoniou/linux-beagle-track-mainline/tree/bbb-overlays
	echo "dir: drivers/ti/bbb_overlays"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0001-gitignore-Ignore-DTB-files.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0002-add-PM-firmware.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0003-ARM-CUSTOM-Build-a-uImage-with-dtb-already-appended.patch"
	fi

	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0004-omap-Fix-crash-when-omap-device-is-disabled.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0005-serial-omap-Fix-port-line-number-without-aliases.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0006-tty-omap-serial-Fix-up-platform-data-alloc.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0007-of-overlay-kobjectify-overlay-objects.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0008-of-overlay-global-sysfs-enable-attribute.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0009-Documentation-ABI-overlays-global-attributes.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0010-Documentation-document-of_overlay_disable-parameter.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0011-of-overlay-add-per-overlay-sysfs-attributes.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0012-Documentation-ABI-overlays-per-overlay-docs.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0013-of-dynamic-Add-__of_node_dupv.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0014-of-changesets-Introduce-changeset-helper-methods.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0015-of-changeset-Add-of_changeset_node_move-method.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0016-of-unittest-changeset-helpers.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0017-OF-DT-Overlay-configfs-interface-v7.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0018-ARM-DT-Enable-symbols-when-CONFIG_OF_OVERLAY-is-used.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0019-misc-Beaglebone-capemanager.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0020-doc-misc-Beaglebone-capemanager-documentation.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0021-doc-dt-beaglebone-cape-manager-bindings.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0022-doc-ABI-bone_capemgr-sysfs-API.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0023-MAINTAINERS-Beaglebone-capemanager-maintainer.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0024-arm-dts-Enable-beaglebone-cape-manager.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0025-of-overlay-Implement-target-index-support.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0026-of-unittest-Add-indirect-overlay-target-test.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0027-doc-dt-Document-the-indirect-overlay-method.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0028-of-overlay-Introduce-target-root-capability.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0029-of-unittest-Unit-tests-for-target-root-overlays.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0030-doc-dt-Document-the-target-root-overlay-method.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0031-RFC-Device-overlay-manager-PCI-USB-DT.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0032-of-rename-_node_sysfs-to-_node_post.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0033-of-Support-hashtable-lookups-for-phandles.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0034-of-unittest-hashed-phandles-unitest.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0035-of-overlay-Pick-up-label-symbols-from-overlays.patch"


	if [ "x${regenerate}" = "xenable" ] ; then
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0036-of-Portable-Device-Tree-connector.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0037-boneblack-defconfig.patch"
	fi

	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0038-bone_capemgr-uboot_capemgr_enabled-flag.patch"
	${git} "${DIR}/patches/drivers/ti/bbb_overlays/0039-bone_capemgr-kill-with-uboot-flag.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		wdir="drivers/ti/bbb_overlays"
		number=39
		cleanup
	fi

	dir 'drivers/ti/cpsw'
	dir 'drivers/ti/etnaviv'
	dir 'drivers/ti/eqep'
	dir 'drivers/ti/rpmsg'
	dir 'drivers/ti/pru_rproc'
	dir 'drivers/ti/serial'
	dir 'drivers/ti/spi'
	dir 'drivers/ti/tsc'
	dir 'drivers/ti/uio'
	dir 'drivers/ti/gpio'
}

soc () {
	dir 'soc/ti'
	dir 'soc/ti/mmc'
	dir 'soc/ti/bone_common'
	dir 'soc/ti/uboot'
	dir 'soc/ti/blue'
	dir 'soc/ti/sancloud'
	dir 'soc/ti/abbbi'
	dir 'soc/ti/am335x_olimex_som'
	dir 'soc/ti/beaglebone_capes'
	dir 'soc/ti/pocketbeagle'
	dir 'soc/ti/pruss'
	dir 'soc/ti/roboticscape'
	dir 'soc/ti/uboot_univ'
	dir 'soc/ti/x15'
}

dtb_makefile_append () {
	sed -i -e 's:am335x-boneblack.dtb \\:am335x-boneblack.dtb \\\n\t'$device' \\:g' arch/arm/boot/dts/Makefile
}

dtb_makefile_append_am57xx () {
	sed -i -e 's:am57xx-beagle-x15.dtb \\:am57xx-beagle-x15.dtb \\\n\t'$device' \\:g' arch/arm/boot/dts/Makefile
}

beaglebone () {
	#This has to be last...
	echo "dir: beaglebone/dtbs"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		patch -p1 < "${DIR}/patches/beaglebone/dtbs/0001-sync-am335x-peripheral-pinmux.patch"
		exit 2
	fi

	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		start_cleanup
	fi

	${git} "${DIR}/patches/beaglebone/dtbs/0001-sync-am335x-peripheral-pinmux.patch"

	if [ "x${regenerate}" = "xenable" ] ; then
		number=1
		cleanup
	fi

	####
	#dtb makefile
	echo "dir: beaglebone/generated"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then

		device="am335x-boneblack-uboot.dtb" ; dtb_makefile_append

		device="am335x-boneblack-roboticscape.dtb" ; dtb_makefile_append
		device="am335x-boneblack-wireless-roboticscape.dtb" ; dtb_makefile_append

		device="am335x-sancloud-bbe.dtb" ; dtb_makefile_append

		device="am335x-abbbi.dtb" ; dtb_makefile_append

		device="am335x-olimex-som.dtb" ; dtb_makefile_append

		device="am335x-boneblack-wl1835mod.dtb" ; dtb_makefile_append

		device="am335x-boneblack-bbbmini.dtb" ; dtb_makefile_append

		device="am335x-boneblack-bbb-exp-c.dtb" ; dtb_makefile_append
		device="am335x-boneblack-bbb-exp-r.dtb" ; dtb_makefile_append

		device="am335x-boneblack-audio.dtb" ; dtb_makefile_append

		device="am335x-pocketbeagle.dtb" ; dtb_makefile_append
		device="am335x-pocketbeagle-simplegaming.dtb" ; dtb_makefile_append

		device="am335x-bone-uboot-univ.dtb" ; dtb_makefile_append
		device="am335x-boneblack-uboot-univ.dtb" ; dtb_makefile_append
		device="am335x-bonegreen-wireless-uboot-univ.dtb" ; dtb_makefile_append

		git commit -a -m 'auto generated: capes: add dtbs to makefile' -s
		git format-patch -1 -o ../patches/beaglebone/generated/
		exit 2
	else
		${git} "${DIR}/patches/beaglebone/generated/0001-auto-generated-capes-add-dtbs-to-makefile.patch"
	fi
}

###
#backports
reverts
drivers
soc
beaglebone
dir 'drivers/ti/sgx'

packaging () {
	echo "dir: packaging"
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cp -v "${DIR}/3rdparty/packaging/Makefile" "${DIR}/KERNEL/scripts/package"
		cp -v "${DIR}/3rdparty/packaging/builddeb" "${DIR}/KERNEL/scripts/package"
		#Needed for v4.11.x and less
		#patch -p1 < "${DIR}/patches/packaging/0002-Revert-deb-pkg-Remove-the-KBUILD_IMAGE-workaround.patch"
		${git_bin} commit -a -m 'packaging: sync builddeb changes' -s
		${git_bin} format-patch -1 -o "${DIR}/patches/packaging"
		exit 2
	else
		${git} "${DIR}/patches/packaging/0001-packaging-sync-builddeb-changes.patch"
	fi
}

readme () {
	#regenerate="enable"
	if [ "x${regenerate}" = "xenable" ] ; then
		cp -v "${DIR}/3rdparty/readme/README.md" "${DIR}/KERNEL/README.md"
		cp -v "${DIR}/3rdparty/readme/jenkins_build.sh" "${DIR}/KERNEL/jenkins_build.sh"
		cp -v "${DIR}/3rdparty/readme/Jenkinsfile" "${DIR}/KERNEL/Jenkinsfile"
		git add -f README.md
		git add -f jenkins_build.sh
		git add -f Jenkinsfile
		git commit -a -m 'enable: Jenkins: http://rcn-ee.online:8080' -s
		git format-patch -1 -o "${DIR}/patches/readme"
		exit 2
	else
		dir 'readme'
	fi
}

packaging
readme
echo "patch.sh ran successfully"
