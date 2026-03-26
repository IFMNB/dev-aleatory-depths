local module = setmetatable({}, {__index=require('./')})

module.CoreApi = {}
module.CoreApi.PhysicService = function () return require('./core/PhysicService') end


return module
