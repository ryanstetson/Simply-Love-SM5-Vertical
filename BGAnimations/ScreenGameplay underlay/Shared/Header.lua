return Def.Quad{
	Name="Header",
	InitCommand=function(self)
		self:diffuse(0,0,0,0.85):zoomtowidth(_screen.w):valign(0):xy( _screen.cx, 0 )

		if SL.Global.GameMode == "StomperZ" then
			self:zoomtoheight(40)
		else
			self:zoomtoheight(65)
		end
	end
}
