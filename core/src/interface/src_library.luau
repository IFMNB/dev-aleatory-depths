local src = {}
local Library = table.freeze({
	Hexagon = require('../storage/library/HexagonLibrary'),
	LarsenBufferize = require('../storage/library/TableToBufferFORK'),
	RbxUtility = require('../storage/library/RbxUtility'),
})

function src:Libs ()
	return Library
end

return src