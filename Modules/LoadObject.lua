local module = {}

function module.read_obj(fileName, voffset, toffset)
	-- Read wavefront models with or without textures, supports triangles and quads (turned into triangles)
	local vertices, triangles, texture_uv, texture_map = {}, {}, {}, {}
	local textured = false

	-- hash table to store texture coordinates for each vertex
	local vertex_uv = {}

	for i,line in pairs(string.split(fileName, "\n")) do
		local words = {}
		for i,word in pairs(string.split(line, " ")) do
			table.insert(words, word)
		end

		if #words == 0 then -- skip empty lines
			continue
		end

		if words[1] == "v" then -- vertices
			table.insert(vertices, {tonumber(words[2]), tonumber(words[3]), tonumber(words[4]), 1, 1, 1}) -- additional spaces for projection

		elseif words[1] == "vt" then -- texture coordinates
			table.insert(texture_uv, {tonumber(words[2]), tonumber(words[3])})

		elseif words[1] == "f" then -- faces
			local face_vertices, face_texture_map = {}, {}
			for i = 2, #words do
				local parts = {}
				for i,part in pairs(string.split(words[i], "/")) do
					table.insert(parts, tonumber(part))
				end
				
				table.insert(face_vertices, parts[1] - voffset)

				if parts[2] ~= nil then
					table.insert(face_texture_map, parts[2] - toffset)
				end
			end
			
			for i = 2, #face_vertices - 1 do
				table.insert(triangles, {face_vertices[1], face_vertices[i], face_vertices[i+1]})

				if #face_texture_map > 0 then
					-- look up texture coordinates for each vertex in the face
					local face_texture_uv = {}
					for j = 1, 3 do
						local vertex_index = face_vertices[j]
						local texture_index = face_texture_map[j]
						if vertex_uv[vertex_index] == nil then
							vertex_uv[vertex_index] = {}
						end
						if vertex_uv[vertex_index][texture_index] == nil then
							vertex_uv[vertex_index][texture_index] = texture_uv[texture_index]
						end
						table.insert(face_texture_uv, vertex_uv[vertex_index][texture_index])
					end
					table.insert(texture_map, face_texture_uv)
				end
			end
		end
	end

	if #texture_uv > 0 and #texture_map > 0 then
		textured = true
		for i = 1, #texture_uv do
			texture_uv[i][2] = 1 - texture_uv[i][2] -- apparently obj textures are upside down they arent
		end
	end
	
	if textured == false then
		for x=1, #triangles do
			if x+1 < #triangles then
				texture_uv[x] = {0, 0}
				texture_uv[x+1] = {1, 0}
				texture_uv[x+2] = {1,1}
			end
			
			texture_map[x] = {
				[1] = {0,0},
				[2] = {1,0},
				[3] = {1,1}
			}
		end
	end

	return vertices, triangles, texture_uv, texture_map, textured
end

function module.read_objs(data)
	local ObjFile = {}
	local vertoffsets = {}
	local texoffsets = {}
	local names = {}
	
	local Sectors = string.split(data, "o ")
	table.remove(Sectors, 1)

	for i,v in pairs(Sectors) do
		local newdata = string.split(v, "\n")
		local objname = newdata[1]
		
		local voffset = vertoffsets[i-1] or 0
		local toffset = texoffsets[i-1] or 0
		
		table.remove(newdata, 1)
		if i > 1 then
			for _,x in pairs(newdata) do
				if x:match("v ") then
					voffset+=1
				end
				if x:match("vt ") then
					toffset+=1
				end
			end
		end
		newdata = table.concat(newdata, "\n")
		newdata = "\n"..newdata.."\n"
		table.insert(ObjFile, newdata)
		table.insert(vertoffsets, voffset)
		table.insert(texoffsets, toffset)
		table.insert(names, objname)
	end
	
	return ObjFile, names, vertoffsets, texoffsets
end

return module
