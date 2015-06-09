#!/bin/bash

HEART='♥'

# 1. find battery data
# for linux
if [[ $(uname) == 'Linux' ]]; then

	# check usual locations for battery folder
	if [[ -d $(echo /sys/class/power_supply/BAT?/ | cut -d " " -f 1) ]]
	then
		DIRECTORY=$(echo /sys/class/power_supply/BAT?/ | cut -d " " -f 1)
	elif [[ -d $(echo /proc/acpi/battery/BAT?/ | cut -d " " -f 1) ]]
	then
		DIRECTORY=$(echo /proc/acpi/battery/BAT?/ | cut -d " " -f 1)
	else
		exit 1
	fi

	# check different possibilities for storing the battery data
	if [[ -f "$DIRECTORY"charge_now ]]
	then
		current_charge=$(cat "$DIRECTORY"charge_now)
		total_charge=$(cat "$DIRECTORY"charge_full)
		design_charge=$(cat "$DIRECTORY"charge_full_design)
	elif [[ -f "$DIRECTORY"energy_now ]]
	then
		current_charge=$(cat "$DIRECTORY"energy_now)
		total_charge=$(cat "$DIRECTORY"energy_full)
		design_charge=$(cat "$DIRECTORY"energy_full_design)
	elif [[ -f "$DIRECTORY"energy_now ]]
	then
		current_charge=$(cat "$DIRECTORY"state | grep 'remaining capacity:' | awk '{print $3}')
		total_charge=$(cat "$DIRECTORY"info | grep 'last full capacity:' | awk '{print $4}')
		design_charge=$(cat "$DIRECTORY"BAT1/info | grep 'design capacity:' | awk '{print $3}')
	else
		exit 2
	fi

# for apple (not tested)
else
	battery_info=$(ioreg -rc AppleSmartBattery)
	current_charge=$(echo $battery_info | grep -o '"CurrentCapacity" = [0-9]\+' | awk '{print $3}')
	total_charge=$(echo $battery_info | grep -o '"MaxCapacity" = [0-9]\+' | awk '{print $3}')
	design_charge=$(echo $battery_info | grep -o '"DesignCapacity" = [0-9]\+' | awk '{print $3}')
fi

# 2. calcuate slots
charged_slots=$(echo "$current_charge/$design_charge*10" | bc -l | awk -F. '{print $1}')

dead_slots=$(echo "(1-$total_charge/$design_charge)*10" | bc -l | awk -F. '{print $1}')
if [[ $dead_slots -lt 1 ]]; then
	dead_slots=0
fi

# 3. print hearts
if [[ $charged_slots -ge 1 ]]
then
	echo -n '#[fg=red]'
	for i in $(seq 1 $charged_slots)
	do
		echo -n "$HEART"
	done
fi

if [[ $charged_slots -lt 10 ]]
then
	echo -n '#[fg=white]'
	for i in $(seq 1 $(echo "10-($charged_slots+$dead_slots)" | bc))
	do
		echo -n "$HEART"
	done
fi

if [[ $dead_slots -ge 1 ]]
then
	echo -n '#[fg=black]'
	for i in $(seq 1 $dead_slots)
	do
		echo -n "$HEART"
	done
fi

