local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Grid = require(script.Parent.Grid:WaitForChild("Grid"))

local Test = Workspace.Test
Test.Anchored = true
local pivot = Workspace:WaitForChild("Pivot")
Test.CFrame = CFrame.new(Test.CFrame.Position) * pivot.CFrame.Rotation

local grid = Grid.new(75, 75, 4, pivot.CFrame)
ReplicatedStorage.RemoteEvent.OnServerEvent:Connect(function(_,pos)
    local x,z = grid:getXZByWorldPosition(pos)
    Test.CFrame = grid:getWorldPositionByXZ(x + .5, z + .5)
end)


