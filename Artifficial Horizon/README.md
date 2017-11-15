# Artifficial Horizon
 ![Artifficial Horizon](/Img/Artifficial%20Horizon/Horizon6.png) 
 
The application displays an artifficial horizon on the transmitter main screen. This app is useful in connection with Assist receivers. 

Based on code of dandys and Marco Ricci.


## Installation
1. Copy the Horizon.lua (or compiled Horizon.lc) file to the **Apps** folder of your transmitter. 

2. Locate the Applications - User Applications menu and select the "Horizon" app by pressing the **F(3)** button and launching the app browser. <br>
![User Applications](/Img/Artifficial%20Horizon/Horizon1.png)

3. Open the app configuration. Here select all the necessary sensors for proper work of your application.
  * Roll sensor - is used together with pitch sensor to draw the orientation of an artifficial horizon.
  * Pitch sensor - is used together with roll sensor to draw the orientation of an artifficial horizon.
  * Altitude sensor - is used to draw the altitude indicator on the right.
  * Vario sensor - is used to draw the climb/sink rate at the right side of the display.
  * Speed sensor - is used to draw the speed indicator on the left.
  * Heading sensor - is used to draw the heading indicator at the bottom (with respect to the North).
  * Distance sensor - is used to draw the distance in the middle of the horizon graphics.
![User Applications](/Img/Artifficial%20Horizon/Horizon2.png)

4. Locate the Timers/Sensors - Displayed Telemetry menu. Here create a new entry and select the "Artifficial Horizon" telemetry widget. The application will use the whole display area.

    | Timers/Sensors | Displayed Telemetry |
    |--- |--- |
    | ![Timers/Sensors](/Img/Artifficial%20Horizon/Horizon4.png) | ![Displayed Telemetry](/Img/Artifficial%20Horizon/Horizon5.png) |
