local mod = mod_loader.mods[modApi.currentMod]

truelch_DiagonalPush = ArtilleryDefault:new{
    Name = "Diagonal Push (Original)",
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

function truelch_DiagonalPush:GetTargetArea(point)
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

function truelch_DiagonalPush:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	ret:AddBounce(p1, 1)

	local damage = SpaceDamage(p2, 1)

	damage.sAnimation = self.ExplosionCenter

	ret:AddArtillery(damage, self.UpShot) --FULL_DELAY?

	--Reminder: in ItB, Up is (0, -1). Here, I'm doing the opposite; Up = (0, 1)
	--          0: Up          1: Right      2: Down      3: Left
	local offsets = { Point(-1, -1), Point(1, -1), Point(1, 1), Point(-1, 1) }

	local pushData = {}
	local terrData = {}

	----- FIRST LOOP -----
	for i, offset in ipairs(offsets) do
		local leapStart = p2 + offset
		local leapEnd = p2 + offset + offset

		local pawnStart = Board:GetPawn(leapStart)
		local pawnEnd = Board:GetPawn(leapEnd)

		local leap = PointList()
		leap:push_back(leapStart)
		leap:push_back(leapEnd)

		local isValid = Board:IsValid(leapEnd)
		local isBump = Board:IsBlocked(leapEnd, PATH_PROJECTILE)

		local isForceAmp = IsPassiveSkill("Passive_ForceAmp")

		--TODO: check if the unit is Tatu (no bump damage)

		--In any case, I need to play (custom) push effects
		local pushFx = SpaceDamage(leapStart, 0)
		pushFx.sAnimation = "truelch_airpush_"..(i - 1)
		ret:AddDamage(pushFx)

		--Big logic
		if isValid then
			--V1
			--original --->
			mod.worldConstants:setHeight(ret, 1)
			ret:AddLeap(leap, NO_DELAY)
			ret.effect:back().bHidePath = true
			mod.worldConstants:resetHeight(ret)
			-- <--- original

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
					mod.weaponPreview:AddDamage(extra_damage_event)

					if not pawnStart:IsAbility("tatu_armordillo") then
						--Bump Damage
						ret:AddScript([[
							local pawnStart = Board:GetPawn(]]..pawnStart:GetId()..[[)
							if pawnStart:IsEnemy() and ]]..tostring(isForceAmp)..[[ then
								pawnStart:SetHealth(pawnStart:GetHealth() - 2)
							else
								pawnStart:SetHealth(pawnStart:GetHealth() - 1)
							end
						]])
					else
						LOG("[TRUELCH] Tatu's immunity to bump damage!") --I guess this would never happen anyway because Tatu's cannot be pushed
					end					

					--Damage to end (could be pawn, could be grid, could be mountain...)
					if pawnEnd ~= nil then
						if not pawnEnd:IsAbility("tatu_armordillo") then
							ret:AddScript([[
								local pawnEnd = Board:GetPawn(]]..pawnEnd:GetId()..[[)
								if pawnEnd:IsEnemy() and ]]..tostring(isForceAmp)..[[ then
									pawnEnd:SetHealth(pawnEnd:GetHealth() - 2)
								else
									pawnEnd:SetHealth(pawnEnd:GetHealth() - 1)
								end
							]])

							--Fake bump damage preview
							local extra_damage_event = SpaceDamage()
							extra_damage_event.loc = leapEnd
							extra_damage_event.iPush = 230 -- hack to display hp loss
							mod.weaponPreview:AddDamage(extra_damage_event)
						else
							LOG("[TRUELCH] Tatu's immunity to bump damage!")
						end
					else
						--Just regular damage (wait maybe the safe damage thingy to no trigger fire). Though, it should not be an empty forest
						terrData[#terrData+1] = leapEnd --store data to damage a bit later so we don't damage the leaped unit
					end

					--pushData[#pushData+1] = { tostring(pawnStart:GetId()), leapStart:GetString() }
					pushData[#pushData+1] = { pawnStart:GetId(), leapStart }
				end
			else
				--There's no pawn to displace
				local damage = SpaceDamage(leapStart, 0)
				damage.sImageMark = "combat/icons/diag_push_off_"..(i - 1)..".png"
				ret:AddDamage(damage)
			end
		end
	end --End of the 1st loop

	--Delay
	if #pushData > 0 then
		ret:AddDelay(0.2)
	end

	----- SECOND LOOP -----
	--After main loop: apply fake bump damage
	--And move back
	for _, data in ipairs(pushData) do
		--SetSpace
		-- DATA CONVERTED TO STRING
		--ret:AddScript([[
		--	local pawnStart = Board:GetPawn(]]..data[1]..[[)
		--	pawnStart:SetSpace(]]..data[2]..[[)
		--]])

		-- ORIGINAL DATA
		ret:AddScript([[
			local pawnStart = Board:GetPawn(]]..tostring(data[1])..[[)
			pawnStart:SetSpace(]]..data[2]:GetString()..[[)
		]])

		--data[1] -> pawnStart:GetId()
		--data[2] -> leapStart

		--AddLeap
		--This is likely to fail since there might be two pawns at this location
		--[[
		local leap = PointList()
		leap:push_back(Board:GetPawn(data[1]):GetSpace())
		leap:push_back(data[2])
		mod.worldConstants:setHeight(ret, 1)
		ret:AddLeap(leap, NO_DELAY)
		ret.effect:back().bHidePath = true
		mod.worldConstants:resetHeight(ret)
		]]
	end

	ret:AddDelay(0.1)

	----- THIRD LOOP -----
	for _, pos in ipairs(terrData) do
		local damage = SpaceDamage(pos, 1)
		ret:AddDamage(damage)
	end

    return ret
end