-- ############################################################################# 
-- # DC-24 Application Dumper - Lua application for JETI DC/DS transmitters 
-- # Copyright (c) 2017, JETI model s.r.o.
-- # All rights reserved.
-- #
-- # The app dumps compiled Lua chunks to files without debugging information.
-- # Useful to shrink the app, reduce memory consumption, improve start-up time 
-- # and prevent memory issues. 
-- #
-- # Load the application and then open it via User Applications form.
-- # Hit "Compile apps and dump" and confirm. All Lua files (*.lua) in the Apps
-- # folder will be converted to their binary representation (*.lc).  
-- # You can then use the binary files (*.lc) in the transmitter instead of (*.lua) 
-- # files. 
-- # NOTICE: This application should be run only via a PC Emulator to reach the 
-- # best performance.
-- #
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

 local appName="App Dumper"
 local path = "Apps"
 
--------------------------------------------------------------------
local function readFile(path) 
 local f = io.open(path,"r")
  local lines={}
  if(f) then
    while 1 do 
      local buf=io.read(f,512)
      if(buf ~= "")then 
        lines[#lines+1] = buf
      else
        break   
      end   
    end 
    io.close(f)
    return table.concat(lines,"") 
  end
end  
  

local function exportFiles()
  local func
  local chunk
  local file 
  local d,fn,ext
  for name, filetype, size in dir(path) do
    d,fn,ext = string.match(name, "(.-)([^/]-)%.([^/]+)$")
    if fn and ext then
      --print (fn,ext)
      if(string.lower(ext)=="lua") then
        print ("Exporting " .. name) 
        func = loadfile(path.."/"..name)
        chunk = string.dump(func,true)
        
        file = io.open(path.."/"..fn..".lc","wb")
        if(file) then
          io.write(file, chunk)
          io.close(file)
        end
      end
    end
  end 
  print ("Exporting finished")
end
 
--------------------------------------------------------------------

local function initForm(formID)
   
  form.addSpacer(100,10)
  form.addLink((function() 
    if(form.question("Really compile apps?")==1) then
      exportFiles()
    end 
  end), {label="Compile apps and dump >>",font=FONT_BOLD})
 
  
   
end  


-------------------------------------------------------------------- 
-- Initialization
--------------------------------------------------------------------
-- Init function
local function init()  
  system.registerForm(1,MENU_APPS,appName,initForm,nil,nil)
end


  

--------------------------------------------------------------------
-- Loop function
local function loop() 
   
end
 
 
return { init=init, loop=loop, author="JETI model", version="1.00",name=appName}





