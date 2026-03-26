local gl = require('../')
local hxc = gl.Library.Hexagon.Classes
local int = hxc.Instance()
local ev = hxc.Events()

local private = {}

private.cl = {}
private.svc = {}



local service = int.New(private.svc, 'PhysicService' :: 'PhysicService')

return service