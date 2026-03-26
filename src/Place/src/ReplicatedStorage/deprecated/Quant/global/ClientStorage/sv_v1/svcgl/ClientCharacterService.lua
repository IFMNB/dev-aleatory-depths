local gl = require('./')
local instance = gl.Library.Hexagon.Classes.Instance()

local func = script.RemoteFunction
local event = script.RemoteEvent

local private = {}
local service

private.service = {}
private.service.ReplicatedCharacterInfo = (nil::any)::any
service = instance.New(private.service, 'ClientConfigService' :: 'ClientConfigService')

return service