local module = {}

module.BaseWelds = {}
module.Welds = {}

function module.new(Name, Part0, Part1, C0, C1)
	local Joint = {
		["Name"] = Name,
		["Part0"] = Part0,
		["Part1"] = Part1,
		["C0"] = C0 or CFrame.new(0,0,0),
		["C1"] = C1 or CFrame.new(0,0,0),
	}
	table.insert(module.Welds, Joint)
	return Joint
end

function module:GetBaseWelds()
	if #module.BaseWelds == 0 then
		for i,w in pairs(module.Welds) do
			module.BaseWelds[w.Name] = {
				C0 = w.C0,
				C1 = w.C1,
			}
		end
	end
	return module.BaseWelds
end

function module:Update()
	for i,v in pairs(module.Welds) do
		local CurrentBone = v
		local Object = CurrentBone.Part1

		Object.CFrame = (CurrentBone.Part0.CFrame * CurrentBone.C0) * CurrentBone.C1:Inverse()
	end
end

return module
