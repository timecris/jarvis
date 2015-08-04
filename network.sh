#!/bin/bash
source ./common.sh

NETWORK_INTERVAL=3
NETWORK_CHECK_TIMES=3

net_repeat_cnt=()
net_repeat_value=()

function Connection_Check() 
{
	ret=($(ping $1 -w 3 | grep ttl))
	if [ "$ret" = "" ] ; then
		echo 0
	else 
		echo 1
	fi
}

function loop_check()
{
	for (( i = 0; i < ${#USER_IP[@]}; i++ ))
	do
		before_state=($(cat $FILE_CONN | grep ${USER_IP[$i]} | awk -F "|" '{print $2}'))
		cur_state=($(Connection_Check ${USER_IP[$i]}))

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
			print_args "NETWORK" "Checking ${USER_IP[$i]} ($before_state->$cur_state) (${net_repeat_cnt[$i]}/$NETWORK_CHECK_TIMES) Times"

	                if [ ${net_repeat_cnt[$i]} == $NETWORK_CHECK_TIMES ]; then
				net_repeat_cnt[$i]=0
				print_args "NETWORK" "Changed ${USER_IP[$i]} state from $before_state to $cur_state"
				cmd="sed -i -e 's/${USER_IP[$i]}|.*/${USER_IP[$i]}|$cur_state/g' $FILE_CONN"
				eval $cmd
				if [ $cur_state == 1 ]; then
					Talk_To_Jarvis "CONNECT" "${USER_IP[$i]}|$cur_state"
				else 
					Talk_To_Jarvis "DISCONNECT" "${USER_IP[$i]}|$cur_state"
				fi
			fi
		fi
	done
}

function init()
{
	truncate -s 0 $FILE_CONN
        for (( i = 0; i < ${#USER_IP[@]}; i++ ))
        do
                ret=($(Connection_Check ${USER_IP[$i]}))
		echo "${USER_IP[$i]}|$ret" >> $FILE_CONN
                eval $cmd
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
