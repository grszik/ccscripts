local drive = peripheral.wrap("right")
local path = drive.getMountPath()

local monitor = peripheral.wrap("top")
monitor.clear()

local modem = peripheral.wrap("front")
local port = 9100
modem.open(port)

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
    if not fs.exists(folder) or user:len() < 2 or folder == path then return false end
    local file = fs.open(fs.combine(folder,"password"),"r").readLine()
    if file == pass then
        return true
    else 
        return false
    end
end
function exists(user)
    local folder = fs.combine(path,user)
    return fs.exists(folder) and user:len() > 2 and folder ~= path
end
function register(user, pass)
    local folder = fs.combine(path,user)
    if fs.exists(folder) or user:len() > 2 or folder ~= path then return false end
    local file = fs.open(fs.combine(folder,"password"),"w")
    file.write(encrypt(pass))
    fs.makeDir(fs.combine(folder,"got"))
    fs.makeDir(fs.combine(folder,"sent"))
end

function send(user,pass,receiver,res, message)
    if not check(user,pass) then 
        modem.transmit(res,port,"no-permission")
    elseif not exists(receiver) then
        modem.transmit(res,port,"unknown-receiver")
    elseif message:len() < 1 then
        modem.transmit(res,port,"no-message")
    end

    local rdirf = fs.combine(path,user,"sent",os.date())
    local sdirf = fs.combine(path,receiver,"got",os.date())
    
    local rfile = fs.open(rdirf,"w")
    rfile.write("To: " .. receiver .. "\nAt (GMT): " .. os.date() .. "Message:\n" .. message)
    local sfile = fs.open(sdirf,"w")
    sfile.write("From: " .. user .. "\nAt (GMT): " .. os.date() .. "Message:\n" .. message)
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
    lines[#lines+1] = text
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
        for p in message:gmatch("([^%-]+)") do table.insert(params, p) end
        local user = params[2]
        mwrite("u: " .. user)
        local pass = params[3]
        mwrite("p: " .. pass)

        local worked = register(user,pass)
        modem.transmit(replyChannel,channel,worked)
    elseif message:match("^send-") then
        local params = {}
        for p in message:gmatch("([^%-]+)") do table.insert(params, p) end
        local user = params[2]
        local pass = params[3]
        local to = params[4]
        local length = 8+user:len()+pass:len()+to:len()
        local data = message:sub(data,-1)
        mwrite(("User %s is trying to message %s."):format(user,to))

        send(user,pess,to,replyChannel,data)
    end
    mwrite(("Message: %s"):format(
        tostring(message)
    ))
end
