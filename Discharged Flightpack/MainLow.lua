-- #############################################################################
-- # Discharged flight pack warning - Lua application for JETI DC/DS transmitters
-- # Developed by Peter A Vogel, donated to JETI Model s.r.o via pull request
-- #
-- # Copyright (c) 2017, Peter A Vogel
-- # All rights reserved.
-- # License donated to JETI Model s.r.o. for the benefit of JETI pilots
-- #
-- # License: Share alike
-- # Can be used and changed non commercial
-- #
-- # V1.0 - Initial release
-- # V1.1 - The readFile() function has been replaced by internal io.readall() (DC/DS FW V4.22)
-- # V1.2 - Translations to several languages
-- #############################################################################


--Configuration
local sensorId=0
local paramId=0

--Local variables
local sensorsAvailable = {}

local lang
local options={} 
local thresholdV = 200
local thresholdVReal = 20.0
local warnV = 320
local warnVReal = 32.0
local warnAudio = ""
local haveChecked = false
local passedThresholdTime = 0
local modelNameAudio = ""
local voltageSettleTime = 5


 
--------------------------------------------------------------------
-- Configure language settings
--------------------------------------------------------------------
local function setLanguage()
  -- Set language
  local lng=system.getLocale()
  local file = io.readall("Apps/MainLow/locale.jsn")
  local obj = json.decode(file)
  if(obj) then
    lang = obj[lng] or obj[obj.default]
  end
end


--------------------------------------------------------------------
-- Get current voltage from sensor - Alert if appropriate
--------------------------------------------------------------------
local function getVoltages()
  if(sensorId==0) then
    return
  end
  local values ={}
  local sensor
  local i = 1
  local voltage
  sensor = system.getSensorByID(sensorId,paramId)
  if sensor and sensor.valid then
    voltage = sensor.value
    if (not haveChecked and voltage > thresholdVReal and passedThresholdTime == 0) then
      passedThresholdTime = system.getTimeCounter() + voltageSettleTime*1000
    end
    if (not haveChecked and voltage > thresholdVReal and system.getTimeCounter() >= passedThresholdTime) then
      if (voltage < warnVReal) then
        system.playFile(warnAudio, AUDIO_IMMEDIATE)
      end
      haveChecked = true
    end
    if (haveChecked and voltage < thresholdVReal) then
      haveChecked = false
      passedThresholdTime = 0
    end
  end

end


--------------------------------------------------------------------
-- Form functions
--------------------------------------------------------------------
--------------------------------------------------------------------
local function sensorChanged(value)
  if value>0 then
    sensorId=sensorsAvailable[value].id
    paramId=sensorsAvailable[value].param
    system.pSave("sensorId",sensorId)
    system.pSave("paramId",paramId)
  end
end

local function thresholdVChanged(value)
  if(value and value >= 0) then
    thresholdV = value
    thresholdVReal = thresholdV/10.0
    system.pSave("thresholdV", thresholdV)
  end
end

local function warnVChanged(value)
  if (value and value >= 200) then
    warnV = value
    warnVReal = warnV/10.0
    system.pSave("warnV", warnV)
  end
end

local function voltageSettleTimeChanged(value)
  if (value and value>0) then
    voltageSettleTime = value
    system.pSave("settleTime", voltageSettleTime)
  end
end

local function warnAudioChanged(value)
  if (value) then
    warnAudio = value
    system.pSave("warnAudio", warnAudio)
  end
end

local function modelNameAudioChanged(value)
  if (value) then
    system.pSave("modelAudio", value) 
    modelNameAudio = value 
  end
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
      descr = sensor.label
    else
      list[#list+1]=string.format("%s - %s [%s]",descr,sensor.label,sensor.unit)
      sensorsAvailable[#sensorsAvailable+1] = sensor
      if(sensor.id==sensorId and sensor.param==paramId) then
        curIndex=#sensorsAvailable
      end
    end
  end
  form.addRow(2)
  form.addLabel({label=lang.modelName})
  form.addAudioFilebox(modelNameAudio, modelNameAudioChanged)
  form.addRow(2)
  form.addLabel({label=lang.selectSensor,width=120})
  form.addSelectbox (list, curIndex,true,sensorChanged,{width=190})
  form.addRow(2)
  form.addLabel({label=lang.triggerVoltage, width=230})
  form.addIntbox(thresholdV,20,84,84,1,1, thresholdVChanged,{label="V"})
  form.addRow(2)
  form.addLabel({label=lang.warnVoltage, width=230})
  form.addIntbox(warnV,41,840,410,1,1, warnVChanged,{label="V"})
  form.addRow(2)
  form.addLabel({label=lang.settleTime, width=230})
  form.addIntbox(voltageSettleTime,1,10,2,0,1, voltageSettleTimeChanged,{label="s"})
  form.addRow(2)
  form.addLabel({label=lang.warnAudio})
  form.addAudioFilebox(warnAudio, warnAudioChanged)
end


--------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------
-- Init function
local function init(code)
  -- play the model name if there is an audio file specified
  modelNameAudio = system.pLoad("modelAudio","")
  if (modelNameAudio ~= "" and code==1) then
    system.playFile(modelNameAudio, AUDIO_IMMEDIATE)
  end

  --load the discharged flight pack check parameters
  sensorId = system.pLoad("sensorId", 0)
  paramId = system.pLoad("paramId",0)
  thresholdV = system.pLoad("thresholdV", 20)
  thresholdVReal = thresholdV/10.0
  warnV = system.pLoad("warnV", 410)
  warnVReal = warnV/10.0
  voltageSettleTime = system.pLoad("voltageSettleTime", 1)
  warnAudio = system.pLoad("warnAudio", "")

  --register our data form
  system.registerForm(1,MENU_TELEMETRY,lang.appName,initForm,nil,printForm)
end




--------------------------------------------------------------------
-- Loop function
local function loop()
  getVoltages()
end


--------------------------------------------------------------------
setLanguage()
return { init=init, loop=loop, author="Peter Vogel - Team JetiUSA", version="1.2",name=lang.appName}
