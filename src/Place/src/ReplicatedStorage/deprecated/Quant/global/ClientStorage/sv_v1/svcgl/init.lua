local module = setmetatable({}, {__index=require('../cls')})
module.Classes = {}
module.Classes.NetResult = function () return require('../cls/NetResult') end

module.Client = {}
module.Client.Classes = {}

return module