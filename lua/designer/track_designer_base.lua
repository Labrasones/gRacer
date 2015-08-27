AddCSLuaFile()
-- Shared code

-- Server only code
if SERVER then
	function startTrackDesigner( pl )
		if ( IsValid( pl ) and pl:IsPlayer() ) then
			pl:GetTable()[GRD_ .. "edit_mode"] = true
			local pawn = ents.Create("prop_physics")
			pawn:SetModel("models/Combine_Scanner.mdl")
			pawn:SetPos(pl:GetPos() + Vector(0,0,40))
			pawn:SetAngles(pl:EyeAngles())
			pawn:Spawn()
			pawn:SetCreator(pl)
			pl:GetTable()[GRD_ .. "pawn"] = pawn
			
			drive.PlayerStartDriving( pl, pawn, "drive_" .. GRD_ .. "designer" );
			net.Start(GRD_ .. "set_client_editmode")
				net.WriteBool(true)
			net.Send(pl)
		end
	end
	function endTrackDesigner( pl )
		pl:GetTable()[GRD_ .. "edit_mode"] = false
		
		drive.PlayerStopDriving( pl )
		if pl:GetTable()[GRD_ .. "pawn"] != nil then
			pl:GetTable()[GRD_ .. "pawn"]:Remove()
		end
		net.Start(GRD_ .. "set_client_editmode")
			net.WriteBool(false)
		net.Send(pl)
	end
end
-- End Server only

-- Client only code
if CLIENT then
	function startTrackDesigner()
		-- Tell the server to put us in edit mode
		net.Start( GRD_ .. "set_client_editmode" )
			net.WriteBool(true)
		net.SendToServer()
		gRacer.waypoints = {}
		gRacer.waypoints[1] = WaypointWidget:Create()
		gRacer.waypoints[1]:SetModel("models/props_gameplay/cap_point_base.mdl")
		gRacer.waypoints[1]:SetPos(Vector(-500,0,0))
		gRacer.waypoints[1]:SetName("Hammerhead")
		gRacer.waypoints[2] = WaypointWidget:Create()
		gRacer.waypoints[2]:SetModel("models/props_gameplay/cap_point_base.mdl")
		gRacer.waypoints[2]:SetPos(Vector(0,500,0))
		gRacer.waypoints[2]:SetName("Waldorf")
		gRacer.waypoints[3] = WaypointWidget:Create()
		gRacer.waypoints[3]:SetModel("models/props_gameplay/cap_point_base.mdl")
		gRacer.waypoints[3]:SetPos(Vector(500,500,50))
		gRacer.waypoints[3]:SetName("Airtime")
		
		gRacer.selectionGroup = SelectionGroup:Create("edit_widgets")
		gRacer.translateWidget = TranslateWidget:Create()
	end
	function endTrackDesigner()
		-- Tell the server to remove us from edit mode
		net.Start( GRD_ .. "set_client_editmode" )
			net.WriteBool(false)
		net.SendToServer()
		
		-- Remove the waypoints from the world
		for index, waypoint in pairs(gRacer.waypoints) do
			waypoint:RemoveModel()
		end
		gRacer.translateWidget:Hide()
	end
	-- The server will let us know when we get into edit mode, set a callback
	net.Receive( GRD_ .. "set_client_editmode", function( len ) -- Set up the event handlers for edit mode
		if net.ReadBool() then -- We where put INTO editmode, hook handlers
			gui.EnableScreenClicker(true)
			-- Set up hooks for designer control
			hook.Add( "KeyPress", GRD_ .. "handle_keypress", designerHandleKeyPress)
			hook.Add( "KeyRelease", GRD_ .. "handle_keyrelease", designerHandleKeyRelease)
			hook.Add( "Think", GRD_ .. "think", function()
				gui.EnableScreenClicker( not input.IsMouseDown( MOUSE_RIGHT ) )
			end )
			hook.Add("GUIMousePressed", GRD_ .. "handle_mouseclick", designerHandleMousePress)
			hook.Add("CalcView", GRD_ .. "calc_view", designerCalcView)
			-- Create the VGUI panels for control
			gRacer["edit_waypoints"] = vgui.Create(GRD_ .. "edit_waypoints")
		else -- We where removed from edit mode, unhook handlers
			gui.EnableScreenClicker(false)
			hook.Remove( "KeyPress", GRD_ .. "handle_keypress")
			hook.Remove( "KeyRelease", GRD_ .. "handle_keyrelease")
			hook.Remove( "Think", GRD_ .. "think")
			hook.Remove("GUIMousePressed", GRD_ .. "handle_mouseclick")
			hook.Remove("CalcView", GRD_ .. "calc_view")
			hook.Remove("PreDrawHalos", "draw_selected_widget_halos")
			
			gRacer["edit_waypoints"]:Close()
		end
	end)
	function designerCalcView(pl, viewPos, viewAng, fov, nearZ, farZ)
		-- Save the current view position so we can use it later
		LocalPlayer():GetTable()["cam_pos"] = viewPos
		LocalPlayer():GetTable()["cam_angle"] = viewAng
	end
	
	function designerHandleMousePress( mouse, aimVec)
		-- Clear focus from VGUIs
		gRacer["edit_waypoints"]:MakeUnpopped()
		if mouse == MOUSE_LEFT then
			camEnt = LocalPlayer():GetViewEntity()
			local tr = pickWaypoint( camEnt:GetPos(), aimVec, gRacer.waypoints)
			if tr.Waypoint then
				gRacer.selectionGroup:ClearSelection()
				gRacer.selectionGroup:AddToSelection(tr.Waypoint)
				gRacer.selectedWidget = tr.Waypoint
				gRacer.translateWidget:SetPos( tr.Waypoint:GetPos() )
			end
		end
	end
	
	function designerHandleKeyPress( ply, key )
		if key == IN_RELOAD then
			-- Show the track overview window
			if gRacer["overview_panel"] == nil then
				gRacer["overview_panel"] = vgui.Create(GRD_ .. "track_overview_panel")
			else
				gRacer["overview_panel"]:SetVisible( true )
			end
		end
	end

	function designerHandleKeyRelease( ply, key )
		
	end
end
-- End Client Only

