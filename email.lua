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
    return count/tonumber(num)
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
local lines = {}
function rewrite()
  for i=1,#lines do
    monitor.setCursorPos(1,i)
    monitor.clearLine()
    monitor.write(lines[i])
  end
end
function mwrite(text)
  local w,h = monitor.getSize()
  if #lines < h-5 then
    lines[#lines+1 = text
    monitor.setCursorPos(1,#lines)
    monitor.clearLine()
    monitor.write(text)
  else
    local tmp = {}
    for i=#lines,1 do
      tmp[i+1] = lines[i]
    end
    tmp[1] = text
    tmp[#tmp] = ""
    lines = tmp
  end
  rewrite()
end

while true do
    term.write("Initialized listener.")
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    if message:match("^register-") then
        local params = {}
        for p in message:gmatch("%-+") do table.insert(params, p) end
        local user = params[1]
        mwrite(user)
        --[[
        local pass = params[2]
        local good = register(user,pass)
        --]]
    end
    mwrite(("Message received on side %s on channel %d (reply to %d) from %f blocks away with message %s"):format(
        side, channel, replyChannel, distance, tostring(message)
    ))
end
