local path = script.Parent.Parent.storage.library
return table.freeze({
	GuiUtils = require(path.GuiUtils);
	SmartBone = require(path.SmartBone);
})