local function isGame()
    return true
        and Game ~= nil
        and GAME ~= nil
end

local function isMission()
    local mission = GetCurrentMission()

    return true
        and isGame()
        and mission ~= nil
        and mission ~= Mission_Test
end

truelch_PermanentHp = Skill:new{
	Name = "Test health bonus",
	Description = "Give a + 1HP permanant bonus.",
	Class = "",
	Icon = "",
}

function truelch_PermanentHp:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	ret:AddScript("Board:GetPawn("..p1:GetString().."):SetMaxHealth(Board:GetPawn("..p1:GetString().."):GetMaxHealth()+1)")
	ret:AddScript("Board:GetPawn("..p1:GetString().."):SetHealth(Board:GetPawn("..p1:GetString().."):GetMaxHealth())")
	if isMission() then --you don't want the player to earn permanent HP in test mode ;)
		ret:AddScript("GAME.Djinn_HealthBonus[Board:GetPawn("..p1:GetString().."):GetId()] = GAME.Djinn_HealthBonus[Board:GetPawn("..p1:GetString().."):GetId()]+1")
	end
	return ret
end

function truelch_PermanentHp:GetTargetArea(point)
	local ret = PointList()
	ret:push_back(point)	
	return ret
end

local function EVENT_GameStart()
	GAME.Djinn_HealthBonus = {}
	for i = 0, 2 do
		GAME.Djinn_HealthBonus[i] = 0
	end
end

local function EVENT_MissionStart(mission)
	for i = 0, 2 do
		if GAME.Djinn_HealthBonus[i] ~= nil and GAME.Djinn_HealthBonus[i] > 0 then
			local mech = Board:GetPawn(i)
			mech:SetMaxHealth(mech:GetMaxHealth() + GAME.Djinn_HealthBonus[i])
			mech:SetHealth(mech:GetMaxHealth())
		end
	end
end

modApi.events.onPostStartGame:subscribe(EVENT_GameStart)
modApi.events.onMissionStart:subscribe(EVENT_MissionStart)