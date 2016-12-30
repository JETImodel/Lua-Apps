
--Configuration
local sensorId=0
local paramId=0

--Local variables
local sensorsAvailable = {}

local lang
local options={}
local appName="Discharged Flightpack Warning"
local thresholdV = 200
local warnV = 320
local warnAudio = ""
local haveChecked = false
local passedThresholdTime = 0
local modelNameAudio = ""


--------------------------------------------------------------------
local function readFile(path)
 local f = io.open(path,"r")
  local lines={}
  if(f) then
    while 1 do
      local buf=io.read(f,512)
      if(buf ~= "")then
        lines[#lines+1] = buf
      else
        break
      end
    end
    io.close(f)
    return table.concat(lines,"")
  end
end
--------------------------------------------------------------------
-- Configure language settings
--------------------------------------------------------------------
local function setLanguage()
  -- Set language
  local lng=system.getLocale()
  local file = readFile("Apps/MainLow/locale.jsn")
  local obj = json.decode(file)
  if(obj) then
    lang = obj[lng] or obj[obj.default]
  end
end


--------------------------------------------------------------------
-- Get current voltage from sensor - Alert if appropriate
--------------------------------------------------------------------
function getVoltages()
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
    if (voltage < thresholdV) then
      haveChecked = true
    end
    if (not haveChecked and voltage > thresholdV and passedThresholdTime == 0) then
      passedThresholdTime = system.getTimeCounter() + 10000
    end
    if (not haveChecked and voltage > thresholdV and system.getTimeCounter() >= passedThresholdTime) then
      if (voltage < warnV) then
        system.playFile(warnAudio, AUDIO_IMMEDIATE)
      end
      haveChecked = true
    end
    if (haveChecked and voltage < thresholdV) then
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
    system.pSave("mlSensor",sensorId)
    system.pSave("mlParam",paramId)
  end
end

local function thresholdVChanged(value)
  if(value and value >= 0) then
    thresholdV = value
    system.pSave("mlThresholdV", thresholdV)
  end
end

local function warnVChanged(value)
  if (value and value >= 200) then
    warnV = value
    system.pSave("mlWarnV", warnV)
  end
end

local function warnAudioChanged(value)
  if (value) then
    warnAudio = value
    system.pSave("mlWarnAudio", warnAudio)
  end
end

local function modelNameAudioChanged(value)
  if (value) then
    system.pSave("mlModelAudio", value)
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
  form.addLabel({label=lang.selectSensor,width=120})
  form.addSelectbox (list, curIndex,true,sensorChanged,{width=190})
  form.addRow(2)
  form.addLabel({label=lang.triggerVoltage})
  form.addIntbox(thresholdV,20,84,84,1,1, thresholdVChanged)
  form.addRow(2)
  form.addLabel({label=lang.warnVoltage})
  form.addIntbox(warnV,41,840,412,1,1, warnVChanged)
  form.addRow(2)
  form.addLabel({label=lang.warnAudio})
  form.addAudioFilebox(warnAudio, warnAudioChanged)
  form.addRow(2)
  form.addLabel({label=lang.modelName})
  form.addAudioFilebox(modelNameAudio, modelNameAudioChanged)
end


--------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------
-- Init function
local function init()
  -- registers a whole-size window
  sensorId = system.pLoad("mlSensor",0)
  paramId = system.pLoad("mlParam",0)
  thresholdV = system.pLoad("mlThresholdV",200)
  warnV = system.pLoad("mlWarnV",410)
  warnAudio = system.pLoad("mlWarnAudio","")
  modelNameAudio = system.pLoad("mlModelAudio","")
  if (modelNameAudio) then
    system.playFile(modelNameAudio, AUDIO_IMMEDIATE)
  end

  system.registerForm(1,MENU_TELEMETRY,lang.appName,initForm,nil,printForm)
end




--------------------------------------------------------------------
-- Loop function
local function loop()
  getVoltages()
end


--------------------------------------------------------------------
setLanguage()
return { init=init, loop=loop, author="Peter Vogel", version="1.00",name=lang.appName}
