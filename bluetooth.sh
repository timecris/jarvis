#!/bin/bash
source ./common.sh

BT_MAC=()
BT_ALIAS=()

BT_MAC=($(grep "pcm.* {" ~/.asoundrc | awk -F "." '{print $2}' | awk -F " " '{print $1}'))
BT_ALIAS=($(grep "device" ~/.asoundrc | awk '{print $2}'))

function Connection_Check() 
{
	ret=($(ping $1 -c 3 | grep ttl))
	if [ "$ret" = "" ] ; then
		echo 0
	else 
		echo 1
	fi
}

function loop_check()
{
	for (( i = 0; i < ${#BT_MAC[@]}; i++ ))
	do
		ret=($(Connection_Check ${BT_MAC[$i]}))

		cur_state=($(cat $FILE_CONN | grep ${BT_MAC[$i]} | awk -F "|" '{print $2}'))

		if [ $ret == $cur_state ]; then
			continue
		else
			print_args "Changed ${BT_MAC[$i]} state from $cur_state to $ret"
                	cmd="sed -i -e 's/${BT_MAC[$i]}|.*/${BT_MAC[$i]}|$ret/g' $FILE_CONN"
			eval $cmd
			if [ $ret == 1 ]; then
				Talk_To_Jarvis "CONNECT" "${BT_MAC[$i]}|$ret"
			else 
				Talk_To_Jarvis "DISCONNECT" "${BT_MAC[$i]}|$ret"
			fi
		fi
	done
}

function init()
{
	truncate -s 0 $FILE_CONN
        for (( i = 0; i < ${#BT_MAC[@]}; i++ ))
        do
                ret=($(Connection_Check ${BT_MAC[$i]}))
		echo "${BT_MAC[$i]}|$ret" >> $FILE_CONN
                eval $cmd
        done
}

init 

while true
do 
	loop_check
	sleep $INTERVAL
done
