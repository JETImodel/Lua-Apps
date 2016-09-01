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

local appName = "Test 20 - Load/Save"
local switch, number, text

local function textChanged(value)
  text=value
  system.pSave("text",value)   
end

local function numberChanged(value)
  number=value
  system.pSave("number",value) 
end

local function switchChanged(value)
  switch=value
  system.pSave("switch",value) 
end
-- Form initialization
local function initForm(subform)
  form.addRow(2)
  form.addLabel({label="Text"})
  form.addTextbox(text,20,textChanged)
  
  form.addRow(2)
  form.addLabel({label="Number"})
  form.addIntbox(number,0,100,0,0,1,numberChanged)
  
  form.addRow(2)
  form.addLabel({label="Switch"})
  form.addInputbox(switch,true,switchChanged)
end
-- Init
local function init()
  system.registerForm(1,MENU_MAIN,appName,initForm) 
  text = system.pLoad("text","Foo")
  switch = system.pLoad("switch")
  number = system.pLoad("number",10)
end
----------------------------------------------------------------------
return { init=init,  author="JETI model", version="1.0", name=appName}