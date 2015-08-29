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
		-- Add some waypoints to test with
		gRacer.waypoints = {}
		gRacer.waypoints[1] = Waypoint:Create()
		gRacer.waypoints[1]:SetPos(Vector(0,0,10))
		gRacer.waypoints[1]:SetName("Hammerhead")
		gRacer.waypoints[2] = Waypoint:Create()
		gRacer.waypoints[2]:SetPos(Vector(0, 1800, 10))
		gRacer.waypoints[2]:SetName("")
		gRacer.waypoints[3] = Waypoint:Create()
		gRacer.waypoints[3]:SetPos(Vector(500, 2600, 10))
		gRacer.waypoints[3]:SetName("Walldorf")
		gRacer.waypoints[4] = Waypoint:Create()
		gRacer.waypoints[4]:SetPos(Vector(1000, 2600, 10))
		gRacer.waypoints[4]:SetName("Airtime")
		
		gRacer.editmode = {}
		createElements()
		createWidgets()
	end
	
	function createElements()
		-- Create the waypoint widgets.
		gRacer.editmode.elementGroup = SelectionRenderGroup:Create( "waypoint" )
		gRacer.editmode.elementGroup:SetRenderSettings( {colour = Color(0,155,247)} )
		
		gRacer.editmode.elements = {}
		for index, waypoint in pairs(gRacer.waypoints) do
			local element = WaypointElement:Create(  waypoint, "models/props_gameplay/cap_point_base.mdl" , gRacer.editmode.elementGroup )
			table.insert(gRacer.editmode.elements, element)
		end
	end
	
	function createWidgets()
		gRacer.editmode.widgets = {}
		local translate = TransformWidget:Create(40)
		translate:AddComponent( "x", TranslateComponent:Create( Vector(1,0,0), translate, function(deltaPos, component)
			for index, element in pairs(gRacer.editmode.elementGroup:GetSelection()) do
				element:SetPos( element:GetPos() + deltaPos*component.axis )
			end
			component.parent:SetPos( component.parent:GetPos() + deltaPos*component.axis)
		end), 50)
		translate:AddComponent( "y", TranslateComponent:Create( Vector(0,1,0), translate, function(deltaPos, component)
			for index, element in pairs(gRacer.editmode.elementGroup:GetSelection()) do
				element:SetPos( element:GetPos() + deltaPos*component.axis )
			end
			component.parent:SetPos( component.parent:GetPos() + deltaPos*component.axis)
		end), 50)
		translate:AddComponent( "z", TranslateComponent:Create( Vector(0,0,1), translate, function(deltaPos, component)
			for index, element in pairs(gRacer.editmode.elementGroup:GetSelection()) do
				element:SetPos( element:GetPos() + deltaPos*component.axis )
			end
			component.parent:SetPos( component.parent:GetPos() + deltaPos*component.axis)
		end), 50)
		gRacer.editmode.widgets.translate = translate
	end
	
	function endTrackDesigner()
		-- Tell the server to remove us from edit mode
		net.Start( GRD_ .. "set_client_editmode" )
			net.WriteBool(false)
		net.SendToServer()
		-- Clear Selection
		gRacer.editmode.elementGroup:ClearSelection()
		
		-- Remove the waypoints from the world
		for index, element in pairs(gRacer.editmode.elements) do
			element:Remove()
			table.Empty(gRacer.editmode.elements)
		end
		-- Remove the widgets from the world
		for index, widget in pairs(gRacer.editmode.widgets) do
			widget:Remove()
			table.Empty(gRacer.editmode.widgets)
		end
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
			hook.Add("GUIMouseReleased", GRD_ .. "handle_mouserelease", designerHandleMouseRelease)
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
			local traceLength = 9999
			-- Check if we hit a transform widget first
			local wt = pickWidget(camEnt:GetPos(), aimVec, gRacer.editmode.widgets, traceLength)
			if wt.Hit then -- Hit a widget component
				local selectedComponent = wt.Component
				gRacer.editmode.oldTransformAimVec = aimVec
				hook.Add("Think", "widget_transform_think", function()
					local transform = selectedComponent:GetTransformFunc()
					local delta = Vector(0,0,0)
					delta = selectedComponent:GetPos():Distance(camEnt:GetPos()) * (gui.ScreenToVector( gui.MousePos() ) - gRacer.editmode.oldTransformAimVec)
					gRacer.editmode.oldTransformAimVec = gui.ScreenToVector( gui.MousePos() )
					transform(delta, selectedComponent)
				end)
			else -- Didn't hit a waidget
				-- Then check if we hit an element
				local et = pickElement(camEnt:GetPos(), aimVec, gRacer.editmode.elements, traceLength)
				local addSelection = input.IsKeyDown(KEY_LCONTROL ) or input.IsKeyDown(KEY_RCONTROL )
				if et.Hit then
					if addSelection then
						if et.Element:GetSelected() then -- Element is already selected, deselect
							et.Element:SetSelected(false)
						else							 -- Element is not yet selected, add to selection
							et.Element:SetSelected(true)
						end
					else
						-- Reset selection and select
						et.Element:GetRenderGroup():ClearSelection()
						et.Element:SetSelected(true)
					end
					for index, widget in pairs(gRacer.editmode.widgets) do
						widget:SetPos(gRacer.editmode.elementGroup:GetMedianPos())
						widget:Show()
					end
				elseif not addSelection then
					--[[gRacer.editmode.elementGroup:ClearSelection()
					for index, widget in pairs(gRacer.editmode.widgets) do
						widget:Hide()
					end]]--
				end
			end
		end
	end
	
	function designerHandleMouseRelease( mouse, aimVec)
		if mouse == MOUSE_LEFT then
			-- Remove the hook for widget interaction
			hook.Remove("Think", "widget_transform_think")
			-- Drop waypoints to the ground
			-- TODO
			-- Set widget position to median position
			for index, widget in pairs(gRacer.editmode.widgets) do
				widget:SetPos(gRacer.editmode.elementGroup:GetMedianPos())
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

