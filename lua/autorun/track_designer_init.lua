-- Shared initialization
include("designer/track_designer_base.lua")
AddCSLuaFile( "designer/track_designer_base.lua")

if SERVER then
-- Server only initialization
	net.Receive( GRD_ .. "set_client_editmode", function( len, pl)
		local editModeState = net.ReadBool()
		if editModeState then
			if pl:GetTable()[GRD_ .. "edit_mode"] != true then
				startTrackDesigner( pl )
			end
		else
			if pl:GetTable()[GRD_ .. "edit_mode"] == true then
				endTrackDesigner( pl )
			end
		end
	end)
end

if CLIENT then
-- Client only initialization
	include("designer/edit_mode_panels.lua")
	include("designer/design_panel.lua")
	include("designer/track_overview_panel.lua")
	include("designer/selectable_elements.lua")
	include("designer/transform_widgets.lua")
	include("designer/interact_util.lua")
	concommand.Add( GRD_ .. "open_designer", function( ply, cmd, args )
		if gRacer["design_panel"] == nil then
			gRacer["design_panel"] = vgui.Create(GRD_ .. "design_panel")
		else
			gRacer["design_panel"]:SetVisible( true )
		end
	end )
end