--[[
    ____      __                       __  _                __  ____  _ ___ __  _          
   /  _/___  / /____  _________ ______/ /_(_)___  ____     / / / / /_(_) (_) /_(_)__  _____
   / // __ \/ __/ _ \/ ___/ __ `/ ___/ __/ / __ \/ __ \   / / / / __/ / / / __/ / _ \/ ___/
 _/ // / / / /_/  __/ /  / /_/ / /__/ /_/ / /_/ / / / /  / /_/ / /_/ / / / /_/ /  __(__  ) 
/___/_/ /_/\__/\___/_/   \__,_/\___/\__/_/\____/_/ /_/   \____/\__/_/_/_/\__/_/\___/____/  
                                                                                           
--]]
AddCSLuaFile()
if SERVER then return end
function pickElement( origin, aimVec, elements, len)
	local closestElement = {}
	local traceResult = {}
	traceResult.Hit = false
	for index, entry in pairs(elements) do
		local csent = entry.csent;
		-- Do the trace
		local hit, normal, fraction = util.IntersectRayWithOBB( origin, aimVec*(len or 9999), csent:GetPos(), csent:GetAngles(), csent:OBBMins(), csent:OBBMaxs() )
		if hit then
			if closestElement.fraction == nil or closestElement.fraction > fraction then -- There was no element hit yet, or this was the closest to origin
				closestElement.element = entry -- Store this element entry
				closestElement.fraction = fraction
				closestElement.normal = normal
				traceResult["Hit"] = hit
			end
		end
	end
	traceResult["Element"] = closestElement.element
	traceResult["Fraction"] = closestElement.fraction
	traceResult["Normal"] = closestElement.normal
	return traceResult
end

function pickWidget( origin, aimVec, widgetList, len)
	local closestComponent = {}
	local traceResult = {}
	traceResult.Hit = false
	for index, widget in pairs(widgetList) do
		for index, component in pairs(widget.components) do
			-- Do the trace
			local hit, normal, fraction = util.IntersectRayWithOBB( origin, aimVec*(len or 9999), component:GetPos(), Angle(0,0,0), component:OBBMins(), component:OBBMaxs() )
			if hit then
				if closestComponent.fraction == nil or closestComponent.fraction > fraction then -- There was no element hit yet, or this was the closest to origin
					closestComponent.component = component -- Store this element entry
					closestComponent.fraction = fraction
					closestComponent.normal = normal
					closestComponent.widget = widget
					traceResult["Hit"] = hit
				end
			end
		end
	end
	traceResult["Component"] = closestComponent.component
	traceResult["Fraction"] = closestComponent.fraction
	traceResult["Normal"] = closestComponent.normal
	return traceResult
end