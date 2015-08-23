-- Recursive file includer and general utilities for making inclusion of file easier

function IncludeClient( pathToInclude)
	AddCSLua( pathToInclude )
end

function IncludeServer( pathToInclude )

end

function IncludeShared( pathToInclude )
	IncludeClient( pathToInclude )
	IncludeServer( pathToInclude )
end

function rIncludeClient( directoryToInclude )

end

function rIncludeServer( directoryToInclude )

end

function IncludeShared( pathToInclude )

end