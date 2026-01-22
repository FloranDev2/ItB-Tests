local mod = mod_loader.mods[modApi.currentMod]

truelch_TestExt2 = Skill:new{
	Name = "Test Ext 2",
	Description = "Test external functions.",
	Class = "",
	Icon = "advanced/weapons/Prime_TC_Punt.png",
}

function truelch_TestExt2:GetTargetArea(point)
	local ret = PointList()

	for dir = DIR_START, DIR_END do
		local curr = point + DIR_VECTORS[dir]
		ret:push_back(curr)
	end

	return ret
end

testExt2_Occ = 0
testExt2_Ret = nil

function TestExt2_Occ()
	return " [occ: "..tostring(testExt2_Occ).."]"
end

function TestExt2_Debug(msg)
	if testExt2_Ret ~= nil then
		if testExt2_Ret.effect == nil then
			LOG("TestExt2_Debug(msg: "..msg..") -> effect list is nil :("..TestExt2_Occ())
		else
			LOG("TestExt2_Debug(msg: "..msg..") -> amount of effects: "..tostring(testExt2_Ret.effect:size())..TestExt2_Occ())
		end
	else
		LOG("TestExt2_Debug(msg: "..msg..") -> testExt2_Ret does not exist :("..TestExt2_Occ())
	end
end

function TestExt2_GetRet()
	return testExt2_Ret
end


function truelch_TestExt2:GetSkillEffect(p1, p2)
	testExt2_Occ = testExt2_Occ + 1

	LOG("===>>> truelch_TestExt2:GetSkillEffect <<<=== "..TestExt2_Occ())

	local ret = SkillEffect()

	testExt2_Ret = ret

	TestExt2_Debug("GetSkillEffect (before AddScript)"..TestExt2_Occ())

	ret:AddScript([[
		TestExt2_Debug("AddScript - BEFORE")
		local damage = SpaceDamage(]]..p2:GetString()..[[, 1)
		TestExt2_GetRet():AddDamage(damage)
		TestExt2_Debug("AddScript - AFTER")
	]])

	TestExt2_Debug("GetSkillEffect (after AddScript)")

	return ret
end