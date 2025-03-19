local scrollTick = 0

local monitorWidth, monitorHeight = Monitor.getSize()

function ScrollOrPadToWidth(text, width)
    if (text == nil) then
        return "?" .. string.rep(" ", width - 1)
    end
    local textLength = string.len(text)
    if textLength > width then
        local scrollTarget = text .. " " .. text .. "  "
        local animation = (scrollTick % (textLength)) + 1

        return string.sub(scrollTarget, animation, width + animation - 1)
    end
    return text .. string.rep(" ", width - textLength)
end

function TickMonitorUtil()
    scrollTick = scrollTick + 1
end

function WriteFullLine(string)
    Monitor.write(string .. string.rep(" ", monitorWidth - string.len(string)))
end

function WriteFixedWidth(string, width)
    Monitor.write(ScrollOrPadToWidth(string, width))
end

function Style(colorBg, colorFg)
    Monitor.setBackgroundColor(colors[colorBg])
    Monitor.setTextColor(colors[colorFg])
end
function ResetStyle()
    Style("black", "white")
end