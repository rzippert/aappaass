# aappaass

Manages "passthrough" sinks for PulseAudio.

## Details

Using pulseaudio, directs the output from a process to a sink and attaches monitors to this sink so that it can be heard through all possible devices, as well as recorded with OBS. This makes it easy to record the audio of a single application with OBS while still hearing its output on linux systems.

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
