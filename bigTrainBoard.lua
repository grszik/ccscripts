local monitor = peripheral.wrap("monitor_196")
local source = peripheral.find("create_target")
local drive = peripheral.find("drive")

function center(text,line)
    local w,h = monitor.getSize()
    if w ~= nil then
    local len = text:len()
    local pos = math.ceil(w/2-len/2)
    monitor.setCursorPos(pos+1,line)
    monitor.write(text)
    end
end
local runTime = 0

while true do
    runTime = runTime + 1
    
    monitor.clear()
    monitor.setTextColor(colors.yellow)
    center("Welcome to CLR!",1)
    local w,h = monitor.getSize()
    
    if w and h then
        term.setCursorPos(1,2)
        term.clearLine()
    
        source.setWidth(125)
        monitor.setTextColor(colors.lightBlue)
        
        local startLine = 2
    
        monitor.setCursorPos(1,startLine)
        monitor.write("ETA   Train")
    
        monitor.setCursorPos(w-("Destination"):len()-1,startLine)
        monitor.write("Destination")
        local pos = startLine-1
        
        for j = 1,(h+2-startLine)/2 do
            local i = j*2
            monitor.setCursorPos(1,pos+i)
            
            eta = string.sub(source.getLine(j+1),1,5):gsub("~",">10m")
            train = string.sub(source.getLine(j+1),4,-1)
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
            bfp = fs.combine("disk","destination",train)
        
            if fs.exists(bfp) and eta:find("%.") == nil then
                file = fs.open(bfp, "r")
                if file then
                    destination = file.readLine()
                    file.close()
                end
            end
            
            if eta:find("%.") ~= nil then destination = "" end

            monitor.setCursorPos(w-1-destination:len(),pos+i)
            monitor.setTextColor(colors.green)
            monitor.write(" " .. destination)

            vdp = fs.combine("disk",train)
            local via = {"Directly"}
        
            if fs.exists(vdp) and eta:find("%.") == nil then
                file = fs.open(vdp, "r")
                if file then
                    via = file.readLine()
                    file.close()
                end
            end
            monitor.setCursorPos(7,pos+i+1)
            monitor.write(viaParts[(runTime%#viaParts)+1])
            
        end
    else
        term.setCursorPos(1,2)
        term.clearLine()
        term.write("No monitor found!")
    end
    sleep(2.5)
end
