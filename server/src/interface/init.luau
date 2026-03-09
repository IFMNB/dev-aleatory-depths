local interface = setmetatable({}, {__index=require(game.ReplicatedStorage.core)})
local classes = require('@self/src_class')

interface.Services = require('@self/src_services')
interface.Classes = classes.Classes
interface.Abstracts = classes.Abstracts
interface.Interfaces = classes.Interfaces
interface.Components = require('@self/src_components')

function interface:GetConfigs ()
	return require('@self/src_config')
end

return interface