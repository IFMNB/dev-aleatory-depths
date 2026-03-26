local gl = require('../')

local tbl = gl.Library.CodeBox.Tables.Table()

local hxc = gl.Library.Hexagon.Classes
local it = hxc.Instance()

local private = {}
local public = {}
local class = {}

private.mt={__index=public}

function private.new <t0, t1> (result: t0, info: t1?)
	local copy
	local origin
	local inf
	
	if type(info) == 'table' then
		inf = tbl.DeepClone(info)
		tbl.DeepFreeze(inf)
	else
		inf = info
	end
	
	if type(result) == 'table' then
		copy = tbl.DeepClone(result)
		origin = tbl.DeepClone(copy)
	else
		copy = result
		origin = result
	end
	
	local interlayer = {}
	interlayer.Result = result
	interlayer.NetInfo = inf
	function interlayer:OriginResult () : t0
		return type(origin)=='table'and tbl.DeepClone(origin) or origin
	end
	function interlayer:OriginNetInfo () : t1
		return inf
	end
	
	setmetatable(interlayer,private.mt)
	local int = it.New(interlayer, 'NetResult'::'NetResult')
	return int
end

class.new = private.new

return class