-- ############################################################################# 
-- # DC/DS Preflight Check - Lua application for JETI DC/DS transmitters  
-- #
-- # Copyright (c) 2016 - 2017, JETI model s.r.o.
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
-- # V1.1 - Added Spanish and Italian language
-- # V1.2 - The readFile() function has been replaced by internal io.readall() (DC/DS FW V4.22)
-- #############################################################################

--Configuration
local optionsValues={}
local cfgAudio
local cfgSwitch
--Local variables
local lang
local options={} 
local selectboxes={} 
local checkboxes={}
local currentForm=0
local MAX_ITEMS = 20
local lastSwitchValue=true
 
--------------------------------------------------------------------
-- Configure language settings
--------------------------------------------------------------------
local function setLanguage()
  -- Set language
  local lng=system.getLocale();
  local file = io.readall("Apps/Preflight/locale.jsn")
  local obj = json.decode(file)  
  if(obj) then
    lang = obj[lng] or obj[obj.default]
  end
end
--------------------------------------------------------------------
-- Setting forms
--------------------------------------------------------------------
local function checkButtons()
  if(currentForm==1) then
    form.setButton(3,":add", #optionsValues < MAX_ITEMS and ENABLED or DISABLED)
    form.setButton(4,":delete",#optionsValues>0 and ENABLED or DISABLED)
    form.setButton(1,":tools",ENABLED)
  else
    form.setButton(1,":play",ENABLED)
  end
end
--------------------------------------------------------------------

local function optionChanged()
  for k, v in ipairs(selectboxes) do 
    optionsValues[k]=form.getValue(v)
  end
  system.pSave("items",optionsValues)
end

local function audioChanged(path)
  cfgAudio=path
  system.pSave("audio",path)
end
local function switchChanged(value)
  cfgSwitch=value
  system.pSave("switch",value)
end
--------------------------------------------------------------------
local function initForm(formID)
  selectboxes={}
  currentForm=formID
  if(formID==1) then 
    for index=1,#optionsValues do
      form.addRow(2)
      form.addLabel({label=index..")",alignRight=true,width=40,font=FONT_BOLD})
      selectboxes[index]=form.addSelectbox(options,optionsValues[index],true,optionChanged,{width=260})
    end 
  else 
    form.addLabel({label=lang.cfgName,font=FONT_BOLD})
    -- Assigned audio file
    form.addRow(2)
    form.addLabel({label=lang.audio})
    form.addAudioFilebox(cfgAudio,audioChanged)
    -- Assigned switch
    form.addRow(2)
    form.addLabel({label=lang.switch})
    form.addInputbox(cfgSwitch,false,switchChanged)
    
  end
  checkButtons()
end  
--------------------------------------------------------------------
local function keyPressed(key)
  if(currentForm==1) then
    if(key==KEY_3 and #optionsValues < MAX_ITEMS) then
      form.addRow(2)
      local vals = #optionsValues+1
      form.addLabel({label=(vals)..")",alignRight=true,width=40,font=FONT_BOLD})
      optionsValues[vals] = 0
      selectboxes[vals]=form.addSelectbox(options,0,true,optionChanged,{width=260})
      form.setFocusedRow(vals)
      --Save current selection
      optionChanged()
      checkButtons()
      return
    end
    local row = form.getFocusedRow()
    if(key==KEY_4 and row>0) then
      table.remove(optionsValues,row)
      table.remove(selectboxes,row) 
      optionChanged()
      form.reinit(1)
      return
    end 
    if(key==KEY_1) then
      form.reinit(2)
    end
  else
    if(key==KEY_1) then
      -- file playback
      system.playFile(cfgAudio,AUDIO_IMMEDIATE)
    elseif(key==KEY_5 or key==KEY_ESC) then
      form.preventDefault()
      form.reinit(1)
    end
  end
end  
--------------------------------------------------------------------
-- Preflight check form
--------------------------------------------------------------------
local function clickedCallback(value)
  local row = form.getFocusedRow()
  form.setValue(checkboxes[row],true)
  local removeForm = true
  for index=1,#checkboxes do
    if(form.getValue(checkboxes[index]) == 0) then
      removeForm = false
    end
  end
  if (removeForm) then
    form.close()
  end
end
--------------------------------------------------------------------
local function initFormPrefl(formID)
  -- form.setButton(5,"",ENABLED)
  local i=1
  checkboxes={}
  for index=1,#optionsValues do
    if(optionsValues[index] > 0) then
      form.addRow(3)
      form.addLabel({label=i..")",alignRight=true,width=40,font=FONT_BOLD})
      form.addLabel({label=options[optionsValues[index]],width=220})
      checkboxes[i] = form.addCheckbox(false,clickedCallback)
      i=i+1
    end
  end
  -- Empty form - immediately close
  if(#checkboxes==0) then
    form.close()
  elseif(string.len(cfgAudio) > 0) then
    -- file playback
    system.playFile(cfgAudio,AUDIO_QUEUE)  
  end   
end 
--------------------------------------------------------------------
local function keyPressedPrefl(key)
  if(key==KEY_MENU or key==KEY_ESC) then
    form.preventDefault()
  end
end 

-------------------------------------------------------------------- 
-- Initialization
--------------------------------------------------------------------
-- Init function
local function init(code) 
  -- Load data
  local file = io.readall("Apps/Preflight/"..lang.data)
  if(file) then
    options = json.decode(file)  
  end
  optionsValues = system.pLoad("items",{})
  cfgAudio = system.pLoad("audio","T_Ding.wav")
  cfgSwitch = system.pLoad("switch")
  system.registerForm(1,MENU_ADVANCED,lang.appName,initForm,keyPressed,printForm);
  -- Show the form (only after model selection)
  if(#optionsValues > 0 and code==1) then
    system.registerForm(0,0,lang.appName,initFormPrefl,keyPressedPrefl);
  end 
end


  

--------------------------------------------------------------------
-- Loop function
local function loop() 
  local val = system.getInputsVal(cfgSwitch)
  if(val and val>0 and not lastSwitchValue) then
    lastSwitchValue = true
    local frm=form.getActiveForm() 
    if(frm==0) then
      for index=1,#checkboxes do
        form.setValue(checkboxes[index],false)
      end
    elseif(#optionsValues > 0) then
      system.registerForm(0,0,lang.appName,initFormPrefl,keyPressedPrefl);
    end 
  elseif(val and val<=0) then 
    lastSwitchValue=false  
  end  
end
 

--------------------------------------------------------------------
setLanguage()
return { init=init, loop=loop, author="JETI model", version="1.2",name=lang.appName}