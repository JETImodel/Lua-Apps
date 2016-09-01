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

local appName="Test 25 - Open/Close form"
local lastTimeChecked
local rowIndex
--------------------------------------------------------------------

local function initForm(formID)
  rowIndex = form.addRow(1)
  form.addLabel({label="Blinking label"}) 
end  

local function keyPressed(key)
  if(key~=KEY_RELEASE) then
    form.close() 
  end
end  

--------------------------------------------------------------------
-- Loop function
local function loop()  
  if( form.getActiveForm() ) then 
    lastTimeChecked = system.getTimeCounter() 
    form.setProperties(rowIndex,{visible = (lastTimeChecked//1000)%2==0}) 
  else   
    if( system.getTimeCounter() > lastTimeChecked + 2000) then
      -- Show the form immediately
      system.registerForm(1,0,appName,initForm,keyPressed);
    end
  end   
end
 
--------------------------------------------------------------------
-- Init function
local function init() 
  lastTimeChecked = system.getTimeCounter() 
end

--------------------------------------------------------------------

return { init=init, loop=loop, author="JETI model", version="1.00",name=appName}