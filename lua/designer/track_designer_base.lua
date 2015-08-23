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
			pawn:SetCreator(pl)
			pl:GetTable()[GRD_ .. "pawn"] = pawn
			
			drive.PlayerStartDriving( pl, pawn, "drive_" .. GRD_ .. "designer" );
			net.Start(GRD_ .. "set_client_editmode")
				net.WriteBool(true)
			net.Send(pl)
		end
	end
	function closeTrackDesigner( pl )
		pl:GetTable()[GRD_ .. "edit_mode"] = false
		
		drive.PlayerStopDriving( pl )
		pl:GetTable()[GRD_ .. "pawn"]:Remove()
		net.Start(GRD_ .. "set_client_editmode")
			net.WriteBool(false)
		net.Send(pl)
	end
end
-- End Server only

-- Client only code
if CLIENT then
	-- The server will let us know when we get into edit mode, set a callback
	net.Receive( GRD_ .. "set_client_editmode", function( len ) -- Set up the event handlers for edit mode
		if net.ReadBool() then -- We where put INTO editmode, hook handlers
			-- Set up hooks for designer control
			hook.Add( "KeyPress", GRD_ .. "handle_keypress", designerHandleKeyPress)
			hook.Add( "KeyRelease", GRD_ .. "handle_keyrelease", designerHandleKeyRelease)
			hook.Add( "GUIMousePressed", GRD_ .. "handle_mousepress", designerHandleMousePress)
			hook.Add( "GUIMouseReleased", GRD_ .. "handle_mouserelease", designerHandleMouseRelease)
		else -- We where removed from edit mode, unhook handlers
			hook.Remove( "KeyPress", GRD_ .. "handle_keypress")
			hook.Remove( "KeyRelease", GRD_ .. "handle_keyrelease")
			hook.Add( "GUIMousePressed", GRD_ .. "handle_mousepress")
			hook.Add( "GUIMouseReleased", GRD_ .. "handle_mouserelease")
		end
	end)
	function startTrackDesigner()
		-- Tell the server to put us in edit mode
		net.Start( GRD_ .. "set_client_editmode" )
			net.WriteBool(true)
		net.SendToServer()
	end
	
	function designerHandleKeyPress( ply, key )
		if key == IN_RELOAD then
			-- Show the track overview window
		end
	end

	function designerHandleKeyRelease( ply, key )
		
	end

	function designerHandleMousePress( mouse, aimVec )
		if mouse == MOUSE_RIGHT then
			print("Lock view to mouse")
		end
	end

	function designerHandleMouseRelease( mouse, aimVec )
		if mouse == MOUSE_RIGHT then
			print("Unlock view to mouse")
		end
	end
end
-- End Client Only

