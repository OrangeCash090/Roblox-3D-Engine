local CanvasDraw = require(game.ReplicatedStorage.CanvasDraw)
local Numpy = require(game.ReplicatedStorage.Numpy)
local objLoader = require(game.ReplicatedStorage.LoadObject)

local function deepCopy(orig)
	local copy
	if type(orig) == 'table' then
		copy = {}
		for k, v in pairs(orig) do
			copy[k] = deepCopy(v)
		end
	else
		copy = orig
	end
	return copy
end

local function RandomName()
	local str = ""
	for i=1, math.random(1,20) do
		str ..= string.char(math.random(65, 90))
	end
	return str
end

local function FindCenter(vertices)
	local centerX, centerY, centerZ = 0, 0, 0
	local numVertices = #vertices

	-- Loop through all the vertices and add their coordinates to the center
	for i = 1, numVertices do
		local vertex = vertices[i]
		centerX = centerX + vertex[1]
		centerY = centerY + vertex[2]
		centerZ = centerZ + vertex[3]
	end

	-- Divide the center coordinates by the number of vertices to get the average
	centerX = centerX / numVertices
	centerY = centerY / numVertices
	centerZ = centerZ / numVertices

	-- Return the center as a table of coordinates
	return Vector3.new(centerX, centerY, centerZ)
end

local function GetSize(verts)
	local minX, minY, minZ = math.huge, math.huge, math.huge
	local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge

	-- Find the minimum and maximum coordinates
	for i, point in pairs(verts) do
		local x, y, z = point[1], point[2], point[3]
		minX = math.min(minX, x)
		minY = math.min(minY, y)
		minZ = math.min(minZ, z)
		maxX = math.max(maxX, x)
		maxY = math.max(maxY, y)
		maxZ = math.max(maxZ, z)
	end

	-- Calculate the size in each dimension
	local sizeX = maxX - minX
	local sizeY = maxY - minY
	local sizeZ = maxZ - minZ

	return Vector3.new(sizeX, sizeY, sizeZ)
end

function GetAverageColor(texture)
	local totalR, totalG, totalB = 0, 0, 0
	local numPixels = 0

	for x, row in pairs(texture) do
		for y, pixel in pairs(row) do
			totalR = totalR + pixel[1]
			totalG = totalG + pixel[2]
			totalB = totalB + pixel[3]
			numPixels = numPixels + 1
		end
	end

	-- Calculate the average RGB values
	local averageR = totalR / numPixels
	local averageG = totalG / numPixels
	local averageB = totalB / numPixels

	return averageR, averageG, averageB
end

-- Create a 3x3 rotation matrix for rotation around the X-axis
local function matrixRotationX(angle)
	local cosAngle = math.cos(angle)
	local sinAngle = math.sin(angle)

	return {
		{1, 0, 0},
		{0, cosAngle, -sinAngle},
		{0, sinAngle, cosAngle}
	}
end

-- Create a 3x3 rotation matrix for rotation around the Y-axis
local function matrixRotationY(angle)
	local cosAngle = math.cos(angle)
	local sinAngle = math.sin(angle)

	return {
		{cosAngle, 0, sinAngle},
		{0, 1, 0},
		{-sinAngle, 0, cosAngle}
	}
end

-- Create a 3x3 rotation matrix for rotation around the Z-axis
local function matrixRotationZ(angle)
	local cosAngle = math.cos(angle)
	local sinAngle = math.sin(angle)

	return {
		{cosAngle, -sinAngle, 0},
		{sinAngle, cosAngle, 0},
		{0, 0, 1}
	}
end

-- Multiply a 3x3 matrix by a 3D vector
local function matrixMultiplyVector(matrix, vector)
	local result = {}

	for i = 1, 3 do
		local sum = 0
		for j = 1, 3 do
			sum = sum + matrix[i][j] * vector[j]
		end
		table.insert(result, sum)
	end

	return result
end

local module = {}
module._Registry = {}

function module.LoadObject(obj, tex, objname, voffset, toffset)
	local Model = {}
	
	local points, triangles, texture_uv, texture_map, textured = objLoader.read_obj(obj, voffset or 0, toffset or 0)

	Model.points = points
	Model.triangles = triangles
	Model.texture_uv = texture_uv
	Model.texture_map = texture_map
	Model.textured = textured
	Model.texture = tex
	Model.texture_size = {#Model.texture, #Model.texture[1]}
	Model.orig_points = deepCopy(points)
	Model.center = FindCenter(Model.points)
	Model.Name = objname or "P" .. math.random(1,9999)
	
	if Model.textured == false then
		Model.texture = Numpy.NewImage({165,165,165}, {256,256})
		Model.textured = true
	end
	
	Model.Position = Vector3.new(0,0,0)
	Model.Rotation = Vector3.new(0,0,0)
	Model.Size = GetSize(Model.points)
	Model.CFrame = CFrame.new(0,0,0)
	Model.Color = {GetAverageColor(Model.texture)}
	
	function Model:Scale(x, y, z)
		for i, point in pairs(Model.points) do
			point[1] = point[1] * x
			point[2] = point[2] * y
			point[3] = point[3] * z
		end
		Model.Size += Vector3.new(x, y, z)
	end

	function Model:ScaleTo(x, y, z)
		-- Calculate the scaling factors for each dimension
		local scaleX = x / Model.Size.X
		local scaleY = y / Model.Size.Y
		local scaleZ = z / Model.Size.Z

		-- Scale the object using the calculated factors
		Model:Scale(scaleX, scaleY, scaleZ)
		Model.Size = Vector3.new(x, y, z)
	end
	
	function Model:SetCFrame(x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
		-- Get the original size of the model
		local originalSize = GetSize(Model.orig_points)

		-- Calculate the scaling factors for each dimension
		local scaleX = Model.Size.X / originalSize.X
		local scaleY = Model.Size.Y / originalSize.Y
		local scaleZ = Model.Size.Z / originalSize.Z

		-- Scale the transformation matrix
		local scaledMatrix = {
			{r00 * scaleX, r01 * scaleY, r02 * scaleZ, x},
			{r10 * scaleX, r11 * scaleY, r12 * scaleZ, y},
			{r20 * scaleX, r21 * scaleY, r22 * scaleZ, z},
			{0, 0, 0, 1}
		}

		-- Apply the transformation to each vertex of the Model
		for i, vertex in pairs(Model.points) do
			-- Get the original vertex from Model.orig_points
			local origVertex = Model.orig_points[i]

			-- Apply the scaled transformation to the original vertex
			local transformedVertex = {
				scaledMatrix[1][1] * origVertex[1] + scaledMatrix[1][2] * origVertex[2] + scaledMatrix[1][3] * origVertex[3] + scaledMatrix[1][4],
				scaledMatrix[2][1] * origVertex[1] + scaledMatrix[2][2] * origVertex[2] + scaledMatrix[2][3] * origVertex[3] + scaledMatrix[2][4],
				scaledMatrix[3][1] * origVertex[1] + scaledMatrix[3][2] * origVertex[2] + scaledMatrix[3][3] * origVertex[3] + scaledMatrix[3][4]
			}

			-- Update the vertex in Model.points
			Model.points[i] = transformedVertex
		end

		Model.CFrame = CFrame.new(x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
	end
	
	function Model:SetColor(r, g, b)
		r = math.floor(r)
		g = math.floor(g)
		b = math.floor(b)
		
		if not (r >= 0 and r <= 255) then
			r = 255
		end
		if not (g >= 0 and g <= 255) then
			g = 255
		end
		if not (b >= 0 and b <= 255) then
			b = 255
		end
		
		Model.texture = Numpy.NewImage({r, g, b}, Model.texture_size)
		Model.Color = {r, g, b}
	end
	
	function Model:ShiftColor(r, g, b)
		r = math.floor(r)
		g = math.floor(g)
		b = math.floor(b)

		if not (r >= 0 and r <= 255) then
			r = 255
		end
		if not (g >= 0 and g <= 255) then
			g = 255
		end
		if not (b >= 0 and b <= 255) then
			b = 255
		end
		
		for x, row in pairs(Model.texture_size[1]) do
			for y, pixel in pairs(Model.texture_size[2]) do
				pixel[1] = pixel[1] + r
				pixel[2] = pixel[2] + g
				pixel[3] = pixel[3] + b
			end
		end
		
		Model.Color = GetAverageColor(Model.texture)
	end
	
	function Model:ResetTransformation()
		for i,Point in pairs(Model.points) do
			Model.orig_points[i][1] = Point[1]
			Model.orig_points[i][2] = Point[2]
			Model.orig_points[i][3] = Point[3]
		end
		Model.CFrame = CFrame.new(0,0,0)
		Model.Size = GetSize(Model.points)
	end
	
	function Model:Update()
		
		local cframe = Model.CFrame
		Model:SetCFrame(cframe:GetComponents())
		Model.Position = Model.CFrame.Position
		
		local RotX, RotY, RotZ = Model.CFrame:ToEulerAnglesXYZ()
		Model.Rotation = Vector3.new(math.deg(RotX), math.deg(RotY), math.deg(RotZ))
		
		Model:ScaleTo(Model.Size.X, Model.Size.Y, Model.Size.Z)
	end
	
	function Model:Destroy()
		for i,v in pairs(module._Registry) do
			if v.Name == Model.Name then
				module._Registry[i] = nil
			end
		end
	end

	table.insert(module._Registry, Model)
	return Model
end

function module.LoadFromName(Name)
	local ObjectFile = require(game.ReplicatedStorage.Objects:FindFirstChild(Name))
	local TextureFile = {}
	
	if ObjectFile.texture then
		TextureFile = Numpy.CDrawToNumpy(CanvasDraw.GetImageDataFromSaveObject(ObjectFile.texture))
	end
	
	return module.LoadObject(ObjectFile.obj, TextureFile)
end

function module.LoadGroupFromName(Name)
	local ObjectFile = require(game.ReplicatedStorage.Objects:FindFirstChild(Name))
	local TextureFile = {}

	if ObjectFile.texture then
		TextureFile = Numpy.CDrawToNumpy(CanvasDraw.GetImageDataFromSaveObject(ObjectFile.texture))
	end
	
	local Data, Names, VOffsets, TOffsets = objLoader.read_objs(ObjectFile.obj)

	local Group = {}
	Group.PrimaryPart = nil
	
	function Group:GetChildren()
		local Obj = {}
		local ObjNames = {}
		
		for i,v in pairs(Group) do
			if type(v) ~= "function" and v.Name ~= nil and table.find(ObjNames, v.Name) == nil then
				table.insert(Obj, v)
				table.insert(ObjNames, v.Name)
			end
		end
		return Obj
	end
	
	function Group:SetPrimaryPartCFrame()
		
	end
	
	for i=1, #Data do
		local Model = module.LoadObject(Data[i], TextureFile, Names[i], VOffsets[i], TOffsets[i])
		Group[Model.Name] = Model
	end
	
	return Group
end

function module.LoadFBX(Name)
	
end

return module
