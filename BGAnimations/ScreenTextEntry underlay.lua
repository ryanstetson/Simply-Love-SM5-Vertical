local af = Def.ActorFrame{}

local border_width = 2
local ins_x = _screen.cx
local ins_y = _screen.cy-40
local ins_w = _screen.w*0.75
local ins_h = _screen.h*0.25
local txt_x = _screen.cx
local txt_y = _screen.cy+16
local txt_w = _screen.w*0.75
local txt_h = 40

if SCREENMAN:GetTopScreen():GetName() == "ScreenSelectMusic" then
	border_width = 1
	ins_x = 62.5
	ins_y = 127
	ins_w = 125
	ins_h = 50
	txt_x = 62.5
	txt_y = 165
	txt_w = 125
	txt_h = 30
end


-- darken the entire screen slightly
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0) end,
	OnCommand=function(self) self:accelerate(0.5):diffusealpha(0.5) end,
	OffCommand=function(self) self:accelerate(0.5):diffusealpha(0) end
}

-- Intructions BG
af[#af+1] = Def.Quad {
	InitCommand=function(self) self:xy(ins_x, ins_y):zoomto(ins_w, ins_h):diffuse(GetCurrentColor()) end
}
-- white border
af[#af+1] = Border(ins_w, ins_h, border_width) .. {
	InitCommand=function(self) self:xy(ins_x, ins_y) end
}


-- Text Entry BG
af[#af+1] = Def.Quad {
	InitCommand=function(self) self:xy(txt_x, txt_y):zoomto(txt_w, txt_h):diffuse(0,0,0,1) end
}
-- white border
af[#af+1] = Border(txt_w, txt_h, border_width)..{
	InitCommand=function(self) self:xy(txt_x, txt_y) end
}

return af
