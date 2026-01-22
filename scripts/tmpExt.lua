function truelch_TestExt:GetSkillEffect(p1, p2)
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

	ret:AddScript([[
		TestExt2_Debug("AddScript - BEFORE")
		local damage = SpaceDamage(]]..p2:GetString()..[[, 1)
		TestExt2_GetRet():AddDamage(damage)
		TestExt2_Debug("AddScript - AFTER")
	]])


--LOG("[TRUELCH] type(testExt2_Ret): "..type(testExt2_Ret)) --user_data
--LOG("[TRUELCH] tostring(testExt2_Ret): "..tostring(testExt2_Ret)) --error

for i = 1, testExt2_Ret.effect:size() do
	--local spaceDamage = testExt2_Ret.effect:index(i)
end	