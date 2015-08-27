-- gRacer Track Designer Management VGUI
--[[
	Displays options to create, modify, and delete tracks
]]--
AddCSLuaFile()
if SERVER then return end

local GRD_track_overview_panel = {}
function GRD_track_overview_panel:Init()
	local h = ScrH() * 0.5
	local w = ScrW() * 0.5
	
	self:SetTitle("Track Overview")
	self:SetSize(w, h)
	self:SetPos(ScrW()*0.5 - w*0.5, ScrH()*0.5 - h*0.5)
	self:SetVisible( true )
	self:SetDraggable( true )
	self:SetSizable( true )
	self:ShowCloseButton( true )
	self:SetDeleteOnClose( false )
	self:MakePopup()
	
	self.bCancel = vgui.Create("DButton", self)
	self.bCancel:SetText("Cancel")
	
	self.bContinue = vgui.Create("DButton", self)
	self.bContinue:SetText("Continue")
	
	self.bDone = vgui.Create("DButton", self)
	self.bDone:SetText("Finished")
	
	self.tfTrackName = vgui.Create("DTextEntry", self)
	self.tfTrackName:SetText("Track Name")
	
	self:Invalidate()
	self:SetupEvents()
end
 
function GRD_track_overview_panel:Invalidate()
	local h = self:GetTall()
	local w = self:GetWide()
	
	self.bCancel:SetSize(100,40)
	self.bCancel:SetPos( 50, h - 60)
	
	self.bContinue:SetSize(100,40)
	self.bContinue:SetPos( w/2-50, h - 60)
	
	self.bDone:SetSize(100,40)
	self.bDone:SetPos( w - 150, h - 60)
	
	self.tfTrackName:SetSize( w*0.5, 40)
	self.tfTrackName:SetPos(50, 50)
end
 
function GRD_track_overview_panel:SetupEvents()
	self.bCancel.DoClick = function()
		-- Leave edit mode
		endTrackDesigner()
		self:Close()
	end
	
	self.bContinue.DoClick = function()
		-- Return to edit mode
		endTrackDesigner()
		self:Close()
	end
	
	self.bDone.DoClick = function()
		-- Leave edit mode
		endTrackDesigner()
		-- Transfer track to server to be sent to the database
		
		self:Close()
	end
end
 
function GRD_track_overview_panel:PerformLayout()
	self.BaseClass.PerformLayout(self);
	self:Invalidate();
end

vgui.Register(GRD_ .. "track_overview_panel", GRD_track_overview_panel, "DFrame")