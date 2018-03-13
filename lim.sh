#!/bin/bash

cgcreate -g cpu,memory:/lim
trap "cgdelete cpu,memory:lim" INT TERM EXIT
while getopts ":m:c:" option
do
	case $option in
		m)
			cgset -r memory.limit_in_bytes=$OPTARG memorylim
			;;
		c)
		vim 	cgset -r cpu.shares=$OPTARG cpulim
			;;
		:)
			echo "The $OPTARG options requires an argument" >&2
			exit 1
			;;
		\?)
			echo "$OPTARG : invalid option"
			exit 1
			;;
	esac
done

shift $((OPTIND-1))
sudo cgexec -g cpui,memory:/cpulim eval $*
exit 0
