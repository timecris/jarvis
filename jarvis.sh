#!/bin/bash
source ./common.sh

function Music_QST()
{
	Talk_To_Jjak "MUSIC_QST" "노래+들으실래요?"
}

function Music_ANS()
{
	echo "JARVIS-Music_ANS-$1"
	if [ "$1" == "응들려줘" -o "$1" == "응알려줘" ]; then
		echo "JARVIS-Music_ANS-$1-OK"
		find /root/music -name "*.mp3" -print | sort -n > /tmp/playlist.txt
		#mplayer -noconsolecontrols -ao alsa:device=btheadset -playlist /tmp/playlist.txt &
		#mplayer -noconsolecontrols -ao alsa:device=soundbar -playlist /tmp/playlist.txt &
		mplayer -noconsolecontrols -playlist /tmp/playlist.txt &
	fi
}

function Tv_QST()
{
	Talk_To_Jjak "TV_QST" "티비+보실래요?"
}

function Tv_ANS()
{
	echo "JARVIS-Tv_ANS-$1"
	if [ "$1" == "응들려줘" -o "$1" == "응알려줘" -o "$1" == "응보여줘" -o "$1" == "보여줘" ]; then
		echo "JARVIS-Tv_ANS-$1-OK"
		sleep 3
		irsend SEND_ONCE tv KEY_POWER
		sleep 1
		irsend SEND_ONCE soundbar KEY_POWER
		sleep 1
		irsend SEND_ONCE btv KEY_POWER
		sleep 1
		irsend SEND_ONCE fan KEY_POWER
		sleep 1
	fi
}

function Connect()
{
	ipaddr=($(echo $1 | awk -F "|" '{print $1}'))
	#NAME=($(GetUserName $ipaddr))
	Talk_To_Jjak "TTS" "고생많으셨습니다"
	sleep 5
	Music_QST
}

function Disconnect()
{
	ipaddr=($(echo $1 | awk -F "|" '{print $1}'))
	#NAME=($(GetUserName $ipaddr))
	Talk_To_Jjak "TTS" "안녕히+가세요+이건테스트에요"
}

function Person()
{
	if [ $1 == 0 ]; then
		Talk_To_Jjak "TTS" "자러+가는+거에요?+안녕히+주무세요+티비는+제가+끌께요"
		sleep 3
                irsend SEND_ONCE tv KEY_POWER
		sleep 1
                irsend SEND_ONCE soundbar KEY_POWER
		sleep 1
                irsend SEND_ONCE btv KEY_POWER
		sleep 1
                irsend SEND_ONCE fan KEY_POWER2
		sleep 1
	elif [ $1 == 1 -o $1 == 2 ]; then
		Tv_QST
	fi
}

function Handler()
{
	echo "HANDLE-$1"
	CMD=($(echo "$1" | awk -F "@" '{print $1}'))
	PAYLOAD=("$(echo "$1" | awk -F "@" '{print $2}')")
	echo "CMD-$CMD"

	case $CMD in
	CONNECT)
		Connect $PAYLOAD
		;;
	DISCONNECT)
		Disconnect $PAYLOAD
		;;
	MUSIC_ANS)
		Music_ANS "$PAYLOAD"
		;;
	TV_ANS)
		Tv_ANS "$PAYLOAD"
		;;
	PERSON)
		Person "$PAYLOAD"
		;;
	esac
}

if [[ ! -p $IPC_JARVIS ]]; then
    mkfifo $IPC_JARVIS
fi

while true
do
    if read line < $IPC_JARVIS; then
        if [[ "$line" == 'quit' ]]; then
            break
        fi	
	Handler $line
    fi
done

echo "Jarvis exiting"
