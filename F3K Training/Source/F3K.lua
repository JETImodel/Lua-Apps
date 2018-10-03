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
-- # V1.0.0 - Initial release with implementation of task D 'Ladder'
-- # V1.0.1 - Release with implementation of tasks        A 'last flight' 
-- #                                                      B 'next to last flight' 
-- #                                                      C 'all up last down'
-- #													  E 'Poker'	
-- #                                                      K 'Big Ladder'
-- #                                                     FF 'Free Flights'  
-- #          Count down on flight breaks for remaining frame time 
-- #		  Dynamic memory management on loading tasks and model change	
-- # V1.0.2 - Release with implementation of tasks  
-- #                                                      F '3 out of 6' 
-- #                                                      G '5 longest flights'
-- #													  H '1,2,3,4 min target '	
-- #                                                      I '3 lognest flights'
-- #                                                      J '3 last flights'   
-- #                                                     TT 'Training Task'        
-- #############################################################################

--Configuration
--Local variables
local appLoaded = false
local main_lib = nil  -- lua main script
local initDelay = 0
F3K_Version="V1.0.2"
mem = 0
debugmem = 0
initScreenIDF3K = 2 -- id of tool screen
taskScreenIDF3K = 1 -- id of task screen
currentFormF3K = nil -- current display
langF3K={}
currentTaskF3K=12    --Index tasklist of last training default is FF (free flights task)
cfgStartFrameSwitchF3K=nil --configured start frame time switch
cfgStartFlightSwitchF3K=nil --configured start flight time switch
cfgStoppFlightSwitchF3K=nil --configured stopp flight time switch
cfgFrameAudioSwitchF3K=nil --configured audio output switch for remaining frame time
cfgTimerResetSwitchF3K=nil --switch for store current training and reset timers
cfgFlightCountDownSwitchF3K=nil --switch for starting flight count down of poker tasks
cfgFrameTimeF3K=nil --Frame time of all F3K training tasks in seconds
cfgPreFrameTimeF3K=10 -- count down time before start of frame timer
cfgTargetTimeF3K=30 -- flight target tim for TF task (training flights) 
currentTimeF3K=nil --current timestamp in milliseconds
frameTimerF3K = 0 -- contains current frame time
colorScreenF3K = false -- display type true for dc\ds 24 otherwise false
prevSoundTimeF3K = 0	   --previous time for audio output
soundTimeF3K = 0		   --calculated time for audio output
flightIndexOffsetScreenF3K = 0 -- for display if more than 8 flights in list
flightIndexScrollScreenF3K = 0 -- for scrolling up and down if more than 8 flights in list
cfgAudioFlights = nil -- number of audio output best flights in order for tasks F,G,H,I,J


-------------------------------------------------------------------- 
-- Initialization
--------------------------------------------------------------------
local function init(code)
	if(initDelay == 0)then
		initDelay = system.getTimeCounter()
	end	
	if(main_lib ~= nil) then
		local func = main_lib[2]
		func(0) --init(0)
	end
end

function resetTask()
	if(main_lib ~= nil) then
		local func = main_lib[1] --resetTask_()
		func(0) --resetTask_
	end
end

function storeTask()
	if(main_lib ~= nil) then
		local func = main_lib[3] --storeTask_()
		func(0)
	end
end


--------------------------------------------------------------------
-- main Loop function
--------------------------------------------------------------------
local function loop() 
	currentTimeF3K = system.getTimeCounter()
	 -- load current task
    if(main_lib == nil)then
		init(0)
		if((system.getTimeCounter() - initDelay > 5000)and(initDelay ~=0)) then
			if(appLoaded == false)then
				local memTxt = "max: "..mem.."K act: "..debugmem.."K"
				print(memTxt)
				main_lib = require("F3K/Tasks/F3K_Main")
				if(main_lib ~= nil)then
					appLoaded = true
					init(0)
					initDelay = 0
				end
				collectgarbage()
			end
		end
	else
		local func = main_lib[4] --loop()
		func() -- execute main loop
	end	
	debugmem = math.modf(collectgarbage('count'))
	if (mem < debugmem) then
		mem = debugmem
	end
end
 
--------------------------------------------------------------------

return { init=init, loop=loop, author="by Geierwally", version=F3K_Version,name="F3K Training"}