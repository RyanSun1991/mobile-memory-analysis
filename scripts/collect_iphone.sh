#!/bin/bash
# iPhone 内存数据采集（macOS 主机，USB 连接，无需越狱）
# 依赖: libimobiledevice (brew), pymobiledevice3 (pip)
# DVT sysmon 需要设备开启开发者模式；--native 走 macOS 自带的 iOS 17+ 隧道，无需 sudo
set -u
export PATH=$PATH:/opt/homebrew/bin:$HOME/.local/bin
U=${1:?usage: collect_iphone.sh <UDID> [outdir]}
OUT=${2:-$(dirname "$0")/../data/iphone}
mkdir -p "$OUT/jetsam" && cd "$OUT" || exit 1

ideviceinfo -u "$U" > info.txt 2>&1
ideviceinfo -u "$U" -q com.apple.disk_usage > disk.txt 2>&1

# IORegistry: GPU (AGX) 性能统计 / ANE 设备属性 / 内存控制器
pymobiledevice3 diagnostics ioregistry --udid "$U" --name AGXAcceleratorG14P > agx.json 2>&1
pymobiledevice3 diagnostics ioregistry --udid "$U" --name H11ANE > ane.json 2>&1
pymobiledevice3 diagnostics ioregistry --udid "$U" --ioclass IOSurfaceRoot > iosurface.json 2>&1
pymobiledevice3 diagnostics ioregistry --udid "$U" --name mcc > mcc.json 2>&1
idevicediagnostics -u "$U" ioreg IOService > ioreg_service.plist 2>&1

# 实时 VM 统计（页状态、压缩器、swap）与逐进程内存
pymobiledevice3 developer dvt sysmon system --native --udid "$U" > sysmon.txt 2>&1
pymobiledevice3 developer dvt sysmon process single --native --udid "$U" > proc_single.txt 2>&1

# Jetsam 报告（含杀进程瞬间的 memoryStatus：压缩器页数、未压缩页数、各页状态）
pymobiledevice3 crash pull --udid "$U" -m '^JetsamEvent' jetsam/ 2>&1 | tail -1
ls -la jetsam/
