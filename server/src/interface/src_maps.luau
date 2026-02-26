local path = script.Parent.Parent.storage.map
local interface = table.freeze({
	TestZone = require(path.TestZone)
});
return interface