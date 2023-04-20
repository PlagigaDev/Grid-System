local changeRotation = require(script.Parent:WaitForChild("ChangeRotation"))

return function(grid, xPos, zPos, object, rotation)
    local width = object:GetAttribute("width")-1
    local height = object:GetAttribute("height")-1

    local width, height = changeRotation(width, height, rotation)
    
    local widthDir = width/math.abs(width)
    local heightDir = height/math.abs(height)
    
    for x = xPos, xPos+width, widthDir  do
        for z = zPos, zPos+height, heightDir do
            if not grid:isValid(x,z) then return false end
            if not grid:getValueXZ(x, z):isEmpty(object:GetAttribute("objectType")) then return false end
        end
    end
    return true
end