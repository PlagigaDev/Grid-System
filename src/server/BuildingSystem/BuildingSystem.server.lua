local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local BuildingSystemsFolder = ReplicatedStorage:WaitForChild("Common"):WaitForChild("Building")

local GridFolder = BuildingSystemsFolder:WaitForChild("Grid")
local Grid = require(GridFolder:WaitForChild("Grid"))
local GridObject = require(GridFolder:WaitForChild("GridObject"))

local BuildingEvents = ReplicatedStorage:WaitForChild("BuildingEvents")
local PlacementEvent = BuildingEvents:WaitForChild("Placement")
local GridRequestEvent = BuildingEvents:WaitForChild("GridRequest")

local PlacementInfo = ReplicatedStorage:WaitForChild("PlacementInfo")

local isValidPlacement = require(BuildingSystemsFolder:WaitForChild("ValidPlacement"))

local Grids = {}

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
    return PlacementInfo:FindFirstChild(objectName)
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
    
    grid:forEach(function(x, z)
        grid.gridArray[x][z] = GridObject.new(x, z)
    end)
    print(grid)
end

for _, player in Players:GetPlayers() do
    addPlayer(player)
end

Players.PlayerAdded:Connect(addPlayer)


PlacementEvent.OnServerEvent:Connect(function(player, pos, objectName)
    if requestPlacementPosition(player, 0, objectName, pos) then
        GridRequestEvent:FireClient(player, getGrid(player, 0))
    end
end)

GridRequestEvent.OnServerEvent:Connect(function(player: Player, floor: number)
    GridRequestEvent:FireClient(player, getGrid(player, floor))
end)