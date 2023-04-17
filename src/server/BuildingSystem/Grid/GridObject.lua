local GridObject = {}
GridObject.__index = GridObject

function GridObject.new(xPos: number, zPos: number)
    return setmetatable({["xPos"] = xPos, ["zPos"] = zPos, ["isWalkable"] = true, ["isOccupied"] = false, ["main"] = 0}, GridObject)
end

function GridObject.isEmpty(self): boolean
    return self.main == 0
end

return GridObject