-- #############################################################################
-- # Throttle Stick "Soft" Detent - Lua application for JETI DC/DS transmitters
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
-- #        Increased reliability of bump value detection
-- #        Automatic detection of throttle stick (P2 vs P4)
-- # V1.2 - Improved translations to different languages
-- #############################################################################
--Configuration
local input
local bumpValue
local lastValue
local haveBumped = false
local swInfo


local lang
 



 
--------------------------------------------------------------------
-- Configure language settings
--------------------------------------------------------------------
local function setLanguage()
  -- Set language
  local lng=system.getLocale()
  local file = io.readall("Apps/ThrotBmp/locale.jsn")
  local obj = json.decode(file)
  if(obj) then
    lang = obj[lng] or obj[obj.default]
  end
end




--------------------------------------------------------------------
-- Form functions
--------------------------------------------------------------------
--------------------------------------------------------------------
local function inputChanged(value)
  input = value
  system.pSave("input", input)
end

local function bumpValueChanged(value)
  bumpValue = value
  system.pSave("bumpValue", bumpValue)
end

--------------------------------------------------------------------

local function initForm(formID)
  form.addRow(2)
  form.addLabel({label=lang.selectInput})
  form.addInputbox(input, true, inputChanged)
  form.addRow(2)
  form.addLabel({label=lang.bumpValue,width=250})
  form.addIntbox(bumpValue, -100, 100, 0, 0, 1, bumpValueChanged,{label="%"})
end


--------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------
-- Init function
local function init()
  input = system.pLoad("input", nil)
  bumpValue = system.pLoad("bumpValue", 0)

  --register our data form
  system.registerForm(1,MENU_ADVANCED,lang.appName,initForm,nil,printForm)
end




--------------------------------------------------------------------
-- Loop function
local function loop()
  local val = system.getInputsVal(input)
  if (not val) then
    return
  end
  if not lastValue then 
    lastValue = val
  end  
  local tol = 2
  val = val * 100
  if not haveBumped and ((val >= bumpValue-tol and lastValue < bumpValue-tol) or 
     (val <= bumpValue+tol and lastValue > bumpValue+tol)) then  
    haveBumped = true
    swInfo = system.getSwitchInfo(input)
    system.vibration(swInfo.label=="P2", 2)
    system.playBeep(1, 430, 100)
  end
  if (haveBumped and (val < bumpValue-tol or val > bumpValue+tol)) then
    haveBumped = false
  end
  lastValue = val
end


--------------------------------------------------------------------
setLanguage()
return { init=init, loop=loop, author="Peter Vogel - Team JetiUSA", version="1.2",name=lang.appName}
