#!/bin/bash
source ./common.sh

BUTTON_INTERVAL=1
BUTTON_GPIO=26

function loop_check()
{
	v=$(cat /sys/class/gpio/gpio$BUTTON_GPIO/value)
	if [ $v == 0 ]; then
		#TalkToJarvis "BUTTON_CLICK" "CLICK"
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
