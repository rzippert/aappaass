# aappaass

This tool creates sinks for monitoring the audio from specific processes.
You may notice that OBS can record a single window, but can't separate audio from each app. This tool leverages PulseAudio features to pipe the audio from a single app to a sink, that OBS can record, but keep it playing on an output device of your choice.

## Details

Using pulseaudio, directs the audio output from a process to a new sink, which can be picked up by OBS. This "mutes" the app for you, so aappaass also attaches a monitor to this sink to direct it to an output device (another sink). This allows OBS to record it while you can hear it as well. This should work with any application that recognizes a sink. 

I think I have forgotten the full meaning of this name, but I'll go with "Advanced Audio Passthrough for PulseAudio Application Sink Script".

## Usage

```
Usage: /usr/local/bin/aappaass [-h] [-s SINKNAME] [-r|-l|-p APPNAME]
	-h		Print this usage text and exits.
	-s SINKNAME	Specify a sink to be used as output excusively.
	-r		Remove loaded modules and sinks (undo changes).
	-l		Lists available processes and output sinks.
	-n RECSINKNAME	Specify recording sink name.
	-p PROCESS	Specify the process name that should have its sound
			monitored.
```

## Example

  - Open your desired app and make it start playing some audio;
  - Run `aappaass -l`, as it will help you identify the process playing audio and the output devices available:
  ```
Possible processes:
Sink Input #146
		application.process.binary = "chrome"
Sink Input #147
		application.process.binary = "chrome"
Possible outputs:
Sink #2
	Name: alsa_output.pci-0000_00_1f.3.analog-stereo
	Description: Built-in Audio Analog Stereo
Sink #3
	Name: alsa_output.usb-GeneralPlus_USB_Audio_Device-00.analog-stereo
	Description: USB Audio Device Analog Stereo
Sink #7
	Name: alsa_output.pci-0000_01_00.1.hdmi-stereo
	Description: GP107GL High Definition Audio Controller Digital Stereo (HDMI)
```
  - Execute `aappaass -p chrome -s 'alsa_output.pci-0000_00_1f.3.analog-stereo'`;
  - Open OBS and add an "Audio Output Capture (PulseAudio)" and select `rec_passthrough` in the list;
  - You may specify an alternative name for `rec_passthrough` with -n;
  - Do whatever you need to do with OBS;
  - When done, run `aappaass -r` to remove your changes, or logoff/reboot your system if it fails.
