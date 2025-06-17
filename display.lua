local monApi = require("monitors")()
local runTime = 0

local station = peripheral.wrap("top")
local source = peripheral.find("create_target")
local drive = peripheral.wrap("bottom")

function center(text,line,monitor)
    local w,h = monitor.getSize()
    if w ~= nil then
    local len = text:len()
    local pos = math.ceil(w/2-len/2)
    monitor.setCursorPos(pos+1,line)
    monitor.write(text)
    end
end
-- credit: https://www.reddit.com/r/learnprogramming/comments/s41ykx/lua_is_there_a_method_to_see_if_a_table_or_array/
function tableContains(table, value)
  for i = 1,#testTable do
    if (testTable[i] == value) then
      return true
    end
  end
  return false
end

function platformDisplay(monitor, station)
  center("Welcome to CLR!",1,monitor)
  local platform = station.getStationName():gsub(-1,-1)

  if station.isTrainPresent() then
    monitor.setTextColor(colors.magenta)
    center("Train: " .. station.getTrainName(),2)
    local bdp = fs.combine("disk","destination",station.getTrainName())
    local vdp = fs.combine("disk","via",station.getTrainName())
    if fs.exists(bdp) then
      local file = fs.open(bdp, "r")
      if file then
        local destination = file.readLine()
        file.close()

        monitor.setTextColor(colors.green)
        center("To: "..destination,3)
      end
    end
  
    if fs.exists(vdp) then
      local file = fs.open(vdp, "r")
      if file then
        local stations = textutils.unserialiseJSON(file.readLine())
        file.close()

        local viaParts = {"via "}
        if #stations > 2 then
          for j=1,#stations-2 do
            local index = (j+stationIndex)%#stations
            if index == 0 then index = #stations end
            local current = stations[index]:gsub(" (%u)%-"," "):gsub(" (%u)B",""):gsub(" Station", ""):gsub(" %*", "")
            local spacer = ", "
            if j == #stations-3 then spacer = " and " end
            if j == #stations-2 then spacer = "" end
            local text = viaParts[#viaParts] .. current .. spacer
            if text:len() >= w then
              table.insert(viaParts, current .. spacer)
            else
              viaParts[#viaParts] = text
            end
          end
        else viaParts = false end
        monitor.setTextColor(colors.lightBlue)
        center(viaParts and viaParts[(runTime%#viaParts)+1] or "Directly", 4)
      end
    end
    monitor.setTextColor(colors.white)
    local dtext = {}
    for w in source.getLine(1):gmatch("%S+") do table.insert(dtext, w) end
    if #dtext >= 4 then center("Departs in: " .. dtext[3] .. dtext[4]:sub(1,1):lower(), 5)
    else
      local departs = ""
      for item in pairs(dtext) do
        departs = departs .. dtext[item] .. " "
      end
      center(departs:sub(1,-2), 5)
    end
  end
  if not station.isTrainPresent() or h > 4 then
    monitor.setTextColor(colors.lightBlue)
        
    local startLine = 2
    if station.isTrainPresent() then startLine = 6 end
    monitor.setCursorPos(1,startLine)
    monitor.write("ETA   Train")
    
    local pos = startLine-1
    for j = 1,(h+2-startLine)/2 do
      local i = j*2
      monitor.setCursorPos(1,pos+i)
            
      eta = string.sub(source.getLine(j+1),1,5):gsub("~",">10m")
      train = string.sub(source.getLine(j+1),7,-1)
      if eta:match("mi$") then
        eta = eta:sub(1,-2)
      end
      monitor.setTextColor(colors.magenta)
      monitor.write(eta:gsub("%s+", ""))
      monitor.setTextColor(colors.white)

      if train:match("^ ") then
        train = train:sub(2)
      end
      if train:match(" $") then
        train = train:sub(1,-2)
      end

      local know = false
            
      local known = fs.list("disk/destination")
      for t in pairs(fs.list("disk/destination")) do
        if train:find(known[t]) then
          know = true
          train = known[t]
        end
      end
            
      monitor.setCursorPos(7,pos+i)
            
      monitor.write(train)
      destination = "unknown"
      bfp = fs.combine("disk","destination",train)
        
      if fs.exists(bfp) and eta:find("%.") == nil then
        file = fs.open(bfp, "r")
        if file then
          destination = file.readLine()
          file.close()
        end
      end
        
      if eta:find("%.") ~= nil then destination = "" end
      monitor.setCursorPos(7,pos+i+1)
      monitor.setTextColor(colors.green)
      monitor.write(" " .. destination)
    end
  end
end
function station(station)
  if station.isTrainPresent() then
    if station.hasSchedule() then  
      local schedule = station.getSchedule() 
      local stations = {}
      local stationIndex = 0
      local entries = schedule.entries
      local step = 0
      local i = 0
      local k = 0
      for x,e in pairs(entries) do
          k = k+1
          if e.instruction.id == "create:destination" then
              table.insert(stations,e.instruction.data.text)
              local ins = e.instruction.data.text:match("(.*%*)")
              if station.getStationName():find(ins or e.instruction.data.text) then stationIndex = k end
          end
      end
      monitor.setTextColor(colors.green)

      local sts = {}
      local destination = (stations[stationIndex-1] or stations[#stations]):gsub(" (%u)%-"," "):gsub(" (%u)B",""):gsub(" Station", ""):gsub(" %*", "")

      for x in pairs(stations) do
        local v = stations[x]
        local st = v:gsub(" (%u)%-"," "):gsub(" (%u)B",""):gsub(" Station", ""):gsub(" %*", "")
        if not tableContains(sts,st) then
          table.insert(sts, st)
        else
          destination = v
        end
      end
      local bdp = fs.combine("disk","destination",station.getTrainName())
      local vdp = fs.combine("disk","via",station.getTrainName())
                
      local f = fs.open(bdp,"w")
      f.writeLine(destination)
      f.close()
      if viaParts then
          f = fs.open(vdp, "w")
          f.writeLine(textutils.serialiseJSON(stations))
          f.close()
      else
          f = fs.delete(vdp)
      end
    end
  end
end

while true do
  runTime = runTime + 1
  monApi.clear()
  monApi.color(colors.yellow)
  monApi.writeCenter("Welcome to CLR!",1)

  for t in pairs(fs.list("disk/destination")) do
    if train:find(known[t]) then
      know = true
      train = known[t]
    end
  end
            
  monApi.pos(7,pos+i)
            
  monApi.write(train)
  destination = "unknown"
  bfp = fs.combine("disk","destination",train)
        
  if fs.exists(bfp) and eta:find("%.") == nil then
    file = fs.open(bfp, "r")
    if file then
      destination = file.readLine()
      file.close()
    end
  end
            
  if eta:find("%.") ~= nil then destination = "" end

  monApi.pos(w-1-destination:len(),pos+i)
  monApi.color(colors.green)
  monApi.write(" " .. destination)

  vdp = fs.combine("disk","via",train)
  local refMonitor = periperal.wrap("monitor_")
  local w,h = refMonitor.getSize()
  if fs.exists(vdp) then
    local file = fs.open(vdp, "r")
    if file then
      local stations = textutils.unserialiseJSON(file.readLine())
      file.close()

      local viaParts = {"via "}
      if #stations > 2 then
        for j=1,#stations-2 do
          local index = (j+stationIndex)%#stations
          if index == 0 then index = #stations end
            local current = stations[index]:gsub(" (%u)%-"," "):gsub(" (%u)B",""):gsub(" Station", ""):gsub(" %*", "")
            local spacer = ", "
            if j == #stations-3 then spacer = " and " end
            if j == #stations-2 then spacer = "" end
            local text = viaParts[#viaParts] .. current .. spacer
            if text:len() >= w then
              table.insert(viaParts, current .. spacer)
            else
              viaParts[#viaParts] = text
            end
          end
      else viaParts = false end
      monitor.setTextColor(colors.lightBlue)
      center(viaParts and viaParts[(runTime%#viaParts)+1] or "Directly", 4)
    end
  end
  monApi.pos(7,pos+i+1)
  monApi.write(viaParts[(runTime%#viaParts)+1])         
end
