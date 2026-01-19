	--Just a test. This displays hollow squares on the ground.
	--[[
	local tosxDamage = SpaceDamage(Point(7, 7), 0, 5)
	ret:AddDamage(tosxDamage)
	local tosxDamage = SpaceDamage(Point(0, 0), 0, 5)
	ret:AddDamage(tosxDamage)
	]]

function truelch_DiagonalPush:GetSkillEffect_TestInTheVaccum(p1, p2)
	local ret = SkillEffect()

	local leapStart = p1
	local leapEnd = p2

	--V3
	mod.worldConstants:setHeight(ret, 1) -- Think of this line as ret:changeWorldConstants(..
	-- The code in the script runs between the time the world constants changed and was reset
	ret:AddScript(string.format([[
	    local p1, p2 = %s, %s;
	    local fx = SkillEffect();
	    local leap = PointList();
	    leap:push_back(p1);
	    leap:push_back(p2);
	    fx:AddLeap(leap, NO_DELAY);
	    sdLeap = fx.effect:index(fx.effect:size());
	    Board:AddEffect()
	    Board:DamageSpace(sdLeap);
	]], leapStart:GetString(), leapEnd:GetString()))
	mod.worldConstants:resetHeight(ret) -- Think of this line as ret:resetWorldConstants(..

	return ret
end

			--Bump
			--[[
			local extra_damage_event = SpaceDamage()
			extra_damage_event.loc = leapStart
			extra_damage_event.iPush = 230 -- hack to display hp loss
			mod.weaponPreview:AddDamage(extra_damage_event)
			extra_damage_event.loc = leapEnd
			extra_damage_event.iPush = 230 -- hack to display hp loss
			mod.weaponPreview:AddDamage(extra_damage_event)
			]]

			--V1
			--original --->
			mod.worldConstants:setHeight(ret, 1)
			ret:AddLeap(leap, NO_DELAY)			
			ret.effect:back().bHidePath = true
			mod.worldConstants:resetHeight(ret)
			-- <--- original
			
			--[[
			local currMod = modApi.currentMod
			if currMod ~= nil then
				LOG("[TRUELCH] type(currMod): "..type(currMod))
				LOG("[TRUELCH] currMod: "..currMod)
			else
				LOG("[TRUELCH] currMod is nil") --here
			end

			--local mod = mod_loader.mods[modApi.currentMod]
			--
			if mod ~= nil then
				LOG("[TRUELCH] type(mod): "..type(mod))
				LOG("[TRUELCH] mod: "..mod)
				LOG("[TRUELCH] save_table(mod): "..save_table(mod))
			else
				LOG("[TRUELCH] mod is nil")
			end
			]]


			--V2
			ret:AddScript([[
				local se = SkillEffect()
				mod.worldConstants:setHeight(se, 1)
				local leap = PointList()
				leap:push_back(]]..leapStart:GetString()..[[)
				leap:push_back(]]..leapEnd:GetString()..[[)
				se:AddLeap(leap, NO_DELAY)
				Board:AddEffect(se)
				mod.worldConstants:resetHeight(se)
			]])


			--V2.5
			mod.worldConstants:setHeight(ret, 1)
			ret:AddScript([[
				local se = SkillEffect()
				local leap = PointList()
				leap:push_back(]]..leapStart:GetString()..[[)
				leap:push_back(]]..leapEnd:GetString()..[[)
				se:AddLeap(leap, NO_DELAY)
				Board:AddEffect(se)
			]])
			mod.worldConstants:resetHeight(ret)


			--V3
			mod.worldConstants:setHeight(ret, 1) -- Think of this line as ret:changeWorldConstants(..
			-- The code in the script runs between the time the world constants changed and was reset
			ret:AddScript(string.format([[
			    local p1, p2 = %s, %s;
			    local fx = SkillEffect();
			    local leap = PointList();
			    leap:push_back(p1);
			    leap:push_back(p2);
			    fx:AddLeap(leap, NO_DELAY);
			    sdLeap = fx.effect:index(fx.effect:size());
			    Board:DamageSpace(sdLeap);
			]], leapStart:GetString(), leapEnd:GetString()))
			mod.worldConstants:resetHeight(ret) -- Think of this line as ret:resetWorldConstants(..


			--V4
			mod.worldConstants:setHeight(ret, 1) -- Think of this line as ret:changeWorldConstants(..
			-- The code in the script runs between the time the world constants changed and was reset
			ret:AddScript(string.format([[
				local p1, p2 = %s, %s;
				local fx = SkillEffect();
				local leap = PointList();
				leap:push_back(p1);
				leap:push_back(p2);
				fx:AddLeap(leap, NO_DELAY);
				sdLeap = fx.effect:index(fx.effect:size());
				Board:AddEffect(fx);
			]], leapStart:GetString(), leapEnd:GetString()))
			mod.worldConstants:resetHeight(ret) -- Think of this line as ret:resetWorldConstants(..



	--After main loop: apply fake bump damage
	--And move back
	for _, data in ipairs(pushData) do
		ret:AddScript([[
			local pawnStart = Board:GetPawn(]]..data[1]..[[)
			pawnStart:SetSpace(]]..data[2]..[[)
		]])
	end