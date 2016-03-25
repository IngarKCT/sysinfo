#!/bin/sh
#
# sysinfo script by Ingar
#

#--- [ OS ] ---------------------------
host=`uname -n`
os=`uname -sr`
uptime=`uptime | rev | cut -d "," -f 5-| rev | cut -d "p" -f 2- | sed 's/^ *//' | sed 's/  */ /g'`

#--- [ MEMORY ] -----------------------
mem_total=`cat /proc/meminfo | grep -i MemTotal | awk '{printf "%d",$2/1024;}'`
mem_free=`free  | tail -n2 | head -n1 | sed 's/^.*://' | awk '{printf "%d",$2/1024;}'`
mem_used=`echo ${mem_total} ${mem_free} | awk '{printf "%d",$1-$2;}'`

swap_total=`cat /proc/meminfo | grep -i SwapTotal | awk '{printf "%d",$2/1024;}'`
swap_free=`cat /proc/meminfo | grep -i SwapFree | awk '{printf "%d",$2/1024;}'`
swap_used=`echo ${swap_total} ${swap_free} | awk '{printf "%d",$1-$2;}'`

#--- [ CPU ] --------------------------
cpu=`cat /proc/cpuinfo | grep "model name" | head -n 1 | sed 's/^.*: //'`
if [ -z "${cpu}" ]; then
	# fallback
	cpu=`uname -p`
fi
cpu_speed=`cat /proc/cpuinfo | head -n 7 | tail -n 1 | cut -d ":" -f 2 | cut -d "." -f 1 | sed 's/^ *//'`
cpu_load=` cat /proc/loadavg | cut -d " " -f 1 | sed 's/,//'`

# Detect frequency scaler
if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ]; then
	cpu_speed_max=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq | awk '{ printf "%d", $1/1000;}'`
	cpu_speed_current=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq | awk '{ printf "%d", $1/1000;}'`
	cpu_speed="${cpu_speed_current}/${cpu_speed_max}"
fi

#---[ HD ] ----------------------------
#sua=`df  -l -x tmpfs  -x devtmpfs | tail -n +1 | awk 'BEGIN {s=0; u=0; a=0;} {s=s+$2; u=u+$3; a=a+$4} END { s=s/1048576; u=u/1048576; a=a/1048576; printf "%d %d %d",s,u,a;}'`
disk_fs=`cat /proc/filesystems | grep -v nodev | sed 's/\t//g' | xargs | sed 's/ /,/g'`
sua=`df  -l -x tmpfs  -x devtmpfs -x devtmpfs --total | tail -n 1`
disk_size=`echo $sua | awk '{printf "%d",$2/1048576;}'`;
disk_used=`echo $sua | awk '{printf "%d",$3/1048576;}'`;
disk_free=`echo $sua | awk '{printf "%d",$4/1048576;}'`;

#---[ VGA ] ---------------------------
vga=""
if [ -x `which lspci` ]; then
	vga=`lspci | grep VGA | cut -d ":" -f 3 | sed 's/ *(rev.*//' | sed 's/^ *//' | sed 's/^.*\[//' | sed 's/\].*//'`
fi

#---[ PRINT LONG VERSION ]-------------
#echo "[system] ${os} uptime: ${uptime}"
#echo "[cpu]    ${cpu} ${cpu_speed} Mhz"
#echo "[memory] ${mem_total}Mib total ${mem_app} Mb used ${mem_free}Mb free ${mem_buffers}Mib buffers ${mem_cache}Mb cache"
#echo "[swap]   ${swap_total}Mib total ${swap_used} Mb used ${swap_free}Mib free"
#echo "[disk]   ${disk_size} Gib total ${disk_used} Gib used ${disk_free} Gib free"

#--- [ PRINT SHORT VERSION ]----------

echo -n "[${host}]"
echo -n "[${os}]"
echo -n "[${cpu}]"
if [  "x${vga}" != "x" ]; then
	echo -n "[${vga}]"
fi
echo -n "[Memory used: ${mem_used}/${mem_total} Mib]"
echo -n "[Swap used: ${swap_used}/${swap_total} Mib]"
echo -n "[Disk used: ${disk_used}/${disk_size} Gib]"
echo -n "[Load ${cpu_load}]"
echo -n "[Uptime ${uptime}]"
echo ""

