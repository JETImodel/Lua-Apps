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
-- # V1.0.1 - Initial release of all specific functions of Task K 'big ladder'
-- #############################################################################

local prevFrameAudioSwitchF3K = 0 --audio switch logic for output ramaining frame time
local taskStateF3K = 1 -- contains the current state of task state machine
local sumTimerF3K = 0 -- summary of valid flights
local flightIndexF3K = 1 -- current flight number of the task
local startFrameTimeF3K = 0 -- start time stamp frame time
local startFlightTimeF3K = 0 -- start time stamp flight time
local startBreakTimeF3K = 0 -- start time stamp break time
local taskStartSwitchedF3K = false -- logic for task start switched
local onFlightF3K = false	-- true if flight is active
local flightFinishedF3K = true -- logic to avoid negative count of remaining flight time
local remainingFlightTimeF3K = 0 -- contains remaining flight time in ms
local remainingFlightTimeMinF3K = 0 -- contains remaining flight time min
local remainingFlightTimeSecF3K = 0 -- contains remaining flight time sec
local flightTimesTxtF3K = nil -- contains all flight times for the task (times to fly)
local flightTimesF3K = nil -- contains all flight times of the task in ms for comparison(times to fly)
local preSwitchNextFlightF3K = false  -- logic for start next flight (stopp switch musst be pressed and released)
local failedFlightIndexF3K = 1 -- current index of failed flight list
local flightTimeF3K = 0
local breakTimeF3K = 0
local failedFlightsF3K = nil --list of failed flights
local goodFlightsF3K = nil --list of all good flights
local preSwitchTaskResetF3K = false --logic for reset task switch (for tasks with combined stopp and reset functionality e.g. task A and B)
local flightCountDownF3K = false -- flight count down for poker task was switched

--------------------------------------------------------------------
-- init function task K
--------------------------------------------------------------------
local function taskInit()
	taskStateF3K = 1
	prevFrameAudioSwitchF3K = 0 --audio switch logic for output ramaining frame time
	sumTimerF3K = 0 -- summary of valid flights
	flightIndexF3K = 1 -- current flight number of the task
	startFrameTimeF3K = 0 -- start time stamp frame time
	startFlightTimeF3K = 0 -- start time stamp flight time
	startBreakTimeF3K = 0 -- start time stamp break time
	taskStartSwitchedF3K = false -- logic for task start switched
	onFlightF3K = false	-- true if flight is active
	flightFinishedF3K = true -- logic to avoid negative count of remaining flight time
	remainingFlightTimeF3K = 0 -- contains remaining flight time in ms
	remainingFlightTimeMinF3K = 0 -- contains remaining flight time min
	remainingFlightTimeSecF3K = 0 -- contains remaining flight time sec
	flightTimesTxtF3K = nil -- contains all flight times for the task (times to fly)
	flightTimesF3K = nil -- contains all flight times of the task in ms for comparison(times to fly)
	preSwitchNextFlightF3K = false  -- logic for start next flight (stopp switch musst be pressed and released)
	failedFlightIndexF3K = 0 -- current index of failed flight list
	flightTimeF3K = 0
	breakTimeF3K = 0
	failedFlightsF3K = nil --list of failed flights
	goodFlightsF3K = nil --list of all good flights
	preSwitchTaskResetF3K = false --logic for reset task switch (for tasks with combined stopp and reset functionality e.g. task A and B)
	flightCountDownF3K = false -- flight count down for poker task was switched
	flightTimesTxtF3K = {"  60s","  90s","120s","150s","180s"}
	flightTimesF3K={60,90,120,150,180}
	goodFlightsF3K = {{0,0},{0,0},{0,0},{0,0},{0,0}} --list of all good flights
end

--------------------------------------------------------------------
-- audio function for count down
--------------------------------------------------------------------
local function audioCountDownF3K()
	if((soundTimeF3K >=0)and(soundTimeF3K ~= prevSoundTimeF3K))then
		if((soundTimeF3K==45)or(soundTimeF3K==30)or(soundTimeF3K==25)or(soundTimeF3K<=20))then
			if(soundTimeF3K > 0)then
				if (system.isPlayback () == false) then
					system.playNumber(soundTimeF3K,0) --audio remaining flight time
					prevSoundTimeF3K = soundTimeF3K
				end			
			else
				system.playBeep(1,4000,500) -- flight finished play beep
				prevSoundTimeF3K = soundTimeF3K
			end
			--print(soundTime)
		end
	end	
end

local function frameTimeChanged(value,formIndex)
--dummy
end

--------------------------------------------------------------------
-- file handler task K  big ladder
--------------------------------------------------------------------
local function file(tFileF3K)
	local breakTimeMs = 0
	local flightTimeMs = 0
	local breakTimeTxt =  nil
	local flightTimeTxt = nil  
	local flightTxt = nil 
    local failedFlightTxt = nil
	local targetTimeTxt = nil
	
	if(goodFlightsF3K[1][2] >0) then
		io.write(tFileF3K,langF3K.flight,langF3K.target,langF3K.time,langF3K.breakTime,"\n")
		for i=1 , flightIndexF3K do
			breakTimeTxt =  nil
			flightTimeTxt = nil  
			flightTxt = nil 
			failedFlightTxt = nil
			targetTimeTxt = nil
			if((goodFlightsF3K[i][2]>0)or(goodFlightsF3K[i][1]>0))then -- write only done flights
				breakTimeMs = ((goodFlightsF3K[i][2] -  math.modf(goodFlightsF3K[i][2]))*100) 
				flightTimeMs = ((goodFlightsF3K[i][1] -  math.modf(goodFlightsF3K[i][1]))*100) 
				breakTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(goodFlightsF3K[i][2]/ 60),goodFlightsF3K[i][2] % 60,breakTimeMs )
				flightTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(goodFlightsF3K[i][1] / 60),goodFlightsF3K[i][1] % 60,flightTimeMs ) 
				targetTimeTxt = string.format( "%02d:%02d", math.modf(flightTimesF3K[i] / 60),flightTimesF3K[i] % 60)
				flightTxt="                  "..i.."      "..targetTimeTxt.."         "..flightTimeTxt.."      "..breakTimeTxt.."\n" --write goog flight information for logfile
				io.write(tFileF3K,flightTxt)
			end
		end
	end	
	local sumTimeTxt =  string.format( "%02d:%02d", math.modf(sumTimerF3K / 60),sumTimerF3K % 60 )
	io.write(tFileF3K,langF3K.sumTime,sumTimeTxt,"\n")
end
--------------------------------------------------------------------
-- eventhandler task K big ladder
--------------------------------------------------------------------
local function task_K_Start() -- wait for start switch start 5s count down and start frame time
	 prevFrameAudioSwitchF3K = 1 -- lock audio output remaining frame time
	 if(taskStartSwitchedF3K == false)then
		if((1==system.getInputsVal(cfgStartFrameSwitchF3K))and currentFormF3K ~= initScreenIDF3K )then
			taskStartSwitchedF3K = true
			startFrameTimeF3K = currentTimeF3K
			frameTimerF3K = cfgPreFrameTimeF3K --preset with 15 seconds
		end
	 else
		local diffTime =(currentTimeF3K - startFrameTimeF3K)/1000 
		frameTimerF3K = cfgPreFrameTimeF3K + 1 - diffTime
		soundTimeF3K = math.modf(frameTimerF3K)
		audioCountDownF3K()
		if((frameTimerF3K == 0)or(cfgPreFrameTimeF3K==0))then
			frameTimerF3K = cfgFrameTimeF3K[currentTaskF3K]
			startFrameTimeF3K = currentTimeF3K
			startFlightTimeF3K = 0
			startBreakTimeF3K = currentTimeF3K
			taskStateF3K = 2
			preSwitchNextFlightF3K = false
		end
	 end
end
--------------------------------------------------------------------
local function task_K_flights() -- wait for start flight switch count preflight time start, end, start next flight
	local diffTime =(currentTimeF3K - startFrameTimeF3K)/1000

	frameTimerF3K = cfgFrameTimeF3K[currentTaskF3K]+1 - diffTime
	if(onFlightF3K == true)then -- flight active
		flightTimeF3K =(currentTimeF3K - startFlightTimeF3K)/1000
		remainingFlightTimeF3K = flightTimesF3K[flightIndexF3K]-flightTimeF3K + 1
	    remainingFlightTimeMinF3K = math.modf( remainingFlightTimeF3K/ 60)
        remainingFlightTimeSecF3K = remainingFlightTimeF3K % 60
		if((flightFinishedF3K == true) or ((remainingFlightTimeMinF3K == 0)and(remainingFlightTimeSecF3K == 0))) then -- avoid negative count of remaining flight time
			flightFinishedF3K = true
			remainingFlightTimeMinF3K = 0
			remainingFlightTimeSecF3K = 0
		end
		soundTimeF3K = math.modf(remainingFlightTimeF3K)
		audioCountDownF3K()
		if((soundTimeF3K >=0)and(soundTimeF3K ~= prevSoundTimeF3K))then
			if((soundTimeF3K%60)==0)then
				system.playNumber(soundTimeF3K/60,0,"min")
				prevSoundTimeF3K = soundTimeF3K
			elseif(soundTimeF3K == flightTimesF3K[flightIndexF3K]) then
				system.playNumber(remainingFlightTimeMinF3K,0,"min")
				system.playNumber(remainingFlightTimeSecF3K,0,"s")
				prevSoundTimeF3K = soundTimeF3K
			end
		end
		if((1==system.getInputsVal(cfgStoppFlightSwitchF3K))or(frameTimerF3K==0)) then  -- stopp flight was switched or end of frame time reached
			if(flightTimeF3K >= flightTimesF3K[flightIndexF3K]) then --
				sumTimerF3K = sumTimerF3K + flightTimesF3K[flightIndexF3K] -- increment sum timer
			else 
				sumTimerF3K = sumTimerF3K + math.modf(flightTimeF3K)
			end
			goodFlightsF3K[flightIndexF3K][1]=flightTimeF3K
			goodFlightsF3K[flightIndexF3K][2]=breakTimeF3K
			if(flightIndexF3K == 5) then -- this was the last flight
				system.playFile("F3K_Tend.wav",AUDIO_QUEUE)
				taskStateF3K = 3
			else
				flightIndexF3K = flightIndexF3K + 1 -- preset next flight
				flightTimeF3K = 0
				breakTimeF3K = 0
				if(frameTimerF3K==0)then
					-- frametimer expired and flight valid , finish task
					system.playFile("F3K_Tend.wav",AUDIO_QUEUE)
					taskStateF3K = 3
				end
			end
			startBreakTimeF3K = currentTimeF3K -- preset times for next flight
			onFlightF3K = false
			preSwitchNextFlightF3K = false
			remainingFlightTimeF3K = 0
			remainingFlightTimeMinF3K = 0
			remainingFlightTimeSecF3K = 0
		end
	else  -- break active
		if(frameTimerF3K == 0)then -- end of frame time reached
			taskStateF3K = 3
			system.playFile("F3K_Tend.wav",AUDIO_QUEUE)
		else
			breakTimeF3K = (currentTimeF3K - startBreakTimeF3K)/1000
			
			local openFlightTimes = 0
			for i=flightIndexF3K, #flightTimesF3K do
				openFlightTimes = openFlightTimes + flightTimesF3K[i]
			end
			soundTimeF3K = math.modf(frameTimerF3K - openFlightTimes) -- count down of remaining frame time for right start of next flight
			audioCountDownF3K()
			
			if(preSwitchNextFlightF3K == false) then -- stopp switch must be active before start of new flight ... wait for release stopp switch
				if(1==system.getInputsVal(cfgStoppFlightSwitchF3K)) then
					preSwitchNextFlightF3K = true
				end
			else
				if(1==system.getInputsVal(cfgStartFlightSwitchF3K)) then
					onFlightF3K = true
					flightFinishedF3K = false
					startFlightTimeF3K = currentTimeF3K
					soundTimeF3K = 0
					prevSoundTimeF3K = 1
				end	
			end
		end
	end
end
--------------------------------------------------------------------
local function task_K_End()     -- safe training?
	prevFrameAudioSwitchF3K = 1 -- lock audio output remaining frame time
	if(1==system.getInputsVal(cfgTimerResetSwitchF3K)) then
		storeTask()
		resetTask()
	end
end
--------------------------------------------------------------------
local task_K_States = {task_K_Start,task_K_flights,task_K_End}
--------------------------------------------------------------------
local function task()
	local taskHandler = task_K_States[taskStateF3K] -- set statemachine depending on last current state
	taskHandler()
	if(1==system.getInputsVal(cfgFrameAudioSwitchF3K)) then
		if(prevFrameAudioSwitchF3K ==0)then
			prevFrameAudioSwitchF3K = 1  -- play audio file for remaining frame time
			system.playNumber(math.modf(frameTimerF3K / 60),0,"min")
			system.playNumber(frameTimerF3K % 60,0,"s")
			system.playFile("F3K_Frame.wav",AUDIO_QUEUE)
		end	
	else
		prevFrameAudioSwitchF3K = 0
	end
end
--------------------------------------------------------------------
-- display task K
--------------------------------------------------------------------
local function screen()
	local breakTimeMs = 0
	local flightTimeMs = 0
	local breakTimeTxt =  nil
	local flightTimeTxt =  nil
	local flightScreenTxt = nil
	local timeTxt = string.format( "%02d:%02d", math.modf(frameTimerF3K / 60),frameTimerF3K % 60 )
	local remainingFlightTimeTxt = nil
	local sumTimeTxt = string.format( "%02d:%02d", math.modf(sumTimerF3K / 60),sumTimerF3K % 60 )
	remainingFlightTimeTxt = string.format( "%02d:%02d",remainingFlightTimeMinF3K ,remainingFlightTimeSecF3K )
	lcd.drawText(10,15,langF3K.Screen_frame,FONT_NORMAL)
	lcd.drawText(40,5,timeTxt,FONT_MAXI)
	lcd.drawText(10,50,langF3K.Screen_flight,FONT_NORMAL)
	lcd.drawText(40,40,remainingFlightTimeTxt,FONT_MAXI)
	lcd.drawText(10,85,langF3K.Screen_Sum,FONT_NORMAL)
	lcd.drawText(40,75,sumTimeTxt,FONT_MAXI)
	
	if(goodFlightsF3K[5][1] >0) then	 -- all flights valid , draw all flights invers
		lcd.drawFilledRectangle(135,15,180,(5*15) +2)
	elseif(flightIndexF3K > 1)then
		lcd.drawFilledRectangle(135,15,180,((flightIndexF3K-1)*15) +2)
	end	
	for i=1 , 5 do
		breakTimeTxt =  nil
		flightTimeTxt =  nil
		flightScreenTxt = nil
		if(i < flightIndexF3K) then -- write stored text for previous finished flights or if last flight valid until last flight
			breakTimeMs = ((goodFlightsF3K[i][2] -  math.modf(goodFlightsF3K[i][2]))*100) 
			flightTimeMs = ((goodFlightsF3K[i][1] -  math.modf(goodFlightsF3K[i][1]))*100)
			breakTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(goodFlightsF3K[i][2]/ 60),goodFlightsF3K[i][2] % 60,breakTimeMs )
			flightTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(goodFlightsF3K[i][1] / 60),goodFlightsF3K[i][1] % 60,flightTimeMs ) 
			flightScreenTxt = string.format("%s  %s  %s",flightTimesTxtF3K[i],breakTimeTxt,flightTimeTxt)

			if(colorScreenF3K== true) then
				lcd.setColor(255,255,255)
				lcd.drawText(135,i*15,flightScreenTxt,FONT_NORMAL)
			else
				lcd.drawText(135,i*15,flightScreenTxt,FONT_REVERSED)
			end
		elseif(i == flightIndexF3K) then -- write current flight
			flightTimeMs = ((flightTimeF3K -  math.modf(flightTimeF3K))*100) 
			breakTimeMs = ((breakTimeF3K -  math.modf(breakTimeF3K))*100) 
			flightTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(flightTimeF3K / 60),flightTimeF3K % 60,flightTimeMs ) 
			breakTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(breakTimeF3K / 60),breakTimeF3K % 60,breakTimeMs )
			flightScreenTxt=string.format("%s  %s  %s",flightTimesTxtF3K[flightIndexF3K],breakTimeTxt,flightTimeTxt)
			if(goodFlightsF3K[5][1] >0) then --write last current flight
				if(colorScreenF3K== true) then
					lcd.setColor(255,255,255)
					lcd.drawText(135,i*15,flightScreenTxt,FONT_NORMAL)
					lcd.setColor(0,0,0)
				else
					lcd.drawText(135,i*15,flightScreenTxt,FONT_REVERSED)
				end			
			else
				lcd.setColor(0,0,0)
				lcd.drawText(135,i*15,flightScreenTxt,FONT_NORMAL)
			end
		else -- write not extcuted flights
			lcd.drawText(135,i*15,flightTimesTxtF3K[i],FONT_NORMAL)
		end
	end

	lcd.drawLine(1,125,310,125)
	lcd.drawLine(130,0,130,125)
end


local task_K = {taskInit,frameTimeChanged,file,task,screen}
return task_K