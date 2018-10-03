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
-- # V1.0.2 - Initial release of all specific functions of Task I '3 longest flights'
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
local sumFlightList = nil -- buble sort list indexes of flight list ordered by flight time
local sumFlightIndex = 0
local sumAudioOutput = 0 -- helper for audio output flight times
local sumAudioCounter = 0 -- helper for audio output flight times

--------------------------------------------------------------------
-- init function task I 3 longest flights
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
	flightTimesTxtF3K = "200s "
	flightTimesF3K=200
	goodFlightsF3K = {{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}} --list of all good flights  flight time , break time
	sumFlightList = {1,1,1,1} -- buble sort list indexes of flight list ordered by flight time
    sumFlightIndex = 0
	flightIndexOffsetScreenF3K = 0 -- for display if more than 8 flights in list
    flightIndexScrollScreenF3K = 0 -- for scrolling up and down if more than 8 flights in list
	sumAudioOutput = 0 -- helper for audio output flight times
    sumAudioCounter = 0 -- helper for audio output flight times
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

local function audioFlightsChanged(value,formIndex) -- number of audio output best flights
	if (value > 3) then
		value = 3
	end	
	sumAudioCounter = value
	cfgAudioFlights[currentTaskF3K-5]=value
  	form.setValue(formIndex,value)
	system.pSave("audioFlights",cfgAudioFlights)
end

local function calcSumTime()
	local sum = 0
	local temp = 0
	local sorted = false

	repeat  -- doe bubble sort
		sorted = true
		if(sumFlightIndex >1)then
			for i = 2,sumFlightIndex,1 do 
				if(goodFlightsF3K[sumFlightList[i]][1] > goodFlightsF3K[sumFlightList[i-1]][1])then
					temp = sumFlightList[i]
					sumFlightList[i] = sumFlightList[i-1]
					sumFlightList[i-1] = temp
					sorted = false
				end
			end
		end
	until sorted == true
	
	for i = 1,sumFlightIndex,1 do -- calculate sum time
		if(i<4) then -- calculate summary of five best flights
			if(goodFlightsF3K[sumFlightList[i]][1] >= flightTimesF3K)then
				sum = sum + flightTimesF3K
			else
				sum = sum + math.modf(goodFlightsF3K[sumFlightList[i]][1])
			end
		end
	end
	return sum
end
--------------------------------------------------------------------
-- file handler task I 3 lognest flights
--------------------------------------------------------------------
local function file(tFileF3K)
	local breakTimeMs = 0
	local flightTimeMs = 0
	local breakTimeTxt =  nil
	local flightTimeTxt = nil  
	local flightTxt = nil 
    local failedFlightTxt = nil
	local targetTimeTxt = nil
	local flightNumberTxt = nil
	
	if(goodFlightsF3K[1][2] >0) then
		io.write(tFileF3K,langF3K.flight,langF3K.target,langF3K.time,langF3K.breakTime,"\n")
		for i=1 , flightIndexF3K do
			breakTimeTxt =  nil
			flightTimeTxt = nil  
			flightTxt = nil 
			failedFlightTxt = nil
			targetTimeTxt = nil
			flightNumberTxt = string.format( "%02d",i)
			if((i == sumFlightList[1])or(i == sumFlightList[2])or(i == sumFlightList[3])or(i == sumFlightList[4])or(i == sumFlightList[5]))then -- best flight list  write target time
				targetTimeTxt = string.format( "%02d:%02d", math.modf(flightTimesF3K / 60),flightTimesF3K % 60)
			else
				targetTimeTxt = "*###*"
			end
			
			if((goodFlightsF3K[i][2]>0)or(goodFlightsF3K[i][1]>0))then -- write only done flights
				breakTimeMs = ((goodFlightsF3K[i][2] -  math.modf(goodFlightsF3K[i][2]))*100) 
				flightTimeMs = ((goodFlightsF3K[i][1] -  math.modf(goodFlightsF3K[i][1]))*100) 
				breakTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(goodFlightsF3K[i][2]/ 60),goodFlightsF3K[i][2] % 60,breakTimeMs )
				flightTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(goodFlightsF3K[i][1] / 60),goodFlightsF3K[i][1] % 60,flightTimeMs ) 
				flightTxt="                 "..flightNumberTxt.."      "..targetTimeTxt.."         "..flightTimeTxt.."      "..breakTimeTxt.."\n" --write goog flight information for logfile
				io.write(tFileF3K,flightTxt)
			end
		end
	end	
	local sumTimeTxt =  string.format( "%02d:%02d", math.modf(sumTimerF3K / 60),sumTimerF3K % 60 )
	io.write(tFileF3K,langF3K.sumTime,sumTimeTxt,"\n")
end
--------------------------------------------------------------------
-- eventhandler task I 3 longest flights
--------------------------------------------------------------------
local function task_I_Start() -- wait for start switch start 5s count down and start frame time
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
local function task_I_flights() -- wait for start flight switch count preflight time start, end, start next flight
	local diffTime =(currentTimeF3K - startFrameTimeF3K)/1000

	frameTimerF3K = cfgFrameTimeF3K[currentTaskF3K]+1 - diffTime
	if(onFlightF3K == true)then -- flight active
		flightTimeF3K =(currentTimeF3K - startFlightTimeF3K)/1000
		remainingFlightTimeF3K = flightTimesF3K-flightTimeF3K + 1
		if(frameTimerF3K < remainingFlightTimeF3K)then 
			remainingFlightTimeF3K = frameTimerF3K
		end
	    remainingFlightTimeMinF3K = math.modf( remainingFlightTimeF3K/ 60)
        remainingFlightTimeSecF3K = remainingFlightTimeF3K % 60
		if((flightFinishedF3K == true) or ((remainingFlightTimeMinF3K == 0)and(remainingFlightTimeSecF3K == 0))) then -- avoid negative count of remaining flight time
			flightFinishedF3K = true
			remainingFlightTimeMinF3K = 0
			remainingFlightTimeSecF3K = 0
		end
		
		if((frameTimerF3K >= remainingFlightTimeF3K)and(frameTimerF3K > 45)and(sumAudioOutput ==0))then -- avoid overlapping frame and flight count down
			soundTimeF3K = math.modf(remainingFlightTimeF3K)
			audioCountDownF3K()
			if((soundTimeF3K >=0)and(soundTimeF3K ~= prevSoundTimeF3K))then
				if((((soundTimeF3K % 15)==0)and(soundTimeF3K > 45)and(soundTimeF3K <=180))or(soundTimeF3K==200))then -- audio output of flight time in 15 seconds cycle
					system.playNumber(math.modf(soundTimeF3K/60),0,"min")
					system.playNumber(soundTimeF3K%60,0,"s")
					prevSoundTimeF3K = soundTimeF3K
				elseif(soundTimeF3K == flightTimesF3K) then
					system.playNumber(remainingFlightTimeMinF3K,0,"min")
					system.playNumber(remainingFlightTimeSecF3K,0,"s")
					prevSoundTimeF3K = soundTimeF3K
				end
			end
		end
		
		if((1==system.getInputsVal(cfgStoppFlightSwitchF3K))or(frameTimerF3K==0)) then  -- stopp flight was switched or end of frame time reached
			goodFlightsF3K[flightIndexF3K][1]=flightTimeF3K
			goodFlightsF3K[flightIndexF3K][2]=breakTimeF3K
			if(sumFlightIndex < 4) then
				sumFlightIndex = sumFlightIndex + 1
			end	
			sumFlightList[sumFlightIndex] = flightIndexF3K
			sumTimerF3K = calcSumTime() -- calculate sum timer
			if(flightIndexF3K == 20) then -- this was the last flight
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
		local shortestFlight = sumFlightIndex
		if(shortestFlight == #sumFlightList)then
			shortestFlight = shortestFlight -1
		elseif(shortestFlight == 0)	then
			shortestFlight = 1
		end
		if(goodFlightsF3K[sumFlightList[shortestFlight]][1]< frameTimerF3K)then --shortest flight is shorter than remaining frame time, continue 	
			if(frameTimerF3K == 0)then -- end of frame time reached
				taskStateF3K = 3
				system.playFile("F3K_Tend.wav",AUDIO_QUEUE)
			else
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
						flightFinishedF3K = false
						startFlightTimeF3K = currentTimeF3K
						soundTimeF3K = 0
						prevSoundTimeF3K = 1
					end	
				end
			end
		else
			-- remaining frame time not enough for next flight
			system.playFile("F3K_Fend.wav",AUDIO_QUEUE)
			taskStateF3K = 3
		end
	end
	soundTimeF3K = math.modf(frameTimerF3K) -- count down of remaining frame time
	audioCountDownF3K()
end
--------------------------------------------------------------------
local function task_I_End()     -- safe training?
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
local task_I_States = {task_I_Start,task_I_flights,task_I_End}
--------------------------------------------------------------------
local function task()
	local taskHandler = task_I_States[taskStateF3K] -- set statemachine depending on last current state
	taskHandler()
	if(1==system.getInputsVal(cfgFrameAudioSwitchF3K)) then
		if(prevFrameAudioSwitchF3K ==0)then
			prevFrameAudioSwitchF3K = 1  -- play audio file for remaining frame time
			system.playNumber(math.modf(frameTimerF3K / 60),0,"min")
			system.playNumber(frameTimerF3K % 60,0,"s")
			system.playFile("F3K_Frame.wav",AUDIO_QUEUE)
			sumAudioCounter = cfgAudioFlights[currentTaskF3K-5]
			if(sumFlightIndex == 4)then
				sumAudioOutput = sumFlightIndex - 1
			else
				sumAudioOutput = sumFlightIndex
			end	
		end	
	else
		prevFrameAudioSwitchF3K = 0
	end

	if((sumAudioOutput>0)and(system.isPlayback() == false))then
		local audioFlights = goodFlightsF3K[sumFlightList[sumAudioOutput]][1]
		if(audioFlights >0)then
			system.playNumber(math.modf(audioFlights / 60),0,"min")
			system.playNumber(audioFlights % 60,0,"s")
		end	
		sumAudioOutput = sumAudioOutput -1
		sumAudioCounter = sumAudioCounter - 1
		if((sumAudioOutput == 0)or(sumAudioCounter == 0))then
			sumAudioOutput = 0
			system.playFile("F3K_Flights.wav",AUDIO_QUEUE)
		end
	end
end
--------------------------------------------------------------------
-- display task I 3 longest flights
--------------------------------------------------------------------
local function screen()
    local listIndex = 0 
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

	--write best flights
	for i=1 , 3 do	
		flightTimeMs = 0
		flightTimeTxt =  nil
		if (goodFlightsF3K[sumFlightList[i]][1]>0) then
			flightTimeMs = ((goodFlightsF3K[sumFlightList[i]][1] -  math.modf(goodFlightsF3K[sumFlightList[i]][1]))*100)
			flightTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(goodFlightsF3K[sumFlightList[i]][1] / 60),goodFlightsF3K[sumFlightList[i]][1] % 60,flightTimeMs ) 
			lcd.drawText(150,(i)*19,flightTimesTxtF3K,FONT_BIG)
			lcd.drawText(220,(i)*19,flightTimeTxt,FONT_BIG)
		end	
		if(i==sumFlightIndex)then
			break
		end
	end	
	--write current flight
	flightTimeTxt = nil
	breakTimeTxt = nil
	flightTimeMs = ((flightTimeF3K -  math.modf(flightTimeF3K))*100) 
	breakTimeMs = ((breakTimeF3K -  math.modf(breakTimeF3K))*100) 
	flightTimeTxt =  string.format( "%02d:%02d:%02d", math.modf(flightTimeF3K / 60),flightTimeF3K % 60,flightTimeMs ) 
	breakTimeTxt =  string.format( "%2d %02d:%02d:%02d",flightIndexF3K,math.modf(breakTimeF3K / 60),breakTimeF3K % 60,breakTimeMs )
	lcd.drawText(135,6*17+1,breakTimeTxt,FONT_NORMAL)
	lcd.drawText(220,6*17,flightTimeTxt,FONT_BIG)

	lcd.drawLine(1,125,310,125)
	lcd.drawLine(130,0,130,125)
	lcd.drawLine(130,99,310,99)
end	

local task_I = {taskInit,frameTimeChanged,file,task,screen,audioFlightsChanged}
return task_I