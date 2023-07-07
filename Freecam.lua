-- Modules --
local Engine3D = require(Modules.Engine3D)
local ModelLoader = require(Modules.ModelLoader)
local CameraModule = require(Modules.Camera)
local WeldModule = require(Modules.Weld)

local Mouse = game.Players.LocalPlayer:GetMouse()
local Camera = CameraModule.new(Vector3.new(0,5,0), Vector3.zero, 1/50, "Freecam")
local World = Engine3D.new(script.Parent.Screen, Vector2.new(128,128), Camera, 70, false)

local Cube = ModelLoader.LoadFromName("Cube")

game:GetService("RunService").RenderStepped:Connect(function(dt)
	Cube.CFrame = Cube.CFrame * CFrame.new(0, 0, -0.1) * CFrame.Angles(0,math.rad(1),0)
	Camera:Update(true)
	World:Update()
end)
