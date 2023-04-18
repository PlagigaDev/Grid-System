local PhysicsService = game:GetService("PhysicsService")
local Workspace = game:GetService("Workspace")
local Grid = {}
Grid.__index = Grid

--To have a Baseplane which can be hit by a ray
local function createGroundPart(self)
    local groundPart = Instance.new("Part")
    groundPart.CanCollide = false
    groundPart.CanQuery = true
    groundPart.Anchored = true
    
    if not PhysicsService:IsCollisionGroupRegistered("Ground") then
        PhysicsService:RegisterCollisionGroup("Ground")
    end
    groundPart.CollisionGroup = "Ground"
    
    --Position and size to exactly fill the whole Grid
    local x = self.width * self.cellSize
    local z = self.height * self.cellSize
    
    groundPart.Size = Vector3.new(x,0.1,z)
    
    local Position = self:getWorldPositionByXZ(self.width/2,self.height/2)
    groundPart.CFrame = Position * CFrame.new(0,-groundPart.Size.Y/2,0)
    
    --To keep things organized I have put it in a seperate folder
    if Workspace:FindFirstChild("Grounds") == nil then
        local Grounds = Instance.new("Folder")
        Grounds.Name = "Grounds"
        Grounds.Parent = Workspace
    end
    
    groundPart.Transparency = 1
    groundPart.Parent = Workspace.Grounds
    return groundPart
end

--If you want to see the grid, for Debuging Purposes only
local function spawnDebugParts(self)
    for x = 0, self.width-1 do
        for z = 0, self.height-1 do
            local part = Instance.new("Part")
            part.Anchored = true
            part.CanCollide = false
            part.Size = Vector3.new(self.cellSize,.2,self.cellSize)
            part.CFrame = self:getWorldPositionByXZ(x + .5, z + .5)
            part.TopSurface = Enum.SurfaceType.Smooth
            part.BottomSurface = Enum.SurfaceType.Smooth
            local surface = Instance.new("SurfaceGui",part)
            local text = Instance.new("TextLabel",surface)
            surface.Face = Enum.NormalId.Top
            text.Rotation = 90
            text.TextScaled = true
            text.Size = UDim2.fromScale(1,1)
            text.Text = string.format("[%s|%s]",x,z)
            text.BackgroundTransparency = 1
            part.Parent = Workspace
        end
    end
end

function Grid.getWorldPositionByXZ(self: {}, x: number, z: number): CFrame
    local pivot = self.pivot
    local xWorld = self.pivot.RightVector * self.cellSize * x
    local zWorld = self.pivot.LookVector * self.cellSize * z
    return (CFrame.new(xWorld+zWorld) * pivot.Rotation) + pivot.Position
end

function Grid.getXZByWorldPosition(self, worldPosition: Vector3): number
    -- convert the world position to a local position relative to the pivot point
    local localPosition = self.pivot:PointToObjectSpace(worldPosition)

    local xGrid = math.floor(localPosition.X / self.cellSize)
    local zGrid = math.floor(-localPosition.Z / self.cellSize)

    --Keep the XZ Values in the Grid
    xGrid = math.clamp(xGrid,0,self.width-1)
    zGrid = math.clamp(zGrid,0,self.height-1)

    return xGrid, zGrid
end

function Grid.new(width: number, height: number, cellSize, pivot: CFrame): {}
    local self = setmetatable({["width"] = width, ["height"] = height, ["cellSize"] = cellSize, ["pivot"] = pivot, ["gridArray"] = {}}, Grid)
    self.groundPart = createGroundPart(self)
    --spawnDebugParts(self)
    for i = 1, width do
        self.gridArray[i] = {}
        for j = 1, height do
            self.gridArray[i][j] = 0
        end
    end
    return self
end

function Grid.from(grid: {}): {}
    return setmetatable(grid, Grid)
end

function Grid.fill(self, value: any)
    self:forEach(function(x, z)
        self.gridArray[x][z] = value
    end)
end

function Grid.forEach(self, func: (gridPosition))
    for x = 1, self.width do
        for z = 1, self.height do
            func(x, z)
        end
    end
end

function Grid.isValid(self, x: number, z: number): boolean
    return (x < self.width and z < self.height)
end

function Grid.setValueXZ(self, x: number, z: number, value: any)
    if not self:isValid(x, z) then return end
    self.gridArray[x+1][z+1] = value
end

function Grid.setValuePosition(self, worldPosition: Vector3, value: number)
    local x, z = self:getXZByWorldPosition(worldPosition)
    self:setValueXZ(x, z, value)
end

function Grid.getValueXZ(self, x: number, z: number): any
    if not self:isValid(x, z) then return end
    return self.gridArray[x+1][z+1]
end

function Grid.getValuePosition(self, worldPosition: Vector3): any
    local x, z = self:getXZByWorldPosition(worldPosition)
    return self:getValueXZ(x, z)
end

return Grid