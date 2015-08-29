--[[
	Edit mode__           __    __   _       ___     __           __      
	| |     / /___  _____/ /___/ /  | |     / (_)___/ /___ ____  / /______
	| | /| / / __ \/ ___/ / __  /   | | /| / / / __  / __ `/ _ \/ __/ ___/
	| |/ |/ / /_/ / /  / / /_/ /    | |/ |/ / / /_/ / /_/ /  __/ /_(__  ) 
	|__/|__/\____/_/  /_/\__,_/     |__/|__/_/\__,_/\__, /\___/\__/____/  
												   /____/
	Class definitions of edit mode widgets which exist in 3D space as part of the world
	NOTE: These classes are only avaliable on the client
--]]
AddCSLuaFile()
if SERVER then return end

-- Base widget
Widget = 
{
	pos = Vector(0, 0, 0),
	ang = Angle(0, 0, 0)
}
function Widget:Create()
	local object = {}
	setmetatable( object, { __index = Widget } )
	return object
end
function Widget:SetPos( pos )
	self.pos = pos
end
function Widget:GetPos( pos )
	return self.pos
end
function Widget:SetAng( ang )
	self.ang = ang
end
function Widget:GetAng()
	return self.ang
end

-- ModelWidget, a widget with a specified model to render
ModelWidget = 
{
	modelName = "",
	csent = nil,
	modelScale = Vector(0, 0, 0),
	OBBMaxs = nil,
	OBBMins = nil
}
setmetatable(ModelWidget, {__index = Widget} )
function ModelWidget:Create()
	local object = {}
	setmetatable(object, {__index = ModelWidget} )
	return object;
end
function ModelWidget:SetModel( modelName )
	self.csent = ClientsideModel(modelName)
	self.csent:SetModel(modelName) -- NOTE: Must call this as well, and with the same model as ClientsideModel or we'll have no OBB. Feels like engine bug!
	self.modelName = modelName
	self.SetOBBMaxs(self.csent:OBBMaxs())
	self.SetOBBMins(self.csent:OBBMins())
end
function ModelWidget:GetModel( modelName )
	return self.modelName
end
function ModelWidget:SetPos( pos )
	Widget.SetPos( self, pos )
	self.csent:SetPos( pos )
end
function ModelWidget:RemoveModel()
	self.csent:Remove()
end
function ModelWidget:SetOBBMaxs( maxs )
	self.OBBMaxs = maxs
end
function ModelWidget:SetOBBMins( mins )
	self.OBBMins = mins
end
function ModelWidget:GetOBBMaxs()
	return self.OBBMaxs
end
function ModelWidget:GetOBBMins()
	return self.OBBMins
end
-- Selection group class
SelectionGroup = 
{
	name = "default",
	renderParams = {
		colour = Color(255, 150, 0),
		blurx = 0,
		blury = 0,
		passes = 1,
		ignorez = true
	},
	selectedWidgets = {},
	selectedCSEnts = {}
}
function SelectionGroup:Create( name )
	local object = {}
	setmetatable( object, {__index = SelectionGroup} )
	object.name = name
	return object
end
function SelectionGroup:AddToSelection( selectableWidget )
	local index = table.insert(self.selectedWidgets, selectableWidget) -- Insert the selected widget
	self.selectedCSEnts[index] = selectableWidget.csent
	--self:ResetRenderHook()
end
function SelectionGroup:RemoveFromSelection( selectableWidget )
	table.RemoveByValue(self.selectedWidgets, selectableWidget) -- Remove the specified widget
	self.selectedCSEnts[index] = nil
	--self:ResetRenderHook()
end
function SelectionGroup:ClearSelection()
	table.Empty(self.selectedWidgets) -- Reset the table
	table.Empty(self.selectedCSEnts)
	--self:ResetRenderHook()
end
function SelectionGroup:IsWidgetSelected( widgetToCheck )
	local key = table.KeyFromValue( self.selectedWidgets, widgetToCheck )
	if key then
		return true
	end
	return false
end
function SelectionGroup:SetRenderParams( renderTable )
	table.Merge(self.renderParams, renderTable)
	--self:ResetRenderHook()
end
function SelectionGroup:ResetRenderHook()
	local this = self
	hook.Add( "PreDrawHalos", "group_" .. self.name .. "_add_selection_halo", function()
		halo.Add( this.selectedCSEnts, this.renderParams.colour, 
					this.renderParams.burx, 
					this.renderParams.bury, 
					this.renderParams.passes,
					true, this.renderParams.ignorez)
	end )
end

SelectableWidget = 
{
	selected = false,
	selectionGroup = nil
}
setmetatable( SelectableWidget, { __index = ModelWidget })
function SelectableWidget:Create( selectionGroup )
	local object = {}
	setmetatable( object, { __index = SelectableWidget } )
	return object
end
function SelectableWidget:SetSelected( selected )
	if selected then
		self.selectionGroup:AddToSelection( self )
	else
		self.selectionGroup:RemoveFromSelection( self )
	end
	self.selected = selected
end


-- TranslateComponent: Used in the TranslateWidget
TranslateComponent = 
{
	colour = Color(255,255,0),
	axis = Vector(1,0,0)
}
setmetatable( TranslateComponent, {__index = Widget} )
function TranslateComponent:Create( axis, scale )
	local object = {}
	setmetatable(object, {__index = TranslateComponent})
	object:SetOBBMaxs( Vector(1,1,1) + axis * scale ) 
	object:SetOBBMins( Vector(-1,-1,-1) )
	object.colour = Color(255*axis.x, 255*axis.y, 255*axis.z)
	object.axis = axis
	return object
end
function TranslateComponent:Scale( scale )
	self:SetOBBMaxs( Vector(1,1,1) + (Vector(numberScale, numberScale, numberScale)* self.axis) )
end
function TranslateComponent:Draw()
	render.DrawWireframeBox( self:GetPos(), self:GetAng(), self:GetOBBMins(), self:GetOBBMaxs(), self.colour, true )
end

debugTransformWidgetList = {}
hook.Add("PostDrawOpaqueRenderables", "draw_transform_widget_debug", function()
	for index, widget in pairs(debugTransformWidgetList) do
		widget:Draw()
	end
end)
-- TranslateWidget: A Widget which contains components which indicate axis of translation
TranslateWidget = 
{
	components = {
		x=nil,
		y=nil,
		z=nil
	},
	shouldDraw = true,
	viz = nil,
	scale = 1
}
setmetatable( TranslateWidget, {__index = Widget} )
function TranslateWidget:Create()
	local object = {}
	setmetatable( object, {__index = TranslateWidget} )
	object.components.x = TranslateComponent:Create(Vector(1,0,0), 20)
	object.components.y = TranslateComponent:Create(Vector(0,1,0), 20)
	object.components.z = TranslateComponent:Create(Vector(0,0,1), 20)
	object.viz = ModelWidget:Create()
	object.viz:SetModel("models/sprops/misc/origin.mdl")
	object:SetScale(20)
	table.insert(debugTransformWidgetList, object)
	return object
end
function TranslateWidget:SetScale( numberScale )
	self.scale = numberScale
	self:SetOBBMaxs( Vector(1,1,1) + Vector(numberScale, numberScale, numberScale) )
	self:SetOBBMins( Vector(-1, -1, -1) )
end
function TranslateWidget:SetPos( pos )
	Widget.SetPos(self, pos)
	for dir, comp in pairs(self.components) do
		comp:SetPos( pos )
	end
	self.viz:SetPos( pos )
end
function TranslateWidget:Hide()
	self.viz:Remove()
	shouldDraw = false
end
function TranslateWidget:Show()
	shouldDraw = true
	object.viz = ModelWidget:Create()
	object.viz:SetModel("models/sprops/misc/origin.mdl")
end
function TranslateWidget:Draw()
	if shouldDraw then
		for dir, comp in pairs(self.components) do
			comp:Draw()
		end
	end
end