# Jarvis
### Hardware
- Raspberry PI 2 
- [Cirrus Logic Audio Card](http://www.element14.com/community/community/raspberry-pi/raspberry-pi-accessories/cirrus_logic_audio_card)
- Bluetooth Speaker (Music)
- Wired Speaker (Command)


### Prerequite
- apt-get update
- apt-get install bluetooth bluez-utils
- apt-get install lirc liblircclient-dev
- apt-get install flac lame

### How to test for playing mp3

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

Bluetooth
http://blog.whatgeek.com.pt/2014/04/raspberry-pi-bluetooth-wireless-speaker/


