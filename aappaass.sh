#!/bin/bash
# Script to make it quick to create a sink that isolates
# system sound from an app sound for desktop recordings
# with OBS. It also "reappends" the application to the
# outputs so that it can be heard as well as recorded.

function usage {
      echo "Usage: $0 [-h] [-s SINKNAME] [-r|-l|-p APPNAME]
	-h		Print this usage text and exits.
	-s SINKNAME	Specify a sink to be used as output excusively.
	-r		Remove loaded modules and sinks (undo changes).
	-l		Lists available processes and output sinks.
	-n RECSINKNAME	Specify recording sink name.
	-p PROCESS	Specify the process name that should have its sound
			monitored."
}

COMMAND=""
RECSINKNAME="recording_sink"

while getopts "hp:ln:rs:" ARG; do
  case $ARG in
    r)
      COMMAND="remove"
      ;;
    p)
      COMMAND="pass"
      APPNAME=$OPTARG
      ;;
    s)
      OUTSINK="$OPTARG"
      ;;
    l)
      COMMAND="list"
      ;;
    n)
      RECSINKNAME="$OPTARG"
      ;;
    h)
      usage
      exit 1
      ;;
  esac
done

if [[ $# -gt 2 || $# -eq 0 || $COMMAND == "" ]]
then
	usage
	exit 1
fi

if [[ -z $OUTSINK ]]
then
	export OUTSINK=$(pactl list sinks | grep -A 3 "Sink #" | grep "Name: " | sed 's/.*Name: //')
fi

if [[ "$COMMAND" == "pass" ]]
then
	LINES=1
	FOUND=0
	SINKNUMBER=""
	while [[ "$FOUND" -eq 0 ]]
	do
		BUFFER=$(pactl list sink-inputs | grep -B $LINES "application.process.binary = \"$APPNAME\"")
		if [[ -z "$BUFFER" ]]
		then
			echo "No sink found for such process name: $APPNAME"
			exit 2
		fi
		if [[ "$(echo $BUFFER | head -n 3)" =~ "Sink Input" ]]
		then
			SINKNUMBER=$(echo "$BUFFER" | grep "Sink Input" | sed 's/.*#\(.*\)$/\1/')
			FOUND=1
			break
		else
			LINES=$(( $LINES + 3 ))
		fi
	done
	echo "Found sink as $SINKNUMBER"

	pactl load-module module-null-sink sink_name=\"$RECSINKNAME\" sink_properties=device.description=\"rec_passthrough\" >> /tmp/addedmodules.list
	pactl move-sink-input $SINKNUMBER $RECSINKNAME

	for SINK in $OUTSINK
	do
		pactl load-module module-loopback source=$RECSINKNAME.monitor sink=$SINK rate=44100 >> /tmp/addedmodules.list
	done
elif [[ "$COMMAND" == "remove" ]]
then
	if [[ -f /tmp/addedmodules.list ]]
	then
		for MODULENUMBER in $(cat /tmp/addedmodules.list)
		do
			pactl unload-module $MODULENUMBER
		done
		rm /tmp/addedmodules.list
	else
		echo "Could not find added modules list."
	fi
else
	echo "Possible processes:"
	pactl list sink-inputs | grep -e "application.process.binary\|Sink Input"
	echo "Possible outputs:"
	pactl list sinks | grep -A 3 "Sink #" | grep -v "State:\|--"
fi
