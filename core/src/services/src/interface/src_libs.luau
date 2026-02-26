local interface = {}

local libs = table.freeze({
	PackageTransport = require('../storage/library/PackageTransport')
})


function interface:Libs ()
	return libs
end

return interface