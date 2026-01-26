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
	self.customAnim     = require(self.scriptPath.."libs/customAnim")

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

	----- ANIMATIONS -----
	--Air push
	for i = 0, 3 do
		local loc = locs[i + 1]

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

	--Fake bump damage
	--health_<armored>_<max_health>_<curr_health>_<bump_damage>
	--[[
	local animName = "health_1_1_1"
	local anim = "effects/"..animName..".png"
	modApi:appendAsset("img/"..anim, self.resourcePath.."img/"..anim)
		Location[anim] = Point(-10, -10)

	ANIMS[animName] = Animation:new{
		Image = anim,
		PosX = -10,
		PosY = -10,
		Time = 0.08,
		NumFrames = 6,
		Layer = ANIMS.LAYER_FRONT,
		Loop = false,
	}
	]]

	local arm = { false, true }
	for max = 1, 6 do
		for curr = 1, max do
			for bumpDmg = 1, math.min(2, curr) do
				for _, armored in ipairs(arm) do
					local anim = "health_"
					if armored then
						anim = anim.."armor_"
					end
					anim = anim..max.."_"..curr.."_"..bumpDmg

					LOG("anim: "..anim)

					modApi:appendAsset("img/effects/"..anim..".png", self.resourcePath.."img/effects/"..anim..".png")
						Location["effects/"..anim..".png"] = Point(-10, -10)

					ANIMS[anim] = Animation:new{
						Image = "effects/"..anim..".png",
						PosX = -10,
						PosY = -10,
						Time = 0.12,
						NumFrames = 6,
						Layer = ANIMS.LAYER_FRONT,
						Loop = false,
					}
				end
			end
		end
	end

	--To have these weapon, outside a mission, open the console and type the following:
	require(self.scriptPath.."excavate") --weapon truelch_Excavate
	require(self.scriptPath.."permanentHp") --weapon truelch_PermanentHp

	--require(self.scriptPath.."diagonalPush")
	--require(self.scriptPath.."diagonalPushEvent")
	--require(self.scriptPath.."diagonalPushMeta")
	--require(self.scriptPath.."diagonalPushExt")
	require(self.scriptPath.."diagonalPushScript")

	require(self.scriptPath.."testPreview") --truelch_TestPreview
	--require(self.scriptPath.."testExt") --truelch_TestExt
	--require(self.scriptPath.."testExt2") --truelch_TestExt2

	--Then, press enter and close the console
end


function mod:load(options, version)
end

return mod