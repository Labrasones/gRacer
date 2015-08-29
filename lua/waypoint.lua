--[[
 _       __                        _       __ 
| |     / /___ ___  ______  ____  (_)___  / /_
| | /| / / __ `/ / / / __ \/ __ \/ / __ \/ __/
| |/ |/ / /_/ / /_/ / /_/ / /_/ / / / / / /_  
|__/|__/\__,_/\__, / .___/\____/_/_/ /_/\__/  
             /____/_/                         
								Waypoint Class
--]]
AddCSLuaFile()
-- SHARED --
--[[
	Waypoint class.
		pos: Position in 3 space
		c1, c2: Control points for Bezier curve drawing
		name: Waypoint name
]]--
Waypoint = 
{
	pos = Vector(0,0,0),
	c1 = Vector(0,0,0),
	c2 = Vector(0,0,0),
	name = ""
}
function Waypoint:Create()
	local o = {}
	setmetatable(o, {__index = Waypoint})
	return o
end
function Waypoint:SetPos( pos )
	self.pos = pos
end
function Waypoint:GetPos()
	return self.pos
end
function Waypoint:SetName( name )
	self.name = name
end
function Waypoint:GetName()
	return self.name
end
function Waypoint:SetControl1( c1 )
	self.c1 = c1
end
function Waypoint:SetControl2( c2 )
	self.c2 = c2
end
function Waypoint:GetControl1()
	return self.c1
end
function Waypoint:GetControl2()
	return self.c2
end