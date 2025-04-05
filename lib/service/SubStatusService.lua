local SubStatus = {}
SubStatus.__index = SubStatus

function SubStatus:nextOrder()
    self.lastSentOrder = self.lastSentOrder + 1
    return self.lastSentOrder
end

function SubStatus.new(substatusId, substatusLabel)
    local self = setmetatable({}, SubStatus)
    self.SubstatusId = substatusId
    self.SubstatusLablel = substatusLabel
    self.lastSentOrder = 0
    SendRawToServer({
        type = "service_call",
        endpoint = "substatus",
        action = "update",
        substatus_id = substatusId,
        substatus_label = self.SubstatusLablel,
        substatus = "none",
        substatus_style = "none",
        order = self:nextOrder()
    })
    return self
end


function SubStatus:update(substatus, substatusStyle)
    if substatusStyle == nil then
        substatusStyle = "missing"
    end
    SendRawToServer({
        type = "service_call",
        endpoint = "substatus",
        action = "update",
        substatus_id = self.SubstatusId,
        substatus_label = self.SubstatusLablel,
        substatus = substatus,
        substatus_style = substatusStyle,
        order = self:nextOrder()
    })
end

return SubStatus