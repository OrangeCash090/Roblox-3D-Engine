local Numpy = {}
local CanvasDraw = require(script.Parent.CanvasDraw)

function Numpy.Custom2(val, dim1, dim2, dim3)
	local result = {}
	for i = 0, dim1 do
		result[i] = {}
		for j = 0, dim2 do
			result[i][j] = {}
			if dim3 == nil then
				result[i][j] = val
			else
				for k = 0, dim3 do
					result[i][j][k] = val
				end
			end
		end
	end
	return result
end

function Numpy.CDrawToNumpy(data)
	local Resolution = data.ImageResolution

	local FinalTbl = {}

	for x=0, Resolution.X-1 do
		local temp = {}
		for y=0, Resolution.Y-1 do
			local PixelColor = CanvasDraw.GetPixelFromImageXY(data, x+1, y+1)
			temp[y] = {math.floor(PixelColor.R*255), math.floor(PixelColor.G*255), math.floor(PixelColor.B*255)}
		end
		FinalTbl[x] = temp
	end

	return FinalTbl
end

function Numpy.NewImage(Color, Resolution)
	local FinalTbl = {}
	
	for x=0, Resolution[1]-1 do
		local temp = {}
		for y=0, Resolution[2]-1 do
			temp[y] = Color
		end
		FinalTbl[x] = temp
	end

	return FinalTbl
end

return Numpy
