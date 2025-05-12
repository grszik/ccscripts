local drive = peripheral.wrap("right")
local path = drive.getMountPath()

local monitor = peripheral.wrap("top")
monitor.clear()

local modem = peripheral.wrap("front")
modem.open(9100)

local funs = {}
local x = {}

-- https://www.reddit.com/r/lua/comments/1ezn10b/luas_missing_switch_statement/
local function switch(x, cases)
  local match = cases[x] or cases.default or function() end

  return match()
end


function encrypt(str)
    local count = 0
    local num = ""
    for i=1,str:len() do
        local n = str:sub(i,i):byte()
        count = count + n
        num = num .. tostring(n)
    end
    return count*tonumber(num)
end
function check(user, pass)
    local folder = fs.combine(path,user)
    if not fs.exists(folder) and user:len() > 2 and folder ~= path then return false end
    local file = fs.open(fs.combine(folder,"password"),"r").readLine()
    if file == pass then
        return true
    else 
        return false
    end
end
function register(user, pass)
    local folder = fs.combine(path,user)
    if fs.exists(folder) or user:len() > 2 or folder ~= path then return false end
    local file = fs.open(fs.combine(folder,"password"),"w")
    file.write(encrypt(pass))
    fs.makeDir(fs.combine(folder,"got"))
    fs.makeDir(fs.combine(folder,"sent"))
end

function send(user,pass,receiver)
    if not check(user,pass) then return false end
    return true
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


while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    if message:match("^register-") then
        local user = message:gmatch("%-")[1]
        term.write(user)
    end
    print(("Message received on side %s on channel %d (reply to %d) from %f blocks away with message %s"):format(
        side, channel, replyChannel, distance, tostring(message)
    ))
end
