local mod = {
	id = "truelch_Tests",
	name = "Truelch's Tests",
	--icon = "img/mod_icon.png",
	version = "0.0.1",
	modApiVersion = "2.9.2",
	--gameVersion = "1.2.88",
    dependencies = {
		memedit = "1.0.4",
        modApiExt = "1.21",
    }
}

function mod:init()
	--Libs
	--Weapon armed is used by one of these libs (I think artilleryArc)
	self.artilleryArc   = require(self.scriptPath.."libs/artilleryArc")
	self.worldConstants = require(self.scriptPath.."libs/worldConstants")
	self.weaponPreview  = require(self.scriptPath.."libs/weaponPreview")

	--Assets
	--Image Mark
	local path = "combat/icons/diag_push_"
	local locs = { Point(-22, -20), Point(-2, 0),  Point(-22, 20), Point(-42, 0) }
	local txts = { "", "off_", "guard_", "hit_" }
	for i, loc in ipairs(locs) do
		for j, txt in ipairs(txts) do
			local str = path..txt..(i - 1)..".png"
			--LOG("[TRUELCH] str: "..str)
			modApi:appendAsset("img/"..str, self.resourcePath.."img/"..str)
				Location[str] = loc
		end
	end

	--Animations
	for i = 0, 3 do
		local loc = locs[i + 1]
		--LOG("loc: "..loc:GetString())

		modApi:appendAsset("img/effects/airpush_"..i..".png", self.resourcePath.."img/effects/airpush_"..i..".png")
			Location["effects/airpush_"..i..".png"] = loc

		ANIMS["truelch_airpush_"..i] = Animation:new{
			Image = "effects/airpush_"..i..".png",
			PosX = loc.x,
			PosY = loc.y,
			Time = 0.08,
			NumFrames = 8,
		}
	end

	--To have these weapon, outside a mission, open the console and type the following:
	require(self.scriptPath.."excavate") --weapon truelch_Excavate
	require(self.scriptPath.."permanentHp") --weapon truelch_PermanentHp

	require(self.scriptPath.."diagonalPush")
	require(self.scriptPath.."diagonalPushEvent")
	require(self.scriptPath.."diagonalPushMeta")

	require(self.scriptPath.."testPreview") --truelch_TestPreview
	require(self.scriptPath.."testCharge") --truelch_TestCharge

	--Then, press enter and close the console
end


function mod:load(options, version)
end

return mod