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

local appName="DC-24 Tx Telemetry"

local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         -- if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. k..'=' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local function printForm()
  local txTel = system.getTxTelemetry();
  lcd.drawText(10,20,string.format("Rx1: %dV, Q=%d%%, A1/2=%d/%d",txTel.rx1Voltage,txTel.rx1Percent,txTel.RSSI[1],txTel.RSSI[2]))
  lcd.drawText(10,40,string.format("Rx2: %dV, Q=%d%%, A1/2=%d/%d",txTel.rx2Voltage,txTel.rx2Percent,txTel.RSSI[3],txTel.RSSI[4]))
  lcd.drawText(10,60,string.format("RxB: %dV, Q=%d%%, A1/2=%d/%d",txTel.rxBVoltage,txTel.rxBPercent,txTel.RSSI[5],txTel.RSSI[6]))
  lcd.drawText(10,80,string.format("Tx: %.2fV, Batt=%d%%, I=%.2fmA",txTel.txVoltage,txTel.txBattPercent,txTel.txCurrent))
  
end

local function init()
  system.registerForm(1,MENU_MAIN,appName,nil,nil,printForm);
end
--------------------------------------------------------------------

return { init=init, loop=loop, author="JETI model", version="1.00",name=appName}