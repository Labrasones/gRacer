-- Include things to make sure they are avalible here
AddCSLuaFile()
include("globals.lua")
include("drive/drive_designer.lua")
include("waypoint.lua")
if SERVER then

end

-- Add the gRacer tool category
if CLIENT then
	gRacer.convars = {}
	-- Check if client side convars exist, create them if they dont
	if not ConVarExists( "gracer_show_tool_category" ) then
		print("Creating CVar: gracer_show_tool_category")
		CreateClientConVar( "gracer_show_tool_category", 1, true, false )
	end
	
	if(GetConVar( "gracer_show_tool_category" ):GetBool()) then
		hook.Add( "AddToolMenuTabs", "CreateGRacerCategory", function()
			spawnmenu.AddToolCategory( "Main", "gRacer", "#spawnmenu.tools.gracer" )
		end )
	end
end