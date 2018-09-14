-- Copyright (c) 2016 JETI
-- Copyright (c) 2015 dandys.
-- Copyright (c) 2014 Marco Ricci.
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    A copy of the GNU General Public License is available at <http://www.gnu.org/licenses/>.
--    
-- Radar is based on Volke Wolkstein MavLink telemetry script
-- https://github.com/wolkstein/MavLink_FrSkySPort
--
-- Version 1.0 - First official release, code cleanup
--         1.1 - Forked to use the renderer on DC/DS-24
--             - Translations to several languages
 
local lang
local ren=lcd.renderer()

-- Various local variables
local X1, Y1, X2, Y2, XH, YH
local delta, deltaX, deltaY
local getTelemetryValues
-- Text color
local txtr,txtg,txtb
-- Text to be drawn
local text
-- Sensors available in a form
local sensorsAvailable = {}
-- Roll sensor
local sensorRId, paramRId
-- Pitch sensor
local sensorPId, paramPId
-- Altimeter sensor (m)
local sensorAId, paramAId
-- Speed sensor (m/s)
local sensorSId, paramSId
-- Heading sensor (deg)
local sensorHId, paramHId
-- Vario sensor (m/s)
local sensorVId, paramVId
-- Distance sensor (m)
local sensorDistId, paramDistId

-- *****************************************************
-- Configure language settings
-- *****************************************************
local function setLanguage()
  -- Set language
  local lng=system.getLocale();
  local file = io.readall("Apps/Horizon_24/locale.jsn")
  local obj = json.decode(file)
  if(obj) then
    lang = obj[lng] or obj[obj.default]
  end
end

-- *****************************************************
-- Optimizations - local variables
-- *****************************************************
local sinShape, cosShape
local sin = math.sin
local cos = math.cos
local floor = math.floor
local rad = math.rad
local tan = math.tan
local format = string.format
local isColor = (tonumber(string.match(system.getDeviceType(),"(%d+)")) == 24)

-- *****************************************************
-- Draw a shape
-- *****************************************************
local function drawShape(col, row, shape, rotation)
  sinShape = math.sin(rotation)
  cosShape = math.cos(rotation)
  ren:reset()
  for index, point in pairs(shape) do
    ren:addPoint(
      col + (point[1] * cosShape - point[2] * sinShape + 0.5),
      row + (point[1] * sinShape + point[2] * cosShape + 0.5)
    ) 
  end
  ren:renderPolygon()
end

-- *****************************************************
-- Mix color with background
-- *****************************************************
local bgr,bgg,bgb
local alphadot
local function mixBgColor(r,g,b,alpha)
  bgr,bgg,bgb = lcd.getBgColor()
  alphadot = 1 - alpha
  r = bgr*alphadot + r*alpha
  g = bgg*alphadot + g*alpha
  b = bgb*alphadot + b*alpha
  return r,g,b
end



-- *****************************************************
-- Telemetry data
-- *****************************************************
local yaw, pitch, roll = 0, nil, nil
local altitude, speed = 0, 0
local heading = 0
local vario = 0
local distance = 0



-- *****************************************************
-- Local definitions
-- *****************************************************
local colAH = 110
local rowAH = 63
local radAH = 62
local pitchR = radAH / 25
 

local colAlt = colAH + 73
local colSpeed = colAH - 73
local heightAH = 145

local colHeading = colAH
local rowHeading = 160  
local rowDistance = rowAH + radAH + 3

local homeShape = {
  { 0, -10},
  {-8,  8},
  { 0,  4},
  { 8,  8}
}

-- *****************************************************
-- Draw & fill artificial horizon
-- *****************************************************
local tanRoll, cosRoll, sinRoll
local dPitch_1, dPitch_2, mapRatio
local r,g,b
local function drawHorizon()
  if not pitch or not roll then return end
  

  r,g,b = lcd.getFgColor()
  r,g,b = mixBgColor(r,g,b,0.5)
  lcd.setColor(r,g,b)
  dPitch_1 = pitch % 180
  if dPitch_1 > 90 then dPitch_1 = 180 - dPitch_1 end

  cosRoll = 1/cos(rad(roll == 90 and 89.99 or (roll == 270 and 269.99 or roll)))
  if pitch > 270 then
    dPitch_1 = -dPitch_1 * pitchR * cosRoll
    dPitch_2 = radAH * cosRoll
  elseif pitch > 180 then
    dPitch_1 = dPitch_1 * pitchR * cosRoll
    dPitch_2 = -radAH * cosRoll
  elseif pitch > 90 then
    dPitch_1 = -dPitch_1 * pitchR * cosRoll
    dPitch_2 = -radAH * cosRoll
  else
    dPitch_1 = dPitch_1 * pitchR * cosRoll
    dPitch_2 = radAH * cosRoll
  end
  
  tanRoll = -tan(rad(roll == 90 and 89.99 or (roll == 270 and 269.99 or roll)))
  lcd.setClipping(colAH-radAH,1,radAH*2+1,2*radAH+1) 
  ren:reset()
  X1 = 0
  YH = (-radAH) * tanRoll
  Y1 = YH + dPitch_1
 
  Y2 = YH + 1.5 * dPitch_2 
 
  if Y1 < Y2 then
    ren:addPoint(X1, rowAH + Y1)
    ren:addPoint(X1, rowAH + Y2 )
  elseif Y1 > Y2 then
    ren:addPoint(X1, rowAH + Y2)
    ren:addPoint(X1, rowAH + Y1) 
  end
  X1 = 2*radAH+1
  YH = (radAH) * tanRoll
  Y1 = YH + dPitch_1
 
  Y2 = YH + 1.5 * dPitch_2 
   
  if Y1 < Y2 then
    ren:addPoint(X1, rowAH + Y2)
    ren:addPoint(X1, rowAH + Y1 )
  elseif Y1 > Y2 then
    ren:addPoint(X1, rowAH + Y1)
    ren:addPoint(X1, rowAH + Y2) 
  end
  ren:renderPolygon() 
  -- lcd.resetClipping()
 

  r,g,b = mixBgColor(txtr,txtg,txtb,0.5) 
  lcd.setColor(r,g,b) 
  lcd.drawLine(0, 0, 0, 2*radAH + 1 )
  lcd.drawLine(2* radAH, 0, 2* radAH , 2*radAH  )
  lcd.drawLine(0, 2*radAH,2* radAH , 2* radAH )
  lcd.drawLine(0, 0, 2*radAH, 0)
end


-- *****************************************************
-- Draw pitch lines indication
-- *****************************************************
local function drawPitch()
  if not pitch or not roll then return end
  lcd.setColor(txtr,txtg,txtb)
  sinRoll = sin(rad(-roll))
  cosRoll = cos(rad(-roll))
  --lcd.drawText(180,10,pitch..", "..roll)
  delta = pitch % 15    
  for i =  delta - 30 , 30 + delta, 15 do  
    XH = math.abs(pitch - i % 360)<0.01 and 30 or 13
    YH = pitchR * i                      
    
    X1 = -XH * cosRoll - YH * sinRoll
    Y1 = -XH * sinRoll + YH * cosRoll
    X2 = (XH - 2) * cosRoll - YH * sinRoll
    Y2 = (XH - 2) * sinRoll + YH * cosRoll

    if not ( -- test dimensions of a canvas
         (X1 < -radAH and X2 < -radAH)
      or (X1 > radAH and X2 > radAH)
      or (Y1 < -radAH and Y2 < -radAH)
      or (Y1 > radAH and Y2 > radAH)
    ) then -- Adjust X and Y coordinates

      
      ren:reset() 
      ren:addPoint(radAH+X1, radAH+ Y1)
      ren:addPoint(radAH + X2, radAH+Y2) 
      ren:renderPolyline(2)
      
    end
  end
  lcd.resetClipping()
end


-- *****************************************************
-- Draw heading indicator
-- *****************************************************
local parmHeading = {
  {0, 2, "N"}, {30, 5}, {60, 5},
  {90, 2, "E"}, {120, 5}, {150, 5},
  {180, 2, "S"}, {210, 5}, {240, 5},
  {270, 2, "W"}, {300, 5}, {330, 5}
}

local wrkHeading = 0
local w
local function drawHeading()
  lcd.setColor(txtr,txtg,txtb)
  lcd.drawLine(colHeading - 50, rowHeading, colHeading + 50, rowHeading)
  for index, point in pairs(parmHeading) do
    wrkHeading = point[1] - heading
    if wrkHeading > 180 then wrkHeading = wrkHeading - 360 end
    if wrkHeading < -180 then wrkHeading = wrkHeading + 360 end
    delatX = floor(wrkHeading / 2.2 + 0.5) - 1

    if delatX >= -31 and delatX <= 31 then
      if point[3] then
        lcd.drawText(colHeading + delatX - 4, rowHeading - 16, point[3], FONT_BOLD)
      end
      if point[2] > 0 then
        lcd.drawLine(colHeading + delatX, rowHeading - point[2], colHeading + delatX, rowHeading)
      end
    end
  end 
  
  text = format("%03d",heading)
  w = lcd.getTextWidth(FONT_NORMAL,text) 
  lcd.setColor(txtr,txtg,txtb)
  lcd.drawFilledRectangle(colHeading - w/2, rowHeading-30, w, lcd.getTextHeight(FONT_NORMAL))
  lcd.setColor(255-txtr,255-txtg,255-txtb)
  lcd.drawText(colHeading - w/2,rowHeading-30,text,  FONT_XOR) 
end

local function drawDistance()
  if distance > 0 then
    text =  format("%dm",distance)
    lcd.drawText(colAH + 16 - lcd.getTextWidth(FONT_NORMAL,text), rowAH + 10, text)
  end
  lcd.setColor(lcd.getFgColor())
  drawShape(colAH, rowAH, homeShape, rad(heading))
end


-- *****************************************************
-- Vertical line parameters (to improve or supress)
-- *****************************************************
local parmLine = {
  {rowAH - 72, 7, 30},  -- +30
  {rowAH - 60, 3},      -- +25
  {rowAH - 48, 7, 20},  -- +20
  {rowAH - 36, 3},      -- +15
  {rowAH - 24, 7, 10},  --  +10
  {rowAH - 12 , 3},      --  +5
  {rowAH     , 7, 0},        --   0
  {rowAH + 12, 3},       --  -5
  {rowAH + 24, 7, -10}, -- -10
  {rowAH + 36, 3},      -- -15
  {rowAH + 48, 7, -20}, -- -20
  {rowAH + 60, 3},      -- -25
  {rowAH + 72, 7, -30}  -- -30
}

-- *****************************************************
-- Draw altitude indicator
-- *****************************************************
local function drawAltitude()
  lcd.setColor(txtr,txtg,txtb)
  delta = altitude % 10
  deltaY = 1 + floor(2.4 * delta)  
  lcd.drawText(colAlt+2, heightAH, "m", FONT_NORMAL)
  lcd.setClipping(colAlt-7,0,45,heightAH)
  lcd.drawLine(7, -1, 7, heightAH)
  
  for index, line in pairs(parmLine) do
    lcd.drawLine(6 - line[2], line[1] + deltaY, 6, line[1] + deltaY)
    if line[3] then
      lcd.drawNumber(11, line[1] + deltaY - 8, altitude+0.5 + line[3] - delta, FONT_NORMAL)
    end
  end

  text = format("%d",altitude)
  lcd.drawFilledRectangle(11,rowAH-8,42,lcd.getTextHeight(FONT_NORMAL))

  lcd.setColor(255-txtr,255-txtg,255-txtb)
  lcd.drawText(12, rowAH-8, text, FONT_NORMAL | FONT_XOR)
  lcd.resetClipping()
end


-- *****************************************************
-- Draw speed indicator
-- *****************************************************
local function drawSpeed() 
  lcd.setColor(txtr,txtg,txtb)
  delta = speed % 10
  deltaY = 1 + floor(2.4 * delta)
  lcd.drawText(colSpeed-30, heightAH, "km/h", FONT_NORMAL)
  lcd.setClipping(colSpeed-37,0,45,heightAH)
  
  lcd.drawLine(37, -1, 37, heightAH)
  for index, line in pairs(parmLine) do
    lcd.drawLine(38, line[1] + deltaY, 38 + line[2], line[1] + deltaY)
    if line[3] then
      text = format("%d",speed+0.5 + line[3] - delta)
      lcd.drawText(35 - lcd.getTextWidth(FONT_NORMAL,text), line[1] + deltaY - 8, text, FONT_NORMAL)
    end
  end

  text = format("%d",speed)
  lcd.drawFilledRectangle(0,rowAH-8,35,lcd.getTextHeight(FONT_NORMAL))
  --lcd.drawNumber(9, 1 + rowAH - 3, altitude, FONT_MINI)
  lcd.setColor(255-txtr,255-txtg,255-txtb)
  lcd.drawText(35 - lcd.getTextWidth(FONT_NORMAL,text), rowAH-8, text, FONT_NORMAL | FONT_XOR)
  lcd.resetClipping() 
end


-- *****************************************************
-- Draw vario function
-- *****************************************************
local rowVario = 80
local colVario = 260
local function drawVario()
  lcd.setColor(txtr,txtg,txtb)
  lcd.drawLine(colVario-28,rowVario,colVario+27, rowVario )
  text = format("%.1f",vario)
  lcd.drawText(colVario+55-lcd.getTextWidth(FONT_NORMAL,text),rowVario-18,text)
  lcd.drawText(colVario+29,rowVario+1,"m/s")
  
  if(vario > 5) then vario = 5 end
  if(vario < -5) then vario = -5 end
  r,g,b = lcd.getFgColor()
  r,g,b = mixBgColor(r,g,b,0.5)
  lcd.setColor(r,g,b)
  if (vario > 0) then 
    lcd.drawFilledRectangle(colVario-26,rowVario-floor(vario*15 + 0.5),52,floor(vario*15+0.5))
  elseif(vario < 0) then 
    lcd.drawFilledRectangle(colVario-26,rowVario+1,52,floor(-vario*15 + 0.5))
  end   
end

 
-- *****************************************************
-- Main function
-- *****************************************************

local test = false                -- test flag (true to simulate telemetry data)
local wrkPitch, wrkRoll = 0, 0

local function getTelemetryValuesEX()
  local sensorData
  roll=nil
  pitch=nil
  distance=0
  -- Altitude
  if(sensorAId and paramAId) then
    sensorData = system.getSensorByID(sensorAId,paramAId)
    if(sensorData and sensorData.valid) then
      altitude =  sensorData.value
    end  
  end 
  
  -- Roll
  if(sensorRId and paramRId) then
    sensorData = system.getSensorByID(sensorRId,paramRId)
    if(sensorData and sensorData.valid) then
      roll =  sensorData.value 
    end  
  end 
  
  -- Pitch
  if(sensorPId and paramPId) then
    sensorData = system.getSensorByID(sensorPId,paramPId)
    if(sensorData and sensorData.valid) then
      pitch =  (360 + sensorData.value ) % 360         
    end  
  end 
  
  -- Speed
  if(sensorSId and paramSId) then
    sensorData = system.getSensorByID(sensorSId,paramSId)
    if(sensorData and sensorData.valid) then
      --Conversion to km/h
      speed = sensorData.value * 3.6
    end  
  end 
  
  -- Heading
  if(sensorHId and paramHId) then
    sensorData = system.getSensorByID(sensorHId,paramHId)
    if(sensorData and sensorData.valid) then 
      heading = sensorData.value
      if heading < 0 then heading = heading + 360 end
    end  
  end
  -- Vario
  if(sensorVId and paramVId) then
    sensorData = system.getSensorByID(sensorVId,paramVId)
    if(sensorData and sensorData.valid) then 
      vario = sensorData.value 
    end  
  end 
  -- Distance
  if(sensorDistId and paramDistId) then
    sensorData = system.getSensorByID(sensorDistId,paramDistId)
    if(sensorData and sensorData.valid) then
      distance = sensorData.value
    end
  end
end

-- *****************************************************
-- Get Test values (PC emulator)
-- *****************************************************
local function getTelemetryValuesTest()
    altitude = altitude + 0.2
    speed = speed + 0.1
    heading = (heading + 1) % 360
    wrkPitch = (wrkPitch + 0.1) % 120
    pitch = (wrkPitch > 60 and 120 - wrkPitch - 30 or wrkPitch - 30) % 360
    wrkRoll = (wrkRoll + 0.5) % 120    
    roll = (wrkRoll > 60 and 120 - wrkRoll - 30 or wrkRoll - 30) % 360
    vario = (roll < 180 and roll or roll-360)/5
    distance = roll
end

 
-- *****************************************************
-- Print telemetry function
-- *****************************************************
local function printTelemetry(width, height)
  -- Set text color
  local bgr,bgg,bgb = lcd.getBgColor()
  if (bgr+bgg+bgb) > 384 then 
    txtr,txtg,txtb = 0,0,0
  else
    txtr,txtg,txtb = 255,255,255
  end
    
  drawAltitude()
  drawSpeed()
  drawHeading()
  drawHorizon()
  drawPitch()
  drawDistance()
  drawVario()
end



-- *****************************************************
-- Configuration callbacks
-- *****************************************************
local function sensorRollChanged(value)
  if not sensorsAvailable[value] then return end
  sensorRId=sensorsAvailable[value].id
  paramRId=sensorsAvailable[value].param
  system.pSave("sensorR",sensorRId)
  system.pSave("paramR",paramRId)      
end

local function sensorPitchChanged(value)
  if not sensorsAvailable[value] then return end
  sensorPId=sensorsAvailable[value].id
  paramPId=sensorsAvailable[value].param
  system.pSave("sensorP",sensorPId)
  system.pSave("paramP",paramPId)      
end

local function sensorAltChanged(value)
  if not sensorsAvailable[value] then return end
  sensorAId=sensorsAvailable[value].id
  paramAId=sensorsAvailable[value].param
  system.pSave("sensorA",sensorAId)
  system.pSave("paramA",paramAId)      
end

local function sensorSpeedChanged(value)
  if not sensorsAvailable[value] then return end
  sensorSId=sensorsAvailable[value].id
  paramSId=sensorsAvailable[value].param
  system.pSave("sensorS",sensorSId)
  system.pSave("paramS",paramSId)      
end

local function sensorHeadChanged(value)
  if not sensorsAvailable[value] then return end
  sensorHId=sensorsAvailable[value].id
  paramHId=sensorsAvailable[value].param
  system.pSave("sensorH",sensorHId)
  system.pSave("paramH",paramHId)      
end

local function sensorVarioChanged(value)
  if not sensorsAvailable[value] then return end
  sensorVId=sensorsAvailable[value].id
  paramVId=sensorsAvailable[value].param
  system.pSave("sensorV",sensorVId)
  system.pSave("paramV",paramVId)      
end

local function sensorDistChanged(value)
  if not sensorsAvailable[value] then return end
  sensorDistId=sensorsAvailable[value].id
  paramDistId=sensorsAvailable[value].param
  system.pSave("sensorD",sensorDistId)
  system.pSave("paramD",paramDistId)
end

-- *****************************************************
-- Form initialization
-- *****************************************************
local function initForm()
  sensorsAvailable = {}
  local available = system.getSensors();
  local list={}
  local curPIndex,curRIndex,curAIndex,curSIndex,curHIndex,curVIndex,curDIndex = -1,-1,-1,-1,-1,-1,-1
  local descr = ""
  for index,sensor in ipairs(available) do 
    if(sensor.param == 0) then
      descr = sensor.label
    else
      list[#list+1]=format("%s - %s [%s]",descr,sensor.label,sensor.unit)
      sensorsAvailable[#sensorsAvailable+1] = sensor
      if(sensor.id==sensorRId and sensor.param==paramRId) then
        curRIndex=#sensorsAvailable
      end
      if(sensor.id==sensorPId and sensor.param==paramPId) then
        curPIndex=#sensorsAvailable
      end
      if(sensor.id==sensorAId and sensor.param==paramAId) then
        curAIndex=#sensorsAvailable
      end
      if(sensor.id==sensorSId and sensor.param==paramSId) then
        curSIndex=#sensorsAvailable
      end
      if(sensor.id==sensorHId and sensor.param==paramHId) then
        curHIndex=#sensorsAvailable
      end
      if(sensor.id==sensorVId and sensor.param==paramVId) then
        curVIndex=#sensorsAvailable
      end
      if(sensor.id==sensorDistId and sensor.param==paramDistId) then
        curDIndex=#sensorsAvailable
      end
    end 
  end
  form.addLabel({label=lang.cfgName,font=1})
  form.addRow(2)
  form.addLabel({label=lang.rollSensor,width=120})
  form.addSelectbox (list, curRIndex,true,sensorRollChanged,{width=190})
  form.addRow(2)
  form.addLabel({label=lang.pitchSensor,width=120})
  form.addSelectbox (list, curPIndex,true,sensorPitchChanged,{width=190})
  form.addRow(2)
  form.addLabel({label=lang.altSensor,width=120})
  form.addSelectbox (list, curAIndex,true,sensorAltChanged,{width=190})
  form.addRow(2)
  form.addLabel({label=lang.varioSensor,width=120})
  form.addSelectbox (list, curVIndex,true,sensorVarioChanged,{width=190})
  form.addRow(2)
  form.addLabel({label=lang.speedSensor,width=120})
  form.addSelectbox (list, curSIndex,true,sensorSpeedChanged,{width=190})
  form.addRow(2)
  form.addLabel({label=lang.hdgSensor,width=120})
  form.addSelectbox (list, curHIndex,true,sensorHeadChanged,{width=190})
  form.addRow(2)
  form.addLabel({label=lang.distSensor,width=120})
  form.addSelectbox (list, curDIndex,true,sensorDistChanged,{width=190})

end

-- *****************************************************
local function keyPressed(key)
  -- Remove available sensors from memory
  if(key==KEY_ESC or key==KEY_5) then
    sensorsAvailable = {} 
  end
end
-- *****************************************************
local function printForm()
  -- Empty function
end


-- *****************************************************
-- Loop function - collects data from sensors
-- *****************************************************
local function loop()
  getTelemetryValues()
end

-- *****************************************************
-- Initialization
-- *****************************************************
local function init()
  sensorRId = system.pLoad("sensorR")
  paramRId = system.pLoad("paramR")
  sensorPId = system.pLoad("sensorP")
  paramPId = system.pLoad("paramP")
  sensorAId = system.pLoad("sensorA")
  paramAId = system.pLoad("paramA")
  sensorSId = system.pLoad("sensorS")
  paramSId = system.pLoad("paramS")
  sensorHId = system.pLoad("sensorH")
  paramHId = system.pLoad("paramH")
  sensorVId = system.pLoad("sensorV")
  paramVId = system.pLoad("paramV")
  sensorDistId = system.pLoad("sensorD")
  paramDistId = system.pLoad("paramD")
  
  local devId,emulator=system.getDeviceType()
  if emulator~=0 then test = true end
  if test then
    getTelemetryValues = getTelemetryValuesTest
  else
    getTelemetryValues = getTelemetryValuesEX
  end
  
  system.registerForm(1,MENU_TELEMETRY,lang.fullName,initForm,keyPressed,printForm);
  system.registerTelemetry(1,lang.fullName,4,printTelemetry); 
  
end

-- *****************************************************
setLanguage()
return { init=init, loop=loop, author="JETI model", version="1.01",name=lang.appName}
