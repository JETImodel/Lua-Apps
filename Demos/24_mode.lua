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
local appName="Test 24 - Mode" 
local mode=1
--------------------------------------------------------------------
 
local function checkButtons()
  form.setButton(1,"1)",mode==1 and HIGHLIGHTED or ENABLED)
  form.setButton(2,"2)",mode==2 and HIGHLIGHTED or ENABLED)
  form.setButton(3,"3)",mode==3 and HIGHLIGHTED or ENABLED)
  form.setButton(4,"4)",mode==4 and HIGHLIGHTED or ENABLED)
end 
--------------------------------------------------------------------
local function initForm(formID)  
  form.setButton(5,"Test",ENABLED)
  checkButtons()
end 
 
--------------------------------------------------------------------
local function keyPressed(key) 
  if(key==KEY_1) then     
    mode=1 
  elseif(key == KEY_2) then 
    mode=2 
  elseif(key == KEY_3) then 
    mode=3
  elseif(key == KEY_4) then 
    mode=4 
  elseif(key == KEY_5) then 
    form.preventDefault() 
    local text,state = form.getButton(5) 
    form.setButton(5,text,(state == HIGHLIGHTED) and ENABLED or HIGHLIGHTED)      
  end  
  checkButtons()
end  

local function printForm() 
  lcd.drawText(10,50,"Tx Mode: "..mode,FONT_MAXI)       
end 
 
--------------------------------------------------------------------
-- Init function
local function init()
  system.registerForm(1,MENU_MAIN,appName,initForm,keyPressed,printForm); 
end 
--------------------------------------------------------------------

return { init=init, author="JETI model", version="1.00",name=appName}
