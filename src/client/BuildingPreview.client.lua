local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local BuildingSystemsFolder = ReplicatedStorage:WaitForChild("Common"):WaitForChild("Building")

local GridFolder = BuildingSystemsFolder:WaitForChild("Grid")
local Grid = require(GridFolder:WaitForChild("Grid"))
local GridObject = require(GridFolder:WaitForChild("GridObject"))

local isValidPlacement = require(BuildingSystemsFolder:WaitForChild("ValidPlacement"))
local changeRotation = require(BuildingSystemsFolder:WaitForChild("ChangeRotation"))

local mouse = player:GetMouse()

local params = RaycastParams.new()

params.FilterDescendantsInstances = {Workspace:WaitForChild("Grounds")}
params.FilterType = Enum.RaycastFilterType.Include

local BuildingEvents = ReplicatedStorage:WaitForChild("BuildingEvents")
local PlacemntRequest = BuildingEvents:WaitForChild("Placement")
local GridRequestEvent = BuildingEvents:WaitForChild("GridRequest")

local PlacementInfo = ReplicatedStorage:WaitForChild("PlacementInfo")
local PlacementObjects = ReplicatedStorage:WaitForChild("Placement")

local currentGrid

local BuildingPreview: Model
local object: Folder
local previewCFrame: CFrame

local Rotation = 0
local SpeedMult = 10

local PreviewTestName = "Drawer"

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



function changeBuildingPreviewColor(buildingPreview: Model, color: Color3)
    for _,v in pairs(buildingPreview:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Color = color
        end
    end
end

function placePreview(position: Vector3, object: Folder, buildingPreview: Model)
    local width = object:GetAttribute("width")-1
    local height = object:GetAttribute("height")-1
    
    width, height = changeRotation(width,height, Rotation)
    
    local x,z = currentGrid:getXZByWorldPosition(position - currentGrid:getWorldPositionByXZ(.5 * width,.5 * height).Position + currentGrid.pivot.Position)
    
    if isValidPlacement(currentGrid, x, z, object, Rotation) then
        changeBuildingPreviewColor(buildingPreview, Color3.fromRGB(0, 255, 0))
    else
        changeBuildingPreviewColor(buildingPreview, Color3.fromRGB(255, 0, 0))
    end
    --buildingPreview:PivotTo(currentGrid:getWorldPositionByXZ(x + .5,z + .5) * CFrame.Angles(0,math.rad(Rotation),0))
    previewCFrame = currentGrid:getWorldPositionByXZ(x + (.5 * (width+1)),z + (.5 * (height + 1))) * CFrame.Angles(0,math.rad(Rotation),0)
end

function getBuildingPreview(objectName): Model
    local BuildingPreview = PlacementObjects[objectName]:Clone()
    BuildingPreview.Parent = Workspace
    for _,v in pairs(BuildingPreview:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = 0.5
            v.CanCollide = false
        end
    end
    return BuildingPreview
end

function setPreview()
    if BuildingPreview then
        BuildingPreview:Destroy()
    end
    BuildingPreview = getBuildingPreview(PreviewTestName)
    object = getPlacementObject(PreviewTestName)
end

setPreview()

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local result = placementRay()
        if result then
            PlacemntRequest:FireServer(result.Position, PreviewTestName, Rotation)
        end
    elseif input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.R then
            Rotation += 90
            Rotation %= 360
        elseif input.KeyCode == Enum.KeyCode.One then
            PreviewTestName = "Drawer"
            setPreview()
        elseif input.KeyCode == Enum.KeyCode.Two then
            PreviewTestName = "Desk"
            setPreview()
        elseif input.KeyCode == Enum.KeyCode.Three then
            PreviewTestName = "DeskWChair"
            setPreview()
        end
        local result = placementRay()
        if result then
            placePreview(result.Position, object, BuildingPreview)
        end
    end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local result = placementRay()
        if result then
            placePreview(result.Position, object, BuildingPreview)
        end
    end
end)

RunService.Heartbeat:Connect(function(deltaTime)
    if previewCFrame == nil then return end
    BuildingPreview:PivotTo(BuildingPreview.PrimaryPart.CFrame:Lerp(previewCFrame,deltaTime * SpeedMult))
end)
   

--[[local result = Workspace:Raycast(Workspace.CurrentCamera.CFrame.Position,mouse.UnitRay.Direction*9999,params)
        if result then
            ReplicatedStorage.RemoteEvent:FireServer(result.Position, "left")
        end]]--
