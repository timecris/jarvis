IPC_JARVIS=/tmp/jarvis
IPC_JJAK=/tmp/jjak

PRC_JARVIS=jarvis.sh
PRC_JJAK=jjak.sh
PRC_NETWORK=network.sh

CONFIG_USER_INFO_FILE="conf/user.conf"
CONFIG_AUDIO_INFO_FILE="conf/audio.conf"

USER_IP=()
USER_NAME=()
USER_STATE=()

FILE_CONN=/tmp/connection
FILE_CAPTURE=/tmp/capture
INTERVAL=5

function GetUserList()
{
        USER_IP=($(cat $CONFIG_USER_INFO_FILE | awk -F "|" '{print $1}'))
        USER_NAME=($(cat $CONFIG_USER_INFO_FILE | awk -F "|" '{print $2}'))

#for debugging
#        for (( i = 0; i < ${#USER_IP[@]}; i++ ))
#        do
#                echo ${USER_IP[$i]}
#                echo ${USER_NAME[$i]}
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
		else
        		echo "JJAK process not found"
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
		else 
        		echo "JARVIS process not found"
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

GetUserList