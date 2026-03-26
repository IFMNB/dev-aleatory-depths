local gl = require('../')

local hxc = gl.Library.Hexagon.Classes
local ob = hxc.Object()
local ev = hxc.Events()

local private = {}
local public = {}
local class = {}

type Metadata = {
	UseReplication: boolean,
	
	
	CanClientChange: boolean,
	
	
	Engine: {
		Func: string?,
		Module: ModuleScript?
	}
}

private.mt={__index=public}
type AbstractNet = typeof(private.new({}::Metadata))
-- Создает абстрактный сетевой объект, который может быть реплицируемым между сервером и клиентом.
function private.new (NetMetadata: Metadata)
	local result = setmetatable({}, private.mt)
	result.NetworkMeta = NetMetadata
	
	return result
end

class.new = private.new
return class