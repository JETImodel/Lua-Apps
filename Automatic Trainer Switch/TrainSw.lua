-- Automatic trainer switch - Lua application for JETI DC/DS transmitters
-- Version 1.0 - First official release
--         1.1 - Translations to several languages

--------------- 
local lang
local prevP1, prevP2, prevP3, prevP4
local playedFileT = ""
local playedFileS = ""
local playedType = 1
local switch
local prevVal = 1
local teacher = 0
local ctrlIdx 
-------------- 

--------------------------------------------------------------------
-- Configure language settings
local function setLanguage()
  local lng=system.getLocale();
  local file = io.readall("Apps/TrainSw/locale.jsn")
  local obj = json.decode(file)
  if(obj) then
    lang = obj[lng] or obj[obj.default]
  end
end

local function initForm(formID)
 
  form.addLabel({label=lang.fullName,font=2})
  form.addRow(2)
  form.addLabel({label=lang.audioTeacher})
  form.addAudioFilebox(playedFileT, function(value) playedFileT=value; system.pSave("fileT",value) end)
  
  form.addRow(2)
  form.addLabel({label=lang.audioStudent})
  form.addAudioFilebox(playedFileS, function(value) playedFileS=value; system.pSave("fileS",value) end)
  
  form.addRow(2)
  form.addLabel({label=lang.switch})
  form.addInputbox(switch,true, function(value) switch=value;system.pSave("switch",value); end ) 
   
end  

local function keyPressed(key)
   
end  

local function printForm()
  form.setButton(1,teacher > 0 and "On" or "Off" ,ENABLED) 
end  

 

--------------- 
-- Init function
local function init()
  playedFileT = system.pLoad("fileT","")
  playedFileS = system.pLoad("fileS","")
  switch = system.pLoad("switch") 
  system.registerForm(1,MENU_ADVANCED,lang.appName,initForm,keyPressed,printForm);
  ctrlIdx = system.registerControl(1, "Trainer Switch","T/S") 
end
 
-------------- 
-- Loop function
local function loop() 
  local val = system.getInputsVal(switch)
  if(val and val>0 and prevVal==0) then 
    prevVal=1
    if system.getProperty("WirelessMode") ~= "Teacher" then
      system.setProperty("WirelessMode","Teacher")
      system.playFile(playedFileT,AUDIO_IMMEDIATE)
    else
      prevP1,prevP2,prevP3,prevP4 = system.getInputs("P1","P2","P3","P4") 
      teacher = 1  
      system.playFile(playedFileS,AUDIO_IMMEDIATE) 
    end 
  elseif(val and val<=0)  then
    prevVal=0    
  end
  
  if teacher>0 then
    local P1,P2,P3,P4 = system.getInputs("P1","P2","P3","P4")
    if(math.abs(P1 - prevP1) > 0.1 or math.abs(P2 - prevP2) > 0.1
       or math.abs(P3 - prevP3) > 0.1 or math.abs(P4 - prevP4) > 0.1) then
      teacher=0 
      system.playFile(playedFileT,AUDIO_IMMEDIATE)
    end     
  end
  if(ctrlIdx) then
    system.setControl(ctrlIdx, teacher,0)
  end
end
 

----------------- 
setLanguage()
return { init=init, loop=loop, author="JETI model", version="1.01",name=lang.appName}
