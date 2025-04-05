local Control = {}
Control.__index = Control

function Control.new(shipId)
    local self = setmetatable({}, Control)
    self.ShipId = shipId
    return self
end

function Control.runLoop(self)
    local shipId = self.ShipId
    
end

return Control