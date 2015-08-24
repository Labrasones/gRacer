AddCSLuaFile()

DEFINE_BASECLASS( "drive_base" );

drive.Register( "drive_" .. GRD_ .. "designer", 
{
	--
	-- Called on creation
	--
	Init = function( self )
		self.Speed = 0.01
		self.SpeedDamp = 0.75
		self.MaxVel = 50
		self.TargHeight = self.Player:GetPos().z + 80
		self.HitHeight = self.Player:GetPos().z
	end,

	--
	-- Called before each move. You should use your entity and cmd to 
	-- fill mv with information you need for your move.
	--
	StartMove =  function( self, mv, cmd )
		-- Update move position and velocity from our entity
		mv:SetOrigin( self.Entity:GetNetworkOrigin() )
		mv:SetVelocity( self.Entity:GetAbsVelocity() )

	end,

	--
	-- Runs the actual move. On the client when there's 
	-- prediction errors this can be run multiple times.
	-- You should try to only change mv.
	--
	Move = function( self, mv )
		-- Set up a speed, go faster if shift is held down
		local speed = self.Speed
		if ( mv:KeyDown( IN_SPEED ) ) then 
			speed = self.Speed * 10 
		end
		speed = speed * FrameTime()

		-- Get information from the movedata
		local ang = mv:GetMoveAngles()
		local pos = mv:GetOrigin()
		local vel = mv:GetVelocity()
		
		-- Get the additional velocity from the player
		local moveVel = Vector(mv:GetForwardSpeed()*speed, (-mv:GetSideSpeed())*speed, 0)
		moveVel:Rotate(Angle(0,ang.yaw,0))
		vel = vel + moveVel
		
		-- Set the target height
		local heightSpeed = 7
		if ( mv:KeyDown( IN_SPEED ) ) then 
			heightSpeed = 15
		end
		if mv:KeyDown( IN_DUCK ) then -- Go down
			self.TargHeight = self.TargHeight - heightSpeed
		elseif mv:KeyDown( IN_JUMP ) then -- Go up
			self.TargHeight = self.TargHeight + heightSpeed
		else
			-- Trace to follow the ground on light curves
			local startPos = self.Entity:GetPos()
			local length = 500 -- Maximum distance from ground to consider still following it's curves
			local dir = Vector(0,0,-1)
			local mins = self.Entity:OBBMins() * 1.5
			local maxs = self.Entity:OBBMaxs() * 1.5
			local trData = {
				start = startPos,
				endpos = startPos + (dir*length),
				maxs = maxs,
				mins = mins,
				filter = self.Entity,
				mask = MASK_PLAYERSOLID_BRUSHONLY
			}
			local tr = util.TraceHull( trData )
			
			local x = tr.HitPos.z - self.HitHeight
			self.HitHeight = tr.HitPos.z
			if math.abs(x) < 50 and tr.Hit then
				self.TargHeight = self.TargHeight + x
			end
			
		end
		
		-- Slow us down
		if ( math.abs(mv:GetForwardSpeed()) + math.abs(mv:GetSideSpeed()) + math.abs(mv:GetUpSpeed()) < 0.01 ) then
			vel = vel * self.SpeedDamp
		else
			vel = vel * (self.SpeedDamp*1.1)
		end
		
		-- Clamp the vel
		if vel:Length() > self.MaxVel then
			vel = self.MaxVel * vel:GetNormalized()
		end
		
		-- Move towards target height
			-- Must be after the slow down and clamp. Can't allow the target height to grow faster than we can move
		vel.z = (self.TargHeight - self.Entity:GetPos().z)
		
		-- Add the velocity to the position (this is the movement)
		pos = pos + vel

		-- We don't set the newly calculated values on the entity itself
		-- we instead store them in the movedata. These get applied in FinishMove.
		mv:SetVelocity( vel )
		mv:SetOrigin( pos )
	end,

	--
	-- The move is finished. Use mv to set the new positions
	-- on your entities/players.
	--
	FinishMove =  function( self, mv )

		--
		-- Update our entity!
		--
		self.Entity:SetNetworkOrigin( mv:GetOrigin() )
		self.Entity:SetAbsVelocity( mv:GetVelocity() )
		self.Entity:SetAngles( mv:GetMoveAngles() )

		--
		-- If we have a physics object update that too. But only on the server.
		--
		if ( SERVER && IsValid( self.Entity:GetPhysicsObject() ) ) then

			self.Entity:GetPhysicsObject():EnableMotion( true )
			self.Entity:GetPhysicsObject():SetPos( mv:GetOrigin() );
			self.Entity:GetPhysicsObject():Wake()
			self.Entity:GetPhysicsObject():EnableMotion( false )

		end
	end,

	--
	-- Calculates the view when driving the entity
	--
	CalcView =  function( self, view )
		
	end
}, "drive_base" );