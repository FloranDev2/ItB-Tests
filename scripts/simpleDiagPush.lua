--[[
Should not be functional yet.
I was trying to make a simpler weapon to test other things but anyway it doesn't reduce much of the code.

]]


local mod = mod_loader.mods[modApi.currentMod]

truelch_SimpleDiagPush = ArtilleryDefault:new{
    Name = "Diagonal Push",
    Description = "Simple artillery with diagonal push.",
    Class = "Ranged",
    Icon = "weapons/ranged_artillery.png",
    Rarity = 3,
    PowerCost = 0,
    LaunchSound = "/weapons/modified_cannons",
	ImpactSound = "/impact/generic/explosion",	
	UpShot = "effects/shotup_tribomb_missile.png",
	--ExplosionCenter = "ExploArt1",
}

function truelch_SimpleDiagPush:GetTargetArea(point)
	local ret = PointList()

	for j = 0, 7 do
		for i = 0, 7 do
			ret:push_back(Point(i, j))
		end
	end

	return ret
end


function truelch_SimpleDiagPush:GetSkillEffect(p1, p2)
	local ret = SkillEffect()

	--Arbitrary diag dir
	local offset = Point(-1, -1)

	local leapStart = p2 + offset
	local leapEnd = p2 + offset + offset

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
	end

	ret:AddDelay(0.1)

	----- THIRD LOOP -----
	for _, pos in ipairs(terrData) do
		local damage = SpaceDamage(pos, 1)
		ret:AddDamage(damage)
	end

	return ret
end