local GridObjectTypes = require(script.Parent:WaitForChild("GridObjectTypes"))

local GridObject = {}
GridObject.__index = GridObject



function GridObject.new(xPos: number, zPos: number)
    local self = setmetatable({["xPos"] = xPos, ["zPos"] = zPos, ["isWalkable"] = true, ["isOccupied"] = false, ["tile"] = {}}, GridObject)
    for name, i  in GridObjectTypes do
        print(name, i)
        self.tile[i] = {groundValue = 0, value = 0}
    end
    return self
end

function GridObject.isEmpty(self, gridObjectType: number): boolean
    return self.tile[gridObjectType].value == 0
end

return GridObject