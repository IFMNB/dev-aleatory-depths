local gl = require('../../..')

local tbl = gl.Library.CodeBox.Tables.Table()
local obj = gl.Library.Hexagon.Classes.Object()

local private = {}
local public = {}
local class = {}

private.mt = {__index = public, __metatable = 'BaseComponentECS'}

function private.new_inter <t0> (base: t0)
	local inter = {}
	inter.Base = base
	
	setmetatable(inter, private.mt)
	table.freeze(base :: t0)
	
	return inter
end

-- Base constructor that is used for creating new components for our ECS engine instances.
function private.new <t0,t1,t2> (base_component: t2, name: t1? )
	local inter = private.new_inter(base_component)
	local object = obj.New(inter, name)
	return object
end

-- Returns full clone of the component.
function private:new_c ()
	return tbl.DeepClone(self.Base) 
end

public.new = private.new_c
class.new = private.new

table.freeze(class)
table.freeze(public)

return class