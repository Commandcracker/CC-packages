--(c) 2013 Felix Maxwell
--License: CC BY-SA 3.0

local fps               = 8.5 --Determines how long the system will wait between each update
local maxLifetime       = 10  --Max lifetime of each char
local minLifetime       = 3   --Min lifetime of each char
local maxSourcesPerTick = 1   --Maximum number of sources created each tick
local sourceWeight      = 0   --Affects the chance that no sources will be generated
local greenWeight       = 8   --Threshhold out of 10 that determines when characters will switch from lime to green
local grayWeight        = 0   --Same as about, but from green to gray

local function printCharAt( monitor, x, y, char )
	monitor.setCursorPos( x, y )
	monitor.write( char )
end

local function printGrid( monitor, grid, color )
	for i=1,#grid do
		for o=1,#grid[i] do
			if color then monitor.setTextColor( grid[i][o]["color"] ) end
			printCharAt( monitor, i, o, grid[i][o]["char"] )
		end
	end
end

local function colorLifetime( life, originalLifetime )
	local lifetimePart = originalLifetime/10
	if life < grayWeight*lifetimePart then
		return colors.gray
	elseif life < greenWeight*lifetimePart then
		return colors.green
	else
		return colors.lime
	end
end

local function getRandomChar()
    return string.char(math.random(33, 126))
end

local function tick( screen )

	--update lifetimes
	for x=1,#screen do
		for y=1,#screen[x] do
			screen[x][y]["curLife"] = screen[x][y]["curLife"] - 1
		end
	end

	--make the sources 'fall' and delete timed out chars
	for x=1,#screen do
		for y=1,#screen[x] do
			if screen[x][y]["type"] == "source" and screen[x][y]["curLife"] == 0 then
				screen[x][y]["type"] = "char"
				screen[x][y]["lifetime"] = math.random(minLifetime, maxLifetime)
				screen[x][y]["curLife"] = screen[x][y]["lifetime"]
				screen[x][y]["color"] = colors.lime
			
				if y < #screen[x] then
					screen[x][y+1]["char"] = getRandomChar()
					screen[x][y+1]["lifetime"] = 1
					screen[x][y+1]["curLife"] = 1
					screen[x][y+1]["type"] = "source"
					screen[x][y+1]["color"] = colors.white
				end
			elseif screen[x][y]["curLife"] < 0 then
				screen[x][y]["char"] = " "
				screen[x][y]["lifetime"] = 0
				screen[x][y]["curLife"] = 0
				screen[x][y]["type"] = "blank"
				screen[x][y]["color"] = colors.black
			elseif screen[x][y]["type"] == "char" then
				screen[x][y]["color"] = colorLifetime( screen[x][y]["curLife"], screen[x][y]["lifetime"] )
			end
		end
	end
		
	--create new character sources
	local newSources = math.random( 0-sourceWeight, maxSourcesPerTick )
	for i=1,newSources do
		local col = math.random(1, #screen)
		screen[col][1]["char"] = getRandomChar()
		screen[col][1]["lifetime"] = 1
		screen[col][1]["curLife"] = 1
		screen[col][1]["type"] = "source"
		screen[col][1]["color"] = colors.white
	end
	
	return screen
end

local function setup( w, h )
	local retTab = {}
	for x=1,w do
		retTab[x] = {}
		for y=1,h do
			retTab[x][y] = {}
			retTab[x][y]["char"] = " "
			retTab[x][y]["lifetime"] = 0
			retTab[x][y]["curLife"] = 0
			retTab[x][y]["type"] = "blank"
			retTab[x][y]["color"] = colors.black
		end
	end
	return retTab
end

local function run()
	local color = term.isColor()
	local w, h = term.getSize()
	local screen = setup( w, h )
	while true do
		screen = tick( screen )
		printGrid( term, screen, color )
		os.sleep(1/fps)
	end
end

run()
