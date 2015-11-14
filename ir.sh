#!/bin/bash
source ./common.sh

function Handler_IR()
{
        print_args "IR" "Handler dispatched - "$1""
	IR_HEX=($(echo "$1" | awk -F " " '{print $1}'))
	IR_CMD=($(echo "$1" | awk -F " " '{print $3}'))
	IR_DEV=($(echo "$1" | awk -F " " '{print $4}'))

        case $IR_CMD in
	KEY_X)
		if [[ "$IR_DEV" =~ "jarvis" ]]; then
			ShutUp
                	SetBlock "STATE"
			Talk_To_Jarvis "BTN_CLICK" "1"
		fi	
		;;
	KEY_Y)
		if [[ "$IR_DEV" =~ "jarvis" ]]; then
			ShutUp
                	SetBlock "STATE"
			Talk_To_Jarvis "BTN_CLICK" "2"
		fi	
		;;

        KEY_POWER)
                echo "Power Manager"
                ;;
        esac
}

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
                Handler_IR "$line"
        fi
    fi
done

print_args "IR exiting"
