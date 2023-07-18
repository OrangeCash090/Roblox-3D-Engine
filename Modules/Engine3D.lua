-- Made by HeroShiner46
local Engine3D = {}

local CanvasDraw = require(game.ReplicatedStorage.CanvasDraw)
local Numpy = require(game.ReplicatedStorage.Numpy)
local ModelLoader = require(game.ReplicatedStorage.ModelLoader)
local Collision = require(game.ReplicatedStorage.Collision)
local CameraModule = require(game.ReplicatedStorage.Camera)

local function argsort(tbl)
	local indices = {1,2,3}
	
	table.sort(indices, function(a, b)
		if tbl[a] == tbl[b] then
			return a < b
		else
			return tbl[a] < tbl[b]
		end
	end)
	
	return indices
end

local function dot_3d(arr1, arr2)
	return arr1[1]*arr2[1] + arr1[2]*arr2[2] + arr1[3]*arr2[3]
end

function Normalize(v)
	local length = math.sqrt(dot_3d(v, v))
	if length == 0 then
		return {v[1], v[2], v[3]}
	else
		return {v[1] / length, v[2] / length, v[3] / length}
	end
end

function Vector_IntersectPlane(plane_p, plane_n, lineStart, lineEnd)
	plane_n = Normalize(plane_n)
	local plane_d = -(dot_3d(plane_n, plane_p))
	local ad = dot_3d(lineStart, plane_n)
	local bd = dot_3d(lineEnd, plane_n)
	local t = (-plane_d - ad) / (bd - ad)

	local lineStartToEnd = {lineEnd[1] - lineStart[1], lineEnd[2] - lineStart[2], lineEnd[3] - lineStart[3]}
	local lineToIntersect = {lineStartToEnd[1] * t, lineStartToEnd[2] * t, lineStartToEnd[3] * t}
	return {lineStart[1] + lineToIntersect[1], lineStart[2] + lineToIntersect[2], lineStart[3] + lineToIntersect[3]}, t
end

function Triangle_ClipPlane(plane_p, plane_n, in_tri, tri_uv)
	-- args: vector3, vector3, triangle
	local function dist(v)
		return (plane_n[1] * v[1] + plane_n[2] * v[2] + plane_n[3] * v[3] - dot_3d(plane_n, plane_p))
	end

	plane_n = Normalize(plane_n)

	local inside_points = {}
	local nInsidePointCount = 0

	local outside_points = {}
	local nOutsidePointCount = 0

	local inside_tex = {}
	local outside_tex = {}

	local d0 = dist(in_tri[1])
	local d1 = dist(in_tri[2])
	local d2 = dist(in_tri[3])

	if d0 >= 0 then
		table.insert(inside_points, in_tri[1])
		table.insert(inside_tex, tri_uv[1])

		nInsidePointCount += 1
	else
		table.insert(outside_points, in_tri[1])
		table.insert(outside_tex, tri_uv[1])

		nOutsidePointCount += 1
	end

	if d1 >= 0 then
		table.insert(inside_points, in_tri[2])
		table.insert(inside_tex, tri_uv[2])

		nInsidePointCount += 1
	else
		table.insert(outside_points, in_tri[2])
		table.insert(outside_tex, tri_uv[2])

		nOutsidePointCount += 1
	end

	if d2 >= 0 then
		table.insert(inside_points, in_tri[3])
		table.insert(inside_tex, tri_uv[3])

		nInsidePointCount += 1
	else
		table.insert(outside_points, in_tri[3])
		table.insert(outside_tex, tri_uv[3])

		nOutsidePointCount += 1
	end

	if nInsidePointCount == 0 then
		return 0, nil, nil, nil
	end

	if nInsidePointCount == 3 then
		return 1, in_tri, nil, tri_uv, nil
	end

	if nInsidePointCount == 1 and nOutsidePointCount == 2 then
		local out_tri1 = {}
		local out_uv1 = {}

		local t

		out_tri1[1] = inside_points[1]
		out_uv1[1] = inside_tex[1]

		out_tri1[2], t = Vector_IntersectPlane(plane_p, plane_n, inside_points[1], outside_points[1])
		out_uv1[2] = {t * (outside_tex[1][1] - inside_tex[1][1]) + inside_tex[1][1], t * (outside_tex[1][2] - inside_tex[1][2]) + inside_tex[1][2]}

		out_tri1[3], t = Vector_IntersectPlane(plane_p, plane_n, inside_points[1], outside_points[2])
		out_uv1[3] = {t * (outside_tex[2][1] - inside_tex[1][1]) + inside_tex[1][1], t * (outside_tex[2][2] - inside_tex[1][2]) + inside_tex[1][2]}

		return 1, out_tri1, nil, out_uv1, nil
	end

	if nInsidePointCount == 2 and nOutsidePointCount == 1 then
		local out_tri1 = {}
		local out_tri2 = {}

		local out_uv1 = {}
		local out_uv2 = {}

		local t

		out_tri1[1] = inside_points[1]
		out_uv1[1] = inside_tex[1]

		out_tri1[2] = inside_points[2]
		out_uv1[2] = inside_tex[2]

		out_tri1[3], t = Vector_IntersectPlane(plane_p, plane_n, inside_points[1], outside_points[1])
		out_uv1[3] = {t * (outside_tex[1][1] - inside_tex[1][1]) + inside_tex[1][1], t * (outside_tex[1][2] - inside_tex[1][2]) + inside_tex[1][2]}


		out_tri2[1] = inside_points[2]
		out_uv2[1] = inside_tex[2]

		out_tri2[2] = out_tri1[3]
		out_uv2[2] = out_uv1[3]

		out_tri2[3], t = Vector_IntersectPlane(plane_p, plane_n, inside_points[2], outside_points[1])
		out_uv2[3] = {t * (outside_tex[1][1] - inside_tex[2][1]) + inside_tex[2][1], t * (outside_tex[1][2] - inside_tex[2][2]) + inside_tex[2][2]}

		return 2, out_tri1, out_tri2, out_uv1, out_uv2
	end
end

local function get_slopes(num_start, num_middle, num_stop, den_start, den_middle, den_stop)
	local slope_1 = (num_stop - num_start)/(den_stop - den_start + 1e-32) -- + 1e-32 avoid zero division ¯\_(ツ)_/¯
	local slope_2 = (num_middle - num_start)/(den_middle - den_start + 1e-32)
	local slope_3 = (num_stop - num_middle)/(den_stop - den_middle + 1e-32)

	return {slope_1, slope_2, slope_3}
end

local function project_points(points, camera)
	local cos_hor = math.cos(camera.Rotation.Y + math.pi / 2) -- add 90° to align with z axis
	local sin_hor = math.sin(camera.Rotation.Y + math.pi / 2) -- negative (counter rotation)

	local cos_ver = math.cos(camera.Rotation.X)
	local sin_ver = math.sin(camera.Rotation.X)

	local hor_fov_adjust = 0.5 * Engine3D.ScreenSize.X / math.tan(Engine3D.FOV_H * 0.5)
	local ver_fov_adjust = 0.5 * Engine3D.ScreenSize.Y / math.tan(Engine3D.FOV * 0.5)

	for i, point in pairs(points) do

		-- translate to have camera as origin
		local translate = {point[1] - camera.Position.X, point[2] - camera.Position.Y, point[3] - camera.Position.Z}

		-- rotate to camera horizontal direction
		local new_x = translate[1] * cos_hor - translate[3] * sin_hor
		local new_z = translate[1] * sin_hor + translate[3] * cos_hor
		translate[1], translate[3] = new_x, new_z

		-- rotate to camera vertical direction
		local new_y = translate[2] * cos_ver - translate[3] * sin_ver
		local new_z = translate[2] * sin_ver + translate[3] * cos_ver
		translate[2], translate[3] = new_y, new_z

		if translate[3] < 0.001 and translate[3] > -0.001 then -- jump over 0 to avoid zero division ¯\_(ツ)_/¯
			translate[3] = -0.001
		end

		point[4] = math.floor(-hor_fov_adjust * translate[1] / translate[3] + 0.5 * Engine3D.ScreenSize.X)
		point[5] = math.floor(-ver_fov_adjust * translate[2] / translate[3] + 0.5 * Engine3D.ScreenSize.Y)
		point[6] = translate[3] -- math.sqrt(translate[1] * translate[1] + translate[2] * translate[2] + translate[3] * translate[3])

		point[7] = translate[1]
		point[8] = translate[2]
		point[9] = translate[3]
	end
end

local function ConvertViewToScreenSpace(triangle)
	local hor_fov_adjust = 0.5 * Engine3D.ScreenSize.X / math.tan(Engine3D.FOV_H * 0.5)
	local ver_fov_adjust = 0.5 * Engine3D.ScreenSize.Y / math.tan(Engine3D.FOV * 0.5)

	for i,point in pairs(triangle) do
		local translate = point

		point[4] = math.floor(-hor_fov_adjust * translate[1] / translate[3] + 0.5 * Engine3D.ScreenSize.X)
		point[5] = math.floor(-ver_fov_adjust * translate[2] / translate[3] + 0.5 * Engine3D.ScreenSize.Y)
		point[6] = translate[3] -- math.sqrt(translate[1] * translate[1] + translate[2] * translate[2] + translate[3] * translate[3])
	end

	return triangle
end

local function Clip_Triangle(triangle, uv, camera)
	local clippedTriangles = {}
	local NewUvs = {}

	triangle = {{triangle[1][7], triangle[1][8], triangle[1][9]}, {triangle[2][7], triangle[2][8], triangle[2][9]}, {triangle[3][7], triangle[3][8], triangle[3][9]}}

	local result, newTriangle, secondTriangle, newuv1, newuv2 = Triangle_ClipPlane({0,0,0.1}, {0, 0, 1}, triangle, uv)

	if result == 0 then
		-- Triangle is entirely outside the clipping plane
		-- Skip this triangle
	elseif result == 1 then
		-- Triangle is entirely inside the clipping plane
		table.insert(clippedTriangles, newTriangle)
		table.insert(NewUvs, newuv1)
	else
		-- Triangle is partially inside the clipping plane
		table.insert(clippedTriangles, newTriangle)
		table.insert(NewUvs, newuv1)

		if secondTriangle then
			table.insert(clippedTriangles, secondTriangle)
			table.insert(NewUvs, newuv2)
		end
	end

	return clippedTriangles, NewUvs
end

local function draw_text_triangle(frame, z_buffer, texture, text_size, shade, start, middle, stop, x_slopes, z_slopes, uv_start, uv_middle, u_slopes, v_slopes)
	local screen_width = Engine3D.ScreenSize.X
	local screen_height = Engine3D.ScreenSize.Y

	local min_y = math.max(0, math.floor(start[2]))
	local max_y = math.min(screen_height, math.floor(stop[2]))

	for y = min_y, max_y do
		local delta_y = y - start[2]

		local x1 = start[1] + math.floor(delta_y * x_slopes[1])
		local z1 = start[3] + (delta_y * z_slopes[1])
		local u1 = uv_start[1] + (delta_y * u_slopes[1])
		local v1 = uv_start[2] + (delta_y * v_slopes[1])

		local x2, z2, u2, v2
		if y < middle[2] then
			delta_y = y - start[2]
			x2 = start[1] + math.floor(delta_y * x_slopes[2])
			z2 = start[3] + (delta_y * z_slopes[2])
			u2 = uv_start[1] + (delta_y * u_slopes[2])
			v2 = uv_start[2] + (delta_y * v_slopes[2])
		else
			delta_y = y - middle[2]
			x2 = middle[1] + math.floor(delta_y * x_slopes[3])
			z2 = middle[3] + (delta_y * z_slopes[3])
			u2 = uv_middle[1] + (delta_y * u_slopes[3])
			v2 = uv_middle[2] + (delta_y * v_slopes[3])
		end

		if x1 > x2 then -- lower x should be on the left
			x1, x2 = x2, x1
			z1, z2 = z2, z1
			u1, u2 = u2, u1
			v1, v2 = v2, v1
		end

		local min_x = math.max(0, math.floor(x1))
		local max_x = math.min(screen_width, math.floor(x2))

		if min_x ~= max_x then
			local dx = x2 - x1
			local z_slope = (z2 - z1) / dx
			local u_slope = (u2 - u1) / dx
			local v_slope = (v2 - v1) / dx

			for x = min_x, max_x do
				local delta_x = x - x1
				local z = 1 / (z1 + (delta_x * z_slope) + 1e-32) -- retrieve z

				if z < z_buffer[x][y] then -- check z buffer
					local u = (u1 + (delta_x * u_slope)) * z -- multiply by z to go back to uv space
					local v = (v1 + (delta_x * v_slope)) * z -- multiply by z to go back to uv space
					if u >= 0 and u <= 1 and v >= 0 and v <= 1 then -- don't render out of bounds
						z_buffer[x][y] = z
						local tex_x = math.floor(u * text_size[1])
						local tex_y = math.floor(v * text_size[2])
						frame[x][y] = {shade * texture[tex_x][tex_y][1], shade * texture[tex_x][tex_y][2], shade * texture[tex_x][tex_y][3]}
					end
				end
			end
		end
	end
end

local function draw_model(frame, points, triangles, camera, light_dir, z_buffer, textured, texture_uv, texture_map, texture)
	local text_size = {#texture, #texture[1]}

	for index = 1, #triangles do
		local triangle = triangles[index]

		-- Use Cross-Product to get surface normal
		local vet1 = Vector3.new(points[triangle[2]][1] - points[triangle[1]][1], points[triangle[2]][2] - points[triangle[1]][2], points[triangle[2]][3] - points[triangle[1]][3])
		local vet2 = Vector3.new(points[triangle[3]][1] - points[triangle[1]][1], points[triangle[3]][2] - points[triangle[1]][2], points[triangle[3]][3] - points[triangle[1]][3])

		-- backface culling with dot product between normal and camera ray
		local normal = vet1:Cross(vet2).Unit
		local CameraRay = Vector3.new((points[triangle[1]][1] - camera.Position.X), (points[triangle[1]][2] - camera.Position.Y), (points[triangle[1]][3] - camera.Position.Z) )
		
		if normal:Dot(CameraRay) < 0 then
			local shade = 0.5* light_dir:Dot(normal) + 0.5 -- directional lighting

			local ClippedTriangles, NewUV = Clip_Triangle({points[triangle[1]], points[triangle[2]], points[triangle[3]]}, texture_map[index], camera)

			for x,Tris in pairs(ClippedTriangles) do
				local ClippedTriangle = ConvertViewToScreenSpace(Tris)

				local proj_points = {{ClippedTriangle[1][4], ClippedTriangle[1][5], ClippedTriangle[1][6]},
				{ClippedTriangle[2][4], ClippedTriangle[2][5], ClippedTriangle[2][6]},
				{ClippedTriangle[3][4], ClippedTriangle[3][5], ClippedTriangle[3][6]}}

				local sorted_y = argsort({proj_points[1][2], proj_points[2][2], proj_points[3][2]})

				local start = proj_points[sorted_y[1]]
				local middle = proj_points[sorted_y[2]]
				local stop = proj_points[sorted_y[3]]

				local x_slopes = get_slopes(start[1], middle[1], stop[1], start[2], middle[2], stop[2])

				start[3], middle[3], stop[3] = 1/start[3], 1/middle[3], 1/stop[3]
				local z_slopes = get_slopes(start[3], middle[3], stop[3], start[2], middle[2], stop[2])

				local uv_points = {NewUV[x][1], NewUV[x][2], NewUV[x][3]}
				local uv_start = {uv_points[sorted_y[1]][1] * start[3], uv_points[sorted_y[1]][2] * start[3]}
				local uv_middle = {uv_points[sorted_y[2]][1] * middle[3], uv_points[sorted_y[2]][2] * middle[3]}
				local uv_stop = {uv_points[sorted_y[3]][1] * stop[3], uv_points[sorted_y[3]][2] * stop[3]}

				local u_slopes = get_slopes(uv_start[1], uv_middle[1], uv_stop[1], start[2], middle[2], stop[2])
				local v_slopes = get_slopes(uv_start[2], uv_middle[2], uv_stop[2], start[2], middle[2], stop[2])

				draw_text_triangle(frame, z_buffer, texture, text_size, shade, start, middle, stop, x_slopes, z_slopes, uv_start, uv_middle, u_slopes, v_slopes)
				Engine3D.TrianglesProccessed+=1
			end
		end
	end
end

local function DrawToScreen(frame, z_buffer)
	for y=1, #frame do
		for x=1, #frame do
			Engine3D.Canvas:SetPixel(x, y, Color3.fromRGB(frame[x][y][1], frame[x][y][2], frame[x][y][3]))
			
			frame[x][y] = {}
			z_buffer[x][y] = 64 -- how to like do distance view thing
		end
	end
end

local function DrawUV(frame, text_size, Object)
	Engine3D.Canvas:DrawImage(CanvasDraw.GetImageDataFromSaveObject(Object.image_texture), Vector2.new(0,0))
	for i,Triangle in pairs(Object.texture_map) do
		Engine3D.Canvas:DrawTriangle(Vector2.new(math.floor(Triangle[1][1]*text_size[1]), math.floor(Triangle[1][2]*text_size[2])), Vector2.new(math.floor(Triangle[2][1]*text_size[1]), math.floor(Triangle[2][2]*text_size[2])), Vector2.new(math.floor(Triangle[3][1]*text_size[1]), math.floor(Triangle[3][2]*text_size[2])), Color3.fromRGB(0,255,0), false)
	end
end

function Engine3D.new(Frame, ScreenSize, Camera, FOV, Debug)
	local World = {}

	Engine3D.ScreenSize = ScreenSize
	Engine3D.Canvas = CanvasDraw.new(Frame, ScreenSize)
	Engine3D.FOV = math.rad(FOV) -- math.rad(70)
	Engine3D.FOV_H = Engine3D.FOV*ScreenSize.X/ScreenSize.Y
	Engine3D.UVDebug = Debug
	Engine3D.TrianglesProccessed = 0

	World.Camera = Camera
	World.Time = 0
	
	local frame = Numpy.Custom2({0,0,0}, Engine3D.ScreenSize.X, Engine3D.ScreenSize.Y, 3)
	local z_buffer = Numpy.Custom2(1000, Engine3D.ScreenSize.X, Engine3D.ScreenSize.Y)
	
	local light_dir = Vector3.new(math.sin(os.clock()), 1, 1).Unit

	function World:Update()
		Engine3D.TrianglesProccessed = 0
		for i,Model in pairs(ModelLoader._Registry) do
			project_points(Model.points, World.Camera)
			draw_model(frame, Model.points, Model.triangles, World.Camera, light_dir, z_buffer, Model.textured, Model.texture_uv, Model.texture_map, Model.texture)
			Model:Update()
		end

		--DrawUV(frame, {#Cube.texture, #Cube.texture[1]}, Cube)
		DrawToScreen(frame, z_buffer)
		World.Time+=1
	end

	return World
end

return Engine3D

-- TODO: get rid of triangle indices and just put the triangles in there!
-- its so bad so just get rid of it :skull:
-- REPLACE CANVASDRAW IT SUC
