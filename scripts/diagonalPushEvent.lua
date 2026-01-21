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

truelch_DiagonalPushEvent = ArtilleryDefault:new{
    Name = "Diagonal Push (Event)",
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

function truelch_DiagonalPushEvent:GetTargetArea(point)
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

function truelch_DiagonalPushEvent:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	ret:AddBounce(p1, 1)

	local artyDamage = SpaceDamage(p2, 0)
	artyDamage.sAnimation = "ExploArt1"

	local offsets = { Point(-1, -1), Point(1, -1), Point(1, 1), Point(-1, 1) }

	for i, offset in ipairs(offsets) do
		local leapStart = p2 + offset
		local leapEnd = p2 + offset + offset

		local pawnStart = Board:GetPawn(leapStart)
		local pawnEnd = Board:GetPawn(leapEnd)

		local isValid = Board:IsValid(leapEnd)
		local isBump = Board:IsBlocked(leapEnd, PATH_PROJECTILE)

		local isForceAmp = IsPassiveSkill("Passive_ForceAmp")

		--Big logic
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

					if not pawnStart:IsAbility("tatu_armordillo") then
						--Bump Damage
						if pawnStart:IsEnemy() and isForceAmp then
							--TODO: display 2 damage
						else
							--TODO: display 1 damage
						end
					else
						LOG("[TRUELCH] Tatu's immunity to bump damage!") --I guess this would never happen anyway because Tatu's cannot be pushed
					end					

					--Damage to end (could be pawn, could be grid, could be mountain...)
					if pawnEnd ~= nil then
						if not pawnStart:IsAbility("tatu_armordillo") then
							if pawnEnd:IsEnemy() and isForceAmp then
								--TODO: display 2 damage
							else
								--TODO: display 1 damage
							end
						else
							LOG("[TRUELCH] Tatu's immunity to bump damage!")
						end
					else
						--Just regular damage (wait maybe the safe damage thingy to no trigger fire). Though, it should not be an empty forest
						local terrDamage = SpaceDamage(leapEnd, 1)
						ret:AddDamage(terrDamage)
					end
				end
			else
				--There's no pawn to displace
				local damage = SpaceDamage(leapStart, 0)
				damage.sImageMark = "combat/icons/diag_push_off_"..(i - 1)..".png"
				ret:AddDamage(damage)
			end
		end
	end --End of the 1st loop

	--ret:AddDamage(artyDamage)
	ret:AddArtillery(artyDamage, "effects/shotup_tribomb_missile.png", NO_DELAY)
	--ret:AddArtillery(artyDamage, "effects/shotup_tribomb_missile.png", FULL_DELAY)

	LOG("[TRUELCH] truelch_DiagonalPushEvent:GetSkillEffect - END")

    return ret
end


local function computeEffect(pawn, p1, p2--[[, ret]])
	LOG("[TRUELCH] computeEffect(pawn: "..pawn:GetMechName()..", p1: "..p1:GetString()..", p2: "..p2:GetString()..")")

	local ret = SkillEffect()

	--[[
	if ret ~= nil then
		LOG("[TRUELCH] ret ~= nil")
	else
		LOG("[TRUELCH] ret IS NIL :(")
	end
	]]

	--ret:AddBounce(p1, 1)
	local damage = SpaceDamage(p2, 1)
	damage.sAnimation = "ExploArt1"

	--LOG("[TRUELCH] computeEffect BEFORE AddArtillery")

	--ret:AddArtillery(damage, "effects/shotup_tribomb_missile.png") --FULL_DELAY? (starts from outside the terrain since it doesn't have a p1)
	--ret:AddArtillery(p1, damage, "effects/shotup_tribomb_missile.png") --DOES NOT WORK
	ret:AddArtillery(p1, damage, "effects/shotup_tribomb_missile.png", FULL_DELAY) --This one is the best working (ae_weapons.lua, line 2338)
	--ret:AddArtillery(p1, damage, "effects/shotup_tribomb_missile.png", NO_DELAY) --ae_weapons.lua, line 2338
	--ret:AddArtillery(p1, "effects/shotup_tribomb_missile.png") --DOES NOT WORK (ae_weapons.lua, line 2523)

	--LOG("[TRUELCH] computeEffect AFTER AddArtillery")

	--Reminder: in ItB, Up is (0, -1). Here, I'm doing the opposite; Up = (0, 1)
	--          0: Up          1: Right      2: Down      3: Left
	local offsets = { Point(-1, -1), Point(1, -1), Point(1, 1), Point(-1, 1) }

	local pushData = {}
	local terrData = {}

	----- FIRST LOOP -----
	LOG("[TRUELCH] ----- FIRST LOOP -----")
	for i, offset in ipairs(offsets) do
		LOG("[TRUELCH] i: "..tostring(i))
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
				elseif not isBump then
					--NO BUMP -> push
				else
					-- BUMP -> mutual bump damage
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
			end
		end
	end --End of the 1st loop

	LOG("[TRUELCH] #pushData: "..tostring(#pushData))

	--Delay
	if #pushData > 0 then
		ret:AddDelay(0.2)
	end

	----- SECOND LOOP -----
	LOG("[TRUELCH] ----- SECOND LOOP -----")
	--After main loop: apply fake bump damage
	--And move back
	for _, data in ipairs(pushData) do
		--SetSpace
		ret:AddScript([[
			local pawnStart = Board:GetPawn(]]..data[1]..[[)
			pawnStart:SetSpace(]]..data[2]..[[)
		]])
	end

	ret:AddDelay(0.1)

	----- THIRD LOOP -----
	LOG("[TRUELCH] ----- THIRD LOOP -----")
	for _, pos in ipairs(terrData) do
		local damage = SpaceDamage(pos, 1)
		ret:AddDamage(damage)
	end

	--ret.iOwner = pawn:GetId() --idk

	LOG("[TRUELCH] ----- (END)-----")

	Board:AddEffect(ret) --only for EVENT_skillStart, to comment for EVENT_skillBuild / HOOK_skillBuild
end

local EVENT_skillStart = function(mission, pawn, weaponId, p1, p2)
	--LOG(string.format("%s is using %s at %s!", pawn:GetMechName(), weaponId, p2:GetString()))

	--TODO: check if it's any variant (upgrade _A, _B, _AB) of the weapon
	if weaponId == "truelch_DiagonalPushEvent" then
		computeEffect(pawn, p1, p2)
	end
end

modapiext.events.onSkillStart:subscribe(EVENT_skillStart)



--Does exactly the same as doing the whole thing in the GetSkillEffect
--For some reason, the event doesn't pass through the skillEffect, while the hook does
--local EVENT_skillBuild = function(mission, pawn, weaponId, p1, p2, skillEffect)
local HOOK_skillBuild = function(mission, pawn, weaponId, p1, p2, skillEffect)
	--LOG("[TRUELCH] EVENT_skillBuild")
	--LOG("[TRUELCH] HOOK_skillBuild")

	if skillEffect ~= nil then
		LOG("[TRUELCH] skillEffect ~= nil")
		LOG("[TRUELCH] skillEffect.iOwner: "..type(skillEffect.iOwner)) --number
		LOG("[TRUELCH] tostring(skillEffect.iOwner): "..tostring(skillEffect.iOwner)) --is -1 for some reason
	else
		LOG("[TRUELCH] skillEffect IS NIL :(")
	end

	if weaponId == "truelch_DiagonalPushEvent" then
		computeEffect(pawn, p1, p2, skillEffect)
	end
end

--modapiext.events.onSkillStart:subscribe(EVENT_skillBuild) --skillEffect is nil?!
--[[
local function EVENT_onModsLoaded()
	modapiext:addSkillBuildHook(HOOK_skillBuild)
end

modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)
]]