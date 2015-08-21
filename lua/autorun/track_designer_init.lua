-- Shared initialization

if SERVER then
-- Server only initialization
	net.Receive( GRD_ .. "set_client_editmode", function( len, pl )
		if ( IsValid( pl ) and pl:IsPlayer() ) then
			PrintTable(pl:GetTable())
		end
	end )
end

if CLIENT then
-- Client only initialization
	include("designer/design_panel.lua")
	concommand.Add( GRD_ .. "open_designer", function( ply, cmd, args )
		if gRacer["design_panel"] == nil then
			gRacer["design_panel"] = vgui.Create("GRD_design_panel")
		else
			gRacer["design_panel"]:SetVisible( true )
		end
	end )
end