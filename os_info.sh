ww_show_os_info_release_etc()
{
    cat /etc/os-release    # Shows OS name and version
    uname -a        # –  Displays kernel name, version, architecture, and more.
    hostnamectl     # –  Displays information about the hostname and OS version.
    lsb_release -a  # –  Displays Linux Standard Base (LSB) version information.
    uptime          # –  Shows how long the system has been running + number of users + system load.
    dmesg | head    # –  Displays boot messages and hardware information.
}
ww_show_os_amd_arm_intel() {
    lscpu | grep 'Architecture:\|Vendor ID:'
}
ww_show_os_info_hardware_etc() {
    lscpu    #–  Provides detailed CPU architecture information.
    lshw     #–  Displays comprehensive information about all hardware.
    lsblk    #–  Lists information about all block devices (disks and partitions).
    free -h  #–  Shows memory usage in a human-readable format.
    df -h    #–  Displays disk space usage in a human-readable format.
    lspci    #–  Lists PCI devices (e.g., GPUs, network cards).
    lsusb    #–  Lists USB devices connected to the system.
    ip addr show       #–  Shows IP addresses and network interfaces.
    nmcli device show  #–  Shows network connection information.
    ss -tuln           #–  Displays listening ports (TCP/UDP).
    ifconfig or ip a   #–  Shows detailed network interface information.
    mount                #–  Lists all mounted filesystems.
    cat /proc/mounts     #–  Displays mounted filesystems (similar to mount).
    du -sh /             #–  Shows disk usage for a specific directory.
}
