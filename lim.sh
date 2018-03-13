#!/bin/bash

rnd_str() {
  cat /dev/urandom | tr -dc 'a-z0-9' | fold -w $1 | head -n 1
}

generate_uuid () {
  echo "$(rnd_str '8')-$(rnd_str '4')-$(rnd_str '4')-$(rnd_str '4')-$(rnd_str '12')"
}

cgroup_name="lim-$(generate_uuid)"

trap "cgdelete cpu,memory:$cgroup_name" INT TERM EXIT

cgcreate -g cpu,memory:/$cgroup_name
while getopts ":hm:c:" option
do
  case $option in
  m)
    cgset -r memory.limit_in_bytes=$OPTARG $cgroup_name
    ;;
  c)
    cgset -r cpu.shares=$OPTARG $cgroup_name
    ;;
  h)
    echo "usage: $0 [-h] [-c <cpu_shares>] [-m <memory_limit_in_bytes>] command" >&2
    exit 2
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
cgexec -g cpu,memory:$cgroup_name $*
exit 0
