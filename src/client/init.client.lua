local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local mouse = player:GetMouse()

local params = RaycastParams.new()

params.CollisionGroup = "Ground"

while task.wait() do
    local result = Workspace:Raycast(Workspace.CurrentCamera.CFrame.Position,mouse.UnitRay.Direction*9999,params)
    if result then
        ReplicatedStorage.RemoteEvent:FireServer(result.Position)
    end
end