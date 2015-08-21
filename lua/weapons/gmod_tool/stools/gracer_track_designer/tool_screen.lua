if SERVER then return false end

--local GRD = "gracer_designer"
--local GRD_ = GRD.."_"

local BGColor = Color(35, 35, 35, 255)

surface.CreateFont( "GRToolScreen_Title",{	font = "DermaLarge", 
											size = 28,
											weight = 10,
											italic = true,
											antialias = true,
											additive = false})
surface.CreateFont( "GRToolScreen_Hint",{	font = "DermaLarge", 
											size = 24,
											weight = 1000,
											antialias = true,
											additive = false})

// Taken from Garry's tool code
local function DrawScrollingText( text, y, texwide )
	local w, h = surface.GetTextSize( text  )
	w = w + 64
	
	local x = math.fmod( CurTime() * 150, w ) * -1
	
	while ( x < texwide ) do
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( x, y )
		surface.DrawText( text )
		
		x = x + w
	end
end

function GRD_DrawToolScreen( w, h )
	local r, e = pcall( function()
		local w = tonumber(w) or 256
		local h = tonumber(h) or 256
		
		surface.SetDrawColor( BGColor )
		surface.DrawRect( 0, 0, w, h )
		
		surface.SetFont("GRToolScreen_Title")
		local titleText = "#Tool."..GRD..".name"
		local logow, logoh = surface.GetTextSize( titleText )
		surface.SetDrawColor( Color( 200, 200, 200 ))
		surface.DrawRect( 0, h-logoh-20, w, h)
		surface.SetTextColor( 10, 10, 10, 255 )
		surface.SetTextPos((w-logow)/2, h-logoh-12 )
		surface.DrawText( titleText )
		
		surface.SetFont("GRToolScreen_Hint")
		local hintText = "#Tool."..GRD..".tool_screen_hint"
		local hintw, hinth = surface.GetTextSize( hintText )
		surface.SetTextColor( 150, 150, 150, 255)
		DrawScrollingText(hintText, h - hinth*2 - logoh -5, w)
		
		
	end )
	
	if !r then
		ErrorNoHalt( e, "\n" )
	end
end