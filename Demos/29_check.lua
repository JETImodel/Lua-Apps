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
local appName="Test 29 - Checkbox/Servo Test" 
local showServo=true
local componentIndex
--------------------------------------------------------------------
local function checkClicked(value)
  showServo = not value
  form.setValue(componentIndex,showServo)
end  
--------------------------------------------------------------------
local function initForm(formID)  
  form.addRow(2)
  form.addLabel({label="Show servo outputs",width=270})
  componentIndex = form.addCheckbox(showServo,checkClicked)
end 
 
--------------------------------------------------------------------


local function printForm() 
  if(not showServo) then
    return 
  end  
  local s1,s2,s3,s4,s5,s6,s7,s8 = system.getInputs("O1","O2","O3","O4","O5","O6","O7","O8")
  local values={s1,s2,s3,s4,s5,s6,s7,s8}
  local offset=25
  local offsetx=10
  local textVal
  for i=1,8 do
    lcd.drawText(offsetx,offset,string.format("Ch %d:",i))
    textVal = string.format("%.1f %%",values[i]*100)
    lcd.drawText(offsetx+130 - lcd.getTextWidth(FONT_NORMAL,textVal),offset,textVal)
    offset=offset + 20
    if(i==4) then 
      offsetx = offsetx + 155
      offset = 25  
    end  
  end     
end 
 
--------------------------------------------------------------------
-- Init function
local function init()
  system.registerForm(1,MENU_MAIN,appName,initForm,keyPressed,printForm); 
end 
--------------------------------------------------------------------

return { init=init, author="JETI model", version="1.00",name=appName}
