-- ############################################################################# 
-- # DC/DS F3K Training - Lua application for JETI DC/DS transmitters  
-- #
-- # Copyright (c) 2017, by Geierwally
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
-- # V1.0.1 - Initial release for main functionalities of F3K Task	
-- # V1.0.2 - Implementation of tasks F, G, H, I, J and TT
-- #############################################################################
--Configuration
--Local variables
local task_lib = nil -- lua script of loaded task
local taskList={} --list of all training tasks
local taskBox
local frameBox
local audioBox
local labelChar = string.byte('A')
local taskCharF3K = nil
local task_Path = nil
local tFileF3K = nil -- file object for the log files
local tDateF3K = system.getDateTime() -- current date for the file name and the task start time

--------------------------------------------------------------------
-- Configure language settings
--------------------------------------------------------------------
local function setLanguage()
  -- Set language
  local lng=system.getLocale();
  local file = io.readall("Apps/F3K/lang/"..lng.."/locale.jsn")
  local obj = json.decode(file)  
  if(obj) then
    langF3K = obj
  end
end

-------------------------------------------------------------------- 
-- Initialization
--------------------------------------------------------------------
local function resetTask_()
  frameTimerF3K = cfgFrameTimeF3K[currentTaskF3K] --preset frame timer with configured value
  tDateF3K = system.getDateTime()
  prevSoundTimeF3K = 0	   --previous time for audio output
  soundTimeF3K = 0		   --calculated time for audio output
  flightTimeF3K = 0
  breakTimeF3K = 0
  failedFlightsF3K = nil --list of failed flights
  goodFlightsF3K = nil --list of all good flights
  preSwitchTaskResetF3K = false --logic for reset task switch (for tasks with combined stopp and reset functionality e.g. task A and B)
  taskCharF3K = nil
  
  if(task_lib ~= nil)then
	package.loaded[task_Path]=nil
	_G[task_Path]=nil
	task_lib = nil
	task_Path = nil
	collectgarbage('collect')
  end	
  -- load current task
  
  if(task_lib == nil)then 
	if(currentTaskF3K == 1)then -- last flight
		task_Path = "F3K/Tasks/task_A"
		task_lib = require(task_Path)
	elseif(currentTaskF3K == 2)then -- next to last flight
		task_Path = "F3K/Tasks/task_B"
		task_lib = require(task_Path)
	elseif(currentTaskF3K == 3)then -- all up last down
		task_Path = "F3K/Tasks/task_C"
		task_lib = require(task_Path)
	elseif(currentTaskF3K == 4)then --ladder
		task_Path = "F3K/Tasks/task_D"
		task_lib = require(task_Path)
	elseif(currentTaskF3K == 5)then --poker
		task_Path = "F3K/Tasks/task_E"
		task_lib = require(task_Path)
	elseif(currentTaskF3K == 6)then --3 out of 6
		task_Path = "F3K/Tasks/task_F"
		task_lib = require(task_Path)
	elseif(currentTaskF3K == 7)then --5 longest flights
		task_Path = "F3K/Tasks/task_G"
		task_lib = require(task_Path)
	elseif(currentTaskF3K == 8)then --1,2,3,4 min target 
		task_Path = "F3K/Tasks/task_H"
		task_lib = require(task_Path)
	elseif(currentTaskF3K == 9)then --3 lognest flights
		task_Path = "F3K/Tasks/task_I"
		task_lib = require(task_Path)
	elseif(currentTaskF3K == 10)then --3 last flights
		task_Path = "F3K/Tasks/task_J"
		task_lib = require(task_Path)
	elseif(currentTaskF3K == 11)then -- big ladder
		task_Path = "F3K/Tasks/task_K"
		task_lib = require(task_Path)
	elseif(currentTaskF3K == 12)then -- free flight
		task_Path = "F3K/Tasks/task_FF"
		task_lib = require(task_Path)
	elseif(currentTaskF3K == 13)then -- trainings statisic task
		task_Path = "F3K/Tasks/task_TS"
		task_lib = require(task_Path)
    elseif(currentTaskF3K == 14)then -- trainings flight task
		task_Path = "F3K/Tasks/task_TF"
		task_lib = require(task_Path)
	elseif(currentTaskF3K == 15)then -- empty task, necessary for loading on startup to avoid storage lack
	    -- nothing to do
	else	-- free flight is default task
		currentTaskF3K = 12
		task_Path = "F3K/Tasks/task_FF"
		task_lib = require(task_Path)	
	end
  end
  if(currentTaskF3K < 12)then
	taskCharF3K = string.char(labelChar+currentTaskF3K-1)
  elseif(currentTaskF3K == 12)then 
	taskCharF3K = "FF"
  elseif(currentTaskF3K == 13)then 
	taskCharF3K = "TS"
  elseif(currentTaskF3K == 14)then 
	taskCharF3K = "TF"
  else
	taskCharF3K = "  "
  end
  if(task_lib ~=nil)then
  	local func = task_lib[1]  --init() 
	func() -- execute specific initializer
  end	
end

-- Init function
local function init(code)
	if(code == 0) then
		setLanguage()
		currentTaskF3K = system.pLoad("currentTask",1)
		cfgFrameTimeF3K = system.pLoad("frameTime",{600,600,3,600,600,600,600,600,600,600,600,600,600,600})--Frame time of all F3K training tasks in seconds
		cfgPreFrameTimeF3K = system.pLoad("preFrameTime",10)
		cfgStartFrameSwitchF3K=system.pLoad("frameSwitch")
		cfgStartFlightSwitchF3K=system.pLoad("startFlightSwitch")
		cfgStoppFlightSwitchF3K=system.pLoad("stoppFlightSwitch")
		cfgFrameAudioSwitchF3K=system.pLoad("frameAudioSwitch")
		cfgTimerResetSwitchF3K=system.pLoad("timerResetSwitch")
		cfgFlightCountDownSwitchF3K=system.pLoad("flightCountDownSwitch")
		cfgTargetTimeF3K=system.pLoad("adTargetTime",30)
		taskList={langF3K.A,langF3K.B,langF3K.C,langF3K.D,langF3K.E,langF3K.F,langF3K.G,langF3K.H,langF3K.I,langF3K.J,langF3K.K,langF3K.FF,langF3K.TS,langF3K.TF} --initialize the task list
		cfgAudioFlights = system.pLoad("audioFlights",{3,5,4,3,3,3})  -- number of audio output best flights in order for tasks F,G,H,I,J
		local deviceType = system.getDeviceType()
		if(( deviceType == "JETI DC-24")or(deviceTypeF3K == "JETI DS-24"))then
			colorScreenF3K = true -- set display type
		end
	else
		currentTaskF3K = 15 -- unload task lib
	end
	resetTask_()
end

local function frameTimeChanged(value)
  if(task_lib ~=nil)then
  	local func = task_lib[2]  --frameTimeChanged() 
	func(value,frameBox) -- execute specific frame time changed handler
  end	
end
local function preFrameTimeChanged(value)
	cfgPreFrameTimeF3K=value
	system.pSave("preFrameTime",cfgPreFrameTimeF3K)
end 
local function audioFlightsChanged(value)
  if(task_lib ~=nil)then
  	local func = task_lib[6]  --audioFligtsChanged() 
	func(value,audioBox) -- execute specific audio flights changed handler
  end	
end 
local function targetTimeChanged(value) -- change flight target time for task TF training flights
  cfgTargetTimeF3K=value
  system.pSave("adtargetTime",value)
end
local function frameSwitchChanged(value)
  cfgStartFrameSwitchF3K=value
  system.pSave("frameSwitch",value)
end
local function flightSwitchChanged(value)
  cfgStartFlightSwitchF3K=value
  system.pSave("startFlightSwitch",value)
end
local function flightCountDownSwitchChanged(value)
  cfgFlightCountDownSwitchF3K=value
  system.pSave("flightCountDownSwitch",value)
end
local function stoppFlightSwitchChanged(value)
  cfgStoppFlightSwitchF3K=value
  system.pSave("stoppFlightSwitch",value)
end
local function frameAudioSwitchChanged(value)
  cfgFrameAudioSwitchF3K=value
  system.pSave("frameAudioSwitch",value)
end
local function timerResetSwitchChanged(value)
  cfgTimerResetSwitchF3K=value
  system.pSave("timerResetSwitch",value)
end
local function taskChanged()
  currentTaskF3K=form.getValue(taskBox)
  resetTask_()
  system.pSave("currentTask",currentTaskF3K)
  form.setTitle("Task "..taskCharF3K.."  "..taskList[currentTaskF3K])
  form.reinit(initScreenIDF3K)
end

--------------------------------------------------------------------
-- main store function
--------------------------------------------------------------------
local function storeTask_()
	local fileName = string.format("F3K%02d%02d%02d.txt",tDateF3K.year-2000,tDateF3K.mon,tDateF3K.day)
	local taskChar = nil
	local modelName = system.getProperty("Model") 
	tFileF3K = io.open("Apps\\F3K\\Logs\\"..fileName,"a")
	if(tFileF3K ~= nil) then
		local fTitle = tDateF3K.hour..":"..tDateF3K.min..":"..tDateF3K.sec.."     Task "..taskCharF3K.."  "..taskList[currentTaskF3K]
		io.write(tFileF3K,"--------------------------------------------------------------------\n")
		io.write(tFileF3K,fTitle,"\n")
		io.write(tFileF3K,langF3K.model,"      ",modelName,"\n")
		io.write(tFileF3K,"--------------------------------------------------------------------\n")

		if(task_lib ~= nil) then
			local func = task_lib[3]  --file() 
			func(tFileF3K) -- execute specific file handler of task
		end	

		if((currentTaskF3K ~=3)and(currentTaskF3K <12)) then -- write remaining frame time except task c and tasks TT and FF
			local frameTimeTxt =  string.format( "%02d:%02d", math.modf(frameTimerF3K / 60),frameTimerF3K % 60 )
			io.write(tFileF3K,langF3K.remFrameTime,frameTimeTxt,"\n")
		end	
		io.close(tFileF3K)
	end	
end


-------------------------------------------------------------------- 
-- tool key eventhandler
--------------------------------------------------------------------
local function keyPressedTools(key)
    if(key==KEY_5 or key==KEY_ESC) then
      form.preventDefault()
      form.reinit(taskScreenIDF3K)
    end
end 

-------------------------------------------------------------------- 
-- main key eventhandler
--------------------------------------------------------------------
local function keyPressedTasks(key)
	if(key==KEY_MENU or key==KEY_ESC) then
		form.preventDefault()
	elseif(key==KEY_1)then
	-- open with Key 1 the toolbox of the app
		form.reinit(initScreenIDF3K)
	elseif(key==KEY_2)then
	-- reset all timers and set task to start state
		resetTask()
	elseif(key==KEY_3)then
		storeTask()
	-- write task informations into file
	elseif(key==KEY_UP)then
	-- scroll up flight screen if more than 8 flights in list
		if(flightIndexScrollScreenF3K<flightIndexOffsetScreenF3K)then
			flightIndexScrollScreenF3K = flightIndexScrollScreenF3K+1
		end
	elseif(key==KEY_DOWN)then
	-- scroll down flight screen if more than 8 flights in list
		if(flightIndexScrollScreenF3K>0)then
			flightIndexScrollScreenF3K = flightIndexScrollScreenF3K-1
		end	
	end
end		

--------------------------------------------------------------------
-- main key event handler
--------------------------------------------------------------------
local function keyPressedF3K(key)
	if(currentFormF3K == taskScreenIDF3K) then
		keyPressedTasks(key)
	else
		keyPressedTools(key)
	end
end

-------------------------------------------------------------------- 
-- tool screen
--------------------------------------------------------------------
local function tools_Screen()
	-- fill task select box
    form.addRow(2)
    form.addLabel({label=taskCharF3K.." )",width=40,font=FONT_BOLD})
    taskBox=form.addSelectbox(taskList,currentTaskF3K,true,taskChanged,{width=280})
	-- Assigned frame time only for task A last flight task B next to last flight all other tasks are fix
	if((currentTaskF3K==1)or(currentTaskF3K==2))then 
		local currentFrameTime = cfgFrameTimeF3K[currentTaskF3K]
		form.addRow(2)
		form.addLabel({label=langF3K.frameTime,width=220})
	frameBox = form.addIntbox(currentFrameTime,0,1200,0,0,10,frameTimeChanged)
	end
	if(currentTaskF3K<12)then
		-- Assigned pre frame time except trainins task and free flight task
		form.addRow(2)
		form.addLabel({label=langF3K.preFrameTime,width=220})
		form.addIntbox(cfgPreFrameTimeF3K,5,15,0,0,5,preFrameTimeChanged)
	end
	if(((currentTaskF3K>5) and (currentTaskF3K <11))or (currentTaskF3K == 13))then
		-- number of audio output best flights in order for tasks F,G,H,I,J and ST
	    local currentAudioFlights = cfgAudioFlights[currentTaskF3K - 5]
		if(currentTaskF3K == 13)then
			currentAudioFlights = cfgAudioFlights[6]
		end
		form.addRow(2)
		form.addLabel({label=langF3K.audioFlights,width=220})
	audioBox = form.addIntbox(currentAudioFlights,1,5,0,0,1,audioFlightsChanged)
	end
	if(currentTaskF3K == 14) then -- Assigned flight times for TF (training flight task)
		form.addRow(2)
		form.addLabel({label=langF3K.target,width=220})
		form.addIntbox(cfgTargetTimeF3K,30,200,0,0,10,targetTimeChanged)
	end
	-- Assigned switch start frame time
	form.addRow(2)
	form.addLabel({label=langF3K.frameSwitch,width=220})
	form.addInputbox(cfgStartFrameSwitchF3K,false,frameSwitchChanged)
	-- Assigned switch start flight time
    form.addRow(2)
    form.addLabel({label=langF3K.flightSwitch,width=220})
    form.addInputbox(cfgStartFlightSwitchF3K,false,flightSwitchChanged)
	-- Assigned switch stopp flight time
    form.addRow(2)
    form.addLabel({label=langF3K.flightStoppSwitch,width=220})
    form.addInputbox(cfgStoppFlightSwitchF3K,false,stoppFlightSwitchChanged)
	-- Assigned switch audio frame time
    form.addRow(2)
    form.addLabel({label=langF3K.frameAudioSwitch,width=220})
    form.addInputbox(cfgFrameAudioSwitchF3K,false,frameAudioSwitchChanged)
	-- Assigned switch reset store
    form.addRow(2)
    form.addLabel({label=langF3K.timerResetSwitch,width=220})
    form.addInputbox(cfgTimerResetSwitchF3K,false,timerResetSwitchChanged)
	if(currentTaskF3K==5)then -- poker 
		-- Assigned switch flight count down 
		form.addRow(2)
		form.addLabel({label=langF3K.flightCountDownSwitch,width=220})
		form.addInputbox(cfgFlightCountDownSwitchF3K,false,flightCountDownSwitchChanged)
	end	
end 


-------------------------------------------------------------------- 
-- Mainscreen
--------------------------------------------------------------------
local function commonScreen()
	if(task_lib ~= nil) then
		form.setTitle("Task "..taskCharF3K.."  "..taskList[currentTaskF3K])
		form.setButton(2,":delete",ENABLED)
		form.setButton(3,":file",ENABLED)
		form.setButton(1,":tools",ENABLED)
	end
end

--------------------------------------------------------------------
-- telemetry display function
--------------------------------------------------------------------
local function printTelemetry()
	if(task_lib ~= nil) then
		local func = task_lib[5]  --screen() 
		func() -- execute task specific screen handler
	end	
	local taskTxt ="Task "..taskCharF3K.."  "..taskList[currentTaskF3K]
	lcd.drawText(10,130,taskTxt,FONT_MINI)
	local frameLabel = "Powered by Geierwally - "..F3K_Version.." "
	lcd.drawText(310 - lcd.getTextWidth(FONT_MINI,frameLabel),145,frameLabel,FONT_MINI)
	local memTxt = "max: "..mem.."K act: "..debugmem.."K"
	lcd.drawText(10,145,memTxt,FONT_MINI)
end

--------------------------------------------------------------------
local function printForm()
	if(currentFormF3K == taskScreenIDF3K) then
		if(task_lib ~= nil) then
			local func = task_lib[5]  --screen() 
			func() -- execute task specific screen handler
		end	
		local frameLabel = "Powered by Geierwally - "..F3K_Version.." "
		lcd.drawText(310 - lcd.getTextWidth(FONT_MINI,frameLabel),130,frameLabel,FONT_MINI)
		local memTxt = "max: "..mem.."K act: "..debugmem.."K"
		lcd.drawText(10,130,memTxt,FONT_MINI)
	end	
end

--------------------------------------------------------------------
-- main display function
--------------------------------------------------------------------
local function initF3K(formID)
    currentFormF3K=formID
	if(currentFormF3K == initScreenIDF3K) then
		tools_Screen()
	else
		commonScreen()
	end
end

--------------------------------------------------------------------
-- main Loop function
--------------------------------------------------------------------
local function loop()
	-- register the main window of F3K App
 	if(task_lib ~= nil)then
		system.registerTelemetry(2,"F3K Training",4,printTelemetry)
		system.registerForm(1,MENU_MAIN,"F3K Training",initF3K,keyPressedF3K,printForm);
		local func = task_lib[4] --task()
		func() -- execute specific task handler
	else	
		system.unregisterForm(1);
	end	
end
 
--------------------------------------------------------------------
local F3K_Main = {resetTask_,init,storeTask_,loop}
return F3K_Main