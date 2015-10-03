#!/bin/bash
source ./common.sh

function getNewGoogleCookie()
{
	curl -c conf/cookie -L --location-trusted -H "$(cat conf/google)" "http://www.google.com/"
}

function SpeechToText()
{
	arecord -D plughw:0,0 -f cd -t wav -d 5 -r 16000 /tmp/out.wav 
	flac -f --best --sample-rate 16000 -o /tmp/out.flac /tmp/out.wav
	
	ret=("$(wget -O - -o /dev/null --post-file /tmp/out.flac --header="Content-Type: audio/x-flac; rate=16000" "http://www.google.com/speech-api/v2/recognize?lang=en-US&key=AIzaSyAe7fGX5otBNDK1krub_WvOj3Of7AFxJ4I&output=json")")
	text=("$(echo "$ret" | cut -f8 -d\")")
	echo "$text"
}

function checkCache()
{
        file=($(grep "$1" conf/sound.conf | awk -F "|" '{print $1}'))
        echo $file
}

function TextToSpeech()
{
	echo "TextToSpeech"
	STRING="$1"
	file=("$(checkCache "$STRING")")
	echo $file
	if [ "$file" == "" ]; then
		getNewGoogleCookie
		#wget -q -U Mozilla -O out.mp3 "http://translate.google.com/translate_tts?ie=UTF-8&tl=ko&q=$STRING"
		curl -b conf/cookie -o /tmp/out.mp3 -L --location-trusted -H "$(cat conf/google_tts)" "http://translate.google.com/translate_tts?ie=UTF-8&tl=en&q=$STRING"
		ranstr=($(GetRandomString))
		cp /tmp/out.mp3 sound/$ranstr.mp3
		echo "$ranstr.mp3|$STRING" >> conf/sound.conf
		mplayer -ao alsa:device=speaker sound/$ranstr.mp3 -channels 6 -af resample=48000,hrtf
	else
		mplayer -ao alsa:device=speaker sound/$file -channels 6 -af resample=48000,hrtf
	fi

	#mplayer -ao alsa:device=soundbar /tmp/out.mp3 -channels 6 -af resample=48000,hrtf
	#mplayer -ao alsa:device=btheadset /tmp/out.mp3 -channels 6 -af resample=48000,hrtf
}

function Handler()
{
	#echo "JJAK-HANDLE-$1"
	CMD=("$(echo "$1" | awk -F "@" '{print $1}')")
	PAYLOAD=("$(echo "$1" | awk -F "@" '{print $2}')")
	#echo "JJAK-CMD-"$CMD
	#echo "JJAK-PAYLOAD-$PAYLOAD"

	case "$CMD" in
	TTS)
		TextToSpeech "$PAYLOAD"
		;;
	MUSIC_QST)
		TextToSpeech "$PAYLOAD"
		ret=("$(SpeechToText)")
		echo "MUSIC_QST-$ret"
		text=("$(echo "$ret" | tr -d '\040\011\012\015')")
		echo "MUSIC_QST-$text"
		Talk_To_Jarvis "MUSIC_ANS" "$text"
		;;
	TV_QST)
		TextToSpeech "$PAYLOAD"
		ret=("$(SpeechToText)")
		echo "TV_QST-$ret"
		text=("$(echo "$ret" | tr -d '\040\011\012\015')")
		echo "TV_QST-$text"
		Talk_To_Jarvis "TV_ANS" "$text"
		;;
	ANY_QST)
		TextToSpeech "$PAYLOAD"
		ret=("$(SpeechToText)")
		echo "ANY_QST-$ret"
		text=("$(echo "$ret" | tr -d '\040\011\012\015')")
		echo "ANY_QST-$text"
		Talk_To_Jarvis "ANY_ANS" "$text"
		;;
	esac
}

SetRecordMixer
SetPlaybackMixer

if [[ ! -p $IPC_JJAK ]]; then
    rm $IPC_JJAK
    mkfifo $IPC_JJAK
fi

while true
do
    if read line < "$IPC_JJAK"; then
        if [[ "$line" == 'quit' ]]; then
            break
        fi

        Handler "$line"
    fi
done

rm $IPC_JJAK
echo "Jjak exiting"
