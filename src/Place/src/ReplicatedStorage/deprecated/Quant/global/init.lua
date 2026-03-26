local global = {}
local api = require('@self/ClientStorage/sv_v1/svcgl/api')

global.Library = require('@self/lib')
global.Core = api.CoreApi

if not game["Run Service"]:IsServer() then
	global.Client = {}
	global.Client.Library = {}
	global.Client.Classes = require('@self/ClientStorage/sv_v1/svcgl').Client.Classes
	global.Client.Service = {}
	global.Client.Service.CoreApi = api.CoreClientApi
	
end

return global