-- ############################################################################# 
-- # DC-24 Properties & Features - Lua application for JETI DC/DS transmitters 
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
local appName="DC-24 Presentation"
local p1,p2,p3,p4
local lastTimeMoved
local values ={}
local formTime
local formSlide

-- Drawing images
local logolua,imgmap,imggear,imggraph

--------------------------------------------------------------------
local function randomGenerator ()
  local prevTime = system.getTimeCounter()
  local lastVal=0
  return function()
    local newTime = system.getTimeCounter();
    if(newTime>=prevTime+400) then
      prevTime = newTime
      lastVal = (lastVal + math.random(-5,5) + math.random(-5, 5)) *0.9
      return lastVal+20, true
    else
      return lastVal+20, false
    end
  end
end
 
local getNextValue = randomGenerator() 

--------------------------------------------------------------------

local function listItem(label,timeFrom,timeTo)
  -- Print function
  return function(curTime,offsetY)
    if(curTime > timeFrom and curTime< timeTo) then
      lcd.setColor(0,0,0,math.min((curTime-timeFrom)/2,255))
      lcd.drawText(10,offsetY,label,FONT_BOLD)
    end
  end
end

local slide1={
  listItem("» 24 proportional channels",0,10000),
  listItem("» Dual band 2.4GHz & 900MHz",1000,10000),
  listItem("» Haptic feedback",2000,10000),
  listItem("» Voice commands",3000,10000),
  listItem("» MP3 playback",4000,10000),
  listItem("» Model & background images",5000,10000),
  listItem("» FM Tuner",6000,10000),  
}

local slide2={
  listItem("» Easily extensible using",0,10000),
  listItem("",1500,10000),
  listItem("  Lua scripting language",1500,10000), 
}

local slide3={
  listItem("The Lua interface offers:",0,10000),
  listItem("» LCD drawing functions",1000,10000),
  listItem("» Audio playback functions",2000,10000),
  listItem("» Form controls",3000,10000),
  listItem("» SD card access",4000,10000),
  listItem("» Telemetry functions",5000,10000),
}

local slide4={
  listItem("» Maps projection",0,10000), 
}
local slide5={
  listItem("» Extended telemetry",0,10000), 
}
local slide6={
  listItem("» Intelligent gear control",0,10000), 
}

local slides = {slide1, slide2,slide3,slide4,slide5,slide6}

--------------------------------------------------------------------

local function initForm(formID)
  formTime = system.getTimeCounter()
  slide = 1
end  

local function keyPressed(key)
  if(key==KEY_ENTER) then
    formTime = system.getTimeCounter()
    slide =  slide + 1
    if(slide > #slides) then 
      slide = 1
    end 
  end
end  

local function printForm()
  local curTime = system.getTimeCounter() - formTime
  if(curTime >=10000) then
    slide = slide + 1
    curTime = curTime-10000
    formTime = formTime+10000
    if(slide > #slides) then 
      slide = 1
    end 
  end
  
  if(slide == 4) then
    if(imgmap) then
      lcd.drawImage(0, -curTime//120, imgmap,200)
    end
  end  
    
  local offY=4
  for i,v in pairs(slides[slide]) do
    v(curTime,offY)
    offY = offY + 20
  end 
  
  -- Print additional info
  if(slide == 2) then
    if(logolua and curTime>1700) then
      lcd.drawImage((310-logolua.width), 30, logolua)
    end  
  elseif(slide == 5) then
    if(imggraph) then
      lcd.drawImage(0,30, imggraph)
    end  
    lcd.setColor(lcd.getFgColor())
    lcd.drawRectangle(10,100,150,22)
    lcd.drawFilledRectangle(12,102,70,18)
    lcd.drawText(170, 102,"Capacity: 50%", FONT_BOLD)
  elseif(slide == 6) then
    if(imggear) then
      lcd.drawImage((310-imggear.width)//2, 50, imggear)
    end  
  end
end  


--------------------------------------------------------------------
local function printTelemetry(width, height)
  -- Print current telemetry
  lcd.setColor(0xAA,0xAA,0xAA)
  lcd.drawFilledRectangle(160,74,158,84)
  lcd.setColor(lcd.getFgColor())
  lcd.drawLine(162,98,308,98)
  lcd.setColor(0,0,0)
  lcd.drawText(170,80,"Altitude",FONT_BOLD)
  local val,isnew = getNextValue()
  if(isnew) then
    table.insert(values,val)
    table.remove(values,1) 
  end
  local text = string.format("%.1fm",val)
  lcd.drawText(310-lcd.getTextWidth(FONT_MAXI,text),110,text,FONT_MAXI)
  
  -- Print graph
  lcd.drawLine(10,10,10,60)
  lcd.drawLine(10,60,310,60)
  lcd.setColor(0x77,0x77,0x77)
  local offset = 10
  for i,v in pairs(values) do
    v=math.floor(v)
    lcd.drawFilledRectangle(offset,60-v,3,v)
    offset = offset + 3
  end
end 

local function printTelemetryMap(width, height)
  -- Print current map
  if(imgmap) then
    lcd.drawImage(0, 0, imgmap)
    
  end
end 

--------------------------------------------------------------------
-- Init function
local function init()
  system.registerForm(1,MENU_MAIN,appName,initForm,keyPressed,printForm);
  system.registerTelemetry(1,"Scriptable telemetry",3,printTelemetry);
  system.registerTelemetry(2,"Scriptable map",4,printTelemetryMap);
  p1,p2,p3,p4 = system.getInputs("P1", "P2", "P3", "P4")
  lastTimeMoved = system.getTimeCounter()
  for i=1,100 do
    values[i] = 0
  end 
  logolua = lcd.loadImage("Apps/img/logolua.png")
  imgmap = lcd.loadImage("Apps/img/map.jpg")
  imggear = lcd.loadImage("Apps/img/gear.jpg")
  imggraph = lcd.loadImage("Apps/img/graph.jpg")
end


  

--------------------------------------------------------------------
-- Loop function
local function loop() 

  local p1a,p2a,p3a,p4a = system.getInputs("P1", "P2", "P3", "P4")
  if(math.abs(p1a-p1) > 0.05 or math.abs(p2a-p2) > 0.05 
    or math.abs(p3a-p3) > 0.05 or math.abs(p4a-p4) > 0.05 
    or form.getActiveForm()
    ) then
    p1=p1a; p2=p2a; p3=p3a; p4=p4a;
    lastTimeMoved = system.getTimeCounter()
  else   
    if( system.getTimeCounter() > lastTimeMoved + 50000) then
      -- Show the form
      system.registerForm(1,0,appName,initForm,keyPressed,printForm);
    end
  end  
    
end
 

--------------------------------------------------------------------

return { init=init, loop=loop, author="JETI model", version="1.00",name=appName}
