--[[
	Edit mode_          _           __     __  _             _____        __   
	  /  |/  /__ ____  (_)__  __ __/ /__ _/ /_(_)__  ___    / ___/__  ___/ /__ 
	 / /|_/ / _ `/ _ \/ / _ \/ // / / _ `/ __/ / _ \/ _ \  / /__/ _ \/ _  / -_)
	/_/  /_/\_,_/_//_/_/ .__/\_,_/_/\_,_/\__/_/\___/_//_/  \___/\___/\_,_/\__/ 
					  /_/          
	Code related to the manipulation (selection, movement, rotation, scaling) of objects in edit mode is kept here
--]]
AddCSLuaFile()
--[[==============
=     Shared     =
==============--]]

--[[==============
=  End Shared   =
==============--]]

-- Server only code
if SERVER then

end -- Server only code

-- Client only code
if CLIENT then
	
	--[[ 
	Gets the picked waypoint from @waypoints along @aimVec. Returns a table with format
		Waypoint	|	The waypoint closest to origin which intersected the ray
		Fraction	|	The fraction of the trace before hitting this object
		Normal		|	The hit normal of the trace
	]]--
	function pickWaypoint( origin, aimVec, waypoints, len)
		local closestWaypoint = {}
		for index, entry in pairs(waypoints) do
			local csent = entry.csent;
			-- Do the trace
			local hit, normal, fraction = util.IntersectRayWithOBB( origin, aimVec*(len or 9999), csent:GetPos(), csent:GetAngles(), csent:OBBMins(), csent:OBBMaxs() )
			if hit then
				if closestWaypoint.fraction == nil or closestWaypoint.fraction < fraction then -- There was no waypoint hit yet, or this was the closest to origin
					closestWaypoint.waypoint = entry -- Store this waypoint entry
					closestWaypoint.fraction = fraction
					closestWaypoint.normal = normal
				end
			end
		end
		local traceResult = {}
		traceResult["Waypoint"] = closestWaypoint.waypoint
		traceResult["Fraction"] = closestWaypoint.fraction
		traceResult["Normal"] = closestWaypoint.normal
		return traceResult
	end
end -- client only code