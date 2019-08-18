-- There's a lot of Lua in ./BGAnimations/ScreenGameplay overlay
-- and a LOT of Lua in ./BGAnimations/ScreenGameplay underlay
--
-- I'm using files in overlay for logic that *does* stuff without directly drawing
-- any new actors to the screen.
--
-- I've tried to title each file helpfully and partition the logic found in each accordingly.
-- Inline comments in each should provide insight into the objective of each file.
--
-- Def.Actor will be used for each underlay file because I still need some way to listen
-- for events broadcast by the engine.
--
-- I'm using files in Gameplay's underlay for actors that get drawn to the screen.  You can
-- poke around in those to learn more.
------------------------------------------------------------

local af = Def.ActorFrame{}

af[#af+1] = LoadActor("./WhoIsCurrentlyWinning.lua")

for player in ivalues( GAMESTATE:GetHumanPlayers() ) do

	t[#t+1] = LoadActor("./PerColumnJudgmentTracking.lua", player)
	t[#t+1] = LoadActor("./ReceptorArrowsPosition.lua", player)
	t[#t+1] = LoadActor("./JudgmentOffsetTracking.lua", player)
	t[#t+1] = LoadActor("./ECS8.lua", player)
end

return af