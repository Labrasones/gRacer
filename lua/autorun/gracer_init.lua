-- Include things to make sure they are avalible here
include("globals.lua")
-- Add the gRacer tool category
if CLIENT then
	gRacer.CustomToolCategory = CreateClientConVar( "gracer_tool_category", 1, true, false );
	if( gRacer.CustomToolCategory:GetBool() ) then
		hook.Add( "AddToolMenuTabs", "CreateGRacerCategory", function()
			spawnmenu.AddToolCategory( "Main", "gRacer", "#spawnmenu.tools.gracer" );
		end );
	end
end