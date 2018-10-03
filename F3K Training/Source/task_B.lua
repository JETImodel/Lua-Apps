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
-- # V1.0.1 - Initial release of all specific functions of Task B 'next to last flight'
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
local alert = false -- F3K alert active

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

--------------------------------------------------------------------
-- init function task B next to last flight
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
	alert = false -- F3K alert active
	
	if(cfgFrameTimeF3K[currentTaskF3K] == 600)then
		flightTimesTxtF3K = "240s"
		flightTimesF3K=240
	else
		flightTimesTxtF3K = "180s"
		flightTimesF3K=180
	end
	flightIndexF3K=0
	goodFlightsF3K = {{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}} --list of all done flights [flightTime][sum time]
end

local function frameTimeChanged(value,formIndex)
	if (value > 600) then
		value = 600
		flightTimesF3K=240
		flightTimesTxtF3K = nil
		flightTimesTxtF3K = "240s"
	elseif (value < 420) then
		value = 420
		flightTimesF3K=180
		flightTimesTxtF3K = nil
		flightTimesTxtF3K = "180s"
	elseif (value == 430) then
		value = 600
		flightTimesF3K=240
		flightTimesTxtF3K = nil
		flightTimesTxtF3K = "240s"
	elseif (value == 590) then
		value = 420
		flightTimesF3K=180
		flightTimesTxtF3K = nil
		flightTimesTxtF3K = "180s"
	else
		value = 600
		flightTimesF3K=240
		flightTimesTxtF3K = nil
		flightTimesTxtF3K = "240s"
	end	
	frameTimerF3K = value
	cfgFrameTimeF3K[currentTaskF3K]=value
	form.setValue(formIndex,value)	
	system.pSave("frameTime",cfgFrameTimeF3K)
end

--------------------------------------------------------------------
-- file handler task B next to last flight
--------------------------------------------------------------------
local function file(tFileF3K)
	local flightTimeMs = 0
	local flightTimeTxt = nil  
	local sumTimeTxt = nil
	local flightTxt = nil 
    
	io.write(tFileF3K,langF3K.flight,langF3K.time,langF3K.sumTime,"\n")
	if(flightIndexF3K >0) then
		for i=1 , flightIndexF3K do
			sumTimeTxt =  nil
			flightTimeTxt = nil  
			flightTxt = nil 
			flightTimeMs = ((goodFlightsF3K[i][1] -  math.modf(goodFlightsF3K[i][1]))*100) 
			sumTimeTxt =  string.format( "%02d:%02d", math.modf(goodFlightsF3K[i][2]/ 60),goodFlightsF3K[i][2] % 60)
			flightTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(goodFlightsF3K[i][1] / 60),goodFlightsF3K[i][1] % 60,flightTimeMs ) 
			flightTxt="                  "..i.."      "..flightTimeTxt.."      "..sumTimeTxt.."\n"  --write flight information for logfile
			io.write(tFileF3K,flightTxt)
		end
	end	

end
--------------------------------------------------------------------
-- eventhandler task B next to last flight
--------------------------------------------------------------------
local function task_B_Start() -- wait for start switch start 5s count down and start frame time
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
local function task_B_flights() -- wait for start flight switch count preflight time start, end, start next flight
	local diffTime =(currentTimeF3K - startFrameTimeF3K)/1000
	local prevFlightTime = 0
	
	if(flightIndexF3K >0) then
		prevFlightTime = goodFlightsF3K[flightIndexF3K][1]
	end
	frameTimerF3K = cfgFrameTimeF3K[currentTaskF3K]+1 - diffTime
	if(onFlightF3K == true)then -- flight active
		if(prevFlightTime > flightTimesF3K) then
			sumTimerF3K = flightTimesF3K
		else
			sumTimerF3K = prevFlightTime
		end	
		flightTimeF3K =(currentTimeF3K - startFlightTimeF3K)/1000
		remainingFlightTimeF3K = flightTimesF3K-flightTimeF3K + 1
		if(remainingFlightTimeF3K > frameTimerF3K)then
			remainingFlightTimeF3K = frameTimerF3K
		end
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
			elseif((soundTimeF3K%30)==0)then	
				system.playNumber(math.modf(soundTimeF3K/60),0,"min")
				system.playNumber(soundTimeF3K%60,0,"s")
				prevSoundTimeF3K = soundTimeF3K
			elseif(soundTimeF3K == flightTimesF3K) then
				system.playNumber(remainingFlightTimeMinF3K,0,"min")
				system.playNumber(remainingFlightTimeSecF3K,0,"s")
				prevSoundTimeF3K = soundTimeF3K
			end
		end
		if((1==system.getInputsVal(cfgStoppFlightSwitchF3K))or(frameTimerF3K==0)or(flightTimeF3K >= flightTimesF3K)) then  -- stopp flight was switched or end of frame time reached
			if(flightTimeF3K >= flightTimesF3K) then -- flight time was reached finish task
				sumTimerF3K=flightTimesF3K + prevFlightTime
				if(sumTimerF3K >= (2*flightTimesF3K)) then
					sumTimerF3K = 2*flightTimesF3K
					system.playFile("F3K_Tend.wav",AUDIO_QUEUE)
					taskStateF3K = 3
				end	
			else
				-- store flight times
				sumTimerF3K=flightTimeF3K + prevFlightTime
			end	
			if(flightIndexF3K <10) then
				flightIndexF3K = flightIndexF3K+1
			end	
			goodFlightsF3K[flightIndexF3K][1]=flightTimeF3K
			goodFlightsF3K[flightIndexF3K][2]=sumTimerF3K
			if(frameTimerF3K==0)then -- frametimer expired, finish task
				system.playFile("F3K_Tend.wav",AUDIO_QUEUE)
				taskStateF3K = 3
			end
			flightTimeF3K = 0 --reset flight time
			remainingFlightTimeF3K = 0
			remainingFlightTimeMinF3K = 0
			remainingFlightTimeSecF3K = 0
			soundTimeF3K = 0
			prevSoundTimeF3K = 1
			onFlightF3K = false
			preSwitchNextFlightF3K = false
		end
	else  -- break active
		if(frameTimerF3K == 0)then -- end of frame time reached
			taskStateF3K = 3
			system.playFile("F3K_Tend.wav",AUDIO_QUEUE)
		else
			if(frameTimerF3K > flightTimesF3K)then
				soundTimeF3K = math.modf(frameTimerF3K - flightTimesF3K) -- count down of remaining frame time for right start of next flight
				audioCountDownF3K()
			end	
			
			if((frameTimerF3K < prevFlightTime)and(frameTimerF3K < flightTimesF3K)and (alert == false))then
				system.playFile("F3K_Alert.wav",AUDIO_QUEUE)  -- remaining frame time not enough to improve next flight
				system.playFile("F3K_NoImpr.wav",AUDIO_QUEUE)
				alert = true
			end
			
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
			if(1==system.getInputsVal(cfgTimerResetSwitchF3K)) then -- combined functionality stopp and reset switch stopps task here
				preSwitchTaskResetF3K = true
				taskStateF3K = 3
				system.playFile("F3K_Mend.wav",AUDIO_QUEUE)
				alert = false
			end
		end
	end
end
--------------------------------------------------------------------
local function task_B_End()     -- safe training?
	prevFrameAudioSwitchF3K = 1 -- lock audio output remaining frame time
	if(1==system.getInputsVal(cfgTimerResetSwitchF3K)) then
		if(preSwitchTaskResetF3K == false)then
			storeTask()
			resetTask()
		end
	else
		preSwitchTaskResetF3K = false
	end
end
--------------------------------------------------------------------
local task_B_States = {task_B_Start,task_B_flights,task_B_End}
--------------------------------------------------------------------
local function task()
	local taskHandler = task_B_States[taskStateF3K] -- set statemachine depending on last current state
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
-- display task B next to last flight
--------------------------------------------------------------------
local function screen()
	local flightTimeMs = 0
	local flightTimeTxt =  nil
	local flightScreenTxt = nil
	local timeTxt = string.format( "%02d:%02d", math.modf(frameTimerF3K / 60),frameTimerF3K % 60 )
	local remainingFlightTimeTxt = nil
	local targetTimeTxt = string.format( "%02d:%02d", math.modf(sumTimerF3K / 60),sumTimerF3K % 60 )
	remainingFlightTimeTxt = string.format( "%02d:%02d",remainingFlightTimeMinF3K ,remainingFlightTimeSecF3K )
	lcd.drawText(10,15,langF3K.Screen_frame,FONT_NORMAL)
	lcd.drawText(40,5,timeTxt,FONT_MAXI)
	lcd.drawText(10,50,langF3K.Screen_flight,FONT_NORMAL)
	lcd.drawText(40,40,remainingFlightTimeTxt,FONT_MAXI)
	lcd.drawText(10,85,langF3K.Screen_Sum,FONT_NORMAL)
	lcd.drawText(40,75,targetTimeTxt,FONT_MAXI)

	if(onFlightF3K == true)then -- flight active
		if(flightIndexF3K > 0)then -- previous flight
			flightTimeMs = ((goodFlightsF3K[flightIndexF3K][1] -  math.modf(goodFlightsF3K[flightIndexF3K][1] ))*100) 
			flightTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(goodFlightsF3K[flightIndexF3K][1]  / 60),goodFlightsF3K[flightIndexF3K][1]  % 60,flightTimeMs )
			lcd.drawText(170,5,flightTimeTxt,FONT_MAXI)
		end
		flightTimeMs = ((flightTimeF3K -  math.modf(flightTimeF3K))*100) 
		flightTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(flightTimeF3K / 60),flightTimeF3K % 60,flightTimeMs ) 
		lcd.drawText(170,40,flightTimeTxt,FONT_MAXI)
	else
		if(flightIndexF3K > 1)then --previous flight
			flightTimeMs = ((goodFlightsF3K[flightIndexF3K-1][1] -  math.modf(goodFlightsF3K[flightIndexF3K-1][1] ))*100) 
			flightTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(goodFlightsF3K[flightIndexF3K-1][1]  / 60),goodFlightsF3K[flightIndexF3K-1][1]  % 60,flightTimeMs )
			lcd.drawText(170,5,flightTimeTxt,FONT_MAXI)
		end
		if(flightIndexF3K > 0)then --previous flight
			flightTimeMs = ((goodFlightsF3K[flightIndexF3K][1] -  math.modf(goodFlightsF3K[flightIndexF3K][1] ))*100) 
			flightTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(goodFlightsF3K[flightIndexF3K][1]  / 60),goodFlightsF3K[flightIndexF3K][1]  % 60,flightTimeMs )
			lcd.drawText(170,40,flightTimeTxt,FONT_MAXI)
		end	
	end
	--target flight time
	lcd.drawText(140,85,langF3K.Screen_Target,FONT_NORMAL)
	flightTimeTxt =  string.format( "%02d:%02d", math.modf(flightTimesF3K  / 60),flightTimesF3K  % 60)
	lcd.drawText(170,75,flightTimeTxt,FONT_MAXI)
	
	lcd.drawLine(1,125,310,125)
	lcd.drawLine(130,0,130,125)
end
local task_B = {taskInit,frameTimeChanged,file,task,screen}
return task_B