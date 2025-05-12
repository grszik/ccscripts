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
    if exists(user) then return false end
    local folder = fs.combine(path,user)
    local file = fs.open(fs.combine(folder,"password"),"r").readLine()
    if file == tostring(encrypt(pass)) then
        return true
    elseif file == pass then
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
    mwrite("1")
    mwrite(fs.exists(folder) or user:len() < 2)
    if fs.exists(folder) or user:len() < 2 or folder == path then return false end
    mwrite("2")
    local file = fs.open(fs.combine(folder,"password"),"w")
    file.write(encrypt(pass))
    fs.makeDir(fs.combine(folder,"got"))
    fs.makeDir(fs.combine(folder,"sent"))
end

function send(user,pass,receiver,res, message)
    if not check(user,pass) then 
        modem.transmit(res,port,"no-permission")
        return
    elseif not exists(receiver) then
        modem.transmit(res,port,"unknown-receiver")
        return
    elseif message:len() < 1 then
        modem.transmit(res,port,"no-message")
        return
    end

    local rdirf = fs.combine(path,user,"sent",os.date())
    local sdirf = fs.combine(path,receiver,"got",os.date())
    
    local rfile = fs.open(rdirf,"w")
    rfile.write("To: " .. receiver .. "\nAt (GMT): " .. os.date() .. "\nMessage:\n" .. message)
    local sfile = fs.open(sdirf,"w")
    sfile.write("From: " .. user .. "\nAt (GMT): " .. os.date() .. "\nMessage:\n" .. message)
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
grosik ~/ccscripts  vim email.lua 
grosik ~/ccscripts  cat email.lua 
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

-- Weird, but working encrypting function
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
-- Checking if the login and password are correct
function check(user, pass)
    if exists(user) then return false end
    local folder = fs.combine(path,user)
    local file = fs.open(fs.combine(folder,"password"),"r").readLine()
    if file == tostring(encrypt(pass)) then
        return true
    elseif file == pass then
        return true
    else
        return false
    end
end
-- Checking if a user exists
function exists(user)
    local folder = fs.combine(path,user)
    return fs.exists(folder) and user:len() > 2 and folder ~= path
end

-- Making a new account
function register(user, pass)
    local folder = fs.combine(path,user)
    if fs.exists(folder) or user:len() < 2 or folder == path then return false end
    local file = fs.open(fs.combine(folder,"password"),"w")
    file.write(encrypt(pass))
    fs.makeDir(fs.combine(folder,"got"))
    fs.makeDir(fs.combine(folder,"sent"))
end

-- Sending messages
function send(user,pass,receiver,res, message)
    if not check(user,pass) then 
        modem.transmit(res,port,"no-permission")
        return
    elseif not exists(receiver) then
        modem.transmit(res,port,"unknown-receiver")
        return
    elseif message:len() < 1 then
        modem.transmit(res,port,"no-message")
        return
    end

    local rdirf = fs.combine(path,user,"sent",os.date())
    local sdirf = fs.combine(path,receiver,"got",os.date())
    
    local rfile = fs.open(rdirf,"w")
    rfile.write("To: " .. receiver .. "\nAt (GMT): " .. os.date() .. "\nMessage:\n" .. message)
    local sfile = fs.open(sdirf,"w")
    sfile.write("From: " .. user .. "\nAt (GMT): " .. os.date() .. "\nMessage:\n" .. message)
    modem.transmit(res,port,"sent")
end

-- List of messages
function list(user,pass,res)
    if not check(user,pass) then
        modem.transmit(res,port,"no-permission")
        return
    end

    local folder = fs.combine(path,user,"got")
    modem.transmit(res,port,os.list(folder))
end

-- Get a message
function get(user, pass, res, id)
    if not check(user,pass) then
        modem.transmit(res,port,"no-permission")
    end

    local filePath = fs.combine(path,user,"got",id)
    local file = fs.open(filePath, "r").readAll()
    modem.transmit(res,port,file)
end

local lines = {}
-- Write the lines variable to the monitor
function rewrite()
  for i=1,#lines do
    monitor.setCursorPos(1,i+2)
    monitor.clearLine()
    monitor.write(lines[i])
  end
end
-- Write to the lines variable
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

-- API
term.write("Initialized listener.")
while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    local params = {}
    for p in message:gmatch("%-") do table.insert(params, p) end

    if message:match("^register-") then
        if #params < 3 then return end

        local user = params[2]
        mwrite("new u: " .. user)
        local pass = params[3]

        local worked = register(user,pass)
        modem.transmit(replyChannel,channel,worked)
    elseif message:match("^send-") then
        if #params < 4 then return end
        
        local user = params[2]
        local pass = params[3]
        local to = params[4]
        local length = 8+user:len()+pass:len()+to:len()
        local data = message:sub(length,-1)
        mwrite(("User %s is trying to message %s."):format(user,to))

        send(user,pass,to,replyChannel,data)
    elseif message:match("^check-") then
        if #params < 3 then return end
        
        local user = params[2]
        local pass = params[3]

        local worked = check(user,pass)
        modem.transmit(replyChannel,channel,worked)
    elseif message:match("^list-") then
        if #params < 4 then return end
        
        local user = params[2]
        local pass = params[3]
        
        local files = list(user,pass,replyChannel)
    elseif message:match("^get-") then
        if #params < 4 then return end

        local user = params[2]
        local pass = params[3]
        local id = params[4]
        
        local files = get(user,pass,replyChannel,id)
    end
    mwrite(("Message: %s"):format(
        tostring(message)
    ))
end
