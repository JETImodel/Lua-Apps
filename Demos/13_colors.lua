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

local level = 200 
-- Prints the last button pressed 
local function printForm()
  lcd.setColor(level,0,0)
  lcd.drawFilledRectangle(10,10,50,50)
  lcd.setColor(0,level,0)
  lcd.drawFilledRectangle(60,60,50,50)
  lcd.setColor(0,0,level)
  lcd.drawFilledRectangle(110,10,50,50)
  lcd.setColor(level,level,0)
  lcd.drawFilledRectangle(160,60,50,50)
  lcd.setColor(0,level,level)
  lcd.drawFilledRectangle(210,10,50,50)
  lcd.setColor(level,0,level)
  lcd.drawFilledRectangle(260,60,50,50)
  -- Transparent rectangle
  lcd.setColor(0,0,0,50)
  lcd.drawFilledRectangle(20,45,280, 30)
   
end


local function init() 
  system.registerForm(1,MENU_MAIN,"Test 12 - Drawing",nil, nil,printForm) 
end
--------------------------------------------------------------------------------
return {init=init, author="JETI model", version="1.0"}

