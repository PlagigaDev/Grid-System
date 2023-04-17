local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local GridFolder = script.Parent:WaitForChild("Grid")
local Grid = require(GridFolder:WaitForChild("Grid"))
local GridObject = require(GridFolder:WaitForChild("GridObject"))

local Placement = ServerStorage:WaitForChild("Placement")

local Grids = {}

PhysicsService:RegisterCollisionGroup("Ground")

function isValidPlacement(grid, xPos, zPos, object)
    local width = object:GetAttribute("width")
    local height = object:GetAttribute("height")
    for x = xPos, xPos+width-1 do
        for z = zPos, zPos+height-1 do
            if not grid:getValueXZ(x, z):isEmpty(object:GetAttribute("objectType")) then return false end
        end
    end
    return true
end

function setGridValues(grid, xPos, zPos, object)
    local width = object:GetAttribute("width")
    local height = object:GetAttribute("height")
    for x = xPos, xPos+width-1 do
        for z = zPos, zPos+height-1 do
           grid:getValueXZ(x, z).tile[object:GetAttribute("objectType")].value = object.Name
        end
    end
end

function placeObject(grid, xPos: number, zPos: number, object: Folder)
    setGridValues(grid, xPos, zPos, object)
    local Visual = ReplicatedStorage.Placement:FindFirstChild(object.name)
    local clone = Visual:Clone()
    clone:PivotTo(grid:getWorldPositionByXZ(xPos, zPos))
    clone.Parent = Workspace
end

function getGrid(player: Player, floor: number): Grid
    return Grids[player.name][string.format("%s",floor)]
end

function getPlacementObject(objectName: string): Folder
    return Placement:FindFirstChild(objectName)
end

function requestPlacementXZ(grid, object: Folder, xPos: number, zPos: number): boolean
    if isValidPlacement(grid, xPos, zPos, object) then
        placeObject(grid, xPos, zPos, object)
        return true
    end
    return false
end

function requestPlacementPosition(player: Player, floor: number, objectName: string, position: Vector3): boolean
    local grid = getGrid(player,floor)
    local object = getPlacementObject(objectName)
    return requestPlacementXZ(grid, object, grid:getXZByWorldPosition(position))
end

function addPlayer(player: Player)
    Grids[player.Name] = {}
    Grids[player.Name]["0"] = Grid.new(50,50,4,CFrame.new() * Workspace.Pivot.CFrame)
    local grid = Grids[player.Name]["0"]
    for x = 0, grid.width-1 do
        for z = 0, grid.height-1 do
            grid:setValueXZ(x, z, GridObject.new(x, z))
        end
    end
end

for _, player in Players:GetPlayers() do
    addPlayer(player)
end

Players.PlayerAdded:Connect(addPlayer)


ReplicatedStorage.RemoteEvent.OnServerEvent:Connect(function(player, pos)
    if requestPlacementPosition(player, 0, "Drawer", pos) then
        print("haha")
    else
        print("nah")
    end
end)