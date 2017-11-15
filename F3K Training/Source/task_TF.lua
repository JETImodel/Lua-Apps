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
-- # V1.0.2 - Initial release of all specific functions of Task TF 'Training Flights'
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
local flightFinishedF3K = true -- logic to avoid negative count of remaining flight time
local sumAudioOutput = 0 -- helper for audio output flight times


--------------------------------------------------------------------
-- init function task TF Training Flights
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
	flightTimesF3K = cfgTargetTimeF3K -- contains all flight times of the task in ms for comparison(times to fly)
	preSwitchNextFlightF3K = false  -- logic for start next flight (stopp switch musst be pressed and released)
	failedFlightIndexF3K = 0 -- current index of failed flight list
	flightTimeF3K = 0
	breakTimeF3K = 0
	failedFlightsF3K = nil --list of failed flights
	goodFlightsF3K = nil --list of all good flights
	preSwitchTaskResetF3K = false --logic for reset task switch (for tasks with combined stopp and reset functionality e.g. task A and B)
	flightCountDownF3K = false -- flight count down for poker task was switched
    flightIndexOffsetScreenF3K = 0 -- for display if more than 8 flights in list
    flightIndexScrollScreenF3K = 0 -- for scrolling up and down if more than 8 flights in list
    goodFlightsF3K = {{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0},{0,0,0}} -- flight time , break time, sum time
	flightFinishedF3K = true -- logic to avoid negative count of remaining flight time
	sumAudioOutput = 0 -- helper for audio output flight times
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
-- file handler task  TF Training Flights
--------------------------------------------------------------------
local function file(tFileF3K)
	local breakTimeMs = 0
	local flightTimeMs = 0
	local breakTimeTxt =  nil
	local flightTimeTxt = nil  
	local flightTxt = nil 
	local sumTimeTxt = nil
	local flightNumberTxt = nil
	if(goodFlightsF3K[1][2] >0) then
		io.write(tFileF3K,langF3K.flight,langF3K.time,langF3K.breakTime,"  ",langF3K.sumTime,"\n")
		for i=1 , flightIndexF3K do
		    flightNumberTxt = nil
			breakTimeTxt =  nil
			flightTimeTxt = nil  
			flightTxt = nil 
			sumTimeTxt = nil
			flightNumberTxt = string.format( "%02d",i)

			if((goodFlightsF3K[i][2]>0)or(goodFlightsF3K[i][1]>0))then -- write only done flights
				breakTimeMs = ((goodFlightsF3K[i][2] -  math.modf(goodFlightsF3K[i][2]))*100) 
				flightTimeMs = ((goodFlightsF3K[i][1] -  math.modf(goodFlightsF3K[i][1]))*100) 
				breakTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(goodFlightsF3K[i][2]/ 60),goodFlightsF3K[i][2] % 60,breakTimeMs )
				flightTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(goodFlightsF3K[i][1] / 60),goodFlightsF3K[i][1] % 60,flightTimeMs ) 
				sumTimeTxt =  string.format( "%02d:%02d", math.modf(goodFlightsF3K[i][3] / 60),goodFlightsF3K[i][3] % 60) 
				flightTxt="                 "..flightNumberTxt.."      "..flightTimeTxt.."      "..breakTimeTxt.."      "..sumTimeTxt.."\n" --write goog flight information for logfile
				io.write(tFileF3K,flightTxt)
			end
		end
	end
	sumTimeTxt = nil
	sumTimeTxt =  string.format( "%02d:%02d", math.modf(sumTimerF3K / 60),sumTimerF3K % 60 )
	io.write(tFileF3K,langF3K.sumTime,sumTimeTxt,"\n")
end
--------------------------------------------------------------------
-- eventhandler task  TF Training Flights
--------------------------------------------------------------------
local function task_TF_Start() -- wait for start switch start 5s count down and start frame time
	prevFrameAudioSwitchF3K = 1 -- lock audio output remaining frame time
	if(taskStartSwitchedF3K == false)then
		if((1==system.getInputsVal(cfgStartFrameSwitchF3K))and currentFormF3K ~= initScreenIDF3K )then
			taskStartSwitchedF3K = true
			startFrameTimeF3K = currentTimeF3K
			frameTimerF3K = 5 --preset with 5 seconds
		end
	else
		local diffTime =(currentTimeF3K - startFrameTimeF3K)/1000 
		frameTimerF3K = 5 + 1 - diffTime
		soundTimeF3K = math.modf(frameTimerF3K)
		audioCountDownF3K()
		if(frameTimerF3K == 0)then
			startFlightTimeF3K = currentTimeF3K
			startBreakTimeF3K = currentTimeF3K
			taskStateF3K = 2
			preSwitchNextFlightF3K = false
		end
	end	
end
--------------------------------------------------------------------
local function task_TF_flights() -- wait for start flight switch count preflight time start, end, start next flight
	if(onFlightF3K == true)then -- flight active
		flightTimeF3K =(currentTimeF3K - startFlightTimeF3K)/1000
		remainingFlightTimeF3K = cfgTargetTimeF3K-flightTimeF3K + 1
	    remainingFlightTimeMinF3K = math.modf( remainingFlightTimeF3K/ 60)
        remainingFlightTimeSecF3K = remainingFlightTimeF3K % 60
		if((flightFinishedF3K == true) or ((remainingFlightTimeMinF3K == 0)and(remainingFlightTimeSecF3K == 0))) then -- avoid negative count of remaining flight time
			flightFinishedF3K = true
			remainingFlightTimeMinF3K = 0
			remainingFlightTimeSecF3K = 0
		end
		if(sumAudioOutput == 0)then
			soundTimeF3K = math.modf(remainingFlightTimeF3K)
			audioCountDownF3K()
		end	
		if((soundTimeF3K >=0)and(soundTimeF3K ~= prevSoundTimeF3K))then
			if((soundTimeF3K%60)==0)then
				system.playNumber(soundTimeF3K/60,0,"min")
				prevSoundTimeF3K = soundTimeF3K
			elseif(soundTimeF3K == cfgTargetTimeF3K) then
				system.playNumber(remainingFlightTimeMinF3K,0,"min")
				system.playNumber(remainingFlightTimeSecF3K,0,"s")
				prevSoundTimeF3K = soundTimeF3K
			end
		end
		if(1==system.getInputsVal(cfgStoppFlightSwitchF3K))then -- stopp flight was switched
			goodFlightsF3K[flightIndexF3K][1]=flightTimeF3K
			goodFlightsF3K[flightIndexF3K][2]=breakTimeF3K 
			if(flightTimeF3K >= cfgTargetTimeF3K) then --
				sumTimerF3K = sumTimerF3K + cfgTargetTimeF3K -- increment sum timer
			else 
				sumTimerF3K = sumTimerF3K + math.modf(flightTimeF3K)
			end			
			goodFlightsF3K[flightIndexF3K][3]=cfgTargetTimeF3K
			if(flightIndexF3K == 20) then -- end of flight list reached finish task
				system.playFile("F3K_Tend.wav",AUDIO_QUEUE)
				taskStateF3K = 3
			else
				flightIndexF3K = flightIndexF3K + 1 -- preset next flight
				flightTimeF3K = 0
				breakTimeF3K = 0
				startBreakTimeF3K = currentTimeF3K -- preset break time for next flight
			end
			remainingFlightTimeF3K = 0
			remainingFlightTimeMinF3K = 0
			remainingFlightTimeSecF3K = 0
			soundTimeF3K = 0
			prevSoundTimeF3K = 1
			onFlightF3K = false
			preSwitchNextFlightF3K = false
		end
	else  -- break active
		breakTimeF3K = (currentTimeF3K - startBreakTimeF3K)/1000

		if(1==system.getInputsVal(cfgTimerResetSwitchF3K)) then -- combined functionality stopp and reset switch stopps task here
			preSwitchTaskResetF3K = true
			taskStateF3K = 3 --task_E_End
			system.playFile("F3K_Mend.wav",AUDIO_QUEUE)
		end
			
		if(preSwitchNextFlightF3K == false) then -- stopp switch must be active before start of new flight ... wait for release stopp switch
			if(1==system.getInputsVal(cfgStoppFlightSwitchF3K)) then
				preSwitchNextFlightF3K = true
			end
		else
			if(1==system.getInputsVal(cfgStartFlightSwitchF3K)) then
				onFlightF3K = true
				flightCountDownF3K = false
				flightFinishedF3K = false
				startFlightTimeF3K = currentTimeF3K
				soundTimeF3K = 0
				prevSoundTimeF3K = 1
				flightFinishedF3K = false
			end	
		end
	end

end
--------------------------------------------------------------------
local function task_TF_End()     -- safe training?
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
local task_TF_States = {task_TF_Start,task_TF_flights,task_TF_End}
--------------------------------------------------------------------
local function task()
	local taskHandler = task_TF_States[taskStateF3K] -- set statemachine depending on last current state
	local soundMin = 0
	local soundSec = 0
	local soundTime = 0
	taskHandler()
	if(1==system.getInputsVal(cfgFrameAudioSwitchF3K)) then
		if((prevFrameAudioSwitchF3K ==0)and (flightIndexF3K >1))then
			prevFrameAudioSwitchF3K = 1  -- play audio file for break time
			soundTime = goodFlightsF3K[flightIndexF3K-1][2] -- break time of previous flight
			soundMin =  math.modf(soundTime / 60)
			if(soundMin>0)then
				system.playNumber(soundMin,0,"min")
				soundSec = soundTime - soundMin * 60
				system.playNumber(soundSec,1)
			else
				soundSec = soundTime
				system.playNumber(soundSec,1)
			end
			sumAudioOutput = 9 --wait 9 cycles a 30ms
		end	
	else
		prevFrameAudioSwitchF3K = 0
	end
	
	if(sumAudioOutput>0)then
		if(sumAudioOutput >1)then 
			sumAudioOutput = sumAudioOutput - 1
		end	
		if((system.isPlayback() == false) and (sumAudioOutput == 1))then
			soundTime = goodFlightsF3K[flightIndexF3K-1][1] -- flight time of previous flight
			soundMin =  math.modf(soundTime / 60)
			if(soundMin>0)then
				system.playNumber(soundMin,0,"min")
				soundSec = soundTime - soundMin * 60
				system.playNumber(soundSec,1)
			else
				soundSec = soundTime
				system.playNumber(soundSec,1)
			end
			sumAudioOutput = 0
		end
	end
end
--------------------------------------------------------------------
-- display task  TF Training Flights
--------------------------------------------------------------------
local function screen()
    local listIndex = 0 
	local breakTimeMs = 0
	local flightTimeMs = 0
	local breakTimeTxt =  nil
	local flightTimeTxt =  nil
	local flightScreenTxt = nil
	local remainingFlightTimeTxt = nil
	local timeTxt = string.format( "%02d:%02d", math.modf(cfgTargetTimeF3K / 60),cfgTargetTimeF3K % 60 )
	local sumTimeTxt = string.format( "%02d:%02d", math.modf(sumTimerF3K / 60),sumTimerF3K % 60 )

	remainingFlightTimeTxt = string.format( "%02d:%02d",remainingFlightTimeMinF3K ,remainingFlightTimeSecF3K )
	lcd.drawText(10,15,langF3K.Screen_Target,FONT_NORMAL) -- target time
	lcd.drawText(40,5,timeTxt,FONT_MAXI)
	lcd.drawText(10,50,langF3K.Screen_flight,FONT_NORMAL)
	lcd.drawText(40,40,remainingFlightTimeTxt,FONT_MAXI)
	lcd.drawText(10,85,langF3K.Screen_Sum,FONT_NORMAL)
	lcd.drawText(40,75,sumTimeTxt,FONT_MAXI)
	
	if(flightIndexF3K > 8)then
		flightIndexOffsetScreenF3K = flightIndexF3K - 8
	end

	if(goodFlightsF3K[20][2] >0) then	 -- all flights valid , draw all flights invers
		lcd.drawFilledRectangle(130,0,180,(8*15) +2)
	elseif(flightIndexF3K > 1)then
		if(flightIndexScrollScreenF3K == 0)then
			lcd.drawFilledRectangle(130,0,180,((flightIndexF3K-flightIndexOffsetScreenF3K-1)*15) +2)
		else
			lcd.drawFilledRectangle(130,0,180,((flightIndexF3K-flightIndexOffsetScreenF3K)*15) +2)
		end
	end	

	for i=1 , 8 do
		listIndex = i + flightIndexOffsetScreenF3K-flightIndexScrollScreenF3K
		breakTimeTxt =  nil
		flightTimeTxt =  nil
		flightScreenTxt = nil
		sumTimeTxt = nil 

		if(listIndex < flightIndexF3K) then -- write stored text for previous finished flights or if last flight valid until last flight
			breakTimeMs = ((goodFlightsF3K[listIndex][2] -  math.modf(goodFlightsF3K[listIndex][2]))*100) 
			flightTimeMs = ((goodFlightsF3K[listIndex][1] -  math.modf(goodFlightsF3K[listIndex][1]))*100)
			breakTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(goodFlightsF3K[listIndex][2]/ 60),goodFlightsF3K[listIndex][2] % 60,breakTimeMs )
			flightTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(goodFlightsF3K[listIndex][1] / 60),goodFlightsF3K[listIndex][1] % 60,flightTimeMs ) 
			sumTimeTxt =  string.format( "%1d:%02d", math.modf(goodFlightsF3K[listIndex][3] / 60),goodFlightsF3K[listIndex][3] % 60) 
			flightScreenTxt = string.format("%s  %s  %s",breakTimeTxt,flightTimeTxt,sumTimeTxt)
			if(colorScreenF3K== true) then
				lcd.setColor(255,255,255) -- white
				lcd.drawText(135,i*15-15,flightScreenTxt,FONT_NORMAL)
				lcd.setColor(0,0,0) -- black
			else
				lcd.drawText(135,i*15-15,flightScreenTxt,FONT_REVERSED)
			end
		elseif(listIndex == flightIndexF3K) then -- write current flight
			flightTimeMs = ((flightTimeF3K -  math.modf(flightTimeF3K))*100) 
			breakTimeMs = ((breakTimeF3K -  math.modf(breakTimeF3K))*100) 
			flightTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(flightTimeF3K / 60),flightTimeF3K % 60,flightTimeMs ) 
			breakTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(breakTimeF3K / 60),breakTimeF3K % 60,breakTimeMs )
			sumTimeTxt =  string.format( "%1d:%02d", math.modf(cfgTargetTimeF3K / 60),cfgTargetTimeF3K % 60) 
			flightScreenTxt=string.format("%s  %s  %s",breakTimeTxt,flightTimeTxt,sumTimeTxt)
			if(goodFlightsF3K[20][2] >0) then --write last current flight
				if(colorScreenF3K== true) then
					lcd.setColor(255,255,255)-- white
					lcd.drawText(135,i*15-15,flightScreenTxt,FONT_NORMAL)
					lcd.setColor(0,0,0) -- black
				else
					lcd.drawText(135,i*15-15,flightScreenTxt,FONT_REVERSED)
				end			
			else --write current flight
				lcd.setColor(0,0,0) -- black
				lcd.drawText(135,i*15-15,flightScreenTxt,FONT_NORMAL)
			end
		end
	end
	lcd.drawLine(1,125,310,125)
	lcd.drawLine(130,0,130,125)
end


local task_TF = {taskInit,frameTimeChanged,file,task,screen}
return task_TF