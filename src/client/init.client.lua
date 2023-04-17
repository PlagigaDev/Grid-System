local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local mouse = player:GetMouse()

local params = RaycastParams.new()

params.CollisionGroup = "Ground"

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local result = Workspace:Raycast(Workspace.CurrentCamera.CFrame.Position,mouse.UnitRay.Direction*9999,params)
        if result then
            ReplicatedStorage.RemoteEvent:FireServer(result.Position)
        end
    end
end)
   

--[[local result = Workspace:Raycast(Workspace.CurrentCamera.CFrame.Position,mouse.UnitRay.Direction*9999,params)
        if result then
            ReplicatedStorage.RemoteEvent:FireServer(result.Position, "left")
        end]]--
