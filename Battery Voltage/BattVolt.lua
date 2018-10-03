-- ############################################################################# 
-- # Battery Voltage - Lua application for JETI DC/DS transmitters
-- # A simplified version of Battery Monitor application  
-- #
-- # Copyright (c) 2016 - 2017, JETI model s.r.o.
-- # All rights reserved.
-- #
-- # License: Share alike                                       
-- # Can be used and changed non commercial                     
-- #                       
-- # V1.0 - Initial release 
-- # V1.1 - The readFile() function has been replaced by internal io.readall() (DC/DS FW V4.22)
-- #        Detection of inactive sensor.
-- # V1.2 - Improved translations to different languages
-- #############################################################################

--Configuration
local sensorId=0

--Local variables
local sensorsAvailable = {}

local lang
local options={} 
local cellfull, cellempty = 4.2, 3.00
                                            
local cell = {0, 0, 0, 0, 0 ,0} 
-- Icon positions - small window       
local positionsSmall = {{10,5}, {10, 27}, {10, 49}, {80,5}, {80, 27}, {80, 49}}        
 
--X,Y coordinates           
local echX, ech100Y, ech0Y = 210, 4, 70                                           
local echH = (ech0Y-ech100Y)  
-- Space between gauges                                                    
local gaugeW, gaugeGap = 12, 3                                                     
local i, cellmin, cellmax, cellresult = 0, cellfull, 0, 0                        
local cellsumpercent, precision, blink = 0, 0, 0                                 
local cellsumpercentminima, cellsumpercentmaxima = 100, 0                        
local percentDelta  
local sensorValid=false  
 
--------------------------------------------------------------------
-- Configure language settings
--------------------------------------------------------------------
local function setLanguage()
  -- Set language
  local lng=system.getLocale();
  local file = io.readall("Apps/BattVolt/locale.jsn")
  local obj = json.decode(file)  
  if(obj) then
    lang = obj[lng] or obj[obj.default]
  end
end


--------------------------------------------------------------------
-- Get current voltage from sensor - return array of 6 values
-------------------------------------------------------------------- 
local function getVoltages()
  sensorValid=false
  if(sensorId==0) then 
    return 
  end
  local values ={}   
  local sensor
  for i = 1,6 do
    sensor = system.getSensorByID(sensorId,i)
    if sensor and sensor.valid then
      cell[i] = sensor.value
      sensorValid=true  
    end
  end 
   
end

 
-------------------------------------------------------------------- 
-- Print batt values - Small Window
--------------------------------------------------------------------
local function printBatterySmall(w,h)
  local label   
  local txtr,txtg,txtb
  local bgr,bgg,bgb = lcd.getBgColor()
  if (bgr+bgg+bgb)/3 >128 then 
    txtr,txtg,txtb = 0,0,0
  else
    txtr,txtg,txtb = 255,255,255
  end            
  -- Print battery icon and voltages 
  for i = 1, 6 do     
    blink = (cell[i] ~= 0 and (cell[i] < cellempty or not sensorValid) ) and true or false
    if blink then
      lcd.setColor(lcd.getFgColor())
    else
      lcd.setColor(txtr,txtg, txtb , 200)
    end                            
    local t = lcd.getTextWidth(FONT_BOLD,i)                          
    lcd.drawLine(positionsSmall[i][1] + 2, positionsSmall[i][2] - 3, positionsSmall[i][1] - 2 + t, positionsSmall[i][2] - 3)
    lcd.drawFilledRectangle(positionsSmall[i][1]-1,positionsSmall[i][2] - 2,t+3,20)
    lcd.setColor(255-txtr,255-txtg,255-txtb)
    lcd.drawNumber(positionsSmall[i][1], positionsSmall[i][2]-1, i, FONT_NORMAL | FONT_XOR)          
    t = positionsSmall[i][1] + t + 8
    
    if cell[i] ~= 0 then 
      if(not blink or (system.getTime()%2 == 1)) then
        label = string.format("%.2fV",cell[i])
        lcd.setColor(txtr,txtg, txtb )                                           
        lcd.drawText(t, positionsSmall[i][2],label, FONT_NORMAL)
      end
    else
      lcd.setColor(txtr,txtg, txtb ) 
      lcd.drawText(t, positionsSmall[i][2],"...",FONT_BOLD)                   
    end
  end
end


-------------------------------------------------------------------- 
-- Form functions
--------------------------------------------------------------------
--------------------------------------------------------------------
local function sensorChanged(value)
  if(value and value >=0) then 
    sensorId=sensorsAvailable[value].id
  else 
    sensorId = 0
  end     
  system.pSave("sensor",sensorId)      
end

 
--------------------------------------------------------------------

local function initForm(formID)
  sensorsAvailable = {}
  local available = system.getSensors();
  local list={}
  local curIndex=-1
  local descr = ""
  for index,sensor in ipairs(available) do 
    if(sensor.param == 0) then
      list[#list+1] = sensor.label
      sensorsAvailable[#sensorsAvailable+1] = sensor
      if(sensor.id==sensorId ) then
        curIndex=#sensorsAvailable
      end 
    end 
  end
  form.addSpacer(100,10)
  form.addLabel({label=lang.sensor,font=FONT_BOLD})
  form.addRow(2)
  form.addLabel({label=lang.selectSensor,width=120})
  form.addSelectbox (list, curIndex,true,sensorChanged,{width=190})
  
   
end  


-------------------------------------------------------------------- 
-- Initialization
--------------------------------------------------------------------
-- Init function
local function init() 
  -- registers a whole-size window
  sensorId = system.pLoad("sensor",0)
  if sensorId == 0 then
    -- Fill default sensors ID - MULi6
    local available = system.getSensors(); 
    for index,sensor in ipairs(available) do  
      if((sensor.id & 0xFFFF) >= 43185 and (sensor.id & 0xFFFF) <= 43188) then
        sensorId = sensor.id
        break
      end 
    end
  end
   
  system.registerTelemetry(2,lang.windowSmall,2,printBatterySmall) 
  system.registerForm(1,MENU_TELEMETRY,lang.appName,initForm,nil,printForm)
end


  

--------------------------------------------------------------------
-- Loop function
local function loop() 
  getVoltages()
end
 

--------------------------------------------------------------------
setLanguage()
return { init=init, loop=loop, author="JETI model", version="1.2",name=lang.appName}





