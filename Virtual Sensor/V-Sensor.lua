-- ############################################################################# 
-- # DC/DS Virtual Sensor - Lua application for JETI DC/DS transmitters 
-- #
-- # Copyright (c) 2017, JETI model s.r.o.
-- # All rights reserved.
-- #
-- # Redistribution and use in source and binary forms, with or without
-- # modification, are permitted provided that the following conditions are met:
-- # 
-- # 1. Redistributions of source code must retain the above copyright notice, this
-- #    list of conditions and the following disclaimer.
-- # 2. Redistributions in binary form must reproduce the above copyright notice,
-- #    this list of conditions and the following disclaimer in the documentation
-- #    and/or other materials provided with the distribution.
-- # 
-- # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- # ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- # WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- # DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
-- # ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- # (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- # LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- # ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- # (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- # SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- # 
-- # The views and conclusions contained in the software and documentation are those
-- # of the authors and should not be interpreted as representing official policies,
-- # either expressed or implied, of the FreeBSD Project.                    
-- #                       
-- # V1.0 - Initial release
-- #############################################################################


--------------------------------------------------------------------  
local sensor1Id, param1Id
local sensor2Id, param2Id
local paramName, paramUnit
local sensorsAvailable = {}
local value1, value2
local condition  = ""
local conditionChanged=false
local fAvailable = {"p1","p2","*","/","+","-","(",")",".","0","1","2","3","4","5","6","7","8","9","sin(","cos(","rad("}
local fIndex = 1
local result = ""
local currentForm=1
local linkIdx=0

local lang

--------------------------------------------------------------------
-- Configure language settings
--------------------------------------------------------------------
local function setLanguage()
  -- Set language
  local lng=system.getLocale();
  local file = io.readall("Apps/V-Sensor/locale.jsn")
  local obj = json.decode(file)  
  if(obj) then
    lang = obj[lng] or obj[obj.default]
  end
end

local function updateValues()
  local sensorData
  if(sensor1Id and param1Id) then
    sensorData = system.getSensorByID(sensor1Id,param1Id)
    if(sensorData and sensorData.valid) then
      value1 =  sensorData.value
    end   
  end  
  if(sensor2Id and param2Id) then
    sensorData = system.getSensorByID(sensor2Id,param2Id)  
    if(sensorData and sensorData.valid) then
      value2 =  sensorData.value
    end 
  end 
end

--------------------------------------------------------------------
local function sensor1Changed(value)
  if value>0 then
    sensor1Id=sensorsAvailable[value].id
    param1Id=sensorsAvailable[value].param
    system.pSave("sensor1",sensor1Id)
    system.pSave("param1",param1Id)
  end      
end
local function sensor2Changed(value)
  if value>0 then
    sensor2Id=sensorsAvailable[value].id
    param2Id=sensorsAvailable[value].param
    system.pSave("sensor2",sensor1Id)
    system.pSave("param2",param1Id)
  end      
end

local function textChanged(value)
   paramName = value
   system.pSave("name",value)      
end
local function unitChanged(value)
   paramUnit = value
   system.pSave("unit",value)      
end


 
--------------------------------------------------------------------

local function initForm(formID)
  currentForm=formID
  fIndex = 1
  sensorsAvailable = {}
  if(currentForm == 1) then
    local available = system.getSensors();
    local list={}
    local cur1Index,cur2Index = -1, -1 
    for index,sensor in ipairs(available) do 
      if(sensor.param ~= 0) then 
        if(sensor.sensorName and string.len(sensor.sensorName) > 0) then
          list[#list+1]=string.format("%s - %s [%s]",sensor.sensorName,sensor.label,sensor.unit)
        else
          list[#list+1]=string.format("%s [%s]",sensor.label,sensor.unit)
        end
        sensorsAvailable[#sensorsAvailable+1] = sensor
        if(sensor.id==sensor1Id and sensor.param==param1Id) then
          cur1Index=#sensorsAvailable
        end
        if(sensor.id==sensor2Id and sensor.param==param2Id) then
          cur2Index=#sensorsAvailable
        end
      end 
    end 
    form.addRow(2)
    form.addLabel({label=lang.selectSensor.." 1",width=130})
    form.addSelectbox (list, cur1Index,true,sensor1Changed,{width=180})
    form.addRow(2)
    form.addLabel({label=lang.selectSensor.." 2",width=130})
    form.addSelectbox (list, cur2Index,true,sensor2Changed,{width=180})
    form.addRow(2)
    form.addLabel({label=lang.sName,width=130})
    form.addTextbox (paramName, 14,textChanged,{width=180})
    form.addRow(2)
    form.addLabel({label=lang.sUnit,width=130})
    form.addTextbox (paramUnit, 4,unitChanged,{width=180})
    
    form.addSpacer(300,8)
    form.addLink((function() form.reinit(2);form.waitForRelease() end),{label=string.format("%s = %s >>",lang.res,condition),font=FONT_BOLD})
    form.setButton(4,":tools",ENABLED)
  else -- Form 2
    form.setButton(4,":backspace",ENABLED)  
  end
end  

local function keyPressed(key)
  if currentForm == 1 then
    if(key == KEY_4) then 
      form.reinit(2)
    elseif(key == KEY_ESC or key == KEY_5) then
      sensorsAvailable = {} 
    end   
  else  --Current form = 2
    if(key == KEY_DOWN) then
      fIndex = fIndex-1
      if fIndex == 0 then fIndex = #fAvailable end
    elseif(key == KEY_UP) then
      fIndex = fIndex+1
      if fIndex == #fAvailable +1 then fIndex = 1 end
    elseif(key == KEY_ENTER) then
      condition = condition .. fAvailable[fIndex]
      conditionChanged = true
      system.pSave("cond",condition)
      form.waitForRelease()
    elseif(key == KEY_3) then
      condition = ""  
      conditionChanged = true
      system.pSave("cond",condition)
    elseif(key == KEY_4) then 
      condition = string.sub(condition,1,-2)
      conditionChanged = true
      system.pSave("cond",condition)
    elseif(key == KEY_ESC or key == KEY_5) then
      form.reinit(1)
      form.preventDefault()                         
    end
  end
end  

local function formattedResult()
  if  type(result)=="number" then
    return string.format("%.1f %s",result,paramUnit)
  else
    return result or ""
  end    
end

local function printForm()
  local r = string.format("%s: %s",paramName,formattedResult())
  lcd.drawText(lcd.width - 10 - lcd.getTextWidth(FONT_BIG,r),120,r, FONT_BIG)
  if(currentForm==2)then                     
    lcd.drawText(10,20,condition or "",FONT_BIG) 
    --lcd.drawText(10+lcd.getTextWidth(FONT_BIG,condition),20,fAvailable[fIndex],FONT_BIG)
    local x=25
    for i = fIndex - 3, fIndex + 3,1 do
      if i < 1 then i = i+#fAvailable 
      elseif i > #fAvailable then i = i - #fAvailable
      end
      local font = i==fIndex and FONT_BIG or FONT_NORMAL
      lcd.drawText(x-lcd.getTextWidth(font,fAvailable[i])/2,50,fAvailable[i],font)
      x=x+43
    end
  end
  
end  


--------------------------------------------------------------------
local function printTelemetry(width, height)
  -- Print current telemetry
  --lcd.setColor(lcd.getFgColor())
  local font = height > 40 and FONT_MAXI or FONT_BIG
  local r = formattedResult()
  lcd.drawText(width-10-lcd.getTextWidth(font,r),(height-lcd.getTextHeight(font))/2,r,font) 
  
  
 
  
end 
 

--------------------------------------------------------------------
-- Init function
local function init()
  sensor1Id = system.pLoad("sensor1")
  param1Id = system.pLoad("param1")
  sensor2Id = system.pLoad("sensor2")
  param12d = system.pLoad("param2")
  condition = system.pLoad("cond","")
  conditionChanged = true
  paramName = system.pLoad("name","")
  paramUnit = system.pLoad("unit","")
  system.registerForm(1,MENU_TELEMETRY,lang.appName,initForm,keyPressed,printForm);
  system.registerTelemetry(1,lang.appName..": "..paramName,0,printTelemetry); 
  if(system.getVersion() < "4.26") then return end
  system.registerLogVariable(paramName,paramUnit,(function(index) 
    return type(result)=="number" and  result*10  or nil, 1   
  end))
   
end


  

--------------------------------------------------------------------
-- Variables for the Loop function
local env = {
  p1 = 0,
  p2 = 0,
  sin = math.sin, 
  cos = math.cos, 
  rad = math.rad
} 
local chunk,err, status
-- Loop function
local function loop() 
  updateValues() 
  env.p1 = value1 or 0 
  env.p2 = value2 or 0 
  
  if conditionChanged == true then
    chunk, err = load("return "..condition,"","t",env)
    conditionChanged = false
  end
  if(chunk) then
    status,result = pcall(chunk)
    result = result or ""
    --if not status then print(result) end
  else
    result = "N/A"
  end
end
 

--------------------------------------------------------------------
setLanguage()
return { init=init, loop=loop, author="JETI model", version="1.00",name=lang.appName}