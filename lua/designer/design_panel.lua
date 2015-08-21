-- gRacer Design Mode options tab menu
if SERVER then return end

local GRD_design_panel = {}
function GRD_design_panel:Init()
	local h = ScrH() * 0.7
	local w = 400
	
	self:SetSize(w, h)
	self:SetPos(10, ScrH()*0.18)
	self:SetTitle("Track Design Overview")
	self:SetVisible( true )
	self:SetDraggable( true )
	self:SetSizable( true )
	self:ShowCloseButton( true )
	self:SetDeleteOnClose( false )
	self:MakePopup()
	
	local bCancel = vgui.Create("DButton", self)
	bCancel:SetText("Close")
	bCancel:SetSize(100,20)
	bCancel:SetPos(w/2-50, h - 25)
	bCancel.DoClick = function()
		self:Close()
	end
	
	local bCancel = vgui.Create("DButton", self)
	bCancel:SetText("Enter Edit Mode")
	bCancel:SetSize(w,20)
	bCancel:SetPos(0, h - 50)
	bCancel.DoClick = function()
		net.Start( GRD_ .. "set_client_editmode" )
			net.WriteBool(true)
		net.SendToServer()
	end
end

--[[function GRD_track_management:Paint()
	local w, h = self:GetSize()
	
	draw.RoundedBox(6, 0, 0, w, h, Color( 20, 20, 20 , 255))
end]]--

vgui.Register("GRD_design_panel", GRD_design_panel, "DFrame")