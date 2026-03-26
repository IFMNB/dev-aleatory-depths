local gl = require('./')

local hxc = gl.Library.Hexagon.Classes
local it = hxc.Instance()
local ev = hxc.Events()

local private = {}
local public = {}
local service = it.new(public, 'RoundService'::'RoundService')

function private.generative (StartTime)
	
end

return service