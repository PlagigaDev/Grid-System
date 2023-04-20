local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
local changeRotation = require(BuildingSystemsFolder:WaitForChild("ChangeRotation"))

local Grids = {}


function setGridValues(grid, xPos, zPos, object, rotation)
    local width = object:GetAttribute("width")-1
    local height = object:GetAttribute("height")-1

    local width, height = changeRotation(width, height, rotation)

    local widthDir = width/math.abs(width)
    local heightDir = height/math.abs(height)

    for x = xPos, xPos+width, widthDir  do
        for z = zPos, zPos+height, heightDir do
           grid:getValueXZ(x, z).tile[object:GetAttribute("objectType")].value = object.Name
        end
    end
end

function placeObject(grid, xPos: number, zPos: number, object: Folder, rotation: number)
    local Visual = ReplicatedStorage.Placement:FindFirstChild(object.name)
    local clone = Visual:Clone()
    local width = object:GetAttribute("width")-1
    local height = object:GetAttribute("height")-1

    width, height = changeRotation(width,height, rotation)

    clone:PivotTo(grid:getWorldPositionByXZ(xPos + (.5 * (width+1)), zPos + (.5 * (height+1))) * CFrame.Angles(0,math.rad(rotation), 0))
    clone.Parent = Workspace
end

function getGrid(player: Player, floor: number): Grid
    return Grids[player.name][string.format("%s",floor)]
end

function getPlacementObject(objectName: string): Folder
    return PlacementInfo:FindFirstChild(objectName)
end

function requestPlacementXZ(grid, object: Folder, rotation: number, xPos: number, zPos: number): boolean
    if isValidPlacement(grid, xPos, zPos, object, rotation) then
        setGridValues(grid, xPos, zPos, object, rotation)
        placeObject(grid, xPos, zPos, object, rotation)
        return true
    end
    return false
end

function requestPlacementPosition(player: Player, floor: number, objectName: string, position: Vector3, rotation: number): boolean
    local grid = getGrid(player,floor)
    local object = getPlacementObject(objectName)
    local width = object:GetAttribute("width")-1
    local height = object:GetAttribute("height")-1
    width, height = changeRotation(width,height, rotation)
    return requestPlacementXZ(grid, object, rotation, grid:getXZByWorldPosition(position - grid:getWorldPositionByXZ(.5 * width, .5 * height).Position + grid.pivot.Position))
end

function addPlayer(player: Player)
    Grids[player.Name] = {}
    Grids[player.Name]["0"] = Grid.new(50,50,4,CFrame.new() * Workspace.Pivot.CFrame)
    local grid = Grids[player.Name]["0"]
    
    grid:forEach(function(x, z)
        grid.gridArray[x][z] = GridObject.new(x, z)
    end)
end

for _, player in Players:GetPlayers() do
    addPlayer(player)
end

Players.PlayerAdded:Connect(addPlayer)


PlacementEvent.OnServerEvent:Connect(function(player, pos, objectName, rotation)
    if requestPlacementPosition(player, 0, objectName, pos, rotation) then
        GridRequestEvent:FireClient(player, getGrid(player, 0))
    end
end)

GridRequestEvent.OnServerEvent:Connect(function(player: Player, floor: number)
    GridRequestEvent:FireClient(player, getGrid(player, floor))
end)
