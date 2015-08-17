#!/bin/bash
source ./common.sh

BUTTON_INTERVAL=1
BUTTON_SLEEP=10
BUTTON_GPIO=26

function loop_check()
{
	v=$(cat /sys/class/gpio/gpio$BUTTON_GPIO/value)
	if [ $v == 0 ]; then
		ShutUp
		Talk_To_Jarvis "BTN_CLICK" "1"
		sleep $BUTTON_SLEEP
	fi
}

function init()
{
	gpiof=/sys/class/gpio/gpio$BUTTON_GPIO/value
	if [ ! -f $gpiof ]; then
		echo $BUTTON_GPIO > /sys/class/gpio/export
	fi

}

function clean()
{
	echo $BUTTON_GPIO > /sys/class/gpio/unexport
}

init

while true
do 
	loop_check
	sleep $BUTTON_INTERVAL
done

clean
