#!/bin/bash
cd $(dirname "$0")/../data/pixel || exit 1
ADB="$HOME/Library/Android/sdk/platform-tools/adb"
S=${1:-67080DLKX006XY}
a(){ "$ADB" -s $S shell "$@"; }
a 'getprop ro.build.fingerprint; getprop ro.soc.manufacturer; getprop ro.soc.model; getprop ro.product.board; getprop ro.hardware; uname -a; id; su -c id 2>&1; echo low_ram=$(getprop ro.config.low_ram); echo lmk_psi=$(getprop ro.lmk.use_psi); echo zram_idle=$(getprop ro.zram.mark_idle_delay_mins); echo zram_size=$(getprop ro.zram.size); getprop | grep -iE "zram|lmk|swap|mglru|dalvik.vm.heap" ' > props.txt 2>&1
a cat /proc/meminfo > meminfo.txt
a cat /proc/swaps > swaps.txt
a 'for f in /sys/block/zram0/*; do [ -f $f ] && echo "$f: $(cat $f 2>&1 | head -3)"; done' > zram.txt 2>&1
a cat /proc/vmstat > vmstat.txt
a 'cat /proc/pressure/memory; echo; cat /proc/pressure/cpu; echo; cat /proc/pressure/io' > psi.txt 2>&1
a dumpsys meminfo > dumpsys_meminfo.txt
a dumpsys gpu --gpumem > gpumem.txt 2>&1
a cat /proc/zoneinfo > zoneinfo.txt
a 'cat /proc/buddyinfo; cat /proc/pagetypeinfo' > buddy.txt 2>&1
a 'ls -la /dev/dma_heap/ 2>&1; ls /sys/kernel/dmabuf/ 2>&1; cat /sys/kernel/dmabuf/total_pools_kb 2>&1; ls /sys/kernel/dma_heap 2>&1; cat /sys/kernel/dma_heap/total_pools_kb 2>&1; ls /sys/kernel/dmabuf/buffers 2>&1 | wc -l' > dmabuf.txt 2>&1
a 'echo thp=$(cat /sys/kernel/mm/transparent_hugepage/enabled); ls /sys/kernel/mm/; echo swappiness=$(cat /proc/sys/vm/swappiness); echo wsf=$(cat /proc/sys/vm/watermark_scale_factor); echo min_free=$(cat /proc/sys/vm/min_free_kbytes); echo extra_free=$(cat /proc/sys/vm/extra_free_kbytes 2>&1); cat /sys/kernel/mm/lru_gen/enabled 2>&1; cat /sys/kernel/mm/lru_gen/min_ttl_ms 2>&1' > vmtunables.txt 2>&1
a 'ls /sys/class/ | tr "\n" " "; echo; echo ---edgetpu; ls -la /sys/class/edgetpu 2>&1; ls /sys/class/edgetpu/*/ 2>&1; echo ---misc; ls /sys/class/misc 2>&1 | tr "\n" " "; echo; echo ---gpu; ls /sys/kernel/gpu 2>&1; for f in /sys/kernel/gpu/*; do echo "$f: $(cat $f 2>&1|head -2)"; done; ls -la /dev | grep -iE "mali|kgsl|pvr|edgetpu|tpu|abrolhos|janeiro|rio|gxp|dri|powervr" ' > accel.txt 2>&1
a 'dumpsys procstats --hours 3' > procstats.txt 2>&1
a 'grep -E "Hardware|CPU part|processor" /proc/cpuinfo | sort | uniq -c; for c in /sys/devices/system/cpu/cpu[0-9]*; do echo "$c $(cat $c/cpufreq/cpuinfo_max_freq 2>/dev/null)"; done' > cpu.txt 2>&1
a 'cat /proc/iomem 2>&1 | head -60; echo ---rsv; ls /proc/device-tree/reserved-memory 2>&1' > reserved.txt 2>&1
a 'dumpsys activity lmk 2>&1 | head -60; echo ---lmkd; dumpsys activity exit-info 2>&1 | grep -E "reason=|description=" | sort | uniq -c | sort -rn | head -20' > lmk.txt 2>&1
a 'cat /proc/sys/kernel/random/boot_id; cat /proc/uptime; dumpsys battery | head -12' > misc.txt 2>&1
a 'dmesg 2>&1 | head -3; logcat -d -b main,system -t 3000 2>/dev/null | grep -iE "lowmemorykiller|lmkd|kill one|psi" | tail -30' > lmklog.txt 2>&1
wc -l *.txt
