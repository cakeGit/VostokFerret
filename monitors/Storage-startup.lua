require("src/Utils")

print("Storage monitor starting up")

print("Searching for target monitor")
Monitor = peripheral.wrap("monitor_9")
GraphMonitor = peripheral.wrap("monitor_8")
if Monitor == nil or GraphMonitor == nil then
    error("Missing monitor on 'monitor_8' or 'monitor_9' on net")
end

require("src/monitors/MonitorUtil")

Monitor.setTextScale(0.5)
Monitor.clear()
Monitor.setCursorPos(1, 1)

Monitor.setPaletteColor(colors.red, 0xEF476F)
Monitor.setPaletteColor(colors.yellow, 0xFFD166)
Monitor.setPaletteColor(colors.lightBlue, 0xb21e11)
Monitor.setPaletteColor(colors.blue, 0x99160f)

GraphMonitor.setTextScale(0.5)
GraphMonitor.clear()
GraphMonitor.setCursorPos(1, 1)

GraphMonitor.setPaletteColor(colors.red, 0xEF476F)
GraphMonitor.setPaletteColor(colors.yellow, 0xFFD166)
GraphMonitor.setPaletteColor(colors.lightBlue, 0xb21e11)
GraphMonitor.setPaletteColor(colors.blue, 0x99160f)

PRINTER = function (text)
    Monitor.write(text)
    Monitor.setCursorPos(1, ({Monitor.getCursorPos()})[2] + 1)
end
printToAll("Connected to monitor")

printToAll("Searching for vaults")
local function isVault(name)
    return startsWith(name, "create:item_vault")
end

local function searchForVaults()
    local avaliableNames = peripheral.getNames()
    local vaults = {}

    for index, name in ipairs(avaliableNames) do
        if isVault(name) then
            table.insert(vaults, name)
        end
    end

    return vaults
end

local function connectToPeripherals(names)
    local peripherals = {}
    for index, name in ipairs(names) do
        peripherals[index] = peripheral.wrap(name)
    end
    return peripherals
end

local vaults = searchForVaults()
printToAll("Found " .. #vaults .. " vaults")
vaults = connectToPeripherals(vaults)
printToAll("Connected to vaults")

printToAll("Running main")

local itemsToDisplay = {}
local itemsSumCount = 0
local lastItemsToDisplay = {}
local lastItemsToDisplayStack = {}
local lastItemUpdate = 0
local itemUpdateInterval = 5

local rowCount = 4
local rowWidth = 39
local rowPad = 2

local graphWidth, graphHeight = GraphMonitor.getSize()
local graphWidthPadding = 6
local itemCountGraph = {}

local function getNameForDisplay(name)
    name = splitFirst(name, ":", 2)[2]
    local result = ""
    local lastWasSpace = true
    for c in name:gmatch"." do
        if (lastWasSpace) then
            c = string.upper(c)
            lastWasSpace = false
        end
        if (c == "_") then
            c = " "
            lastWasSpace = true
        end
        result = result .. c
    end
    return result
end

local function getItemChangeOfId(name)
    local last = lastItemsToDisplay[name]
    local now = itemsToDisplay[name]
    if (last == nil) then
        last = 0
    end
    if (now == nil) then
        now = 0
    end
    return now - last
end

local function getItemTrendOfId(name)
    if #lastItemsToDisplayStack == 0 then
        return 0
    end

    local last = lastItemsToDisplayStack[1][name]
    local now = itemsToDisplay[name]
    if (last == nil) then
        last = 0
    end
    if (now == nil) then
        now = 0
    end
    return now - last
end

local function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

local function secondsToTimeString(seconds)
    local result = ""
    if seconds > 60 then
        result = result .. math.floor(seconds / 60) .. " minutes and "
    end
    result = result .. (seconds % 60) .. " seconds"
    return result
end

local function drawItemCountGraphMonitor()
    GraphMonitor.setCursorPos(1, 1)

    GraphMonitor.setBackgroundColor(colors.black)
    GraphMonitor.setTextColor(colors.gray)
    GraphMonitor.write("STORAGE - Central monitor item count graph, showing last " .. secondsToTimeString(((#itemCountGraph) * itemUpdateInterval)) .. " of data")

    local graphAverage = 0
    local graphCount = 0
    for _, v in ipairs(itemCountGraph) do
        graphAverage = graphAverage + v
        graphCount = graphCount + 1
    end
    graphAverage = graphAverage / graphCount
    local range = 1
    for _, v in ipairs(itemCountGraph) do
        range = math.max(range, math.abs(v - graphAverage))
    end
    range = range * 1.2

    local graphHeights = {}
    for index, value in ipairs(itemCountGraph) do
        graphHeights[index] = (math.ceil((graphHeight - 2) * ((range + value - graphAverage) / (range * 2))))
    end

    for i = 1, graphHeight-1, 1 do
        GraphMonitor.setCursorPos(1, i + 1)
        local y = graphHeight - (i+1)
        local x = 1
        for index, value in ipairs(graphHeights) do
            local graphY = value
            GraphMonitor.setBackgroundColor(colors.black)
            if (y < graphY) then
                GraphMonitor.setBackgroundColor(colors.lightBlue)
            elseif (graphY == y) then
                GraphMonitor.setTextColor(colors.lightBlue)
                GraphMonitor.setBackgroundColor(colors.blue)
            end
            GraphMonitor.write(" ")
            GraphMonitor.setBackgroundColor(colors.black)
            x = x + 1
        end
        
        GraphMonitor.setBackgroundColor(colors.black)
        GraphMonitor.write(string.rep(" ", graphWidth - x))
    end
    GraphMonitor.setBackgroundColor(colors.lightBlue)
    GraphMonitor.setTextColor(colors.black)
    
    GraphMonitor.setCursorPos(graphWidth - graphWidthPadding, 2)
    GraphMonitor.write(">" .. math.floor(graphAverage + range))
    GraphMonitor.setCursorPos(graphWidth - graphWidthPadding, graphHeight)
    GraphMonitor.write(">" .. math.ceil(graphAverage - range))
    GraphMonitor.setBackgroundColor(colors.white)
    GraphMonitor.setCursorPos(graphWidth - graphWidthPadding, (graphHeight - 1) -
        ((graphHeight - 2) * ((range + itemsSumCount - graphAverage) / (range * 2)))
    )
    GraphMonitor.write(">" .. itemsSumCount)
    GraphMonitor.setBackgroundColor(colors.black)
    GraphMonitor.setTextColor(colors.white)
end

local function redraw()
    Monitor.clear()
    Monitor.setCursorPos(1, 1)
    Style("black", "gray")
    Monitor.write("STORAGE - Central monitor " .. tablelength(itemsToDisplay) .. " Items, " .. itemsSumCount .. " Total, Next refresh: ")

    local timeToRefresh = math.floor(itemUpdateInterval - (os.clock()- lastItemUpdate));
    if (timeToRefresh == 0) then
        Style("lime", "black")
    end
    Monitor.write(timeToRefresh)
    ResetStyle()

    Style("gray", "black")
    for i = 1, rowCount, 1 do
        Monitor.setCursorPos(1 + (rowWidth + rowPad) * (i - 1), 2)
        WriteFullLine("ITEM ID/NAME          :NUMBER:CHNG:TREND")
    end
    ResetStyle()

    local y = 3
    local x = 1
    local stortedItemsToDisplay = {}
    for n in pairs(itemsToDisplay) do table.insert(stortedItemsToDisplay, n) end
    table.sort(stortedItemsToDisplay, function (a, b)
        return itemsToDisplay[a] > itemsToDisplay[b]
    end)

    for i, name in pairs(stortedItemsToDisplay) do
        local monitorX = 1 + (rowWidth + rowPad) * (x - 1)

        local count = itemsToDisplay[name]
        Monitor.setCursorPos(monitorX, y)
        Style("black", (startsWith(name, "create:") and "lightBlue" or "white"))
        WriteFixedWidth(getNameForDisplay(name), 22)

        ResetStyle()
        Monitor.write(" ")

        Style("black", ((count < 250) and "gray" or "white"))
        WriteFixedWidth(count, 6)
        ResetStyle()

        Monitor.write(" ")

        local change = getItemChangeOfId(name)
        Style(((change < 0) and "red" or ((change > 0) and "lime" or "black")), ((change == 0) and "gray" or "black"))
        WriteFixedWidth(change, 4)
        ResetStyle()

        Monitor.write(" ")

        local trend = getItemTrendOfId(name)
        Style(((trend < 0) and "red" or ((trend > 0) and "lime" or "black")), ((trend == 0) and "gray" or "black"))
        WriteFixedWidth(trend, 5)
        ResetStyle()

        x = x + 1
        if (x == rowCount + 1) then
            y = y + 1
            x = 1
        end
    end

    drawItemCountGraphMonitor()
end
function table.shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end
local isFirstTick = true
local function collectItemsIfOutdated()
    if os.clock() - lastItemUpdate > itemUpdateInterval or isFirstTick then
        local allItems = {}
        itemsSumCount = 0
        for _, vault in ipairs(vaults) do
            for _, item in pairs(vault.list()) do
                if (allItems[item.name] == nil) then
                    allItems[item.name] = 0
                end
                allItems[item.name] = allItems[item.name] + item.count
                itemsSumCount = itemsSumCount + item.count
            end
        end
        table.insert(itemCountGraph, itemsSumCount)
        if #itemCountGraph > (graphWidth-(graphWidthPadding + 1)) then
            table.remove(itemCountGraph, 0)
        end
        -- local finalItemsToDisplay = {}
        -- for name, count in pairs(allItems) do
        --     finalItemsToDisplay[name] = count
        --     -- if (count > 5) then
        --     -- end
        -- end
        table.insert(lastItemsToDisplayStack, allItems)
        if #lastItemsToDisplayStack > 30 then
            table.remove(lastItemsToDisplayStack, 0)
        end

        lastItemsToDisplay = itemsToDisplay
        itemsToDisplay = allItems
        lastItemUpdate = os.clock()
    end
end

local function onTick()
    TickMonitorUtil()
    collectItemsIfOutdated()
    redraw()
    isFirstTick = false
end

local lastClockId = 0
local function ticker()
    lastClockId = os.startTimer(0.25)
    while true do
        local event = {os.pullEvent()}
        if event[1] == "timer" and event[2] == lastClockId then
            onTick()

            lastClockId = os.startTimer(0.25)
        end
    end

end

PRINTER = function() end
parallel.waitForAll(ticker)