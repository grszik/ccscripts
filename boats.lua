local station = peripheral.wrap("top")
local monitor = peripheral.wrap("monitor_198")
local source = peripheral.wrap("front")
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
    --if monitor ~= nil then 
        
    peripheral.wrap("left").setAnalogOutput("front",0)
    monitor.clear()
    monitor.setTextColor(colors.yellow)
    center("Welcome to CLR boat dock!",1)
    local w,h = monitor.getSize()
    
    if w == nil or h == nil then os.reboot() end
    
    source.setWidth(w)
    monitor.setTextColor(colors.lightBlue)
    if station.isTrainPresent() then
        center("Boat: " .. station.getTrainName(),2)
        if station.hasSchedule() then  
            if station.getTrainName():match("^CLR") then
                peripheral.wrap("left").setAnalogOutput("front",15)
            end
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
            destination = destination:gsub(" b%-"," "):gsub(" (%u)B",""):gsub(" Station", ""):gsub(" Docks",""):gsub(" Dock","")
            local bdp = fs.combine("disk",station.getTrainName())
            
            fs.open(bdp,"w").writeLine(destination)
            center("To: "..destination,3)    
            monitor.setTextColor(colors.white)
            local dtext = {}
            for w in source.getLine(1):gmatch("%S+") do table.insert(dtext, w) end
            if #dtext > 1 then center("Departs in: " .. dtext[3] .. dtext[4]:sub(1,1):lower(), 4) end
        else
            monitor.setTextColor(colors.lime)
            center("No schedule found",3)
        end
    else
        monitor.setCursorPos(1,2)
        monitor.write("ETA   Boat")
    
        monitor.setCursorPos(math.ceil(w/2)+3,2)
        monitor.write("Destination")
        
        for i = 2,4 do
            local p = math.ceil(w/2)+3
            monitor.setCursorPos(1,1+i)
            
            eta = string.sub(source.getLine(i),1,5):gsub("~",">10m")
            boat = string.sub(source.getLine(i),4,string.len(" CLR BRW [002] SB ")*(-1))
            
            if eta:match("mi$") then
                eta = eta:sub(1,-2)
            end
            monitor.setTextColor(colors.magenta)
            monitor.write(eta:gsub("%s+", ""))
            monitor.setTextColor(colors.white)

            boat = boat:sub(4,p)
            
            if boat:match("^ ") then
                boat = boat:sub(2)
            end
            if boat:match(" $") then
                boat = boat:sub(1,-2)
            end
            monitor.setCursorPos(7,1+i)
            
            monitor.write(boat)
            destination = "unknown"
            bfp = fs.combine("disk",boat)
        
            if fs.exists(bfp) and eta:find("%.") == nil then
                destination = fs.open(bfp, "r").readLine()
            end
            
            if eta:find("%.") ~= nil then destination = "" end
            
            monitor.setCursorPos(p,1+i)
            monitor.setTextColor(colors.green)
            monitor.write(destination)
        end
    end
    --end
    sleep(2.5)
end
