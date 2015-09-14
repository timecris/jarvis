#!/bin/bash
source ./common.sh

function Handler()
{
        echo "HANDLE-$1"
	IR_HEX=($(echo "$1" | awk -F " " '{print $1}'))
	IR_CMD=($(echo "$1" | awk -F " " '{print $3}'))
	IR_DEV=($(echo "$1" | awk -F " " '{print $4}'))

        case $IR_CMD in
	KEY_1)
		if [ "$IR_DEV" == "rpi" ]; then
			ShutUp
			Talk_To_Jarvis "BTN_CLICK" "1"
		fi	
		;;
        KEY_POWER)
                echo "Power Manager"
                ;;
        esac
}

function init()
{
	pid=($(GetPid irw))
	if [[ "$pid" == "" ]]; then
		echo "Starting irw process"
		irw > $IPC_IR &
	fi
}

init

if [[ ! -p $IPC_IR ]]; then
    mkfifo $IPC_IR
fi

while true
do
    if read line < $IPC_IR; then
        if [[ "$line" == 'quit' ]]; then
            break
        fi
        Handler "$line"
    fi
done

echo "IR exiting"

