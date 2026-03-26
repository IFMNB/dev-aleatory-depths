local gl = require('../')
local AbstractNet = require('./')

local hxc = gl.Library.Hexagon.Classes
local ob = hxc.Object()
local ev = hxc.Events()

local private = {}
local public = {}
local class = {}

type Metadata = {
	Creator: ModuleScript?,
	FuncNameCreator: string?
}

function private.new <t0> (HxInstance: t0, metadata: Metadata)
	local a = AbstractNet.new({UseReplication=true, CanClientChange=true, Engine={Module=nil,Func=nil}})
	local result = setmetatable(table.clone(public), {__index=a})
	result.Metadata = metadata
	result.Replicated = HxInstance
	
	
	local netobject=  ob.New(result, 'NetObject'::'NetObject')
	return netobject
end

class.new = private.new

local a = private.new({}, {Creator=nil, FuncNameCreator=nil})
local c = a.NetworkMeta


return class