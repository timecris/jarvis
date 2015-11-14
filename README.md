# Jarvis
### Hardware
- [Raspberry PI 2](http://kr.element14.com/raspberry-pi/rpi2-modb-8gb-noobs/raspberry-pi-2-model-b-8gb-noobs/dp/2461032)
- [Cirrus Logic Audio Card](http://www.element14.com/community/community/raspberry-pi/raspberry-pi-accessories/cirrus_logic_audio_card)
- Bluetooth Speaker (Music)
- Wired Speaker (Command)

### Prerequite
- apt-get update
- apt-get install bluetooth bluez-utils
- apt-get install lirc liblircclient-dev
- apt-get install flac lame

### How to test for playing mp3 through the Cirrus Logic Audio Card

```sh
$ ./use_case_scripts/Playback_to_Lineout.sh 
$ mpg123 "MP3 File Name"
```

### Installation

```sh
$ git clone https://github.com/timecris/jarvis.git
$ cd jarvis
$ cp ./system/asoundrc ~/.asoundrc
$ cp ./system/jarvis /etc/init.d/jarvis
```

You can download mixer script below.

https://github.com/CirrusLogic/wiki-content/tree/master/scripts

/boot/config.txt
```sh
dtoverlay=lirc-rpi,gpio_in_pin=16,gpio_out_pin=12
```
/etc/lirc/hardware.conf
```sh
LIRCD_ARGS="--uinput"
DRIVER="default"
DEVICE="/dev/lirc0"
MODULES="lirc_rpi"
```

/etc/rc.local
```sh
service jarvis start
```



