local interface = {}

local libs = table.freeze({
	PackageTransport = require('../storage/library/PackageTransport');
	LarsenBufferize = require('../storage/library/TableToBufferFORK'),
})


function interface:Libs ()
	return libs
end

return interface