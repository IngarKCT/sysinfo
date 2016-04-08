# sysinfo

Shell script for Linux to show essential system information.

This script can be used to show off your computer specs on IRC.

Example output:

    $ sysinfo
    [aeon][Linux 4.4.5-1-ARCH][Intel Core i7-6700K CPU * 8 cores @ 900/4200 MHz][NVIDIA GeForce GTX 970][Memory used: 14599/16044 MiB][Swap used: 0/16383 MiB][Disk used: 68/716 GiB][Load 0.04][Uptime 1:25]

    $ sysinfo -l
    [host]   aeon
    [system] Linux 4.4.5-1-ARCH, uptime: 1:25, load: 0.04
    [cpu]    Intel Core i7-6700K CPU * 8 cores, 3328/4200 Mhz
    [gpu]    NVIDIA GeForce GTX 970
    [memory] 16044 MiB total, 14598 MiB used, 1446 MiB free
    [swap]   16383 MiB total, 0 MiB used, 16383 MiB free
    [disk]   716 GiB total, 68 GiB used, 645 GiB free
    
### License

This script is licensed as CC0 1.0 Universal

You can copy, modify, distribute and perform the work, even for commercial purposes, all without asking permission.

See https://creativecommons.org/publicdomain/zero/1.0/ for more information.
