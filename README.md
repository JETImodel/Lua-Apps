# Lua-Apps
Official Lua applications for DC/DS-24 transmitters. Applications should be located in the Apps folder of the internal SD card.
![img](http://www.jetimodel.com/files/photo-thumb/DSCN7506.jpg)



Complete Lua API description can be found here: http://www.jetimodel.com/en/DC-DS-24-Lua-API-1/

Based on Lua 5.3.1:
- http://www.lua.org/
- http://www.lua.org/manual/5.3/


## Hardware specification
The transmitter runs at this configuration:
-	MCU: STM32F439 @ 168MHz
-	External memory: 8MB (1MB reserved for framebuffer and system resources)
-	SD card support: Up to 32GB micro SDHC
-	Audio playback: MP3 (44.1kHz, 32kHz), WAV (8kHz, 11kHz, 16kHz, 22.05kHz, 32kHz, 44.1kHz; Mono/Stereo)
-	Vibration support: Left and right gimbal


 ## Available Applications
 - **Automatic Trainer Switch** - Switch between teacher and student automatically. 
 - **Battery Monitor** - A display telemetry widget that shows voltages of up to 6 LiPo cells (measured by MULi6S).
 - **Battery Voltage** - A simplified telemetry widget that shows voltages of up to 6 LiPo cells (measured by MULi6S). It doesn't offer balancing information nor approx. discharged percentage.
 - **DC-24 Presentation** - An application that can be run on Desktop and gives the user some basic features of the transmitter.
 - **Demos** - List of all demos included in the official API documentation. Each application demonstrates several API functions.
 - **Preflight Check** - Use this application as a preflight checklist, so that you will never forget any step necessary before flight. (Included in DC-24 SW version 4.10)
 - **Sensor Chart** - A display telemetry widget that can display any telemetry variable into a chart. (Included in DC-24 SW version 4.10)
 - **Source Dumper** - The app dumps compiled Lua chunks to files without debugging information (stripped down). Useful to shrink the app, reduce memory consumption, improve start-up time and prevent memory issues. 

##  Installation
1. Connect the transmitter to PC and establish a link via USB (the transmitter is registered as a mass-storage device).
2. Open one of the folders from above (for example, if you want to install *Battery Monitor*, open the Battery Monitor folder here on Github).
3. Copy all files from the selected folder into the **Apps** folder of your transmitter.
4. Disconnect the transmitter and locate its menu *Applications - User Applications*.
5. Select the application you want and activate it.
