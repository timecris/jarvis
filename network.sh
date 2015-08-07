#!/bin/bash
source ./common.sh

NETWORK_INTERVAL=3
NETWORK_CHECK_TIMES=3

net_repeat_cnt=()
net_repeat_value=()

function Connection_Check() 
{
	#ret=("$(ping $1 -w 3 | grep ttl)")
	ret=("$(l2ping -t 3 -c 3 $1 | grep time)")
	if [ "$ret" = "" ] ; then
		echo 0
	else 
		echo 1
	fi
}

function loop_check()
{
	for (( i = 0; i < ${#USER_MAC[@]}; i++ ))
	do
		before_state=($(cat $FILE_CONN | grep ${USER_MAC[$i]} | awk -F "|" '{print $2}'))
		cur_state=($(Connection_Check ${USER_MAC[$i]}))

		if [ "$cur_state" == "$before_state" ]; then
			net_repeat_cnt[$i]=0
			net_repeat_value[$i]=0
		else
			if [ ${net_repeat_cnt[$i]} == 0 ]; then
				net_repeat_value[$i]=$cur_state
			fi

			if [ ${net_repeat_value[$i]} == $cur_state ]; then
				net_repeat_cnt[$i]=$((${net_repeat_cnt[$i]}+1))
			fi
			print_args "NETWORK" "Checking ${USER_MAC[$i]} ($before_state->$cur_state) (${net_repeat_cnt[$i]}/$NETWORK_CHECK_TIMES) Times"

	                if [ ${net_repeat_cnt[$i]} == $NETWORK_CHECK_TIMES ]; then
				net_repeat_cnt[$i]=0
				print_args "NETWORK" "Changed ${USER_MAC[$i]} state from $before_state to $cur_state"
				cmd="sed -i -e 's/${USER_MAC[$i]}|.*/${USER_MAC[$i]}|$cur_state/g' $FILE_CONN"
				eval $cmd
				if [ $cur_state == 1 ]; then
					Talk_To_Jarvis "CONNECT" "${USER_MAC[$i]}|$cur_state"
				else 
					Talk_To_Jarvis "DISCONNECT" "${USER_MAC[$i]}|$cur_state"
				fi
			fi
		fi
	done
}

function init()
{
	truncate -s 0 $FILE_CONN
        for (( i = 0; i < ${#USER_MAC[@]}; i++ ))
        do
                ret=($(Connection_Check ${USER_MAC[$i]}))
		echo "${USER_MAC[$i]}|$ret" >> $FILE_CONN
		net_repeat_cnt[$i]=0
		net_repeat_value[$i]=0
        done
}

init 

while true
do 
	loop_check
	sleep $NETWORK_INTERVAL
done
