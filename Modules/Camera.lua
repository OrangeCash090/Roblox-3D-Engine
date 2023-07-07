local CameraModule = {}
local Mouse = game.Players.LocalPlayer:GetMouse()
local UserInput = game:GetService("UserInputService")
UserInput.MouseBehavior = Enum.MouseBehavior.LockCenter

local pressed_key = nil

Mouse.KeyDown:Connect(function(key)
	pressed_key = key
end)

Mouse.KeyUp:Connect(function()
	pressed_key = nil
end)

function CameraModule.new(Position, Rotation, Sensitivity)
	local Camera = {}
	Camera.Position = Position
	Camera.Rotation = Rotation
	Camera.CFrame = CFrame.new(0,0,0)
	Camera.Target = Vector3.new(1,0,0)

	Camera.fpsController = {
		direction = 0,
		pitch = 0,
	}

	Camera.Sensitivity = Sensitivity

	function Camera:Movement()
		local key = pressed_key

		if key == "e" then
			Camera.CFrame += Vector3.new(0,0.4,0)
		elseif key == "q" then
			Camera.CFrame -= Vector3.new(0,0.4,0)
		elseif key == "w" then
			Camera.CFrame += Vector3.new(0.4*math.cos(-Camera.Rotation.Y), 0, 0.4*math.sin(-Camera.Rotation.Y))
		elseif key == "s" then
			Camera.CFrame -= Vector3.new(0.4*math.cos(-Camera.Rotation.Y), 0, 0.4*math.sin(-Camera.Rotation.Y))
		elseif key == "a" then
			Camera.CFrame += Vector3.new(0.4*math.sin(-Camera.Rotation.Y), 0, -0.4*math.cos(-Camera.Rotation.Y))
		elseif key == "d" then
			Camera.CFrame += Vector3.new(-0.4*math.sin(-Camera.Rotation.Y), 0, 0.4*math.cos(-Camera.Rotation.Y))
		end

		Camera:Pan(UserInput:GetMouseDelta().X, UserInput:GetMouseDelta().Y)
	end

	function Camera:Pan(dx, dy)
		Camera.fpsController.direction = math.max(math.min(Camera.fpsController.direction - dy * Camera.Sensitivity, math.pi * 0.5), math.pi * -0.5)
		Camera.fpsController.pitch = Camera.fpsController.pitch - dx * Camera.Sensitivity
		
		local rotationCFrame = CFrame.Angles(0, Camera.fpsController.pitch, 0) * CFrame.Angles(Camera.fpsController.direction, 0, 0)
		local positionCFrame = CFrame.new(Camera.CFrame.Position)

		Camera.CFrame = positionCFrame * rotationCFrame
	end
	
	function Camera:Update(move: true?)
		Camera.Position = Camera.CFrame.Position
		local xRotation, yRotation, _ = Camera.CFrame:ToOrientation()
		Camera.Rotation = Vector3.new(xRotation, yRotation + math.rad(90), 0)
		
		if move == true then
			Camera:Movement()
		end
	end

	return Camera
end

return CameraModule
