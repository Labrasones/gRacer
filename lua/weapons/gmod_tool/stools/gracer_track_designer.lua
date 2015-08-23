-- gRacer Track Designer Stool code, By Labrasones
local cat = ((gRacer.CustomToolCategory and gRacer.CustomToolCategory:GetBool()) and "gRacer" or "Construction");

--local GRD = "gracer_designer"
--local GRD_ = GRD.."_"

TOOL.Category		= "gRacer"
TOOL.Name			= "#Tool."..GRD..".name"
TOOL.Command		= nil
TOOL.ConfigName		= ""

AddCSLuaFile(GRD.."/tool_screen.lua")

include( "weapons/gmod_tool/stools/"..GRD.."/tool_screen.lua" )

function TOOL:LeftClick( trace )
	
end

function TOOL:RightClick( trace )
	
end

function TOOL:Reload( trace )
	if CLIENT then return false end
	local ply = self:GetOwner()
	ply:ConCommand( GRD_.."open_designer" )
	return false
end

if CLIENT then
	function TOOL.BuildCPanel( panel )
		panel:Help("#Tool."..GRD..".desc")
		
		panel:AddControl("Button", {Label = "Open Designer",Command = GRD_.."open_designer"})
	end
	
	function TOOL:DrawToolScreen( w, h )
		GRD_DrawToolScreen()
	end
	
	function TOOL:DrawHUD()
	
	end
end