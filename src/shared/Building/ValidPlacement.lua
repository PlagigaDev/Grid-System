return function(grid, xPos, zPos, object)
    --print(grid)
    --print(getmetatable(grid))
    local width = object:GetAttribute("width")
    local height = object:GetAttribute("height")
    for x = xPos, xPos+width-1 do
        for z = zPos, zPos+height-1 do
            if not grid:getValueXZ(x, z):isEmpty(object:GetAttribute("objectType")) then return false end
        end
    end
    return true
end