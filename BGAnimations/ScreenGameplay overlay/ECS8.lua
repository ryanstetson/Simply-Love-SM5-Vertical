local player = ...
local profile_name = PROFILEMAN:GetPlayerName(player)
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)


-- local WriteOutSongDataToDisk = function()
-- 	-- get songs
-- 	local songs = SONGMAN:GetSongsInGroup("ECS8")
--
-- 	-- get just song titles
-- 	local titles = {}
-- 	for song in ivalues(songs) do
-- 		titles[#titles+1] = song:GetDisplayMainTitle()
-- 	end
--
-- 	-- sort alphabetically
-- 	table.sort(titles)
--
-- 	local s = "ECS.Songs={\n"
-- 	for i,title in ipairs(titles) do
-- 		s = s .."\t[\"" .. title .. "\"] = {id=".. i .."}," .."\n"
-- 	end
-- 	s = s .."}"
--
-- 	local path = "Themes/ECS8/ECS8Data/songs.lua"
-- 	local f = RageFileUtil.CreateRageFile()
--
-- 	if f:Open(path, 2) then
-- 		f:Write( s )
-- 	else
-- 		local fError = f:GetError()
-- 		Trace( "[FileUtils] Error writing to ".. path ..": ".. fError )
-- 		f:ClearError()
-- 	end
--
-- 	f:destroy()
-- end


local CreateScoreFile = function(day, month_string, year, seconds, hour, minute, second)
	local passed_song = pss:GetFailed() and "Failed" or "Passed"

	local dance_points = pss:GetPercentDancePoints()
	local percent_score = FormatPercentScore( dance_points ):sub(1,-2):gsub(" ", "")

	local song = GAMESTATE:GetCurrentSong()
	local group_name = song:GetGroupName()
	local song_name = song:GetMainTitle()

	-- local song_id = ""
	-- if group_name == "ECS8" then
	-- 	song_id = ECS.Songs[song_name] and ECS.Songs[song_name].id or ""
	-- end

	-- ----------------------------------------------------------

	local path = "Themes/ECS8/ECS8Data/"..day..month_string..year.."-"..seconds.."-"..profile_name.."-".."SCORE"..".txt"

	local data = ""
	data = data..percent_score .."\n"
	data = data..passed_song.."\n"
	data = data..group_name.."\n"
	-- data = data..song_id.."\n"
	data = data..song_name.."\n"
	data = data..day.." "..month_string.." "..year.."\n"
	data = data..hour..":"..minute..":"..second

	local f = RageFileUtil.CreateRageFile()

	if f:Open(path, 2) then
		f:Write( data )
	else
		local fError = f:GetError()
		SM("There was some kind of error writing your score to disk.  You should let Ian know.")
		Trace( "[FileUtils] Error writing to ".. path ..": ".. fError )
		f:ClearError()
	end

	f:destroy()
end

local CreateRelicFile = function(day, month_string, year, seconds)


	local path = "Themes/ECS8/ECS8Data/"..day..month_string..year.."-"..seconds.."-"..profile_name.."-".."RELIC"..".txt"
	local data = ""

	for i=1, 4 do
		local relic = ECS.Player.Relics[i]
		local name =  relic and relic.name or "*"
		local oghma = (relic and relic.Oghma) and true or false
		local oghma_player = oghma and relic.Oghma or "*"

		data = data .. name .. "+" .. tostring(oghma) .. "+" .. oghma_player .. "\n"
	end

	local f = RageFileUtil.CreateRageFile()

	if f:Open(path, 2) then
		f:Write( data )
	else
		local fError = f:GetError()
		SM("There was some kind of error writing your score to disk.  You should let Ian know.")
		Trace( "[FileUtils] Error writing to ".. path ..": ".. fError )
		f:ClearError()
	end

	f:destroy()
end

-- ----------------------------------------------------------
local WriteRelicDataToDisk = function()

	local p = PlayerNumber:Reverse()[GAMESTATE:GetMasterPlayerNumber()] + 1
	local profile_dir = PROFILEMAN:GetProfileDir("ProfileSlot_Player"..p)

	if profile_dir then

		local s = "return {\n"
		for relic in ivalues(ECS.Players[profile_name].relics) do
			s = s .. "\t{name=\"" .. relic.name .. "\", chg=" .. relic.chg .."},\n"
		end
		s = s .. "}"


		local f = RageFileUtil.CreateRageFile()
		local path = profile_dir.."Player_Relic_Data.lua"

		if f:Open(path, 2) then
			f:Write( s )
		else
			local fError = f:GetError()
			Trace( "[FileUtils] Error writing to ".. path ..": ".. fError )
			f:ClearError()
		end

		f:destroy()
	end
end

-- ----------------------------------------------------------
-- We need a way to check if the player gave up before the song properly ended.
-- It doesn't look like the engine broadcasts any messages that would be helpful here,
-- so we do the best we can by toggling a flag when the player presses START.
--
-- If the screen's OffCommand occurs while START is being held, we assume they gave up early.
-- It's certainly not foolproof, but I'm unsure how else to handle this.

local start_is_being_held = false
local protect_ring_is_active = false

for relic in ivalues(ECS.Player.Relics) do
	if relic.name == "Protect Ring" then
		protect_ring_is_active = true
	end
end


local InputHandler = function(event)
	if not event.PlayerNumber or not event.button then return false	end
	if protect_ring_is_active then return false end

	if event.GameButton == "Start" then
		start_is_being_held = (not (event.type == "InputEventType_Release"))
	end
end

-- ----------------------------------------------------------

local ExpendChargesOnActiveRelics = function()
	for relic in ivalues(ECS.Players[profile_name].relics) do
		for active_relic in ivalues(ECS.Player.Relics) do
			if active_relic.name == relic.name then
				relic.chg = relic.chg - 1
			end
		end
	end
end

-- ----------------------------------------------------------

local ApplyRelicActions = function()
	for active_relic in ivalues(ECS.Player.Relics) do
		active_relic.action()
	end
end

-- ----------------------------------------------------------
-- actually hook into the screen so that we can do thing at screen's OnCommand and OffCommand

return Def.Actor{
	OnCommand=function(self)
		-- relic actions depend on the current screen,
		-- so ApplyRelicActions() must be called from OnCommand
		ApplyRelicActions()

		ExpendChargesOnActiveRelics()

		SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
	end,
	OffCommand=function(self)
		if start_is_being_held then
			pss:FailPlayer()
			passed_song = "Failed"
		end

		if ECS.Mode ~= "Warmup" then
			local year, month, day = Year(), MonthOfYear() + 1, DayOfMonth()
			local hour, minute, second = Hour(), Minute(), Second()
			local seconds = (hour*60*60) + (minute*60) + second
			local month_string = THEME:GetString("ScreenNameEntryTraditional", "Month"..month)

			CreateScoreFile(day, month_string, year, seconds, hour, minute, second)
			CreateRelicFile(day, month_string, year, seconds)
			WriteRelicDataToDisk()
			-- WriteOutSongDataToDisk()
		end
	end
}