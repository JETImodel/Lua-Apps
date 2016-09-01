-- ############################################################################# 
-- # DC-24 Demos 
-- #
-- # Copyright (c) 2016, JETI model s.r.o.
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
local appName="Test 22 - Audio play"
local playedFile
local playedType = 1
local switch
local prevVal = 1

local typeOptions={"Play in background", "Play immediately", "Add to queue"}
local typeValues={AUDIO_BACKGROUND, AUDIO_IMMEDIATE, AUDIO_QUEUE} 
 
-------------------------------------------------------------------- 
local function fileChanged(value)
  playedFile=value
  system.pSave("file",value)   
end

local function typeChanged(value)
  playedType=value
  system.pSave("type",value) 
end

local function switchChanged(value)
  switch=value
  system.pSave("switch",value) 
end 
--------------------------------------------------------------------

local function initForm(formID)
  form.addRow(2)
  form.addLabel({label="Select file"})
  form.addAudioFilebox(playedFile or "", fileChanged)
  
  form.addRow(2)
  form.addLabel({label="Playback type",width=120})
  form.addSelectbox(typeOptions,playedType or 1,false,typeChanged,{width=190})
  
  form.addRow(2)
  form.addLabel({label="Switch"})
  form.addInputbox(switch,true,switchChanged)  
  form.setButton(1,"Play",ENABLED)
end  

local function keyPressed(key)
  if(key==KEY_1) then
    system.playFile(playedFile,typeValues[playedType]) 
  end
end  
 
--------------------------------------------------------------------
-- Init function
local function init()
  system.registerForm(1,MENU_MAIN,appName,initForm,keyPressed); 
  playedFile = system.pLoad("file","")
  switch = system.pLoad("switch")
  playedType = system.pLoad("type",1) 
end
  
--------------------------------------------------------------------
-- Loop function
local function loop() 
  local val = system.getInputsVal(switch)
  if(val and val>0 and prevVal==0) then 
    system.playFile(playedFile,typeValues[playedType])
    prevVal=1 
  elseif(val and val<=0)  then
    prevVal=0    
  end  
  
end          

--------------------------------------------------------------------

return { init=init, loop=loop, author="JETI model", version="1.00",name=appName}
