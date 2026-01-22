local mod = mod_loader.mods[modApi.currentMod]

truelch_TestExt = Skill:new{
	Name = "Test Ext",
	Description = "Test external functions.",
	Class = "",
	Icon = "advanced/weapons/Prime_TC_Punt.png",
}

function truelch_TestExt:GetTargetArea(point)
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
	--local se = 
end

TruelchExtraAddScript_se = nil
TruelchExtraAddScript_pawnId = nil
TruelchExtraAddScript_pos = nil

function TruelchExtraAddScript_OLD(se, pawnId, pos)

	if (se) == nil then LOG("TruelchExtraAddScript -> se == nil :(") else LOG("TruelchExtraAddScript -> se ~= nil :)") end
	LOG("TruelchExtraAddScript -> pawnId: "..tostring(pawnId))
	LOG("TruelchExtraAddScript -> pos: "..pos:GetString())

	TruelchExtraAddScript_se = se
	TruelchExtraAddScript_pawnId = pawnId
	TruelchExtraAddScript_pos = pos

	local damage = SpaceDamage(pos, 0)
	damage.sScript = [[
		local pawn = Board:GetPawn(]]..tostring(TruelchExtraAddScript_pawnId)..[[)
		pawn:SetSpace(TruelchExtraAddScript_pos)
	]]
	se:AddDamage(damage)
end

function TruelchExtraAddScript(se, pawnId, pos)

	if (se) == nil then LOG("TruelchExtraAddScript -> se == nil :(") else LOG("TruelchExtraAddScript -> se ~= nil :)") end
	LOG("TruelchExtraAddScript -> pawnId: "..tostring(pawnId))
	LOG("TruelchExtraAddScript -> pos: "..pos:GetString())

	TruelchExtraAddScript_se = se
	TruelchExtraAddScript_pawnId = pawnId
	TruelchExtraAddScript_pos = pos

	se:AddScript([[
		if (se) == nil then LOG("se:AddScript -> TruelchExtraAddScript_se == nil :(") else LOG("se:AddScript -> TruelchExtraAddScript_se ~= nil :)") end
		LOG("se:AddScript -> TruelchExtraAddScript_pawnId: "..tostring(TruelchExtraAddScript_pawnId))
		LOG("se:AddScript -> TruelchExtraAddScript_pos: "..TruelchExtraAddScript_pos:GetString())

		local pawn = Board:GetPawn(]]..tostring(TruelchExtraAddScript_pawnId)..[[)

		if (pawn) == nil then LOG("se:AddScript -> pawn == nil :(") else LOG("se:AddScript -> pawn ~= nil :)") end

		pawn:SetSpace(TruelchExtraAddScript_pos)
	]])
end

function truelch_TestExt:GetSkillEffect(pos1, pos2)
	local ret = SkillEffect()

	ret:AddScript([[
		local se = SkillEffect()
		local p1 = ]]..pos1:GetString()..[[
		local p2 = ]]..pos2:GetString()..[[
		local pawn = GetPawn(pos1)
		TruelchExtraAddScript(se, pawn:GetId(), p2)
		Board:AddEffect(se)
	]])

	return ret
end



function truelch_TestExt:GetSkillEffect_THISWORKS(pos1, pos2)
	local ret = SkillEffect()

	truelch_mod = mod

	ret:AddScript([[
		local p1 = ]]..pos1:GetString()..[[
		local p2 = ]]..pos2:GetString()..[[
		local se = SkillEffect()
		local dir = GetDirection(p2 - p1)
		
		se:AddBounce(p1, 1)
		
		local damage = SpaceDamage(p1 , 1)
		damage.sAnimation = "ExploAir1"
		se:AddDamage(damage)
		
		damage = SpaceDamage(p2, 2)
		damage.sAnimation = "ExploArt2"
		
		se:AddArtillery(damage, "effects/shotup_ignite_fireball.png", NO_DELAY)
		
		local target = p1 + DIR_VECTORS[dir]
		while target ~= p2 do 
			se:AddBounce(target, 1)
			se:AddDelay(0.1)
			damage = SpaceDamage(target, 1)
			damage.sAnimation = "ExploRaining1"
			damage.sSound = "/weapons/raining_volley_tile"
			se:AddDamage(damage)
			target = target + DIR_VECTORS[dir]
		end
		
		se:AddBounce(p2, 2)

		Board:AddEffect(se)
	]])

	return ret
end


function truelch_TestExt:GetSkillEffect_Test1(p1, p2)
	local ret = SkillEffect()

	truelch_mod = mod

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