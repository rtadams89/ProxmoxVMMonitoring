# ProxmoxVMMonitoring

This script attempts to connect to the qemu-guest-agent on each running VM. If it succeeds, it records the time of connection. If it fails, it compares the current time to the last successful connection, and if that time exceeds a threshold, it resets the VM.

First download the script and place in /etc/pve/vmmonitoring/

Create a custom cron file:

nano /etc/pve/customcron.cron

    # cluster wide custom cron jobs
    PATH="/usr/sbin:/usr/bin:/sbin:/bin"
    */1 * * * * root bash /etc/pve/vmmonitoring/reset_frozen_vms.sh
    
Link the custom file to the system cron directory:

ln -s /etc/pve/customcron.cron /etc/cron.d/customcron
