	--Fake artillery arcs
	local path = "combat/icons/arty_"
	local locs = {
--index for dist is dist-1
--dist:   2            3            4            5            6            7              --index for dir is dir+1 since indexes start at 1 in lua
		{ Point(0, 0), Point(0, 0), Point(0, 0), Point(0, 0), Point(0, 0), Point(0, 0) }, --dir: 0 (DIR_UP)
		{ Point(0, 0), Point(0, 0), Point(0, 0), Point(0, 0), Point(0, 0), Point(0, 0) }, --dir: 1 (DIR_RIGHT)
		{ Point(0, 0), Point(0, 0), Point(0, 0), Point(0, 0), Point(0, 0), Point(0, 0) }, --dir: 2 (DIR_DOWN)
		{ Point(0, 0), Point(0, 0), Point(0, 0), Point(0, 0), Point(0, 0), Point(0, 0) }, --dir: 3 (DIR_LEFT)
	}
	for dir = DIR_START, DIR_END do
		LOG("dir: "..dir)
		for k = 2, 7 do
			LOG("k: "..k)
			local str = path..dir.."_"..k..".png"
			LOG("str: "..str)
			local loc = locs[dir+1][k-1]
			LOG("loc: "..loc:GetString())
			modApi:appendAsset("img/"..str, self.resourcePath.."img/"..str)
				Location[str] = Point(0, 0)
				--Location[str] = loc
		end
	end