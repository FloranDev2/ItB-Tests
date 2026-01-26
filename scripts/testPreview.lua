local mod = mod_loader.mods[modApi.currentMod]

truelch_TestPreview = Skill:new{
	Name = "Test Preview",
	Description = "Test some previews.",
	Class = "",
	Icon = "advanced/weapons/Brute_TC_GuidedMissile.png",
}

function truelch_TestPreview:GetTargetArea(point)
	local ret = PointList()

	--[[
	for j = 0, 7 do
		for i = 0, 7 do
			ret:push_back(Point(i, j))
		end
	end
	]]

	for dir = DIR_START, DIR_END do
		for k = 2, 7 do
			local curr = point + DIR_VECTORS[dir]*k
			ret:push_back(curr)
		end
	end

	return ret
end


function truelch_TestPreview:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	local fakeArc = SpaceDamage(p1, 0)
	local dir = GetDirection(p2 - p1)
	local distance = p1:Manhattan(p2)
	fakeArc.sImageMark = "combat/icons/arty_"..dir.."_"..distance..".png"
	ret:AddDamage(fakeArc)

	--:AddDamage(spaceDamage, duration)
	--local damage = SpaceDamage(p2, 2)
	--mod.weaponPreview:AddDamage(damage, 1)

	local previewArtillery = SpaceDamage(p2, 0)
	previewArtillery:SetType(1) --constant for artillery
	--mod.weaponPreview:AddDamage(previewArtillery)
	ret:AddDamage(previewArtillery) --just to see if it works normally

	--:AddDesc(point, desc, flag, duration)
	--mod.weaponPreview:AddDesc(p2, "ZOG ZOG", true, 1) --this changes the tile description (or rather title of the tile info pop up)

	--:AddSimpleColor(point, gl_color, duration)
	--:AddColor(point, gl_color, duration)
	--addSimpleColor

	return ret
end