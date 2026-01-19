local mod = mod_loader.mods[modApi.currentMod]

--[[
TODO:
- make the unit play their hurt sound
- preview doesn't show the bump damage
- maybe hide the semi-transparent unit at the end pos
- damage the bumped units after the leaped unit comes back ot its position (it's too early atm)
- do a target area that's also diagonal????

tosx and lemon:
- There's a spacedamage.iPush value that gives a directionless square; I think I used it for the Far Line lighthouse attack
- local lens = SpaceDamage(p2,0,5) --5 gives a directionless push square
- Look at magnetic golems Catapult weapon, Lemonymous gave me some code to fake bump damage, I think it mostly works (if there are cases where it doesn't, I'm not sure what they are)
- https://github.com/Lemonymous/ITB-LemonymousMods/blob/f6fb784359235e374ad23cbb2b0b6f067bcd36c2/mods/Bots'n'Bugs/scripts/secret.lua#L1190
]]

truelch_DiagonalPush = ArtilleryDefault:new{
    Name = "Diagonal Push",
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
						if not pawnStart:IsAbility("tatu_armordillo") then
							ret:AddScript([[
								local pawnEnd = Board:GetPawn(]]..pawnEnd:GetId()..[[)
								if pawnEnd:IsEnemy() and ]]..tostring(isForceAmp)..[[ then
									pawnEnd:SetHealth(pawnEnd:GetHealth() - 2)
								else
									pawnEnd:SetHealth(pawnEnd:GetHealth() - 1)
								end
							]])
						else
							LOG("[TRUELCH] Tatu's immunity to bump damage!")
						end
					else
						--Just regular damage (wait maybe the safe damage thingy to no trigger fire). Though, it should not be an empty forest
						terrData[#terrData+1] = leapEnd --store data to damage a bit later so we don't damage the leaped unit
					end

					pushData[#pushData+1] = { tostring(pawnStart:GetId()), leapStart:GetString() }
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
		ret:AddScript([[
			local pawnStart = Board:GetPawn(]]..data[1]..[[)
			pawnStart:SetSpace(]]..data[2]..[[)
		]])

		--AddLeap
		--This is likely to fail since there might be two pawns at this location
		--[[
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