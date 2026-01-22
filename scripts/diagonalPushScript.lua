truelch_diagonal_mod = mod_loader.mods[modApi.currentMod]

--Maybe the function is unnecessary? Since truelch_diagonal_mod is also global?
function TruelchGetDiagMod()
	return truelch_diagonal_mod
end

truelch_DiagonalPushScript = ArtilleryDefault:new{
    Name = "Diagonal Push (Script)",
    Description = "Simple artillery with diagonal push.",
    Class = "Ranged",
    Icon = "weapons/ranged_artillery.png",
    Rarity = 3,
    PowerCost = 0,
    LaunchSound = "/weapons/modified_cannons",
	ImpactSound = "/impact/generic/explosion",	
	UpShot = "effects/shotup_tribomb_missile.png",
	ExplosionCenter = "ExploArt1",
	TipImage = {
		Unit   = Point(2, 4),
		Enemy  = Point(2, 2),
		Enemy2 = Point(3, 3),
		Target = Point(2, 2),
	}
}

function truelch_DiagonalPushScript:GetTargetArea(point)
	local ret = PointList()

	for dir = DIR_START, DIR_END do
		for k = 2, 7 do
			local curr = point + DIR_VECTORS[dir]*k
			ret:push_back(curr)
		end
	end

	local offsets = { Point(-1, -1), Point(1, -1), Point(1, 1), Point(-1, 1) }

	for i, offset in ipairs(offsets) do
		for k = 2, 7 do
			local curr = point + offset*k
			if Board:IsValid(curr) then
				ret:push_back(curr)
			else
				break
			end
		end
	end

	return ret
end

Truelch_SetPos_se = nil
Truelch_SetPos_pawnId = nil
Truelch_SetPos_pos = nil
function Truelch_SetPos(se, pawnId, pos)
	Truelch_SetPos_se = se
	Truelch_SetPos_pawnId = pawnId
	Truelch_SetPos_pos = pos

	se:AddScript([[
		local pawn = Board:GetPawn(]]..tostring(Truelch_SetPos_pawnId)..[[)
		pawn:SetSpace(Truelch_SetPos_pos)
	]])

	--Truelch_SetPos_se = nil
	--Truelch_SetPos_pawnId = nil
	--Truelch_SetPos_pos = nil
end

function truelch_DiagonalPushScript:ScriptEffect(ret, pos1, pos2)
	ret:AddScript([[
		LOG("------------------------------ A")
		local mod = TruelchGetDiagMod()
		local se = SkillEffect()
		local p1 = ]]..pos1:GetString()..[[
		local p2 = ]]..pos2:GetString()..[[
		local offsets = { Point(-1, -1), Point(1, -1), Point(1, 1), Point(-1, 1) }
		local pushData = {}
		local terrData = {}

		se:AddBounce(p1, 1)
		local damage = SpaceDamage(p2, 1)
		damage.sAnimation = "ExploArt1"
		se:AddArtillery(p1, damage, "effects/shotup_tribomb_missile.png", NO_DELAY) --FULL_DELAY?
		--If I used FULL_DELAY, it'll add more delay than needed

		--local dist = p1:Manhattan(p2)

		--Seemingly makes the game crashes??!
		local diff = p2 - p1
		local dx = math.abs(diff.x)
		local dy = math.abs(diff.y)
		local dist = math.max(dx, dy)
		se:AddDelay(0.35 + dist * 0.075)

		--se:AddDelay(0.3)

		for i, offset in ipairs(offsets) do
			local leapStart = p2 + offset
			local leapEnd = p2 + offset + offset

			local pawnStart = Board:GetPawn(leapStart)
			local pawnEnd = Board:GetPawn(leapEnd)

			local isValid = Board:IsValid(leapEnd)
			local isBump = Board:IsBlocked(leapEnd, PATH_PROJECTILE)
			local isForceAmp = IsPassiveSkill("Passive_ForceAmp")

			if isValid then

				local leap = PointList()
				leap:push_back(leapStart)
				leap:push_back(leapEnd)

				local pushFx = SpaceDamage(leapStart, 0)
				pushFx.sAnimation = "truelch_airpush_"..(i - 1)
				se:AddDamage(pushFx)

				mod.worldConstants:setHeight(se, 1)
				se:AddLeap(leap, NO_DELAY)
				se.effect:back().bHidePath = true
				mod.worldConstants:resetHeight(se)

				if pawnStart ~= nil then
					if not pawnStart:IsGuarding() and isBump then
						if pawnStart:IsEnemy() and isForceAmp then
							pawnStart:SetHealth(pawnStart:GetHealth() - 2)
						else
							pawnStart:SetHealth(pawnStart:GetHealth() - 1)
						end

						if pawnEnd ~= nil then
							if pawnEnd:IsAbility("tatu_armordillo") then
								--No damage
							elseif pawnEnd:IsEnemy() and isForceAmp then
								pawnEnd:SetHealth(pawnEnd:GetHealth() - 2)
							else
								pawnEnd:SetHealth(pawnEnd:GetHealth() - 1)
							end
						else
							terrData[#terrData+1] = leapEnd
						end

						pushData[#pushData+1] = { pawnStart:GetId(), leapStart }
					end
				end
			end		
		end

		LOG("#pushData: "..tostring(#pushData))

		if #pushData > 0 then
			LOG("se:AddDelay(0.2)")
			se:AddDelay(0.2)
		end

		for _, data in ipairs(pushData) do
			LOG("data[1]: "..tostring(data[1])..", data[2]: "..data[2]:GetString())
			local pawnStart = Board:GetPawn(data[1])
			LOG("pawnStart: "..pawnStart:GetMechName())
			--pawnStart:SetSpace(data[2])
			Truelch_SetPos(se, pawnStart:GetId(), data[2])
		end

		se:AddDelay(0.1)
		LOG("se:AddDelay(0.1)")

		for _, pos in ipairs(terrData) do
			LOG("terrData -> pos: "..pos:GetString())
			local damage = SpaceDamage(pos, 1)
			se:AddDamage(damage)
		end

		se:AddBounce(p2, 1)

		Board:AddEffect(se)
	]])
end

function truelch_DiagonalPushScript:Preview(ret, p1, p2)
	--Reminder: in ItB, Up is (0, -1). Here, I'm doing the opposite; Up = (0, 1)
	--          0: Up          1: Right      2: Down      3: Left
	local offsets = { Point(-1, -1), Point(1, -1), Point(1, 1), Point(-1, 1) }

	local pushData = {}
	local terrData = {}

	for i, offset in ipairs(offsets) do
		local leapStart = p2 + offset
		local leapEnd = p2 + offset + offset

		local pawnStart = Board:GetPawn(leapStart)
		local pawnEnd = Board:GetPawn(leapEnd)

		local isValid = Board:IsValid(leapEnd)
		local isBump = Board:IsBlocked(leapEnd, PATH_PROJECTILE)

		if isValid then
			if pawnStart ~= nil then
				if pawnStart:IsGuarding() then
					--STABLE -> no push (no bump damage either)
					local damage = SpaceDamage(leapStart, 0)
					damage.sImageMark = "combat/icons/diag_push_off_"..(i - 1)..".png"
					ret:AddDamage(damage)
				elseif not isBump then
					--NO BUMP -> push
					local damage = SpaceDamage(leapStart, 0)
					damage.sImageMark = "combat/icons/diag_push_"..(i - 1)..".png"
					ret:AddDamage(damage)
				else
					-- BUMP -> mutual bump damage
					local damage = SpaceDamage(leapStart, 0)
					damage.sImageMark = "combat/icons/diag_push_hit_"..(i - 1)..".png"
					ret:AddDamage(damage)

					--Fake bump damage preview
					local extra_damage_event = SpaceDamage()
					extra_damage_event.loc = leapStart
					extra_damage_event.iPush = 230 -- hack to display hp loss
					truelch_diagonal_mod.weaponPreview:AddDamage(extra_damage_event)			

					--Damage to end (could be pawn, could be grid, could be mountain...)
					if pawnEnd ~= nil then
						if not pawnStart:IsAbility("tatu_armordillo") then
							--Fake bump damage preview
							local extra_damage_event = SpaceDamage()
							extra_damage_event.loc = leapEnd
							extra_damage_event.iPush = 230 -- hack to display hp loss
							truelch_diagonal_mod.weaponPreview:AddDamage(extra_damage_event)
						else
							LOG("[TRUELCH] Tatu's immunity to bump damage!")
						end
					else
						--Just regular damage (wait maybe the safe damage thingy to no trigger fire). Though, it should not be an empty forest
						terrData[#terrData+1] = leapEnd --store data to damage a bit later so we don't damage the leaped unit
					end

					pushData[#pushData+1] = { pawnStart:GetId(), leapStart }
				end
			else
				--There's no pawn to displace
				local damage = SpaceDamage(leapStart, 0)
				damage.sImageMark = "combat/icons/diag_push_off_"..(i - 1)..".png"
				ret:AddDamage(damage)
			end
		end
	end



end

function truelch_DiagonalPushScript:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	--[[
	local damage = SpaceDamage(p2, 1)
	damage.sAnimation = self.ExplosionCenter
	ret:AddArtillery(damage, self.UpShot, NO_DELAY)
	]]

	self:ScriptEffect(ret, p1, p2)
	self:Preview(ret, p1, p2)

	return ret
end