-- vector.lua
-- A simple Vector3 implementation in Lua

local Vector3 = {}
Vector3.__index = Vector3

-- Constructor
function Vector3.new(x, y, z)
    local self = setmetatable({}, Vector3)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
    return self
end

-- Add two vectors
function Vector3:add(other)
    return Vector3.new(self.x + other.x, self.y + other.y, self.z + other.z)
end

-- Subtract two vectors
function Vector3:subtract(other)
    return Vector3.new(self.x - other.x, self.y - other.y, self.z - other.z)
end

-- Multiply vector by a scalar
function Vector3:scale(scalar)
    return Vector3.new(self.x * scalar, self.y * scalar, self.z * scalar)
end

-- Calculate the dot product of two vectors
function Vector3:dot(other)
    return self.x * other.x + self.y * other.y + self.z * other.z
end

-- Calculate the cross product of two vectors
function Vector3:cross(other)
    return Vector3.new(
        self.y * other.z - self.z * other.y,
        self.z * other.x - self.x * other.z,
        self.x * other.y - self.y * other.x
    )
end

-- Calculate the magnitude of the vector
function Vector3:magnitude()
    return math.sqrt(self.x^2 + self.y^2 + self.z^2)
end

-- Normalize the vector
function Vector3:normalize()
    local mag = self:magnitude()
    if mag == 0 then
        return Vector3.new(0, 0, 0)
    end
    return self:scale(1 / mag)
end

-- String representation of the vector
function Vector3:__tostring()
    return string.format("(%f, %f, %f)", self.x, self.y, self.z)
end

return Vector3