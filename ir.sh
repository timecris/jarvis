#!/bin/bash
source ./common.sh

function Handler()
{
        print_args "IR" "Handler dispatched - "$1""
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
		print_args "IR" "Starting irw process"
		irw > $IPC_IR &
	fi
}

init

if [[ ! -p $IPC_IR ]]; then
    rm $IPC_IR
    mkfifo $IPC_IR
fi

while true
do
    if read line < $IPC_IR; then
        if [[ "$line" == 'quit' ]]; then
            break
        fi
	
        checkret=($(CheckReady))
        if [[ "$checkret" == 'ready' ]]; then
                SetBlock "STATE"
                Handler "$line"
        fi
    fi
done

rm $IPC_IR
print_args "IR exiting"
