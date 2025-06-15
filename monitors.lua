local mons = {}
local this = {}

function clear()
    for mon in pairs(mons) do
        mons[mon].clear()
    end
end

function color(c)
    for mon in pairs(mons) do
        mons[mon].setTextColor(c)
    end
end

function pos(x,y)
    for mon in pairs(mons) do
        mons[mon].setCursorPos(x,y)
    end
end

function write(text)
    for mon in pairs(mons) do
        mons[mon].write(text)
    end
end

function centerPos(text,y)
    for mon in pairs(mons) do
        local w,h = mons[mon].getSize()
        local x = (w/2)-(text:len()/2)
        mons[mon].setCursorPos(x+1,y)
    end
end

function writeCenter(text,y)
    this.centerPos(text,y)
    this.write(text,y)
end

function writeBack(text,y)
    for mon in pairs(mons) do
        local w,h = mons[mon].getSize()
        mons[mon].setCursorPos(w-text:len(),y)
        mons[mon].write(text)
    end
end

function setup(monitors)
    for mon in pairs(monitors) do
        local m = peripheral.wrap(monitors[mon])
        while not m do
            sleep(1.25)
        end
        
        table.insert(mons, m)
    end
    
    this = {
      clear = clear, color = color,
      pos = pos, write = write,
      centerPos = centerPos,
      writeCenter = writeCenter, writeBack = writeBack,
      exist = true
    }
    return this
end

return setup
