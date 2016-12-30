
--Configuration
local input
local bumpValue
local haveBumped = false


local lang

local appName="Throttle Detent/Beep"



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
  local file = readFile("Apps/ThrotBmp/locale.jsn")
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
  form.addLabel({label=lang.bumpValue})
  form.addIntbox(bumpValue, -100, 100, 0, 0, 1, bumpValueChanged)
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
  local tol = 2
  val = val * 100
  if (not haveBumped and (val >= bumpValue-tol and val <= bumpValue+tol)) then
    haveBumped = true
    system.vibration(false, 2)
    system.playBeep(1, 430, 100)
  end
  if (haveBumped and (val < bumpValue-tol or val > bumpValue+tol)) then
    haveBumped = false
  end
end


--------------------------------------------------------------------
setLanguage()
return { init=init, loop=loop, author="Peter Vogel - Team JetiUSA", version="1.00",name=lang.appName}
