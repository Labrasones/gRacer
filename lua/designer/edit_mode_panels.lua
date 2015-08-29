-- gRacer Track Designer Edit Mode VGUIs
--[[
	Definition for the VGUIs used during edit mode
]]--
AddCSLuaFile()
if SERVER then return end

--[[
  _      __                    _      __    ____                    _           
 | | /| / /__ ___ _____  ___  (_)__  / /_  / __ \_  _____ _____  __(_)__ _    __
 | |/ |/ / _ `/ // / _ \/ _ \/ / _ \/ __/ / /_/ / |/ / -_) __/ |/ / / -_) |/|/ /
 |__/|__/\_,_/\_, / .__/\___/_/_//_/\__/  \____/|___/\__/_/  |___/_/\__/|__,__/ 
             /___/_/     
]]--
local GRD_edit_waypoints = {}
function GRD_edit_waypoints:Init()
	local h = ScrH() * 0.7
	local w = 300
	
	self:SetTitle("Waypoints")
	self:SetSize(w, h)
	self:SetPos(ScrW() - w - 10, ScrH()*0.5 - h*0.5)
	self:SetVisible( true )
	self:SetDraggable( true )
	self:SetSizable( true )
	self:ShowCloseButton( false )
	self:SetDeleteOnClose( true )
	self:MakePopup() -- NOTE: self must be poped up when the elements are created or they won't be focusable. Engine bug maybe? Seems like it.
	
	--[[
	ScrollPanel (Container)
		ListView (TrackOverview)
			DPanel (TrackGraphicTop)
			ListView (WaypointEntries)
			DPanel (TrackGraphicBottom)
	]]--
	
	-- Set up the panel hierarchy
	-- Scroll panel to hold list
	self.Container = vgui.Create("DScrollPanel", self)
	self.Container:Dock( FILL )
	self.Container:DockMargin( 5, 5, 0, 5)
	
		-- List view to hold the track overview
		self.TrackOverview = vgui.Create("DListLayout", self.Container)
		self.TrackOverview:Dock( FILL )
		self.TrackOverview:DockMargin( 0, 0, 5, 0)
	
			-- DPanel for the top of the track graphic
			self.TrackGraphicTop = vgui.Create(GRD_ .. "edit_track_cap_panel", self.TrackOverview)
			self.TrackGraphicTop:SetCapEnd( true )
			self.TrackOverview:Add(self.TrackGraphicTop)
			
			-- ListLayout for waypoint entries
			self.WaypointEntries = vgui.Create("DListLayout", self.TrackOverview)
			self.TrackOverview:Add(self.WaypointEntries)
			
			-- DPanel for the bottom of the track graphic
			self.TrackGraphicBottom = vgui.Create(GRD_ .. "edit_track_cap_panel", self.TrackOverview)
			self.TrackGraphicBottom:SetCapEnd( false )
			self.TrackOverview:Add(self.TrackGraphicBottom)
	
	-- End panel hierarchy setup
	
	-- Add the waypoints we currently have to the list
	for index, waypoint in pairs(gRacer.waypoints) do
		self:PushWaypoint( waypoint, index )
	end

	self:MakeUnpopped()
	self:SetupEvents()
end

function GRD_edit_waypoints:MakeUnpopped()
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
end

function GRD_edit_waypoints:Think()
	self.BaseClass.Think(self) -- Do the base class think
	local mx, my = gui.MousePos() -- Get the positiono of the mouse and bounds of the panel
	local px, py, pw, ph = self:GetBounds()
	mx = mx - px -- Transform the mouse into panel space
	my = my - py
	if mx > 0 and mx < pw and my > 0 and my < ph then
		-- Mouse is over the panel
		if not self:IsMouseInputEnabled()  then -- Only make it popup if it isn't already popped
			self:MakePopup() -- Make the panel trap input
		end
	else
		-- Mouse is outside the panel
		--[[
		if self:IsMouseInputEnabled() then -- Only make it unpopped if it is already popped
			self:MakeUnpopped() -- Stop the panel from trapping input
		end
		]]--
	end
	-- and ( input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT) )
end


function GRD_edit_waypoints:SetupEvents()
	
end

function GRD_edit_waypoints:PushWaypoint( waypoint, index )
	local waypointPanel = vgui.Create(GRD_ .. "edit_waypoint_panel", self.WaypointEntries)
	waypointPanel:SetWaypoint( waypoint, index )
	self.WaypointEntries:Add(waypointPanel)
end

function GRD_edit_waypoints:InsertWaypoint( waypoint, index )
	
end

function GRD_edit_waypoints:RemoveWaypoint( waypoint, index )
	
end
vgui.Register(GRD_ .. "edit_waypoints", GRD_edit_waypoints, "DFrame")

--[[
  _      __                    _      __    ___                __
 | | /| / /__ ___ _____  ___  (_)__  / /_  / _ \___ ____  ___ / /
 | |/ |/ / _ `/ // / _ \/ _ \/ / _ \/ __/ / ___/ _ `/ _ \/ -_) / 
 |__/|__/\_,_/\_, / .__/\___/_/_//_/\__/ /_/   \_,_/_//_/\__/_/  
             /___/_/ 
]]--

local GRD_waypoint_panel = {}
function GRD_waypoint_panel:SetWaypoint( waypoint, index )
	self.waypoint = waypoint
	self.name:SetText(self.waypoint:GetName())
	self.waypointIndex = index
end

function GRD_waypoint_panel:Init()
	self.parent = self:GetParent() or self
	self.isLast = false
	
	-- Set up parameters of this panel
	self:SetPaintBackground( false )
	self:SetSize(0, 70)
	
	-- Track Graphic
	self.trackGraphic = vgui.Create("DImage", self)
	self.trackGraphic:SetImage( "vgui/gracer/track_mid" )
	self.trackGraphic:SetSize( 64, self:GetTall())
	
	-- Waypoint Graphic
	self.waypointGraphic = vgui.Create("DImage", self)
	self.waypointGraphic:SetImage( "vgui/gracer/waypoint" )
	self.waypointGraphic:SizeToContents()
	
	-- Insert Waypoint Button
	self.insertWaypointBtn = vgui.Create("DImageButton", self)
	self.insertWaypointBtn:SetImage( "gui/silkicons/add" )
	self.insertWaypointBtn:SizeToContents()
	
	-- Remove Waypoint Button
	self.removeWaypointBtn = vgui.Create("DImageButton", self)
	--self.removeWaypointBtn:SetImage( "icons16/delete.png" )
	local mat, time = Material("icon16/delete.png", "unlitgeneric alphatest")
	self.removeWaypointBtn:SetMaterial(mat)
	self.removeWaypointBtn:SizeToContents()
	
	-- Create the name text field
	self.name = vgui.Create("DTextEntry", self)
	self.name:SetMouseInputEnabled(true)
	self.name:SetKeyboardInputEnabled(true)
	
	self:SetupEvents()
end
 
function GRD_waypoint_panel:SetupEvents()
	
end

function GRD_waypoint_panel:Invalidate()
	local h = self:GetTall()
	local w = self:GetWide()
	
	self.trackGraphic:SetPos( w-64, 0)
	self.waypointGraphic:SetPos( w-64 - (self.waypointGraphic:GetWide()/2) + 2, 0 )
	
	self.name:SetSize(w - 64 - (self.waypointGraphic:GetWide()/2) - 2, 20)
	self.name:SetPos(0,(self.waypointGraphic:GetWide()/2) - 10)
	
	self.insertWaypointBtn:SetPos(w-64 - (self.insertWaypointBtn:GetWide()/2) + 2, 42)
	
	self.removeWaypointBtn:SetPos(w-64 - (self.insertWaypointBtn:GetWide()/2) + 2, self.waypointGraphic:GetTall()/2 - (self.removeWaypointBtn:GetTall()/2))
end

function GRD_waypoint_panel:PerformLayout()
	self.BaseClass.PerformLayout(self);
	self:Invalidate();
end
vgui.Register(GRD_ .. "edit_waypoint_panel", GRD_waypoint_panel, "DPanel")

--[[
 ______             __     _____            ___                __
/_  __/______ _____/ /__  / ___/__ ____    / _ \___ ____  ___ / /
 / / / __/ _ `/ __/  '_/ / /__/ _ `/ _ \  / ___/ _ `/ _ \/ -_) / 
/_/ /_/  \_,_/\__/_/\_\  \___/\_,_/ .__/ /_/   \_,_/_//_/\__/_/  
                                 /_/  
]]--
local GRD_track_cap_panel = {}
function GRD_track_cap_panel:SetCapEnd( isTop )
	self.isStart = isTop
	if isTop then
		self.graphic:SetImage("vgui/gracer/track_top")
		
		self.addWaypointBtn = vgui.Create("DImageButton", self)
		self.addWaypointBtn:SetImage( "gui/silkicons/add" )
		self.addWaypointBtn:SizeToContents()
		
		self:SetSize(0,32 + (self.addWaypointBtn:GetTall()/2) - 3)
	else
		self.graphic:SetImage("vgui/gracer/track_bottom")
	end
	-- We might have changed the action on the addWaypointBtn, set it up again.
	self:SetupEvents()
end

function GRD_track_cap_panel:Init()
	self.parent = self:GetParent() or self
	self.isStart = true
	self:SetPaintBackground( false )
	
	self.graphic = vgui.Create("DImage", self)
	self.graphic:SetImage("vgui/gracer/track_top")
	self.graphic:SizeToContents()
	
	self:SetSize(0,32)
	
	self:SetupEvents()
end
 
function GRD_track_cap_panel:SetupEvents()
	
end

function GRD_track_cap_panel:Invalidate()
	local h = self:GetTall()
	local w = self:GetWide()
	
	local gx = w - 64
	local gy = 0
	
	if self.isStart then
		gy = self.addWaypointBtn:GetTall()/2 - 3 -- minus 3 is there to put the button in the middle of the track, which was 4 pixels wide plus a 1 pixel border
		self.addWaypointBtn:SetPos(w - 32 - (self.addWaypointBtn:GetWide()/2), 0)
	end
	
	self.graphic:SetPos(gx, gy)
end

function GRD_track_cap_panel:PerformLayout()
	self.BaseClass.PerformLayout(self);
	self:Invalidate();
end
vgui.Register(GRD_ .. "edit_track_cap_panel", GRD_track_cap_panel, "DPanel")