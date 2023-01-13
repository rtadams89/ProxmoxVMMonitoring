#!/bin/bash
SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
runningvms=$(qm list --full | grep -v 'VMID' | grep 'running' | awk '{ print $1 }')
havms=$(grep 'vm:' /etc/pve/ha/resources.cfg | awk '{ print $2 }')
for VMID in $runningvms
do
	if [[ " ${havms[*]} " == *"$VMID"* ]]; then  
		echo "Checking VM $VMID now"
		qm agent $VMID ping
		if test $? -ne 0; then
			TIMESTAMPSECONDS="$(date -r $SCRIPTPATH/$VMID.lastup +%s)" 
			COMPARISON="$(date -d "5 minutes ago" +%s)"
			if [[ "${TIMESTAMPSECONDS}" -lt "${COMPARISON}" ]]; then
				echo "VM $VMID has been frozen for 5 minutes...resetting..."
				logger "VMMonitoring: VM $VMID has been frozen for 5 minutes...resetting..."
				qm reset $VMID
			else
				echo "VM $VMID has been frozen for less than 5 minutes...not taking action yet..."
				logger "VMMonitoring: VM $VMID has been frozen for less than 5 minutes...not taking action yet..."
			fi
		else
			echo "VM $VMID is OK"
			touch $SCRIPTPATH/$VMID.lastup
		fi
	else
		echo "Skipping VM $VMID as it is not configured for HA"
	fi
done
