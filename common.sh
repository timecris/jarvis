IPC_JARVIS=/tmp/jarvis
IPC_JJAK=/tmp/jjak
IPC_IR=/tmp/ir

PRC_JARVIS=jarvis.sh
PRC_JJAK=jjak.sh
PRC_NETWORK=network.sh

CONFIG_USER_INFO_FILE="conf/user.conf"
CONFIG_AUDIO_INFO_FILE="conf/audio.conf"

USER_IP=()
USER_NAME=()
USER_MAC=()

AUDIO_NAME=()
AUDIO_MAC=()

FILE_CONN=/tmp/connection
FILE_CAPTURE=/tmp/capture
FILE_STATE=/tmp/state
INTERVAL=5

function GetBtDevices()
{
	AUDIO_NAME=($(grep "pcm" ~/.asoundrc | awk -F "." '{print $2}' | awk -F " " '{print $1}'))
	AUDIO_MAC=($(grep "device" ~/.asoundrc | awk -F " " '{print $2}'))

#for debugging
#        for (( i = 0; i < ${#AUDIO_MAC[@]}; i++ ))
#        do
#                echo ${AUDIO_NAME[$i]}
#                echo ${AUDIO_MAC[$i]}
#        done
}

function GetUserList()
{
        USER_IP=($(cat $CONFIG_USER_INFO_FILE | awk -F "|" '{print $1}'))
        USER_NAME=($(cat $CONFIG_USER_INFO_FILE | awk -F "|" '{print $2}'))
        USER_MAC=($(cat $CONFIG_USER_INFO_FILE | awk -F "|" '{print $3}'))

#for debugging
#        for (( i = 0; i < ${#USER_IP[@]}; i++ ))
#        do
#                echo ${USER_IP[$i]}
#                echo ${USER_NAME[$i]}
#                echo ${USER_MAC[$i]}
#        done
}

function GetUserName()
{
        for (( i = 0; i < ${#USER_IP[@]}; i++ ))
        do
                if [ "$1" == "${USER_IP[$i]}" ]; then
                        echo "${USER_NAME[$i]}"
                fi
        done
}

function GetUserNameByMAC()
{
        for (( i = 0; i < ${#USER_MAC[@]}; i++ ))
        do
                if [ "$1" == "${USER_MAC[$i]}" ]; then
                        echo "${USER_NAME[$i]}"
                fi
        done
}

function GetAudioMACByName()
{
        for (( i = 0; i < ${#AUDIO_MAC[@]}; i++ ))
        do
                if [ "$1" == "${AUDIO_NAME[$i]}" ]; then
                        echo "${AUDIO_MAC[$i]}"
                fi
        done
}


function GetPid()
{
	pid=($(pgrep $1))
	echo "$pid"
}

function Talk_To_Jjak()
{
	if [[ -p $IPC_JARVIS ]]; then
		pid=($(GetPid $PRC_JJAK))
		if [[ "$pid" -ne "" ]]; then
        		echo "PACKET-$1@$2"
		        echo "$1@$2" > $IPC_JJAK
        		print_args "COMMON" "Send message($1@$2) to JJAK($IPC_JJAK, $pid)"
		else
        		print_args "COMMON" "JJAK process not found"
		fi
	fi
}

function Talk_To_Jarvis()
{
	if [[ -p $IPC_JARVIS ]]; then
		pid=($(GetPid $PRC_JARVIS))
		if [[ "$pid" -ne "" ]]; then
	        	echo "$1@$2"
	        	echo "$1@$2" > $IPC_JARVIS
        		print_args "COMMON" "Send message($1@$2) to Jarvis($IPC_JARVIS, $pid)"
		else 
        		print_args "COMMON" "JARVIS process not found"
		fi
	fi
}

print_args() 
{
	echo "[`date`] $*" >> ./log.log
}

function GetRandomString()
{
	str=($(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-6} | head -n 1))
	echo "$str"
}

function ShutUp()
{
	killall -9 mplayer 2&>1
}

function SetPlaybackMixer()
{
	#Playback from AP to Line Output, default gain 0dB

	# Clear the HPOUT2 Input 1 and 2  mixers. This will ensure no previous paths are connected to the HPOUT2.
	# This doesn't include Inputs 3 and 4.
	amixer $1 -Dhw:sndrpiwsp cset name='HPOUT2L Input 1' None
	amixer $1 -Dhw:sndrpiwsp cset name='HPOUT2R Input 1' None
	amixer $1 -Dhw:sndrpiwsp cset name='HPOUT2L Input 2' None
	amixer $1 -Dhw:sndrpiwsp cset name='HPOUT2R Input 2' None
	# Setup HPOUT2 input path and volume
	amixer $1 -Dhw:sndrpiwsp cset name='HPOUT2L Input 1' AIF1RX1
	amixer $1 -Dhw:sndrpiwsp cset name='HPOUT2L Input 1 Volume' 32
	amixer $1 -Dhw:sndrpiwsp cset name='HPOUT2R Input 1' AIF1RX2
	amixer $1 -Dhw:sndrpiwsp cset name='HPOUT2R Input 1 Volume' 32
	# Unmute HPOUT2 Output
	amixer $1 -Dhw:sndrpiwsp cset name='HPOUT2 Digital Switch' on
}

function SetRecordMixer()
{
	# $1 added to support 1st line argument. i.e. "./Record_from_linein.sh -q" will stop all the control information being displayed on screen

	#Record from onboard Line Input to AP
	# +8dB input PGA gain
	amixer $1 -Dhw:sndrpiwsp cset name='IN3L Volume' 8
	amixer $1 -Dhw:sndrpiwsp cset name='IN3R Volume' 8
	
	#JSH
	amixer $1 -Dhw:sndrpiwsp cset name='IN3L Volume' 100
	amixer $1 -Dhw:sndrpiwsp cset name='IN3R Volume' 100

	# better THD in normal mode vs lower noise floor in high performance
	amixer $1 -Dhw:sndrpiwsp cset name='IN3 High Performance Switch' on
	# Configure the input path for 0dB Gain,  HPF with a low cut off for DC removal
	amixer $1 -Dhw:sndrpiwsp cset name='IN3L Digital Volume' 128
	amixer $1 -Dhw:sndrpiwsp cset name='IN3R Digital Volume' 128
	amixer $1 -Dhw:sndrpiwsp cset name='LHPF1 Input 1' IN3L
	amixer $1 -Dhw:sndrpiwsp cset name='LHPF2 Input 1' IN3R
	amixer $1 -Dhw:sndrpiwsp cset name='LHPF1 Mode' High-pass
	amixer $1 -Dhw:sndrpiwsp cset name='LHPF2 Mode' High-pass
	amixer $1 -Dhw:sndrpiwsp cset name='LHPF1 Coefficients' 240,3
	amixer $1 -Dhw:sndrpiwsp cset name='LHPF2 Coefficients' 240,3
	# Configure the Audio Interface and volume 0dB
	amixer $1 -Dhw:sndrpiwsp cset name='AIF1TX1 Input 1' LHPF1
	amixer $1 -Dhw:sndrpiwsp cset name='AIF1TX1 Input 1 Volume' 32
	amixer $1 -Dhw:sndrpiwsp cset name='AIF1TX1 Input 1 Volume' 100
	amixer $1 -Dhw:sndrpiwsp cset name='AIF1TX2 Input 1' LHPF2
	amixer $1 -Dhw:sndrpiwsp cset name='AIF1TX2 Input 1 Volume' 32
	amixer $1 -Dhw:sndrpiwsp cset name='AIF1TX2 Input 1 Volume' 100
}

function SoundbarReadyToPair()
{
	irsend SEND_ONCE soundbar KEY_POWER
	sleep 3
	irsend SEND_ONCE soundbar KEY_3
	sleep 3
	irsend SEND_ONCE soundbar KEY_CONNECT
	sleep 7
	Talk_To_Jjak "TTS" "Now+is+preparing+to+connect"
}

function ConnectToSoundbar()
{
	bluez-simple-agent hci0 $1
	sleep 3
	bluez-test-device trusted $1
	bluez-test-device trusted $1 yes
	sleep 3
	bluez-test-audio connect $1
	Talk_To_Jjak "TTS" "connect+successfully"
}

function SetReady()
{
	cmd="sed -i -e 's/$1|.*/$1|1/g' $FILE_STATE"
	eval $cmd
	print_args "COMMON" "Set Ready $1"
}

function SetBlock()
{
	cmd="sed -i -e 's/$1|.*/$1|0/g' $FILE_STATE"
	eval $cmd
	print_args "COMMON" "Set Stop $1"
}

function CheckReady()
{
	state=($(cat $FILE_STATE | grep STATE | awk -F "|" '{print $2}'))	
	print_args "COMMON" "STATE-$state"
	if [[ "$state" == "1" ]]; then
		echo "ready"
		print_args "COMMON" "All process are ready to run"
	fi
}

GetUserList
GetBtDevices
