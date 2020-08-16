local af = Def.ActorFrame{}

local border_width = 2
local ins_x = 0
local ins_y = 102
local ins_w = 125
local ins_h = 50
local txt_x = 0
local txt_y = 150
local txt_w = 125
local txt_h = 30

-- darken the entire screen slightly
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0) end,
	OnCommand=function(self) self:accelerate(0.5):diffusealpha(0.5) end,
	OffCommand=function(self) self:accelerate(0.5):diffusealpha(0) end
}

-- Intructions BG
af[#af+1] = Def.Quad {
	InitCommand=function(self) self:xy(ins_x, ins_y):halign(0):valign(0):zoomto(ins_w, ins_h):diffuse(GetCurrentColor()) end
}
-- white border
af[#af+1] = Border(ins_w, ins_h, border_width) .. {
	InitCommand=function(self) self:xy(ins_x+ins_w/2, ins_y+ins_h/2) end
}


-- Text Entry BG
af[#af+1] = Def.Quad {
	InitCommand=function(self) self:xy(txt_x, txt_y):halign(0):valign(0):zoomto(txt_w, txt_h):diffuse(0,0,0,1) end
}
-- white border
af[#af+1] = Border(txt_w, txt_h, border_width)..{
	InitCommand=function(self) self:xy(txt_x+txt_w/2, txt_y+txt_h/2) end
}

return af
