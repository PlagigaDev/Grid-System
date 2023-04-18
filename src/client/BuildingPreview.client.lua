local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local BuildingSystemsFolder = ReplicatedStorage:WaitForChild("Common"):WaitForChild("Building")

local GridFolder = BuildingSystemsFolder:WaitForChild("Grid")
local Grid = require(GridFolder:WaitForChild("Grid"))
local GridObject = require(GridFolder:WaitForChild("GridObject"))

local isValidPlacement = require(BuildingSystemsFolder:WaitForChild("ValidPlacement"))

local mouse = player:GetMouse()

local params = RaycastParams.new()

params.FilterDescendantsInstances = {Workspace:WaitForChild("Grounds")}
params.FilterType = Enum.RaycastFilterType.Include

local BuildingEvents = ReplicatedStorage:WaitForChild("BuildingEvents")
local PlacemntRequest = BuildingEvents:WaitForChild("Placement")
local GridRequestEvent = BuildingEvents:WaitForChild("GridRequest")

local PlacementInfo = ReplicatedStorage:WaitForChild("PlacementInfo")

local currentGrid

GridRequestEvent.OnClientEvent:Connect(function(grid)
    currentGrid = Grid.from(grid)
    currentGrid:forEach(function(x, z)
        currentGrid.gridArray[x][z] = GridObject.from(currentGrid.gridArray[x][z])
    end)
end)

GridRequestEvent:FireServer(0)

function placementRay()
    return Workspace:Raycast(Workspace.CurrentCamera.CFrame.Position,mouse.UnitRay.Direction*9999,params)
end

function getPlacementObject(objectName: string): Folder
    return PlacementInfo:FindFirstChild(objectName)
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local result = placementRay()
        if result then
            PlacemntRequest:FireServer(result.Position, "Drawer")
        end
    end
end)

local BuildingPreview = ReplicatedStorage:WaitForChild("Placement"):WaitForChild("Drawer"):Clone()
BuildingPreview.Parent = Workspace
local object = getPlacementObject("Drawer")
for _,v in pairs(BuildingPreview:GetChildren()) do
    v.Transparency = 0.5
    --v.CanCollide = false

end
UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local result = placementRay()
        if result then
            print(result.Position)
            local x,z = currentGrid:getXZByWorldPosition(result.Position)
            if isValidPlacement(currentGrid, x, z, object) then
                for _, v in pairs(BuildingPreview:GetChildren()) do
                    v.Color = Color3.fromRGB(0, 255, 0)
                end
                
            else
                for _, v in pairs(BuildingPreview:GetChildren()) do
                    v.Color = Color3.fromRGB(255,0,0)
                end
            end
            BuildingPreview:PivotTo(currentGrid:getWorldPositionByXZ(x,z))
            print(BuildingPreview.PrimaryPart.CFrame.Position)
        end
    end
end)
   

--[[local result = Workspace:Raycast(Workspace.CurrentCamera.CFrame.Position,mouse.UnitRay.Direction*9999,params)
        if result then
            ReplicatedStorage.RemoteEvent:FireServer(result.Position, "left")
        end]]--
