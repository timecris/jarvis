#!/bin/bash
source ./common.sh

CAPTURE_DEVICE=/dev/video0
CAPTURE_IMAGE=/tmp/in.jpg
CAPTURE_SIZE="640x480"
CAPTURE_INTERVAL=3
CAPTURE_CHECK_TIMES=5

capture_repeat_cnt=0
capture_repeat_value=0

function Person_Check() 
{
	fswebcam -p YUYV -d $CAPTURE_DEVICE -r $CAPTURE_SIZE $CAPTURE_IMAGE > /dev/null 2>&1
	person_cnt=($(python ./opencv/face.py))

	echo $person_cnt
}

function loop_check()
{
	cur_cnt=($(Person_Check))
	before_cnt=($(cat $FILE_CAPTURE))

	#echo "BEFORE_CNT-$before_cnt"
	#echo "CUR_CNT-$cur_cnt"

	if [ $before_cnt == $cur_cnt ]; then
		capture_repeat_cnt=0
		capture_repeat_value=0
	else
		if [ $capture_repeat_cnt == 0 ]; then
			capture_repeat_value=$cur_cnt
		fi
		if [ $capture_repeat_value == $cur_cnt ]; then
			capture_repeat_cnt=$((capture_repeat_cnt+1))
		fi
		print_args "CAPTURE" "Checking ($before_cnt->$cur_cnt) ($capture_repeat_cnt/$CAPTURE_CHECK_TIMES) Times"

		if [ $capture_repeat_cnt == $CAPTURE_CHECK_TIMES ]; then
			capture_repeat_cnt=0
			echo "$cur_cnt" > "$FILE_CAPTURE"
			Talk_To_Jarvis "PERSON" "$cur_cnt"
			print_args "CAPTURE" "Changed person count $before_cnt->$cur_cnt"
		fi
	fi
}

function init()
{
	truncate -s 0 $FILE_CAPTURE
	person_cnt=($(Person_Check))

	echo "$person_cnt" > "$FILE_CAPTURE"
}

init 

while true
do 
	loop_check
	sleep $CAPTURE_INTERVAL
done
