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
local appName="Test 23 - Buttons" 
local intIdx,timeIdx
--------------------------------------------------------------------

local function valueChanged(val)
  if(val==0) then
    form.setButton(1,"<<",DISABLED)
    form.setButton(2,">>",ENABLED)
  elseif(val==100) then
    form.setButton(1,"<<",ENABLED)
    form.setButton(2,">>",DISABLED)
  else
    form.setButton(1,"<<",ENABLED)
    form.setButton(2,">>",ENABLED)
  end
end
--------------------------------------------------------------------
local function initForm(formID)
  form.addRow(2)
  form.addLabel({label="Select value"}) 
  intIdx = form.addIntbox(0,0,100,0,0,1,valueChanged)  
  
  form.addRow(2)
  form.addLabel({label="Timestamp"}) 
  timeIdx = form.addIntbox(0,0,32000,0,0,1,nil,{enabled=false}) 
  
  form.setButton(1,"<<",DISABLED)
  form.setButton(2,">>",ENABLED)
end  
--------------------------------------------------------------------
local function keyPressed(key)
  local val = form.getValue(intIdx)
  if(key==KEY_1) then     
    if(val>0) then
      val=val-1
      form.setValue(intIdx,val)
    end
  elseif(key == KEY_2) then 
    if(val<100) then
      val=val+1
      form.setValue(intIdx,val)   
    end
  end  
end  

local function printForm(key)
  local value = form.getValue(intIdx)
  lcd.drawText(10,50,value.."%",FONT_MAXI)       
end 
 
--------------------------------------------------------------------
-- Init function
local function init()
  system.registerForm(1,MENU_MAIN,appName,initForm,keyPressed,printForm); 
end

local function loop()
  if(timeIdx) then
    form.setValue(timeIdx,system.getTimeCounter()//1000)
  end 
end 
--------------------------------------------------------------------

return { init=init, loop=loop, author="JETI model", version="1.00",name=appName}
