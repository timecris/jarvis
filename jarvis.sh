#!/bin/bash
source ./common.sh

function Any_QST()
{
	Talk_To_Jjak "ANY_QST" "What+can+I+do+for+you?"
}

function Any_ANS()
{
	shopt -s nocasematch
	a_mac=($(GetAudioMACByName "soundbar"))

	print_args "JARVIS" "Any_ANS - $1"
	if [[ "$1" =~ "music" && "$1" =~ "speaker" ]]; then
		find /root/music -name "*.mp3" -print | sort -n > /tmp/playlist.txt
		mplayer -noconsolecontrols -shuffle -ao alsa:device=speaker -playlist /tmp/playlist.txt &
	elif [[ "$1" =~ "music" && "$1" =~ "soundbar" ]]; then
		SoundbarReadyToPair
		ConnectToSoundbar $a_mac
		find /root/music -name "*.mp3" -print | sort -n > /tmp/playlist.txt
		mplayer -noconsolecontrols -shuffle -ao alsa:device=soundbar -playlist /tmp/playlist.txt &
	elif [[ "$1" =~ "classic" && "$1" =~ "speaker" ]]; then
		find /root/classic/classic_1 -name "*.mp3" -print | sort -n > /tmp/playlist.txt
		mplayer -noconsolecontrols -shuffle -ao alsa:device=speaker -playlist /tmp/playlist.txt &
	elif [[ "$1" =~ "classy" && "$1" =~ "soundbar" ]]; then
		SoundbarReadyToPair
		ConnectToSoundbar $a_mac
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
		SoundbarReadyToPair
		ConnectToSoundbar $a_mac
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
	if [[ "$1" =~ "yes" && "$1" =~ "speaker" ]]; then
		find /root/music -name "*.mp3" -print | sort -n > /tmp/playlist.txt
		mplayer -noconsolecontrols -shuffle -ao alsa:device=speaker -playlist /tmp/playlist.txt &
	elif [[ "$1" =~ "yes" && "$1" =~ "soundbar" ]]; then
		a_mac=($(GetAudioMACByName "soundbar"))
		SoundbarReadyToPair
		ConnectToSoundbar $a_mac
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
}

function Disconnect()
{
	ipaddr=($(echo $1 | awk -F "|" '{print $1}'))
	#NAME=($(GetUserName $ipaddr))
	Talk_To_Jjak "TTS" "have+a+good+day+bye+bye"
}

function Handler()
{
	CMD=($(echo "$1" | awk -F "@" '{print $1}'))
	PAYLOAD=("$(echo "$1" | awk -F "@" '{print $2}')")
	print_args "JARVIS" "Handler dispatched - CMD:"$CMD" PAYLOAD:$PAYLOAD"
	
	case $CMD in
	CONNECT)
		Connect "$PAYLOAD"
		Any_QST "$PAYLOAD"
		;;
	DISCONNECT)
		Disconnect "$PAYLOAD"
		;;
	MUSIC_ANS)
		Music_ANS "$PAYLOAD"
		;;
	TV_ANS)
		Tv_ANS "$PAYLOAD"
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
    rm $IPC_JARVIS
    mkfifo $IPC_JARVIS
fi

while true
do
    if read line < $IPC_JARVIS; then
        if [[ "$line" == 'quit' ]]; then
            break
        fi	
	Handler $line
	cat $IPC_JARVIS > /dev/null
    fi
done

print_args "Jarvis exiting"
