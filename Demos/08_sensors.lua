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

local function init() 
  local sensors = system.getSensors()
  for i,sensor in ipairs(sensors) do
    if (sensor.type == 5) then
      if (sensor.decimals == 0) then
        -- Time
        print (string.format("%s = %d:%02d:%02d", sensor.label, sensor.valHour, 
               sensor.valMin, sensor.valSec))
      else
        -- Date 
        print (string.format("%s = %d-%02d-%02d", sensor.label, sensor.valYear, 
               sensor.valMonth, sensor.valDay)) 
      end 
    elseif (sensor.type == 9) then
      -- GPS coordinates
      local nesw = {"N", "E", "S", "W"}
      local minutes = (sensor.valGPS & 0xFFFF) * 0.001
      local degs = (sensor.valGPS >> 16) & 0xFF
      print (string.format("%s = %d° %f' %s", sensor.label,    
             degs, minutes, nesw[sensor.decimals+1])) 
    else
      if(sensor.param == 0) then
        -- Sensor label
        print (string.format("%s:",sensor.label))
      else  
        -- Other numeric value
        print (string.format("%s = %.1f %s (min: %.1f, max: %.1f)", sensor.label,    
                sensor.value, sensor.unit, sensor.min, sensor.max))
      end        
    end
  end
end
--------------------------------------------------------------------------------
return {init=init, author="JETI model", version="1.0"}

