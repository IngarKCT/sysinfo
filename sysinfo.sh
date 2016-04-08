#!/bin/sh
#
# sysinfo script by Ingar
#

#--- [ OS ] ---------------------------
host=`uname -n`
os=`uname -sr`
uptime=`uptime | sed -e 's/[ ][ ]*/ /g;s/ [0-9:]* up \(.*\), [0-9]* user.*/\1/'`

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
gpu=''
if which lspci 2>/dev/null; then
	gpu_slot=`lspci -mm | grep 'VGA' | head -n 1 | cut -f1 -d' '`
	gpu_vendor=`lspci -s "${gpu_slot}" -mm -v | grep '^Vendor' | sed -e 's/Vendor:\t//' | sed -e 's/.*[ ]\[//;s/\].*//' | sed -e 's/, Inc.//;s/ Corporation//;s/ Co.//;s/,Ltd.//'`
	gpu_model=`lspci -s "${gpu_slot}" -mm -v | grep '^Device' | sed -e 's/Device:\t//' | sed -e 's/.*[ ]\[//;s/\].*//'`
	gpu="${gpu_vendor} ${gpu_model}"
fi

#---[ OUTPUT ]------------------------

case "${1}" in
	'-l'|'--long')

		#---[ LONG VERSION ]-- 

		gpu_line=''
		if [ ! -z "${gpu}" ]; then
			gpu_line="[gpu]    ${gpu}"
		fi

		# output until EOF, strip leading TAB characters and empty lines
		grep -v '^$' <<-EOF
		[host]   ${host}
		[system] ${os}, uptime: ${uptime}, load: ${cpu_load}
		[cpu]    ${cpu}${cpu_count_notice}, ${cpu_speed} Mhz
		${gpu_line}
		[memory] ${mem_total} MiB total, ${mem_used} MiB used, ${mem_free} MiB free
		[swap]   ${swap_total} MiB total, ${swap_used} MiB used, ${swap_free} MiB free
		[disk]   ${disk_size} GiB total, ${disk_used} GiB used, ${disk_free} GiB free
		EOF
		;;
	*)
		#---[ SHORT VERSION ]-
		
		gpu_line=''
		if [ ! -z "${gpu}" ]; then
			gpu_line="[${gpu}]"
		fi

		# output until EOF, strip TAB characters
		tr -d "\t" <<-EOF
		[${host}]\
		[${os}]\
		[${cpu}${cpu_count_notice} @ ${cpu_speed} MHz]\
		${gpu_line}\
		[Memory used: ${mem_used}/${mem_total} MiB]\
		[Swap used: ${swap_used}/${swap_total} MiB]\
		[Disk used: ${disk_used}/${disk_size} GiB]\
		[Load ${cpu_load}]\
		[Uptime ${uptime}]
		EOF
		;;
esac

