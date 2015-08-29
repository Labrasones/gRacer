--[[
	Edit mode     __          __        __    __        ________                          __      
	  / ___/___  / /__  _____/ /_____ _/ /_  / /__     / ____/ /__  ____ ___  ___  ____  / /______
	  \__ \/ _ \/ / _ \/ ___/ __/ __ `/ __ \/ / _ \   / __/ / / _ \/ __ `__ \/ _ \/ __ \/ __/ ___/
	 ___/ /  __/ /  __/ /__/ /_/ /_/ / /_/ / /  __/  / /___/ /  __/ / / / / /  __/ / / / /_(__  ) 
	/____/\___/_/\___/\___/\__/\__,_/_.___/_/\___/  /_____/_/\___/_/ /_/ /_/\___/_/ /_/\__/____/ 
	Class definitions of edit mode Elements which exist in 3D space as part of the world
	NOTE: These classes are only avaliable on the client
--]]
AddCSLuaFile()
if SERVER then return end

Element = {}
function Element:Create()
	local o = {
		pos = Vector(0,0,0),
		ang = Angle(0,0,0),
		scale = Vector(0,0,0)
	}
	setmetatable(o, {__index = Element})
	
	return o
end
function Element:SetPos( pos )
	self.pos = pos
end
function Element:GetPos()
	return self.pos
end
function Element:SetAng( angle )
	self.ang = angle
end
function Element:GetAng()
	return self.ang
end
function Element:SetScale( scale )
	self.scale = scale
end
function Element:GetScale()
	return self.scale
end

SelectionRenderGroups = {}
SelectionRenderGroup = {}
function SelectionRenderGroup:SetRenderSettings( renderTable )
	table.Merge( self.renderParams, renderTable )
end
function SelectionRenderGroup:SetRenderHook()
	local this = self -- Don't precache the parameters of halo.add in the lambda func. Precache the reference to self, then use it to look them up!
	hook.Add( "PreDrawHalos", "group_" .. self.name .. "_add_selection_halo", function()
		halo.Add( this.selectedCSEnts, this.renderParams.colour, 
					this.renderParams.blurx, 
					this.renderParams.blury, 
					this.renderParams.passes,
					true, this.renderParams.ignorez)
	end )
end
function SelectionRenderGroup:GetSelection()
	return self.selection
end
function SelectionRenderGroup:AddToSelection( selectableElement )
	table.insert(self.selection, selectableElement)
	table.insert(self.selectedCSEnts, selectableElement.csent)
end
function SelectionRenderGroup:RemoveFromSelection( selectableElement )
	table.RemoveByValue(self.selection, selectableElement)
	table.RemoveByValue(self.selectedCSEnts, selectableElement.csent)
end
function SelectionRenderGroup:ClearSelection()
	for index, element in pairs(self.selection) do
		element.selected = false
	end
	table.Empty(self.selectedCSEnts)
	table.Empty(self.selection)
end
function SelectionRenderGroup:GetMedianPos()
	local totalPos = Vector(0,0,0)
	local count = 0
	for index, element in pairs(self.selection) do
		totalPos = totalPos + element:GetPos()
		count = count + 1
	end
	return totalPos/count
end
function SelectionRenderGroup:Create( name )
	local o = SelectionRenderGroups[name] -- Get this group
	if not o then -- doesn't exist
		o =  {
				renderParams = {
				colour = Color(255,150,0),
				blurx = 1,
				blury = 1,
				passes = 1,
				ignorez = true
			},
			name = "",
			selectedCSEnts = {}, -- Need this to pass to the halo.Add function in the render hook.
			selection = {}
		}
		setmetatable(o, {__index = SelectionRenderGroup})
		o.name = name
		SelectionRenderGroups[name] = o -- store it
		o:SetRenderHook()
	end
	return o
end


SelectableElement = {}
setmetatable(SelectableElement, {__index = Element})
function SelectableElement:SetModel( model )
	-- NOTE: Must both create CSEnt with model an set it's model to the same model or it won't have an OBB
	self.csent = ClientsideModel( model )
	self.csent:SetModel( model )
end
function SelectableElement:SetRenderGroup( group )
	if self.group then
		self.group:RemoveFromSelection( self.csent )
	end
	self.group = group
end
function SelectableElement:GetRenderGroup( group )
	return self.group
end
function SelectableElement:SetPos( pos )
	Element.SetPos(self, pos)
	self.csent:SetPos( pos )
end
function SelectableElement:SetSelected( selected )
	if selected then -- We changed to deselected
		self.group:AddToSelection(self)
	else -- We changed to selected
		self.group:RemoveFromSelection(self)
	end
	self.selected = selected -- Update selection flag
end
function SelectableElement:GetSelected()
	return self.selected
end
function SelectableElement:OBBMaxs()
	return (self.csent:OBBMaxs() * scale)
end
function SelectableElement:OBBMins()
	return (self.csent:OBBMins() * scale)
end
function SelectableElement:Remove()
	self.csent:Remove()
end
function SelectableElement:Create( model, renderGroup )
	local o = {selected = false}
	setmetatable(o, { __index = SelectableElement })
	o:SetRenderGroup(renderGroup)
	o:SetModel(model)
	return o
end

WaypointElement = {}
setmetatable( WaypointElement, {__index = SelectableElement}) -- Make it inherit from SelectableElement
function WaypointElement:Create( waypoint, model, group )
	local o = SelectableElement:Create( model or "models/props_junk/sawblade001a.mdl", group or SelectionRenderGroup:Create( "waypoints" ))
	setmetatable(o, {__index = WaypointElement})
	o:SetWaypoint( waypoint )
	o:SetPos( waypoint:GetPos() )
	self.waypoint = waypoint
	return o
end
function WaypointElement:SetWaypoint( waypoint )
	self.waypoint = waypoint
end
function WaypointElement:SetWaypoint()
	return self.waypoint
end
function WaypointElement:SetPos( pos )
	SelectableElement.SetPos(self, pos )
	if self.waypoint then
		self.waypoint:SetPos( pos ) -- This element is a representation of the waypoint. If it moves, so does the waypoint. Although I'd prefer a relationship in the other direction
	end
end