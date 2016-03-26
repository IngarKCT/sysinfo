#!/bin/sh
#
# sysinfo script by Ingar
#

#--- [ OS ] ---------------------------
host=`uname -n`
os=`uname -sr`
uptime=`uptime | sed -e 's/[ ][ ]*/ /g;s/ [0-9:]* up \(.*\), [0-9]* users.*/\1/'`

#--- [ MEMORY ] -----------------------
mem_total=`cat /proc/meminfo | grep -i MemTotal | awk '{printf "%d",$2/1024;}'`
mem_free=`free  | tail -n2 | head -n1 | sed 's/^.*://' | awk '{printf "%d",$2/1024;}'`
mem_used=`echo ${mem_total} ${mem_free} | awk '{printf "%d",$1-$2;}'`

swap_total=`cat /proc/meminfo | grep -i SwapTotal | awk '{printf "%d",$2/1024;}'`
swap_free=`cat /proc/meminfo | grep -i SwapFree | awk '{printf "%d",$2/1024;}'`
swap_used=`echo ${swap_total} ${swap_free} | awk '{printf "%d",$1-$2;}'`

#--- [ CPU ] --------------------------
cpu=`cat /proc/cpuinfo | grep "model name" | head -n 1 | sed 's/[ ][ ]*/ /g;s/^.*: //' | sed -e 's/ @ .*//' | sed -e 's/ [A-Za-z]*[ -]Core Processor//' | sed -e 's/([Tt][Mm])//;s/([Rr])//'`
if [ -z "${cpu}" ]; then
	# fallback
	cpu=`uname -p`
fi
cpu_speed=`cat /proc/cpuinfo | grep '^cpu MHz' | head -n 1 | cut -f2 -d':' | cut -c2- | cut -f1 -d'.'`
cpu_load=` cat /proc/loadavg | cut -d " " -f 1 | sed 's/,//'`

cpu_count=`grep '^processor' /proc/cpuinfo | wc -l`
if [ "${cpu_count}" -gt 1 ]
then
	cpu_count_notice=" * ${cpu_count} cores"
fi

# Detect frequency scaler
if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ]; then
	cpu_speed_max=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq | awk '{ printf "%d", $1/1000;}'`
	cpu_speed_current=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq | awk '{ printf "%d", $1/1000;}'`
	cpu_speed="${cpu_speed_current}/${cpu_speed_max}"
fi

#---[ HD ] ----------------------------
sua=`grep 'nodev' '/proc/filesystems' | sed -e 's/nodev\t/-x /' | xargs df --local --total | tail -n 1`
disk_size=`echo $sua | awk '{printf "%d",$2/1048576;}'`;
disk_used=`echo $sua | awk '{printf "%d",$3/1048576;}'`;
disk_free=`echo $sua | awk '{printf "%d",$4/1048576;}'`;

#---[ VGA ] ---------------------------
vga=""
if [ -x `which lspci` ]; then
	vga=`lspci | grep VGA | cut -d ":" -f 3 | sed 's/ *(rev.*//' | sed 's/^ *//' | sed 's/^.*\[//' | sed 's/\].*//'`
fi

case "${1}" in
	'-l'|'--long')

#---[ PRINT LONG VERSION ]-------------

		vga_line=''
		if [ ! -z "${vga}" ]; then
			vga_line="[vga]    ${vga}"
		fi

		grep -v '^$' <<-EOF
		[host]   ${host}
		[system] ${os}, uptime: ${uptime}, load: ${cpu_load}
		[cpu]    ${cpu}${cpu_count_notice}, ${cpu_speed} Mhz
		${vga_line}
		[memory] ${mem_total} Mib total, ${mem_used} Mib used, ${mem_free} Mib free
		[swap]   ${swap_total} Mib total, ${swap_used} Mb used, ${swap_free} Mib free
		[disk]   ${disk_size} Gib total, ${disk_used} Gib used, ${disk_free} Gib free
		EOF

		exit
	;;
esac

#--- [ PRINT SHORT VERSION ]----------

echo -n "[${host}]"
echo -n "[${os}]"
echo -n "[${cpu}${cpu_count_notice} @ ${cpu_speed} MHz]"
if [ ! -z "${vga}" ]; then
	echo -n "[${vga}]"
fi
echo -n "[Memory used: ${mem_used}/${mem_total} Mib]"
echo -n "[Swap used: ${swap_used}/${swap_total} Mib]"
echo -n "[Disk used: ${disk_used}/${disk_size} Gib]"
echo -n "[Load ${cpu_load}]"
echo -n "[Uptime ${uptime}]"
echo ""

