#!/bin/bash

HEART='♥'

# 1. find battery data
# for linux
if [[ `uname` == 'Linux' ]]; then
	# in modern Linux distributions files are located here
	if [ -d /sys/class/power_supply/BAT0/ ]
	then
		current_charge=$(cat /sys/class/power_supply/BAT0/charge_now)
		total_charge=$(cat /sys/class/power_supply/BAT0/charge_full)
		design_charge=$(cat /sys/class/power_supply/BAT0/charge_full_design)
	# in Mint 15 it's here
	elif [ -d /sys/class/power_supply/BAT1/ ]
	then
		current_charge=$(cat /sys/class/power_supply/BAT1/energy_now)
		total_charge=$(cat /sys/class/power_supply/BAT1/energy_full)
		design_charge=$(cat /sys/class/power_supply/BAT1/energy_full_design)
	# in older Linux (e. g. CentOS) the files are located here
	elif [ -d /proc/acpi/battery/BAT1/ ]
	then
		current_charge=$(cat /proc/acpi/battery/BAT1/state | grep 'remaining capacity:' | awk '{print $3}')
		total_charge=$(cat /proc/acpi/battery/BAT1/info | grep 'last full capacity:' | awk '{print $4}')
		design_charge=$(cat /proc/acpi/battery/BAT1/info | grep 'design capacity:' | awk '{print $3}')
	fi
	
# for apple (not tested)
else
	battery_info=`ioreg -rc AppleSmartBattery`
	current_charge=$(echo $battery_info | grep -o '"CurrentCapacity" = [0-9]\+' | awk '{print $3}')
	total_charge=$(echo $battery_info | grep -o '"MaxCapacity" = [0-9]\+' | awk '{print $3}')
	design_charge=$(echo $battery_info | grep -o '"DesignCapacity" = [0-9]\+' | awk '{print $3}')
fi

# 2. calcuate slots
charged_slots=$(echo "(($current_charge/$design_charge)*10)+1" | bc -l | awk -F. '{print $1}')
if [[ $charged_slots -gt 10 ]]; then
	charged_slots=10
fi

dead_slots=$(echo "(1-$total_charge/$design_charge)*10" | bc -l | awk -F. '{print $1}')
if [[ $dead_slots -lt 1 ]]; then
	dead_slots=0
fi

# 3. print hearts
echo -n '#[fg=red]'
for i in `seq 0 $charged_slots`
do
	echo -n "$HEART"
done

if [[ $charged_slots -lt 10 ]]
then
	echo -n '#[fg=white]'
	for i in `seq 1 $(echo "10-($charged_slots+$dead_slots)" | bc)`
	do
		echo -n "$HEART"
	done
fi

if [[ $dead_slots -ge 1 ]]
then
	echo -n '#[fg=black]'
	for i in `seq 1 $dead_slots`
	do
		echo -n "$HEART"
	done
fi
