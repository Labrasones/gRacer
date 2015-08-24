-- Shared code

-- Server only code
if SERVER then
	function startTrackDesigner( pl )
		if ( IsValid( pl ) and pl:IsPlayer() ) then
			pl:GetTable()[GRD_ .. "edit_mode"] = true
			local pawn = ents.Create("prop_physics")
			pawn:SetModel("models/Combine_Scanner.mdl")
			pawn:SetPos(pl:GetPos() + Vector(0,0,40))
			pawn:Spawn()
			pawn:SetCollisionGroup(COLLISION_GROUP_WORLD)
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
	end
	function endTrackDesigner()
		-- Tell the server to remove us from edit mode
		net.Start( GRD_ .. "set_client_editmode" )
			net.WriteBool(false)
		net.SendToServer()
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
			--hook.Add("PostDrawOpaqueRenderables", GRD_ .. "post_draw", designerPostDraw)
			hook.Add("CalcView", GRD_ .. "calc_view", designerCalcView)
			
			local model = "models/props_interiors/Furniture_Couch02a.mdl"
			gRacer["Test"] = ClientsideModel(model)
			gRacer["Test"]:SetModel(model)
			gRacer["Test"]:SetSolid(SOLID_OBB)
			gRacer["Test"]:Spawn()
			gRacer["Test"]:SetPos(LocalPlayer():GetPos() + Vector(0,70,70))
			print(gRacer["Test"]:OBBMaxs())
			
		else -- We where removed from edit mode, unhook handlers
			gui.EnableScreenClicker(false)
			hook.Remove( "KeyPress", GRD_ .. "handle_keypress")
			hook.Remove( "KeyRelease", GRD_ .. "handle_keyrelease")
			hook.Remove( "Think", GRD_ .. "think")
			hook.Remove("GUIMousePressed", GRD_ .. "handle_mouseclick")
			--hook.Remove("PostDrawOpaqueRenderables", GRD_ .. "post_draw")
			hook.Remove("CalcView", GRD_ .. "calc_view")
			
			gRacer["Test"]:Remove()
		end
	end)
	function designerCalcView(pl, viewPos, viewAng, fov, nearZ, farZ)
		-- Save the current view position so we can use it later
		LocalPlayer():GetTable()["cam_pos"] = viewPos
		LocalPlayer():GetTable()["cam_angle"] = viewAng
	end
	function designerPostDraw(bDrawDepth, bDrawSkybox)
		--gRacer["Test"]:DrawModel()
	end
	
	function designerHandleMousePress( mouse, aimVec)
		if mouse == MOUSE_LEFT then
			local camEnt = LocalPlayer():GetViewEntity()
			local testObj = gRacer["Test"]
			
			local hit, norm, fraction = util.IntersectRayWithOBB( camEnt:GetPos(), aimVec*99999, testObj:GetPos(), testObj:GetAngles(), testObj:OBBMins(), testObj:OBBMaxs() )
			if hit then
				-- Hit an object, add it to the list to consider
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

