# Artificial Horizon
 ![Artificial Horizon](/Img/Artificial%20Horizon/Horizon6.png) 
 
The application displays an Artificial horizon on the transmitter main screen. This app is useful in connection with Assist receivers. 

Based on code of dandys and Marco Ricci.

## Compatibility
There are two variants of the Horizon app:
1. **Horizon.lua (compiled Horizon.lc)** - the app is compatible with all JETI DC/DS transmitters.
2. **Horizon_24.lua (compiled Horizon_24.lc)** - the app is compatible with DC/DS-24 only since it uses an antialised rendering.  

## Installation
1. Copy the _Horizon.lua_ (or compiled _Horizon.lc_) file and the _Horizon folder_ to the **Apps** folder of your transmitter. (For DC/DS-24: Copy the _Horizon_24.lua_ and _Horizon_24 folder_ instead). Alternatively you can install the correct version of the app via **JETI Studio**. 

2. Locate the Applications - User Applications menu and select the "Horizon" app by pressing the **F(3)** button and launching the app browser. <br>
![User Applications](/Img/Artificial%20Horizon/Horizon1.png)

3. Open the app configuration. Here select all the necessary sensors for proper work of your application.
  * Roll sensor - is used together with pitch sensor to draw the orientation of an artificial horizon.
  * Pitch sensor - is used together with roll sensor to draw the orientation of an artificial horizon.
  * Altitude sensor - is used to draw the altitude indicator on the right.
  * Vario sensor - is used to draw the climb/sink rate at the right side of the display.
  * Speed sensor - is used to draw the speed indicator on the left.
  * Heading sensor - is used to draw the heading indicator at the bottom (with respect to the North).
  * Distance sensor - is used to draw the distance in the middle of the horizon graphics.
![User Applications](/Img/Artificial%20Horizon/Horizon2.png)

4. Locate the Timers/Sensors - Displayed Telemetry menu. Here create a new entry and select the "Artificial Horizon" telemetry widget. The application will use the whole display area.

    | Timers/Sensors | Displayed Telemetry |
    |--- |--- |
    | ![Timers/Sensors](/Img/Artificial%20Horizon/Horizon4.png) | ![Displayed Telemetry](/Img/Artificial%20Horizon/Horizon5.png) |
