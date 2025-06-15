local target = peripheral.find("create_target")

local bounds = {"WB", "EB"}
local directions = {"Starfall", "CLR Main"}

local station = "john"
local nation = "CLR"
local title = "Cappymetro"
local line = "M1"

local api1 = require("monitors1")({"right"})
local api2 = require("monitors2")({"monitor_386"})
local monApi = require("monitors")({"right", "monitor_386"})

target.setWidth(132)

function time(text)
    return (text or "-"):sub(1,6):gsub("%s+",""):gsub("in",""):gsub("~",">10m")
end
while true do
  if monApi.exist then
  
  monApi.clear()
  monApi.pos(2,1)
  
  monApi.color(colors.green)
  monApi.write(nation ~= "" and (nation .. " ") or "")
    
  monApi.color(colors.lightBlue)
  monApi.write(station)
  
  monApi.color(colors.orange)
  api1.writeCenter("to "..directions[1],3)
  api2.writeCenter("to "..directions[2],3)
  
  local msg1, msg2, msg3, msg4
  for j=1,8 do
    if not (msg1 and msg2 and msg3 and msg4) then
      local bound = target.getLine(j):gsub("%s+",""):sub(-2,-1)
      
      if bound == bounds[1] then
        if msg1 == nil then msg1 = target.getLine(j)
        elseif msg3 == nil then msg3 = target.getLine(j) end
      elseif bound == bounds[2] then
        if msg2 == nil then msg2 = target.getLine(j)
        elseif msg4 == nil then msg4 = target.getLine(j) end
      end
    end
  end
    
  local time1 = time(msg1)
  local time2 = time(msg2)
  local time3 = time(msg3)
  local time4 = time(msg4)
  
  monApi.color(colors.yellow)
  
  if not time1:find("now") then
    api1.writeCenter("in "..time1,2)
  else
    api1.writeCenter("now",2)
  end
  if not time2:find("now") then
    api2.writeCenter("in "..time2,2)
  else
    api2.writeCenter("now",2)
  end
  
  api1.writeCenter("next: "..time3,4)
  api2.writeCenter("next: "..time4,4)
  
  monApi.color(colors.lightGray)
  monApi.pos(2,5)
  monApi.write(title)
  monApi.color(colors.red)
  monApi.writeBack(line,5)

  term.setCursorPos(1,2)
  term.clearLine()
  term.write("Monitors: ON")

  else
    term.setCursorPos(1,2)
    term.clearLine()
    term.write("Monitors: OFF")
  end
  sleep(5)
end
