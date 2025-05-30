local station = peripheral.wrap("top")
local monitor = peripheral.find("monitor")
local source = peripheral.find("create_target")
local drive = peripheral.wrap("bottom")

function center(text,line)
    local w,h = monitor.getSize()
    if w ~= nil then
    local len = text:len()
    local pos = math.ceil(w/2-len/2)
    monitor.setCursorPos(pos+1,line)
    monitor.write(text)
    end
end
    
while true do
    monitor.clear()
    monitor.setTextColor(colors.yellow)
    center("Welcome to CLR!",1)
    local w,h = monitor.getSize()
    
    if w and h then
        term.setCursorPos(1,2)
        term.clearLine()
    
    source.setWidth(w)
    monitor.setTextColor(colors.lightBlue)
    if station.isTrainPresent() then
        center("Train: " .. station.getTrainName(),2)
        if station.hasSchedule() then  
            local schedule = station.getSchedule() 
            local stations = {}
            local entries = schedule.entries
            local step = 0
            local i = 0
            for x,e in pairs(entries) do
                if e.instruction.id == "create:destination" then
                    table.insert(stations,e.instruction.data.text)
                end
            end
            monitor.setTextColor(colors.lime)
        
            local destination = stations[#stations]
            if destination == station.getStationName() then
                destination = stations[#stations-1]
            end
            destination = destination:gsub(" b%-"," "):gsub(" (%u)B",""):gsub(" Station", "")
            local bdp = fs.combine("disk",station.getTrainName())
            
            local f = fs.open(bdp,"w")
            f.writeLine(destination)
            f.close()
            
            center("To: "..destination,3)    
            monitor.setTextColor(colors.white)
            local dtext = {}
            for w in source.getLine(1):gmatch("%S+") do table.insert(dtext, w) end
            if #dtext > 4 then center("Departs in: " .. dtext[3] .. dtext[4]:sub(1,1):lower(), 4)
            else
                local departs = ""
                for item in pairs(dtext) do
                    departs = departs .. dtext[item] .. " "
                end
                center(departs:sub(1,-2), 4)
            end
        else
            monitor.setTextColor(colors.lime)
            center("No schedule found",3)
        end
    end
    if not station.isTrainPresent() or h > 4 then
        monitor.setTextColor(colors.lightBlue)
        
        local startLine = 2
        if station.isTrainPresent() then startLine = 6 end
    
        monitor.setCursorPos(1,startLine)
        monitor.write("ETA   Train")
    
        monitor.setCursorPos(math.ceil(w/2)+3,startLine)
        monitor.write("Destination")
        local pos = startLine-1
        
        for i = 2,h+2-startLine do
            local p = math.ceil(w/2)+3
            monitor.setCursorPos(1,pos+i)
            
            eta = string.sub(source.getLine(i),1,5):gsub("~",">10m")
            train = string.sub(source.getLine(i),4,-1)
            if eta:match("mi$") then
                eta = eta:sub(1,-2)
            end
            monitor.setTextColor(colors.magenta)
            monitor.write(eta:gsub("%s+", ""))
            monitor.setTextColor(colors.white)

            --train = train:sub(4,p)
            
            if train:match("^ ") then
                train = train:sub(2)
            end
            if train:match(" $") then
                train = train:sub(1,-2)
            end

            local know = false
            
            local known = fs.list("disk")
            for t in pairs(fs.list("disk")) do
                if train:find(known[t]) then
                    know = true
                    train = known[t]
                end
            end
            
            monitor.setCursorPos(7,pos+i)
            
            monitor.write(train)
            destination = "unknown"
            bfp = fs.combine("disk",train)
        
            if fs.exists(bfp) and eta:find("%.") == nil then
                file = fs.open(bfp, "r")
                if file then
                    destination = file.readLine()
                    file.close()
                end
            end
            
            if eta:find("%.") ~= nil then destination = "" end
            if know then
                monitor.setCursorPos(p-1,pos+i)
                monitor.setTextColor(colors.green)
                monitor.write(" " .. destination)
            end
        end
    end

    else
        term.setCursorPos(1,2)
        term.clearLine()
        term.write("No monitor found!")
    end
    sleep(2.5)
end
