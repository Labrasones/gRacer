--[[
 HERP HERP HERP, THIS WAS MODIFIED IN THE WORKING DIRECTORY
]]--
function bezier_at(x, curve)
	local P1 = curve["first"]
	local C1 = curve["cp1"]
	local C2 = curve["cp2"]
	local P2 = curve["last"]
	local point = ((1-x)^3)*P1 + 3*((1-x)^2)*x*C1 + 3*(1-x)*(x^2)*C2 + (x^3)*P2
	return point
end
function bezier_tangent_at(x, curve)
	local P1 = curve["first"]
	local C1 = curve["cp1"]
	local C2 = curve["cp2"]
	local P2 = curve["last"]
	local tangent = (3*((1-x)^2)*(C1-P1) + 6*(1-x)*x*(C2-C1) + 3*(x^2)*(P2-C2)):GetNormalized()
	return tangent
end
function init_g_racer()
	print("Initializing gRacer")
	
	local spline = {
		{
			first = Vector(0, 0, -10),
			cp1 = Vector(0, 20, 10),
			cp2 = Vector(20, 20, 5),
			last = Vector(20, 0, 0)
		},
		{
			first = Vector(20, 0, 0),
			cp1 = Vector(20, -20, 5),
			cp2 = Vector(40, -20, -20),
			last = Vector(40, 0, -15)
		},
		{
			first = Vector(40, 0, -15),
			cp1 = Vector(40, 20, -15),
			cp2 = Vector(0, -20, -10),
			last = Vector(0, 0, -10)
		}
	}
	
	local Segments = 12
	
	--local trackSurface = Material( "models/debug/debugwhite" )
	local trackSurface = Material( "gui/track" )

	local verts = {}
	local vertCount = 0
	for key, value in pairs(spline) do
		local step = 1/Segments
		for i=0, 1, step do
			local onCurve = bezier_at(i, value)
			local tangent = bezier_tangent_at(i, value)
			local normal = Vector(0,0,1):Cross(tangent)
			local P1 = onCurve + (normal * 2)
			local P2 = onCurve - (normal * 2)
			local planeNormal = tangent:Cross(normal)
			table.insert(verts,P1)
			table.insert(verts,P2)
			vertCount = vertCount + 2
		end
	end
	
	local track = Mesh()
	local spline_mesh_data = {}
	for i=1, vertCount-2, 2 do
		-- Insert tri1
		local vert = {}
		vert["pos"] = verts[i+2]
		vert["u"] = 0
		vert["v"] = 1
		table.insert(spline_mesh_data, vert)
		
		local vert = {}
		vert["pos"] = verts[i+1]
		vert["u"] = 1
		vert["v"] = 0
		table.insert(spline_mesh_data, vert)
		
		local vert = {}
		vert["pos"] = verts[i]
		vert["u"] = 0
		vert["v"] = 0
		table.insert(spline_mesh_data, vert)
		
		local vert = {}
		vert["pos"] = verts[i+1]
		vert["u"] = 1
		vert["v"] = 0
		table.insert(spline_mesh_data, vert)
		
		local vert = {}
		vert["pos"] = verts[i+2]
		vert["u"] = 0
		vert["v"] = 1
		table.insert(spline_mesh_data, vert)
		
		local vert = {}
		vert["pos"] = verts[i+3]
		vert["u"] = 1
		vert["v"] = 1
		table.insert(spline_mesh_data, vert)
	end

	track:BuildFromTriangles( spline_mesh_data ) -- Load the vertices into the IMesh object
	
	hook.Add( "PostDrawOpaqueRenderables", "IMeshTest", function()
		render.SetMaterial( trackSurface ) -- Apply the material
		render.SetLightingMode(2)
		track:Draw() -- Draw the mesh
		render.SetLightingMode(0)
	end )
end
init_g_racer()