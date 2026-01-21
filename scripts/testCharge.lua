local mod = mod_loader.mods[modApi.currentMod]
--LOG("[TRUELCH] tostring(mod): "..tostring(mod))
--LOG("[TRUELCH] save_table(mod): "..save_table(mod))

truelch_TestCharge = Skill:new{
	Name = "Test Charge",
	Description = "Test custom charge.",
	Class = "",
	Icon = "advanced/weapons/Prime_TC_Punt.png",
}

function truelch_TestCharge:GetTargetArea(point)
	local ret = PointList()

	for j = 0, 7 do
		for i = 0, 7 do
			ret:push_back(Point(i, j))
		end
	end

	return ret
end

truelch_ret = nil
function TruelchGetRet()
	--return truelch_ret
	local se = SkillEffect()
	return se
end

truelch_mod = nil
function TruelchGetMod()
	LOG("[TRUELCH] TruelchGetMod()")
	--local truelch_mod = mod_loader.mods[modApi.currentMod]
	if truelch_mod ~= nil then
		LOG("[TRUELCH] truelch_mod EXISTS!!! YAY")
	else
		LOG("[TRUELCH] truelch_mod is nil :(")
	end
	return truelch_mod
end

function Tmp()
	ret:AddScript([[
		local leap = PointList()
		leap:push_back(]]..p1:GetString()..[[)
		leap:push_back(]]..p2:GetString()..[[)
		ret:AddLeap(leap, FULL_DELAY)

		local leap = PointList()
		leap:push_back(]]..p2:GetString()..[[)
		leap:push_back(]]..p1:GetString()..[[)
		ret:AddLeap(leap, NO_DELAY)
	]])
end

function TruelchDoTheFuckingLogic()
	local se = 
end


function truelch_TestCharge:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	truelch_mod = mod
	if truelch_mod ~= nil then
		LOG("[TRUELCH] GetSkillEffect truelch_mod EXISTS!!! YAY")
	else
		LOG("[TRUELCH] GetSkillEffect truelch_mod is nil :(")
	end

	local ret2 = TruelchGetRet()
	local mod2 = TruelchGetMod()

	if mod2 ~= nil then
		LOG("[TRUELCH] mod2 EXISTS!!! YAY")
		--LOG("[TRUELCH] tostring(mod2): "..tostring(mod2))
		--LOG("[TRUELCH] save_table(mod2): "..save_table(mod2))
	else
		LOG("[TRUELCH] mod2 is nil :(")
	end

	mod2.worldConstants:setHeight(ret2, 1)
	local leap = PointList()
	leap:push_back(p1:GetString())
	leap:push_back(p2:GetString())
	ret2:AddLeap(leap, FULL_DELAY)
	mod2.worldConstants:resetHeight(ret2)

	mod2.worldConstants:setHeight(ret2, 1)
	local leap2 = PointList()
	leap2:push_back(p2:GetString())
	leap2:push_back(p1:GetString())
	ret2:AddLeap(leap2, NO_DELAY)
	mod2.worldConstants:resetHeight(ret2)

	Board:AddEffect(ret2)

	return ret
end



function truelch_TestCharge:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	truelch_mod = mod
	if truelch_mod ~= nil then
		LOG("[TRUELCH] GetSkillEffect truelch_mod EXISTS!!! YAY")
	else
		LOG("[TRUELCH] GetSkillEffect truelch_mod is nil :(")
	end

	ret:AddScript([[
		local ret2 = TruelchGetRet()
		local mod2 = TruelchGetMod()

		if mod2 ~= nil then
			LOG("[TRUELCH] mod2 EXISTS!!! YAY")
			--LOG("[TRUELCH] tostring(mod2): "..tostring(mod2))
			--LOG("[TRUELCH] save_table(mod2): "..save_table(mod2))
		else
			LOG("[TRUELCH] mod2 is nil :(")
		end

		mod2.worldConstants:setHeight(ret2, 1)
		local leap = PointList()
		leap:push_back(]]..p1:GetString()..[[)
		leap:push_back(]]..p2:GetString()..[[)
		ret2:AddLeap(leap, FULL_DELAY)
		mod2.worldConstants:resetHeight(ret2)

		mod2.worldConstants:setHeight(ret2, 1)
		local leap2 = PointList()
		leap2:push_back(]]..p2:GetString()..[[)
		leap2:push_back(]]..p1:GetString()..[[)
		ret2:AddLeap(leap2, NO_DELAY)
		mod2.worldConstants:resetHeight(ret2)

		Board:AddEffect(ret2)
	]])

	return ret
end