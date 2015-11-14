#!/bin/bash
source ./common.sh

function Any_QST()
{
	if [[ "$1" == "1" ]]; then
		Talk_To_Jjak "ANY_QST" "What+can+I+do+for+you?"
	elif [[ "$1" == "2" ]]; then
		Talk_To_Jjak "TTS" "Ok+I'll+play+the+classic"
		shopt -s nocasematch
		a_mac=($(GetAudioMACByName "soundbar"))
                SoundbarReadyToPair
                ConnectToSoundbar $a_mac
                find /mnt/data/music/classic_2 -name "*.mp3" -print | sort -n > /tmp/playlist.txt
		mpg123 -a soundbar --list /tmp/playlist.txt --shuffle &
                #mplayer -noconsolecontrols -shuffle -ao alsa:device=soundbar -playlist /tmp/playlist.txt &
    		SetReady "STATE"
	fi
}

function Any_ANS()
{
	shopt -s nocasematch
	a_mac=($(GetAudioMACByName "soundbar"))

	print_args "JARVIS" "Any_ANS - $1"
	if [[ "$1" =~ "music" && "$1" =~ "speaker" ]]; then
		find /root/music -name "*.mp3" -print | sort -n > /tmp/playlist.txt
		mpg123 -a speaker --list /tmp/playlist.txt --shuffle &
	elif [[ "$1" =~ "music" && "$1" =~ "soundbar" ]]; then
		SoundbarReadyToPair
		ConnectToSoundbar $a_mac
		find /root/music -name "*.mp3" -print | sort -n > /tmp/playlist.txt
		#mplayer -noconsolecontrols -shuffle -ao alsa:device=soundbar -playlist /tmp/playlist.txt &
		mpg123 -a speaker --list /tmp/playlist.txt --shuffle &
	elif [[ "$1" =~ "classic" && "$1" =~ "speaker" ]]; then
                find /mnt/data/music/classic_2 -name "*.mp3" -print | sort -n > /tmp/playlist.txt
		#mplayer -noconsolecontrols -shuffle -ao alsa:device=speaker -playlist /tmp/playlist.txt &
		mpg123 --list /tmp/playlist.txt --shuffle &
        elif [[ "$1" =~ "classic" || "$1" =~ "classy" ]] && [[ "$1" =~ "soundbar" ]]; then
                SoundbarReadyToPair
                ConnectToSoundbar $a_mac
                find /mnt/data/music/classic_2 -name "*.mp3" -print | sort -n > /tmp/playlist.txt
                #mplayer -noconsolecontrols -shuffle -ao alsa:device=soundbar -playlist /tmp/playlist.txt &
		mpg123 -a soundbar --list /tmp/playlist.txt --shuffle &
	elif [[ "$1" =~ "baby" && "$1" =~ "soundbar" ]]; then
                SoundbarReadyToPair
                ConnectToSoundbar $a_mac
                find /mnt/data/music/baby -name "*.mp3" -print | sort -n > /tmp/playlist.txt
                #mplayer -noconsolecontrols -shuffle -ao alsa:device=soundbar -playlist /tmp/playlist.txt &
		mpg123 -a soundbar --list /tmp/playlist.txt --shuffle &
	elif [[ "$1" =~ "billboard" && "$1" =~ "soundbar" ]]; then
                SoundbarReadyToPair
                ConnectToSoundbar $a_mac
                find /mnt/data/music/billboard -name "*.mp3" -print | sort -n > /tmp/playlist.txt
                #mplayer -noconsolecontrols -ao alsa:device=soundbar -playlist /tmp/playlist.txt &
		mpg123 -a soundbar --list /tmp/playlist.txt --shuffle &
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
		date=($(date "+%Y%m%d_%H%M%S"))
		fswebcam -p YUYV -d /dev/video0 -r 1024x768 /mnt/data/picture/cam/"$date".jpg > /dev/null 2>&1
	elif [[ "$1" =~ "turnon" && "$1" =~ "fan" ]]; then
		irsend SEND_ONCE fan KEY_POWER
	elif [[ "$1" =~ "turnoff" && "$1" =~ "fan" ]]; then
		irsend SEND_ONCE fan KEY_POWER2
	elif [[ "$1" =~ "spin" && "$1" =~ "fan" ]]; then
		irsend SEND_ONCE fan KEY_POWER
	elif [[ "$1" =~ "what" && "$1" =~ "date" ]]; then
		ret=($(date "+Today+is+%B+%e+It's+%A" | tr -d '\040'))
		Talk_To_Jjak "TTS" "$ret"
	elif [[ "$1" =~ "what" && "$1" =~ "weather" ]]; then
		if [[ "$1" =~ "today" ]]; then
			ret=0
			str="today"
		elif [[ "$1" =~ "tomorrow"  ]]; then
			ret=1
			str="tomorrow"
		elif [[ "$1" =~ "aftertomorrow"  ]]; then
			ret=2
			str="after+tomorrow"
		elif [[ "$1" =~ "twodaysaftertomorrow"  ]]; then
			ret=3
			str="two+days+after+tomorrow"
		elif [[ "$1" =~ "saturday"  ]]; then
			ret=$((6 - ($(date +%u)) ))
			str="saturday"
		elif [[ "$1" =~ "sunday"  ]]; then
			ret=$((7 - ($(date +%u)) ))
			str="sunday"
		fi
		curl -o weather "http://api.openweathermap.org/data/2.5/forecast/daily?q=Seoul&mode=json&units=metric&cnt=15&APPID=$OWM_KEY"

		weather_temp_min=($(./json/JSON.sh -l < weather | egrep '\["list",'$ret',"temp","min"\]' | awk -F "\t" '{print $2}' | awk '{print int($1+0.5)}'))
		weather_temp_max=($(./json/JSON.sh -l < weather | egrep '\["list",'$ret',"temp","max"\]' | awk -F "\t" '{print $2}' | awk '{print int($1+0.5)}'))
		weather_description="$(./json/JSON.sh -l < weather | egrep '\["list",'$ret',"weather",0,"description"\]' | awk -F "\t" '{print $2}' | tr "\040" "\053")"
		weather_humidity=($(./json/JSON.sh -l < weather | egrep '\["list",'$ret',"humidity"\]' | awk -F "\t" '{print $2}'))

		print_args "JARVIS" "Weather RET-$ret"

		Talk_To_Jjak "TTS" "$str+weather+is+$weather_description+and+the+high+will+be+$weather_temp_max+degrees+and+the+low+$weather_temp_min+degrees."
	else
		if [[ "$1" != "" ]]; then
			Talk_To_Jjak "TTS" "I+Can't+understand.+Please+repeat+again"
		fi
	fi
    	SetReady "STATE"
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
	LED_ON)
		Talk_To_Jjak "TTS" "Turn+on+the+LED"
		;;
	esac
}

function init()
{
	#set ready to run
	echo "STATE|1" > $FILE_STATE
}

init

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
	
        Handler "$line"
    fi
done

rm $IPC_JARVIS
print_args "Jarvis exiting"
