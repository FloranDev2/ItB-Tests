local mod = {
	id = "truelch_Tests",
	name = "Truelch's Tests",
	--icon = "img/mod_icon.png",
	version = "0.0.1",
	modApiVersion = "2.9.2",
	--gameVersion = "1.2.88",
    dependencies = {
		memedit = "1.2.0", --was 1.0.4
        modApiExt = "1.21",
    }
}

function mod:init()
	--Libs
	--Weapon armed is used by one of these libs (I think artilleryArc)
	self.artilleryArc   = require(self.scriptPath.."libs/artilleryArc")
	self.worldConstants = require(self.scriptPath.."libs/worldConstants")
	self.weaponPreview  = require(self.scriptPath.."libs/weaponPreview")
	--self.customAnim     = require(self.scriptPath.."libs/customAnim")

	--Assets
	--Fake artillery arcs
	local path = "combat/icons/arty_"
	local locs = {
--index for dist is dist-1
--dist:   2                3                4                  5                  6                  7                    --index for dir is dir+1 since indexes start at 1 in lua
		{ Point( -6, -83), Point( -6, -95), Point(  -5, -108), Point(  -5, -122), Point(  -4, -137), Point(  -4, -153) }, --dir: 0 (DIR_UP) (problem starting from 4)
		{ Point( -6, -40), Point( -6, -34), Point(  -5,  -28), Point(  -5,  -23), Point(  -4,  -18), Point(  -4,  -14) }, --dir: 1 (DIR_RIGHT)
		{ Point(-60, -40), Point(-90, -33), Point(-114,  -27), Point(-144,  -22), Point(-171,  -17), Point(-198,  -13) }, --dir: 2 (DIR_DOWN)
		{ Point(-63, -83), Point(-90, -95), Point(-114, -108), Point(-141, -122), Point(-161, -137), Point(-190, -153) }, --dir: 3 (DIR_LEFT)
	}
	for dir = DIR_START, DIR_END do
		--LOG("dir: "..dir)
		for k = 2, 7 do
			--LOG("k: "..k)
			local str = path..dir.."_"..k..".png"
			--LOG("str: "..str)
			local loc = locs[dir+1][k-1]
			--LOG("loc: "..loc:GetString())
			modApi:appendAsset("img/"..str, self.resourcePath.."img/"..str)
				Location[str] = loc
		end
	end

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

					--LOG("anim: "..anim)

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
	--require(self.scriptPath.."diagonalPushScript")

	require(self.scriptPath.."testPreview") --truelch_TestPreview
	--require(self.scriptPath.."testExt") --truelch_TestExt
	--require(self.scriptPath.."testExt2") --truelch_TestExt2

	--Then, press enter and close the console
end


function mod:load(options, version)
end

return mod