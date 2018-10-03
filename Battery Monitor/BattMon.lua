-- ############################################################################# 
-- # Battery Monitor - Lua application for JETI DC/DS transmitters
-- # Inspired by LI-xx BATTCHECK (Developped by Heisenberg, debugged by Sacre100) 
-- #
-- # Copyright (c) 2016, JETI model s.r.o.
-- # All rights reserved.
-- #
-- # License: Share alike                                       
-- # Can be used and changed non commercial                     
-- #                       
-- # V1.0 - Initial release
-- # V1.1 - Displayed voltage values for the graph axes
-- # V1.2 - The readFile() function has been replaced by internal io.readall() (DC/DS FW V4.22)
-- #        Better displayed on DC/DS-16/14. Detection of inactive sensor.
-- # V1.3 - Improved translations to different languages 
-- ############################################################################# 


--Configuration
local sensorId=0

--Local variables
local sensorsAvailable = {}

local lang
local options={} 
local cellfull, cellempty = 4.2, 3.00
-- Lipo discharge table
local myArrayPercentList =                                                
{
{3.000, 0},           
{3.380, 5},
{3.580, 10},
{3.715, 15},
{3.747, 20},
{3.769, 25},
{3.791, 30},
{3.802, 35},
{3.812, 40},
{3.826, 45},
{3.839, 50},
{3.861, 55},
{3.883, 60},
{3.910, 65},
{3.936, 70},
{3.986, 75},
{3.999, 80},
{4.042, 85},
{4.085, 90},
{4.142, 95},
{4.170, 97},
{4.200, 100}            
}
-- Minimum voltage
local cellminima = {cellfull, cellfull, cellfull, cellfull, cellfull, cellfull}  
-- Maximum voltage
local cellmaxima = {0, 0, 0, 0, 0 ,0}                                            
local cell = {0, 0, 0, 0, 0 ,0}
-- Statistics
local cellsumfull, cellsumempty, cellsumtype, cellsum = 0, 0, 0, 0      
-- Icon positions - large window         
local positions = {{170,90}, {170, 115}, {170, 140}, {250,90}, {250, 115}, {250, 140}} 
-- Icon positions - small window       
local positionsSmall = {{10,5}, {10, 27}, {10, 49}, {80,5}, {80, 27}, {80, 49}}        
-- Local variables
local cellsumfull, cellsumempty, cellsumtype, cellsum = 0, 0, 0, 0     
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
---- Calculate percentage voltage 
--------------------------------------------------------------------
local function percentcell(targetVoltage)
  local result = 0
  if targetVoltage > cellfull or targetVoltage < cellempty then
    if  targetVoltage >= cellfull then                                            
      result = 100
    end
    if  targetVoltage <= cellempty then
      result = 0
    end
  else
    for i, v in ipairs( myArrayPercentList ) do     
      -- Interpolate values                             
      if v[ 1 ] >= targetVoltage and i > 1 then
        local lastVal = myArrayPercentList[i-1]
        result = (targetVoltage - lastVal[1]) / (v[1] - lastVal[1])
        result = result * (v[2] - lastVal[2]) + lastVal[2]
        break
      end
    end --for
  end --if
 return result
end
 
--------------------------------------------------------------------
-- Configure language settings
--------------------------------------------------------------------
local function setLanguage()
  -- Set language
  local lng=system.getLocale();
  local file = io.readall("Apps/BattMon/locale.jsn")
  local obj = json.decode(file)  
  if(obj) then
    lang = obj[lng] or obj[obj.default]
  end
end


--------------------------------------------------------------------
-- Get current voltage from sensor - return array of 6 values
--------------------------------------------------------------------
-- local values = {3.9, 3.85, 3.9, 4.0,4.1,4.2}
local function getVoltages()
  sensorValid=false
  if(sensorId==0) then 
    return 
  end
  local values ={}  
  -- values[1] = values[1] - 0.0005 -- + math.random(-100,100)*0.0005
  -- values[2] = values[2] - 0.0005
  -- values[3] = values[3] - 0.0005
  -- values[4] = values[4] - 0.0005
  -- values[5] = values[5] - 0.0005
  -- values[6] = values[6] - 0.0005
  local sensor
  for i = 1,6 do
    sensor = system.getSensorByID(sensorId,i)
    if sensor and sensor.valid then
      values[#values+1] = sensor.value
      sensorValid=true 
    end
  end 
  
  cellmin = cellfull
  cellmax = 0

  cellsum = 0                                      
  for i = 1, #cell do cell[i] = 0 end            
  cellsumtype = #values                            
  for i, v in pairs(values) do                     
    cellsum = cellsum + v                              
    cell[i] = v                                        
    if cellmaxima[i] < v then                          
      cellmaxima[i] = v
    end
    if cellminima[i] > v then
      cellminima[i] = v
    end
    if cellmin > v then                                 
      cellmin = v
    end
    if cellmax < v then                                 
      cellmax = v
    end
  end  


                  
  cellsumpercent = percentcell(cellsum/cellsumtype)       
  if cellsumpercentmaxima < cellsumpercent then
    cellsumpercentmaxima = cellsumpercent
  end
  if cell[1]>0 then                                       
    if cellsumpercentminima > cellsumpercent then
      cellsumpercentminima = cellsumpercent
    end
  end
end


-------------------------------------------------------------------- 
-- Print batt values
--------------------------------------------------------------------
local function printBattery(w,h)
  local txtr,txtg,txtb
  local bgr,bgg,bgb = lcd.getBgColor()
  if (bgr+bgg+bgb)/3 >128 then 
    txtr,txtg,txtb = 0,0,0
  else
    txtr,txtg,txtb = 255,255,255
  end
      
  -- Separator line
  lcd.setColor(130,130,130)
  lcd.drawLine(235, 80, 235, 158) 
  local label               
  
  -- Maximum charged                        
  lcd.setColor(txtr,txtg, txtb , 100)
  lcd.drawFilledRectangle(6, 11, cellsumpercentmaxima*44/100,18,FONT_GRAYED)         
  lcd.setColor(lcd.getFgColor())
  -- Current value
  lcd.drawFilledRectangle(6, 11, cellsumpercent*44/100, 18 )                                
  -- Minimum
  if cellsumpercentminima < cellsumpercent and cellsumpercentminima > 0 then                          
    lcd.setColor(130,130,130)
    lcd.drawLine(6+(cellsumpercentminima*44/100), 11, 6+(cellsumpercentminima*44/100), 28)  
  end
  
  -- Battery shape
  lcd.setColor(txtr,txtg, txtb)
  lcd.drawRectangle(5, 10, 46, 20)                                          
  lcd.drawFilledRectangle (51,15,2,10)                                       

 
  label = string.format("%d%%",cellsumpercent)
  lcd.drawText(50-lcd.getTextWidth(FONT_BIG,label),30,label,FONT_BIG)

  
  
  for i = 1, 6 do    
    blink = (cell[i] ~= 0 and (cell[i] < cellempty or not sensorValid) ) and true or false 
    if blink then
      lcd.setColor(lcd.getFgColor())
    else
      lcd.setColor(txtr,txtg, txtb , 200)
    end                            
    local t = lcd.getTextWidth(FONT_BOLD,i)                          
    lcd.drawLine(positions[i][1] + 2, positions[i][2] - 3, positions[i][1] - 2 + t, positions[i][2] - 3)
    lcd.drawFilledRectangle(positions[i][1]-1,positions[i][2] - 2,t+3,20)
    lcd.setColor(255-txtr,255-txtg,255-txtb)
    lcd.drawNumber(positions[i][1], positions[i][2]-1, i, FONT_NORMAL | FONT_XOR)          
    t = positions[i][1] + t + 8
    
    if cell[i] ~= 0 then 
      if(not blink or (system.getTime()%2 == 1)) then
        label = string.format("%.2fV",cell[i])
        lcd.setColor(txtr,txtg, txtb)                                          
        lcd.drawText(t, positions[i][2],label, FONT_NORMAL)
      end
      percent       = math.floor(percentcell(cell[i]) * (echH/100))                          
      percentminima = math.floor(percentcell(cellminima[i]) * (echH/100))                    
      percentmaxima = math.floor(percentcell(cellmaxima[i]) * (echH/100))                    
      lcd.setColor(lcd.getFgColor())
      lcd.drawFilledRectangle(echX + 2 + (i - 1) * (gaugeW + gaugeGap), (ech100Y + echH - percentmaxima), gaugeW, percentmaxima,FONT_GRAYED)                                  
      lcd.setColor(txtr,txtg, txtb)
      lcd.drawFilledRectangle(echX + 2 + (i - 1) * (gaugeW + gaugeGap), (ech100Y + echH - percent), gaugeW, percent)                                                              
      if percentminima < percent and percentminima > 0 then
        lcd.setColor(lcd.getFgColor())                                                                                                                                    
        lcd.drawLine(echX + 2 + (i - 1) * (gaugeW + gaugeGap), ech100Y + echH - percentminima, (echX + 2 + (i - 1) * (gaugeW + gaugeGap)) + gaugeW-1,  ech100Y + echH - percentminima) 
      end
    else
      lcd.setColor(txtr,txtg, txtb) 
      lcd.drawText(t, positions[i][2],"...",FONT_BOLD)                    
      lcd.drawText (echX + 5 + (i - 1)*(gaugeW + gaugeGap), ech0Y-17, "*", FONT_NORMAL)
    end
  end
  
  -- Graph axis
  lcd.drawLine(echX, ech100Y, echX, ech0Y)                                                    
  lcd.drawLine(echX+1, ech0Y, echX + gaugeGap + 5*(gaugeW + gaugeGap) + gaugeW, ech0Y)        
  lcd.drawText(echX-25,0,"4.2V",FONT_MINI)
  lcd.drawText(echX-25,ech0Y-5,"3.0V",FONT_MINI)
  i = 6                                                                                                        
  while (i >= 0) do
    lcd.drawLine(echX-2, (ech100Y+echH)-((echH/6)*i), echX-1, (ech100Y+echH)-((echH/6)*i))  
    i= i-1
  end
  
  
  -- Draw values - average, sum, ...
  lcd.drawText (60,4, string.format(lang.pack,cellsumtype),FONT_NORMAL)
  lcd.drawText (60,22, lang.voltage, FONT_NORMAL)
  label = string.format
  
  if cellsum > 10 then
    label = string.format("%.1fV",cellsum)
  else
    label = string.format("%.2fV",cellsum)
  end
  lcd.drawText (echX-20-lcd.getTextWidth(FONT_NORMAL,label),22, label, FONT_NORMAL)

  lcd.drawText (60,40, lang.average, FONT_NORMAL)
  if cellsum > 0 then
    label = string.format("%.2fV",(cellsum / cellsumtype))
  else
    label = "0V"
  end
  lcd.drawText (echX-20-lcd.getTextWidth(FONT_NORMAL,label),40, label, FONT_NORMAL)
  
  
  if cell[1] > 0 then
    percentDelta = math.floor(100 - (percentcell(cellmax) - percentcell(cellmin)))
  else
    percentDelta = "-"
  end 
  
  label = string.format(lang.delta,(cell[1] > 0 and (cellmax * 1000) - (cellmin * 1000) or 0), percentDelta)
  lcd.drawText (5,58,label,FONT_MINI)
   
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
  
  system.registerTelemetry(1,lang.appName,3,printBattery)
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
return { init=init, loop=loop, author="JETI model", version="1.3",name=lang.appName}





