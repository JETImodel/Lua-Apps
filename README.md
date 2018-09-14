# Lua-Apps 
Official Lua applications for DC/DS transmitters. Applications should be located in the Apps folder of the internal SD card.
>**Note:** The applications in this repository are compatible with the firmware version **4.22** of JETI DC/DS transmitters. Older versions are **_not supported_**.

![img](http://www.jetimodel.com/files/photo-thumb/DSCN7506.jpg)



Complete Lua API description can be found here: http://www.jetimodel.com/en/DC-DS-24-Lua-API-1/

Based on Lua 5.3.1:
- http://www.lua.org/
- http://www.lua.org/manual/5.3/


## Hardware specification
The transmitter runs at this configuration:

|  | DC/DS-16, DC/DS-14 | DC/DS-24 |
| --- | --- | --- | 
| MCU: | STM32F405 @ 168MHz | STM32F439 @ 168MHz |
| External memory: | None | 8MB (1MB reserved for framebuffer and system resources) |
| SD card support: | Up to 32GB micro SDHC  | Up to 32GB micro SDHC |
| Audio playback: | WAV (8kHz, 11kHz, 16kHz, 22.05kHz, 32kHz, 44.1kHz; Mono/Stereo) | MP3 (44.1kHz, 32kHz), WAV (8kHz, 11kHz, 16kHz, 22.05kHz, 32kHz, 44.1kHz; Mono/Stereo) |
| Vibration support: | None | Left and right gimbal |


## Available Applications
 - **Automatic Trainer Switch** - Switch between teacher and student automatically. 
 - **Artificial Horizon** - Displays an artificial horizon on the transmitter main screen. This app is useful in connection with Assist receivers. 
 - **Battery Monitor** - A display telemetry widget that shows voltages of up to 6 LiPo cells (measured by MULi6S).
 - **Battery Voltage** - A simplified telemetry widget that shows voltages of up to 6 LiPo cells (measured by MULi6S). It doesn't offer balancing information nor approx. discharged percentage.
 - **DC-24 Presentation** - An application that can be run on Desktop and gives the user some basic features of the transmitter.
 - **Demos** - List of all demos included in the official API documentation. Each application demonstrates several API functions.
 - **Discharged Flightpack** (by Peter Vogel) - Warns if a discharged flight pack is installed and announces the name of the model using an audio file of the user's choice.  
 - **Preflight Check** - Use this application as a preflight checklist, so that you will never forget any step necessary before flight.  
 - **Sensor Chart** - A display telemetry widget that can display any telemetry variable into a chart.  
 - **Source Dumper** - The app dumps compiled Lua chunks to files without debugging information (stripped down). Useful to shrink the app, reduce memory consumption, improve start-up time and prevent memory issues. 
 - **Throttle Detent** (by Peter Vogel) - This app engages the stick vibration and emits a beep when the throttle stick is positioned within a few percent of a user-specified position. 

##  Installation
There are two possible ways of installing the apps to your transmitter. If you prefer ready-made application packs, the first option is for you. It is also a recommended procedure if you want to run the Lua applications on DC/DS-16/14. 
The second option is available for expert users and developers and allows you to modify the Lua application code right inside your transmitter.  

### 1) Install a ready-made pack
We have prepared a set of compiled applications packed in a ZIP archive. The compilation process reduces memory requirements of the apps, and we recommend running this pack on DC/DS-16 and DC/DS-14.
1. Connect the transmitter to your PC and establish a link via USB (the transmitter is registered as a mass-storage device).
2. Download the latest release of compiled apps from this repository: [Release-Compiled.zip](Release-Compiled.zip).
3. Unzip all files to your transmitter into the **Apps** folder.
4. Disconnect the transmitter and locate its menu *Applications - User Applications*.
5. Select the application you want and activate it.

### 2) Install the application with possibility of editing.
Using this procedure you will install the Lua application source files to your transmitter:
1. Connect the transmitter to your PC and establish a link via USB (the transmitter is registered as a mass-storage device).
2. Open one of the folders from above (for example, if you want to install *Battery Monitor*, open the Battery Monitor folder here on Github).
3. Copy all files from the selected folder into the **Apps** folder of your transmitter.
4. Disconnect the transmitter and locate its menu *Applications - User Applications*.
5. Select the application you want and activate it.


**Notes:**
- The file extension of compiled apps is set to **\*.LC** which differenciates them from source-code based apps with **\*.LUA** extension. Please note that even if the application names are the same, the resulting apps are considered different to each other.  
- The compilation can be done using the [Lua Src Dumper](Src Dumper) application installed in DC-24 Emulator. The emulator is an integral part of the [JETI Studio software](http://www.jetimodel.com/en/JETI-Studio-2/).
