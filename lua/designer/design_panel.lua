-- gRacer Track Designer Management VGUI
--[[
	Displays options to create, modify, and delete tracks
]]--
if SERVER then return end

local GRD_design_panel = {}
function GRD_design_panel:Init()
	local h = ScrH() * 0.7
	local w = ScrW() * 0.7
	self:SetTitle("Track Design Management")
	self:SetSize(w, h)
	self:SetPos(ScrW()*0.5 - w*0.5, ScrH()*0.5 - h*0.5)
	self:SetVisible( true )
	self:SetDraggable( true )
	self:SetSizable( true )
	self:ShowCloseButton( true )
	self:SetDeleteOnClose( false )
	self:MakePopup()
	
	local bCancel = vgui.Create("DButton", self)
	bCancel:SetText("Close")
	self.bCancel = bCancel
	
	local bCreateNew = vgui.Create("DButton", self)
	bCreateNew:SetText("Create New Track")
	self.bCreateNew = bCreateNew
	
	self:Invalidate()
	self:SetupEvents()
end
 
function GRD_design_panel:Invalidate()
	local h = self:GetTall()
	local w = self:GetWide()
	
	self.bCancel:SetSize(100,40)
	self.bCancel:SetPos(w - 150, h - 60)
	
	self.bCreateNew:SetSize(400,40)
	self.bCreateNew:SetPos(w/2 - 200, h - 60)
end
 
function GRD_design_panel:SetupEvents()
	self.bCancel.DoClick = function()
		self:Close()
	end

	self.bCreateNew.DoClick = function()
		startTrackDesigner()
		self:Close()
	end
end
 
function GRD_design_panel:PerformLayout()
	self.BaseClass.PerformLayout(self);
	self:Invalidate();
end

vgui.Register(GRD_ .. "design_panel", GRD_design_panel, "DFrame")