#!/bin/bash
cd $(dirname "$0")/../data/pixel || exit 1
ADB="$HOME/Library/Android/sdk/platform-tools/adb"
S=${1:-67080DLKX006XY}
a(){ "$ADB" -s $S shell "$@"; }
a 'ls -la /sys/block/ 2>&1 | head; ls -la /sys/block/zram0/ 2>&1 | head -40; cat /sys/block/zram0/comp_algorithm /sys/block/zram0/mm_stat /sys/block/zram0/bd_stat /sys/block/zram0/backing_dev 2>&1; grep -B1 -A3 -iE "lz|zstd|lz77" /proc/crypto 2>&1 | head -30; ls /sys/module/ | grep -iE "zram|zsmalloc|lz|zstd|eh|emerald" ' > zram2.txt 2>&1
a 'D=/sys/devices/platform/sswrp_tpu@36000000/36558000.santafe; ls $D $D/edgetpu/edgetpu-soc 2>&1; for f in $D/edgetpu/edgetpu-soc/*; do [ -f $f ] && echo "$f: $(cat $f 2>&1 | head -3 | tr "\n" " ")"; done' > tpu.txt 2>&1
a 'G=$(readlink -f /sys/class/gxp/* 2>/dev/null | head -1); echo $G; ls /sys/class/gxp/; ls $G 2>&1; for f in $G/*; do [ -f $f ] && echo "$f: $(cat $f 2>&1 | head -2 | tr "\n" " ")"; done' > gxp.txt 2>&1
a 'ls /sys/class/devfreq/; for d in /sys/class/devfreq/*; do echo "$d cur=$(cat $d/cur_freq 2>&1) max=$(cat $d/max_freq 2>&1) gov=$(cat $d/governor 2>&1) avail=$(cat $d/available_frequencies 2>&1 | wc -w)"; done' > devfreq.txt 2>&1
a 'ls -d /sys/devices/platform/*gpu* /sys/devices/platform/*rgx* /sys/devices/platform/*pvr* 2>&1; for d in /sys/devices/platform/*gpu*; do ls $d; done 2>&1 | head -60' > gpu_sys.txt 2>&1
a 'dumpsys meminfo -S --sort-by-pss 2>/dev/null | sed -n "/Total PSS by process/,/Total PSS by OOM/p" | head -45' > top_pss.txt 2>&1
a 'dmabuf_dump 2>&1 | tail -40' > dmabuf_dump.txt 2>&1
a 'dumpsys SurfaceFlinger 2>/dev/null | grep -iE "GraphicBufferAllocator|Total allocated|buffers" | head -10; dumpsys gfxinfo 2>/dev/null | grep -iE "Total GPU memory|Total CPU memory" | head' > gfx.txt 2>&1
a 'for p in $(pidof com.google.android.apps.nexuslauncher system_server surfaceflinger com.android.systemui); do echo "== $p $(cat /proc/$p/cmdline | tr "\0" " ")"; grep -E "VmRSS|RssAnon|RssFile|RssShmem|VmSwap" /proc/$p/status 2>&1 | tr -s " " | tr "\n" " "; echo; done' > procstatus.txt 2>&1
a 'cat /proc/sys/vm/page-cluster 2>&1; getprop ro.boot.hardware.revision; getprop ro.boot.ddr_size 2>&1; getprop | grep -iE "ddr|dram|lpddr|ram_size|mem" | head' > ddr.txt 2>&1
