local src = {}
local Library = table.freeze({
	Hexagon = require('../storage/library/HexagonLibrary'),
    RbxUtility = require('../storage/library/RbxUtility'),
    CodeUtility = require('../storage/library/CodeUtility')
})

function src:Libs ()
	return Library
end

return src