--[[      				   Waluigi Client
          
						Made By NameGoesThere


This is a lua script intended to be loaded with the BizHawk emulator, other emulators WILL NOT work with this script.
This script will only work with the popular NES title, Super Mario Bros. This script WILL NOT work with other games.

You can find the BizHawk emulator at https://tasvideos.org/Bizhawk

(note: I don't like lua, and i'm not good at it either, if I made a mistake, please make an issue or a pull request.)
]]--

-- All the different cheats
hacks = {"Powerup State", "Player Size", "Invincibility", "Lives", "Enemy ESP", "Powerup ESP", "Star"}

-- Customizable values for the cheats (some cheats may not need these, so the max and min are set to 0)
values = {0, 0, 0, 3, 0, 0, 0}
maxValues = {2, 1, 0, 127, 0, 0, 0}
minValues = {0, 0, 0, 1, 0, 0, 0}

-- What cheats are enabled
enabled = {false, false, false, false, false, false, false}

-- What cheat is selected
selected = 0

-- Keys pressed
up = joypad.get()["P1 Up"]
down = joypad.get()["P1 Down"]
left = joypad.get()["P1 Left"]
right = joypad.get()["P1 Right"]
press = joypad.get()["P1 A"]

-- Previous keys pressed
prevUp = false
prevDown = false
prevLeft = false
prevRight = false
prevPress = false

-- Is user changing the values of the different cheats
isSettings = false


-- Memory addresses for certain values (DO NOT CHANGE)
PAUSED = 0x0776

POWERUP_STATE = 0x0756
PLAYER_SIZE = 0x0754
INVINCIBILITY = 0x079E
LIVES = 0x075A
STAR = 0x079F

ENEMY_X = 0x03AE
ENEMY_Y = 0x03B9
ENEMY_DRAWN = 0x000F

POWERUP_X = 0x03B3
POWERUP_Y = 0x03BE
POWERUP_DRAWN = 0x0014

-- Gets the hash of the ROM
ROM_HASH = gameinfo.getromhash()

-- Expected hash
CORRECT_HASH = "AB30029EFEC6CCFC5D65DFDA7FBC6E6489A80805"

-- Incorrect ROM
UNEXPECTED_ROM = false
if ROM_HASH ~= CORRECT_HASH then
	console.writeline("WARN: Unexpected ROM hash encountered. Expected: "..CORRECT_HASH..". Got: "..ROM_HASH)
	UNEXPECTED_ROM = true
end

-- Main loop
while true do
	-- Is the user pausing the game?
	local _paused = mainmemory.readbyte(PAUSED)

	-- Changing the previously pressed keys
	prevDown = down
	prevUp = up
	prevPress = press
	prevLeft = left
	prevRight = right

	-- Checking for keyboard input
	up = joypad.get()["P1 Up"]
	down = joypad.get()["P1 Down"]
	left = joypad.get()["P1 Left"]
	right = joypad.get()["P1 Right"]
	press = joypad.get()["P1 A"]


	-- Should the cheat menu be showed?
	if _paused ~= 0 then
		-- Unexpected ROM warning
		if UNEXPECTED_ROM then
			gui.drawText(1, 210, "WARN: Unexpected ROM hash encountered.", 0xffffff00, 0xff000000, 11, "candara")
		end
	
		-- Enables a cheat if you are hovering over it and you click the A button
		if (not isSettings) and press and not prevPress then
			enabled[selected+1] = not enabled[selected+1]
		end
		
		-- Down button pressed
		if down and not prevDown then
			if not isSettings then
				-- Changes the selected cheat
				selected = selected + 1
			else
				-- Decreases the current value (if selected)
				values[selected+1] = values[selected+1] - 1
				if values[selected+1] < minValues[selected+1] then
					values[selected+1] = minValues[selected+1]
				end
			end
		end
		
		-- Up button pressed
		if up and not prevUp then
			if not isSettings then
				-- Changes the selected cheat
				selected = selected - 1
			else
				-- Increases the current value (if selected)
				values[selected+1] = values[selected+1] + 1
				if values[selected+1] > maxValues[selected+1] then
					values[selected+1] = maxValues[selected+1]
				end
			end
		end
		
		-- Makes sure you can't select out of bounds (prevents crashes)
		if selected < 0 then
			selected = #hacks - 1
		elseif selected > #hacks - 1 then
			selected = 0
		end
		
		-- Is changing values
		if right and not prevRight then
			isSettings = true
		elseif left and not prevLeft then
			isSettings = false
		end
		

		-- Cheat menu background
		gui.drawBox( 20, 24, 240, 180, 0x33000000, 0x55000000)
		
		-- Title
		gui.drawText( 21, 25, "Waluigi Client", 0xAAAA60AA, 0x00FFFFFF, 17, "calibri")
		gui.drawText( 20, 24, "Waluigi Client", 0xFFFFB0FF, 0x00FFFFFF, 17, "calibri")
		
		-- Loops over the cheats and renders their names based off of if they are enabled or not.
		for i, h in pairs(hacks) do
				if enabled[i] == false then
					-- Not enabled
					gui.drawText( 21, 25+(i+1)*11, h, 0xFF880000, 0x00000000, 10)
					gui.drawText( 20, 24+(i+1)*11, h, 0xFFFF0000, 0x00000000, 10)
				else
					-- Enabled
					gui.drawText( 21, 25+(i+1)*11, h, 0xFF006600, 0x00000000, 10)
					gui.drawText( 20, 24+(i+1)*11, h, 0xFF00FF00, 0x00000000, 10)
				end
		end
		
		-- Draws the customizable values of the cheats
		for i, h in pairs(values) do
			gui.drawText( 20+100+1, (24+(i+1)*11)+1, h, 0x88303030, 0x00000000, 10)
			gui.drawText( 20+100, 24+(i+1)*11, h, 0xFF909090, 0x00000000, 10)
		end
		
		-- Draws the cursor
		if not isSettings then
			-- Not changing values
			gui.drawBox(18, 24+(selected+2)*11, 20, 24+(selected+2)*11+10, 0xAAFFFFFF, 0xAAFFFFFF)
		else
			-- Changing values
			gui.drawBox(118, 24+(selected+2)*11, 120, 24+(selected+2)*11+10, 0xAAFFFFFF, 0xAAFFFFFF)
		end
	else
		-- Not paused
		selected = 0
		gui.clearGraphics()
	end
	
	
	-- Powerup state cheat
	if enabled[1] == true then
		mainmemory.writebyte(POWERUP_STATE, values[1])
	end
	
	-- Player size cheat
	if enabled[2] == true then
		mainmemory.writebyte(PLAYER_SIZE, 1-values[2])
	end
	
	-- Invincibility cheat
	if enabled[3] == true then
		mainmemory.writebyte(INVINCIBILITY, 2)
	end
	
	-- Lives cheat
	if enabled[4] == true then
		mainmemory.writebyte(LIVES, values[4] - 1)
	end
	
	-- Enemy ESP
	if enabled[5] == true then
		if mainmemory.readbyte(ENEMY_DRAWN) == 1 then
			local x = mainmemory.readbyte(ENEMY_X)
			local y = mainmemory.readbyte(ENEMY_Y)
			gui.drawBox(x, y, x+16, y+16, 0xFFFFB0FF, 0x40FFB0FF)
		end
	end
	
	-- Powerup ESP
	if enabled[6] == true then
		if mainmemory.readbyte(POWERUP_DRAWN) == 1 then
			local x = mainmemory.readbyte(POWERUP_X)
			local y = mainmemory.readbyte(POWERUP_Y)
			gui.drawBox(x, y, x+16, y+16, 0xFFFFB0FF, 0x40FFB0FF)
		end
	end
	
	if enabled[7] == true then
		mainmemory.writebyte(STAR, 2)
	end
	
	-- Update graphics
	emu.frameadvance()
end