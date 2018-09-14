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

local appName="Renderer test" 

local ren=lcd.renderer()
ren:addPoint(5,75) 
ren:addPoint(10,50)
ren:addPoint(20,100)
ren:addPoint(30,75)
ren:addPoint(50,75)

local renShape=lcd.renderer()
local homeShape = {
  { 0, -50},
  {-40,  40},
  { 0,  20},
  { 40,  40}
}
local heading = 0

-- *****************************************************
-- Draw a shape
-- *****************************************************
local function drawShape(col, row, shape, rotation)
  sinShape = math.sin(rotation)
  cosShape = math.cos(rotation)
  renShape:reset()
  for index, point in pairs(shape) do
    renShape:addPoint(
      col + (point[1] * cosShape - point[2] * sinShape + 0.5),
      row + (point[1] * sinShape + point[2] * cosShape + 0.5)
    ) 
  end
  renShape:renderPolygon()
end

--------------------------------------------------------------------
-- Init function
--------------------------------------------------------------------
local function initForm(formId) 
  
      
end

--------------------------------------------------------------------
-- Init function
--------------------------------------------------------------------
local function printForm(formId)
  lcd.setColor(lcd.getFgColor())  
  ren:renderPolyline(4) 
  drawShape(200, 80, homeShape, math.rad(heading)) 
end
 
local function loop()
  heading = (heading + 1) % 360 
end 
--------------------------------------------------------------------
-- Init function
--------------------------------------------------------------------
local function init() 
  system.registerForm(1,MENU_APPS,appName,initForm,nil,printForm) 
end 
return { init=init, loop=loop, author="JETI model", version="1.00",name=appName}