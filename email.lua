local drive = peripheral.wrap("right")
local path = drive.getMountPath()

local monitor = peripheral.wrap("top")
monitor.clear()

function button(text,color,fun,line)
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
