Vector3 = require("src/lib/Vector")

local inputDeltaStreamName = "computer_" .. os.getComputerID() .. ".test_stream";

local currentTargetDelta = {x=0, y=0}

SendRawToServer({
    type = "service_call",
    endpoint = "data_stream",
    action = "set_format",
    format = {
        type = "input.vector2"
    },
    data_stream_name = inputDeltaStreamName,
})

SendRawToServer({
    type = "service_call",
    endpoint = "data_stream",
    action = "subscribe",
    data_stream_name = inputDeltaStreamName,
})

local sequencedGearshiftRollName = "Create_SequencedGearshift_0"
local sequencedGearshiftPitchName = "Create_SequencedGearshift_1"

local sequencedGearshiftRoll = peripheral.wrap(sequencedGearshiftRollName);
local sequencedGearshiftPitch = peripheral.wrap(sequencedGearshiftPitchName);

local currentRoll = 0;
local currentPitch = 0;

local function signum(x)
    if x > 0 then
        return 1
    elseif x < 0 then
        return -1
    else
        return 0
    end
end

local RPM = 32
local function getSecondsOfRPMForAngle(angle, rpm)
    local seconds = math.abs(angle) / (rpm * 6)
    return math.max(seconds * 20) / 20 + 2 / 20
end

local function tickControlSurfaces()
    local rollDelta = currentTargetDelta.y - currentRoll
    local pitchDelta = currentTargetDelta.x - currentPitch

    if rollDelta ~= 0 and pitchDelta ~= 0 then
        print("Moving to target delta: " .. currentTargetDelta.x .. ", " .. currentTargetDelta.y)
        sequencedGearshiftRoll.rotate(math.abs(rollDelta), signum(rollDelta))
        sequencedGearshiftPitch.rotate(math.abs(pitchDelta), signum(pitchDelta))
    
        currentRoll = currentRoll + rollDelta
        currentPitch = currentPitch + pitchDelta

        sleep(math.max(getSecondsOfRPMForAngle(math.abs(rollDelta), RPM), getSecondsOfRPMForAngle(math.abs(pitchDelta), RPM)))
    else
        rollDelta = math.max(rollDelta, -45)
    end
    sleep(0.1)
end

AddWebsocketHandlerOfType("data_stream_format", function (ignored) end)
AddWebsocketHandlerOfType("data_stream_data", function (data)
    currentTargetDelta = {
        x = math.floor(tonumber(data.entry.x) * 35 + 0.5),
        y = math.floor(tonumber(data.entry.y) * 45 + 0.5),
    }
end)

while true do
    tickControlSurfaces()
end