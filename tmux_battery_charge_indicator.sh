#!/bin/bash

# global variables
total_slots=10

# 1. find battery data
function find_battery_data {
	# for linux
	if [[ $(uname) == "Linux" ]]
	then

		# check usual locations for battery folder
		if [[ -d $(echo /sys/class/power_supply/BAT?/ | cut -d " " -f 1) ]]
		then
			directories=$(echo /sys/class/power_supply/BAT?/)
		elif [[ -d $(echo /proc/acpi/battery/BAT?/ | cut -d " " -f 1) ]]
		then
			directories=$(echo /proc/acpi/battery/BAT?/)
		else
			exit 1
		fi

		# check different possibilities for storing the battery data
		for directory in ${directories}
		do
			if [[ -f "${directory}charge_now" ]]
			then
				((current_charge+=$(cat "${directory}charge_now")))
				((total_charge+=$(cat "${directory}charge_full")))
				((design_charge+=$(cat "${directory}charge_full_design")))
			elif [[ -f "${directory}energy_now" ]]
			then
				((current_charge+=$(cat "${directory}energy_now")))
				((total_charge+=$(cat "${directory}energy_full")))
				((design_charge+=$(cat "${directory}energy_full_design")))
			elif [[ -f "${directory}state" ]]
			then
				((current_charge+=$(grep "remaining capacity:" "${directory}state" | cut -d " " -f 3)))
				((total_charge+=$(grep "last full capacity:" "${directory}info" | cut -d " " -f 4)))
				((design_charge+=$(grep "design capacity:" "${directory}info" | cut -d " " -f 3)))
			else
				exit 2
			fi
		done

	# for apple (not tested)
	else
		battery_info=$(ioreg -rc AppleSmartBattery)
		current_charge=$(echo ${battery_info} | grep -o '"CurrentCapacity" = [0-9]\+' | cut -d " " -f 3)
		total_charge=$(echo ${battery_info} | grep -o '"MaxCapacity" = [0-9]\+' | cut -d " " -f 3)
		design_charge=$(echo ${battery_info} | grep -o '"DesignCapacity" = [0-9]\+' | cut -d " " -f 3)
	fi

	echo ${current_charge}
	echo ${total_charge}
	echo ${design_charge}
}

# 2. calcuate slots
# $1 current charge
# $2 total charge
# $3 design charge
# ceil(x/y)=(x+y-1)/y with integer arithmetic
function calculate_slots {
	current_charge=$1
	total_charge=$2
	design_charge=$3

	charged_slots=$(((${current_charge}*${total_slots}+${design_charge}-1)/${design_charge}))

	dead_slots=$((${total_slots}-(${total_charge}*${total_slots}+${design_charge}-1)/${design_charge}))
	if [[ ${dead_slots} -lt 1 ]]
	then
		dead_slots=0
	fi

	echo ${charged_slots}
	echo ${dead_slots}
}

# 3. print hearts
# $1 number of charged slots
# $2 number of dead slots
function print_hearts {
	charged_slots=$1
	dead_slots=$2

	heart="♥"

	if [[ ${charged_slots} -ge 1 ]]
	then
		echo -n "#[fg=red]"
		for i in $(seq 1 ${charged_slots})
		do
			echo -n "${heart}"
		done
	fi

	if [[ ${charged_slots} -lt ${total_slots} ]]
	then
		echo -n "#[fg=white]"
		for i in $(seq 1 $((${total_slots}-(${charged_slots}+${dead_slots}))))
		do
			echo -n "${heart}"
		done
	fi

	if [[ ${dead_slots} -ge 1 ]]
	then
		echo -n "#[fg=black]"
		for i in $(seq 1 ${dead_slots})
		do
			echo -n "${heart}"
		done
	fi
}

charges=$(find_battery_data)
slots=$(calculate_slots ${charges})
print_hearts ${slots}
