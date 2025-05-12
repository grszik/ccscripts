local drive = peripheral.wrap("right")
local path = drive.getMountPath()

local monitor = peripheral.wrap("top")
monitor.clear()

local funs = {}
local x = {}

function encrypt(str)
    local count = 0
    for i=1,str:len() do
        count = count + str:sub(i,i):byte()
    end
    return count
end
function check(user, pass)
    local folder = fs.combine(path,user)
    if not fs.exists(folder) and user:len() > 2 and folder ~= path then return false end
    local file = fs.open(fs.combine(folder,"password"),"r").readLine()
    if file == pass return true
    else return false end
end
function register(user, pass)
    local folder = fs.combine(path,user)
    if fs.exists(folder) or user:len() > 2 or folder ~= path then return false end
    local file = fs.open(fs.combine(folder,"password"),"w")
    file.write(encrypt(pass))
end
        
function button(text,color,fun,line)
    if funs[line] == nil then 
        funs[line] = {} 
        x[line] = {} 
    end
    local w,h = monitor.getSize()
    startX = x[line]
    monitor.setTextColor(color)
    monitor.setCursorPos(x[line],h-line+1)
    monitor.write(text)
    x[line] = x[line] + string.len(text) + 2
    endX = x[line]
    for i=startX,endX do
        funs[line][i] = fun
    end
end

term.write(encrypt("banana")
