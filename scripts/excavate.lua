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

truelch_Excavate = Skill:new{
    Name = "Excavate",
    Description = "Force an enemy to emerge.",
    Class = "",
    Icon = "",
}

function truelch_Excavate:GetTargetArea(point)
    local ret = PointList()

    if isMission() then
        local mission = GetCurrentMission()
        for j = 0, 7 do
            for i = 0, 7 do
                local curr = Point(i, j)
                local spawn = GetCurrentMission():GetSpawnPointData(curr)
                if spawn ~= nil then
                    ret:push_back(curr)
                end
            end
        end
    end

    return ret
end

function truelch_Excavate:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    ret:AddScript([[
        local mission = GetCurrentMission()
        local spawn2 = mission:GetSpawnPointData(]]..p2:GetString()..[[)
        if spawn2 ~= nil then
            Board:AddPawn(spawn2.type, ]]..p2:GetString()..[[)
            if Board:GetPawn(]]..p2:GetString()..[[) ~= nil then
                Board:GetPawn(]]..p2:GetString()..[[):SpawnAnimation()
            end
            mission:RemoveSpawnPoint(]]..p2:GetString()..[[)
        end
    ]])
    return ret
end