local path = script.Parent.Parent.cls
local module = setmetatable({}, {__index = require('../cls')})
module.Classes = {}
module.Classes.Timer = function () return require(path.Timer) end
module.Classes.Interactive = function () return require(path.interact) end

return module