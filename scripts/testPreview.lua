local mod = mod_loader.mods[modApi.currentMod]

truelch_TestPreview = Skill:new{
	Name = "Test Preview",
	Description = "Test some previews.",
	Class = "",
	Icon = "advanced/weapons/Brute_TC_GuidedMissile.png",
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

	local s = SpaceDamage(p2)
	--s.bHide = true
	s.sSound = ""
	ret:AddArtillery(s, "")

	local d = SpaceDamage(p2, 1)
	ret:AddDamage(d)

	return ret
end


function truelch_TestPreview:GetSkillEffect_Old(p1, p2)
	local ret = SkillEffect()

	local pawn = Board:GetPawn(p2)

	if pawn ~= nil then
		local damage = SpaceDamage(p2, 0)

		local sfx = _G[pawn:GetType()].SoundLocation.."hurt"

		LOG("sfx: "..sfx)

		damage.sSound = sfx
		--damage.sSound = "/weapons/bomb_strafe"
		--damage.sSound = "/enemy/firefly_soldier_1/hurt"
		ret:AddDamage(damage)


		--ret:AddSound(sfx)
		--ret:AddSound("/weapons/bomb_strafe")
	end

	return ret
end