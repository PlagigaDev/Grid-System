return function(width, height, rotation): number
    if rotation == 90 then
        return height, width
    elseif rotation == 180 then
        return -width, height
    elseif rotation == 270 then
        return -height, -width
    end
    return width, height
end