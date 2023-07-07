-- I forgor wtf this was but im adding it anyway.
local module = {}

function module.Subtract(v1, v2)
	return Vector3.new(v1[1] - v2[1], v1[2] - v2[2], v1[3] - v2[3])
end

function module.Add(v1, v2)
	return Vector3.new(v1[1] + v2[1], v1[2] + v2[2], v1[3] + v2[3])
end

function module.RotateVector(vector, rotation)
	local x, y, z = vector[1], vector[2], vector[3]
	local rx, ry, rz = rotation[1], rotation[2], rotation[3]

	-- Apply rotation around X-axis
	local rotatedX = x
	local rotatedY = y * math.cos(rx) - z * math.sin(rx)
	local rotatedZ = y * math.sin(rx) + z * math.cos(rx)

	-- Apply rotation around Y-axis
	local tempX = rotatedX * math.cos(ry) + rotatedZ * math.sin(ry)
	local tempY = rotatedY
	local tempZ = -rotatedX * math.sin(ry) + rotatedZ * math.cos(ry)

	-- Apply rotation around Z-axis
	local finalX = tempX * math.cos(rz) - tempY * math.sin(rz)
	local finalY = tempX * math.sin(rz) + tempY * math.cos(rz)
	local finalZ = tempZ

	return {finalX, finalY, finalZ}
end


return module
