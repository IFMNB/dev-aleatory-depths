local SharedTableRegistry = game:GetService('SharedTableRegistry')

local private = {}
local global = {Library=setmetatable({}, {__index=require(game.ReplicatedStorage.global.lib)})}

global.Server = {}
global.Server.Library = {}

global.Server.Classes = require('@self/sv_v2/localgl').Classes

global.Server.Services = {}
global.Server.Services.NetworkControlService = function () return require('@self/sv_v2/localgl/s_api/NetworkControlService') end
global.Server.Services.DataService = function () return require('@self/sv_v2/localgl/s_api/DataService') end
global.Server.Services.ConfigService = function () return require('@self/sv_v2/localgl/s_api/ConfigService') end
global.Server.Services.HitboxService = function () return require('@self/sv_v2/localgl/s_api/HitboxService') end
global.Server.Services.HitRegService = function () return require('@self/sv_v2/localgl/s_api/HitboxService/HitRegService') end
global.Server.Services.HumanoidService = function () return require('@self/sv_v2/localgl/s_api/NetworkControlService/HumanoidService') end
global.Server.Services.CoreApi = require('@self/sv_v2/localgl/s_api').CoreApi


return global 