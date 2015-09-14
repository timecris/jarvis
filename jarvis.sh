#!/bin/bash
source ./common.sh

function Any_QST()
{
	Talk_To_Jjak "ANY_QST" "What+can+I+do+for+you?"
}

function Any_ANS()
{
	shopt -s nocasematch

	echo "JARVIS-Any_ANS-$1"
	if [[ "$1" =~ "music" && "$1" =~ "speaker" ]]; then
		find /root/music -name "*.mp3" -print | sort -n > /tmp/playlist.txt
		mplayer -noconsolecontrols -shuffle -ao alsa:device=speaker -playlist /tmp/playlist.txt &
	elif [[ "$1" =~ "music" && "$1" =~ "soundbar" ]]; then
		find /root/music -name "*.mp3" -print | sort -n > /tmp/playlist.txt
		mplayer -noconsolecontrols -shuffle -ao alsa:device=soundbar -playlist /tmp/playlist.txt &
	elif [[ "$1" =~ "classic" && "$1" =~ "speaker" ]]; then
		find /root/classic/classic_1 -name "*.mp3" -print | sort -n > /tmp/playlist.txt
		mplayer -noconsolecontrols -shuffle -ao alsa:device=speaker -playlist /tmp/playlist.txt &
	elif [[ "$1" =~ "classic" && "$1" =~ "soundbar" ]]; then
		find /root/classic/classic_1 -name "*.mp3" -print | sort -n > /tmp/playlist.txt
		mplayer -noconsolecontrols -shuffle -ao alsa:device=soundbar -playlist /tmp/playlist.txt &
	elif [[ "$1" =~ "tv" ]]; then
		irsend SEND_ONCE tv KEY_POWER
		sleep 1
		irsend SEND_ONCE soundbar KEY_POWER
		sleep 1
		irsend SEND_ONCE btv KEY_POWER
		sleep 1
	elif [[ "$1" =~ "connect" && "$1" =~ "soundbar" ]]; then
		a_mac=($(GetAudioMACByName "soundbar"))
		echo A_MAC-$a_mac

		irsend SEND_ONCE soundbar KEY_POWER
		sleep 3
		irsend SEND_ONCE soundbar KEY_3
		sleep 3
		irsend SEND_ONCE soundbar KEY_CONNECT
		sleep 7
		Talk_To_Jjak "TTS" "Now+is+preparing+to+connect"

		bluez-simple-agent hci0 $a_mac
		sleep 3
		bluez-test-device trusted $a_mac
		bluez-test-device trusted $a_mac yes
		sleep 3
		bluez-test-audio connect $a_mac

		#should verify connection
		#Fix me

		Talk_To_Jjak "TTS" "connect+successfully"
	elif [[ "$1" =~ "take" && "$1" =~ "picture" ]]; then
		fswebcam -p YUYV -d /dev/video0 -r 640x480 ./picture/picture.jpg > /dev/null 2>&1
	elif [[ "$1" =~ "turnon" && "$1" =~ "fan" ]]; then
		irsend SEND_ONCE fan KEY_POWER
	elif [[ "$1" =~ "turnoff" && "$1" =~ "fan" ]]; then
		irsend SEND_ONCE fan KEY_POWER2
	elif [[ "$1" =~ "spin" && "$1" =~ "fan" ]]; then
		irsend SEND_ONCE fan KEY_POWER
	else
		Talk_To_Jjak "TTS" "I+Can't+understand.+Please+repeat+again"
		print_args "JARVIS" "Wrong command. You said ($1)"    
	fi
}

function Music_QST()
{
	Talk_To_Jjak "MUSIC_QST" "Do+you+want+to+listen+music?"
}

function Music_ANS()
{
	echo "JARVIS-Music_ANS-$1"
	if [ "$1" == "yes" ]; then
		echo "JARVIS-Music_ANS-$1-OK"
		find /root/music -name "*.mp3" -print | sort -n > /tmp/playlist.txt
		#mplayer -noconsolecontrols -ao alsa:device=btheadset -playlist /tmp/playlist.txt &
		#mplayer -noconsolecontrols -ao alsa:device=soundbar -playlist /tmp/playlist.txt &
		mplayer -noconsolecontrols -shuffle -ao alsa:device=speaker -playlist /tmp/playlist.txt &
	fi
}

function Tv_QST()
{
	Talk_To_Jjak "TV_QST" "Do+you+want+to+watch+TV?"
}

function Tv_ANS()
{
	echo "JARVIS-Tv_ANS-$1"
	if [ "$1" == "yes" ]; then
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
	Talk_To_Jjak "TTS" "Hello+My+name+is+Jarvis."
	sleep 5
	Music_QST
}

function Disconnect()
{
	ipaddr=($(echo $1 | awk -F "|" '{print $1}'))
	#NAME=($(GetUserName $ipaddr))
	Talk_To_Jjak "TTS" "have+a+good+day+bye+bye"
}

function Person()
{
	if [ $1 == 0 ]; then
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
	BTN_CLICK)
		Any_QST "$PAYLOAD"
		;;
	ANY_ANS)
		Any_ANS "$PAYLOAD"
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
