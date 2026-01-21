local mod = mod_loader.mods[modApi.currentMod]

truelch_TestPreview = Skill:new{
	Name = "Test Preview",
	Description = "Test some previews.",
	Class = "",
	Icon = "",
}

function truelch_TestPreview:GetTargetArea(point)
	local ret = PointList()

	for j = 0, 7 do
		for i = 0, 7 do
			ret:push_back(Point(i, j))
		end
	end

	return ret
end

function truelch_TestPreview:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	local damage = SpaceDamage(p2, 0)
	ret:AddDamage(damage)

	for dir = DIR_START, DIR_END do
		local loc = p2 + DIR_VECTORS[dir]
		local extra_damage_event = SpaceDamage()
		extra_damage_event.loc = loc
		extra_damage_event.iPush = 230 -- hack to display hp loss
		mod.weaponPreview:AddDamage(extra_damage_event)
	end

	return ret
end