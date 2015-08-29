--[[
	Edit mode                     ____                        _       ___     __           __      
	 /_  __/________ _____  _____/ __/___  _________ ___     | |     / (_)___/ /___ ____  / /______
	  / / / ___/ __ `/ __ \/ ___/ /_/ __ \/ ___/ __ `__ \    | | /| / / / __  / __ `/ _ \/ __/ ___/
	 / / / /  / /_/ / / / (__  ) __/ /_/ / /  / / / / / /    | |/ |/ / / /_/ / /_/ /  __/ /_(__  ) 
	/_/ /_/   \__,_/_/ /_/____/_/  \____/_/  /_/ /_/ /_/     |__/|__/_/\__,_/\__, /\___/\__/____/  
																			/____/
	Class definitions of edit mode widgets which exist in 3D space as part of the world
	NOTE: These classes are only avaliable on the client
--]]
AddCSLuaFile()
if SERVER then return end
local matArrow = Material( "gracer/widgets/arrow.png", "nocull unlitgeneric mips" )
local matDisc = Material( "widgets/disc.png", "nocull alphatest smooth mips" )

WidgetDrawList = {}
-- Draw widgets post everything else so they appear on top
hook.Add("PostDrawTranslucentRenderables", "transform_widget_draw", function()
	for index, widget in pairs(WidgetDrawList) do
		widget:Draw()
	end
end)

WidgetComponent = {}
function WidgetComponent:GetTransformFunc()
	return self.transformFunc
end
function WidgetComponent:SetColor( col )
	self.col = col
end
function WidgetComponent:Draw()
	
end
function WidgetComponent:SetScale( scale )
	o.scale = scale
end
function WidgetComponent:OBBMaxs()
	return Vector(1,1,1)
end
function WidgetComponent:OBBMins()
	return Vector(-1,-1,-1)
end
function WidgetComponent:Origin()
	return self.parent:GetPos()
end
function WidgetComponent:Create( parent, transformFunc, scale )
	local o = {
		col = Color(255,255,255)
	}
	o.parent = parent
	o.transformFunc = transformFunc
	o.scale = scale or 1
	setmetatable(o, {__index = WidgetComponent})
	return o
end

TranslateComponent = {}
setmetatable(TranslateComponent, {__index = WidgetComponent})
function TranslateComponent:Draw()
	-- If Garry just documented how he uses those bone widgets, I might be able to use them!
	-- But alas, he does not (Or at least, I couldn't find it). They are probably half serverside anyway and fuck that shit. Track Design has no business taking up Server CPU time!
	render.SetMaterial( matArrow )	
	render.DepthRange( 0, 0.01 )
	render.DrawBeam(  self:GetPos(), self:GetPos() + self:OBBMaxs() * self.axis, self.width, 1, 0, self.col )
	render.DepthRange( 0, 1 )
end
function TranslateComponent:SetScale( scale )
	self.scale = scale
	self.width = scale * 0.3
	self.maxs = (Vector(self.width/2, self.width/2, self.width/2) + self.axis*self.scale)
	self.mins = Vector(-self.width/2, -self.width/2, -self.width/2)
	self.origin_off = self.axis*(self.width+self.gap)
end
function TranslateComponent:OBBMaxs()
	return self.maxs
end
function TranslateComponent:OBBMins()
	return self.mins
end
function TranslateComponent:GetPos()
	return self.parent:GetPos() + self.origin_off
end
function TranslateComponent:Create( axis, parent, transformFunc, centerGap )
	local o = WidgetComponent:Create( parent, transformFunc )
	o.axis = axis
	o.gap = centerGap or 0
	setmetatable(o, {__index = TranslateComponent})
	o:SetColor(Color(255*axis.x, 255*axis.y, 255*axis.z))
	o:SetScale( parent:GetScale() )
	return o
end

TransformWidget = {}
function TransformWidget:Create( scale )
	local o = {
		pos = Vector(0,0,0),
		components = {},
		shouldDraw = true,
		scale = 1
	}
	o.scale = scale
	o.shouldDraw = false
	setmetatable(o, {__index = TransformWidget})
	table.insert(WidgetDrawList, o) -- This widget will need to be drawn, add it to the draw list
	return o
end
function TransformWidget:AddComponent( name, widgetComponent )
	self.components[name] = widgetComponent
end
function TransformWidget:GetComponents()
	return self.components
end
function TransformWidget:SetScale( numberScale )
	self.scale = numberScale
	for index, component in pairs(self.components) do
		component:SetScale( numberScale )
	end
end
function TransformWidget:GetScale()
	return self.scale
end
function TransformWidget:SetPos( pos )
	self.pos = pos
end
function TransformWidget:GetPos()
	return self.pos
end
function TransformWidget:Hide()
	self.shouldDraw = false
end
function TransformWidget:Show()
	self.shouldDraw = true
end
function TransformWidget:Draw()
	if self.shouldDraw then
		for dir, comp in pairs(self.components) do
			comp:Draw()
		end
	end
end
function TransformWidget:Remove()
	table.RemoveByValue(WidgetDrawList, self)
end