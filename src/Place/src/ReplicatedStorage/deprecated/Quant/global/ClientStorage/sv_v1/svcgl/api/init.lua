local module = setmetatable({}, {__index=require('./')})

module.CoreApi = require('./core_client').CoreApi
module.CoreClientApi = {}
module.CoreClientApi.CameraService = function () return require('./core_client/ControlsService/CameraService') end
module.CoreClientApi.NetOwnerService = function () return require('./core_client/NetOwnerService') end
module.CoreClientApi.ControlsService = function () return require('./core_client/ControlsService') end
module.CoreClientApi.VisualizerService = function () return require('./core_client/VisualizerService') end

return module