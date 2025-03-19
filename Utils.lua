--Legacy util of my old code
local host
local serverBuild

function isWebServerAlive()
    if host == nil then
        host = readAllFile("host.txt")
    end
    local pingRequest = http.get("https://" .. host .. "ping")
    if pingRequest == nil then
        printToAll("Failed to ping server")
        return false
    end
    return true
end

function getCurrentBuildNumber()
    if serverBuild == nil then
        serverBuild = tonumber(split(readAllFile("localBuild.txt"))[1])
    end
    return serverBuild
end

function printTermHeader(text)
    local width, height = term.getSize()
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.black)
    term.write(text .. string.rep(" ", width - string.len(text)))
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end

function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function splitFirst(inputstr, sep, limit)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    local i = 1
    local remaining = inputstr
    while i < limit do
        local start, stop = string.find(remaining, sep)
        if start == nil then
            break
        end
        table.insert(t, string.sub(remaining, 1, start - 1))
        remaining = string.sub(remaining, stop + 1)
        i = i + 1
    end
    table.insert(t, remaining)
    return t
end

function startsWith(String, Start)
    return string.sub(String, 1, string.len(Start))==Start
end

function getAndReadFromServer(path)
    if host == nil then
        host = readAllFile("host.txt")
    end
    local request = http.get("https://" .. host .. path)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.gray)
    print("(request sent to '" .. "https://" .. host .. path .. "')")
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

    local data = request.readAll();
    request.close();
    return data
end

function readAllFile(path)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.gray)
    print("(reading file '" .. path .. "')")
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

    local file = fs.open(path, "r")
    local data = file.readAll()
    file.close()
    return data
end

function writeAllFile(path, data)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.gray)
    print("(writing file '" .. path .. "')")
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

    local file = fs.open(path, "w")
    file.write(data)
    file.close()
end

function printTable(table)
    local isEmpty = true
    for index, value in pairs(table) do
        isEmpty = false
        printToAll(index .. " = " .. tostring(value) .. "")
    end
    if isEmpty then
        printToAll("Empty table")
    end
end

function printArray(table, indendation)
    if indendation == nil then
        indendation = ""
    end
    local isEmpty = true
    for index, value in ipairs(table) do
        isEmpty = false
        printToAll(indendation .. tostring(value))
    end
    if isEmpty then
        printToAll("Empty array")
    end
end

function printTableKeys(table)
    local isEmpty = true
    for index, value in pairs(table) do
        isEmpty = false
        printToAll(index)
    end
    if isEmpty then
        printToAll("None")
    end
end

function printToAll(...)
    if (PRINTER ~= nil) then
        for index, value in ipairs({...}) do
            PRINTER(value)
        end
    end
    print(table.unpack({...}))
end

function hslToRgb(h, s, l)
    local r, g, b
  
    if s == 0 then
      r, g, b = l, l, l
    else
      function hue2rgb(p, q, t)
        if t < 0   then t = t + 1 end
        if t > 1   then t = t - 1 end
        if t < 1/6 then return p + (q - p) * 6 * t end
        if t < 1/2 then return q end
        if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
        return p
      end
  
      local q
      if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
      local p = 2 * l - q
  
      r = hue2rgb(p, q, h + 1/3)
      g = hue2rgb(p, q, h)
      b = hue2rgb(p, q, h - 1/3)
    end
  
    return r, g, b
end

-- function wrapRemotePeripheral(modem, name)
--     local wrappedPeripheral = { name = name }
--     for index, value in ipairs(modem.getMethodsRemote(name)) do
--         wrappedPeripheral[value] = function (self, ...)
--             local args = { ... }
--             printTable(args)
--             modem.callRemote(self.name, value, table.unpack(args))
--         end
--     end

--     return wrappedPeripheral
-- end