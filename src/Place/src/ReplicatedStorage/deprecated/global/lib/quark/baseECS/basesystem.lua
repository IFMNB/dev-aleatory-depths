local gl = require('../../..')

local int = gl.Library.Hexagon.Classes.Instance()

local private = {}
local public = {}
local class = {}

private.mt = {__index=public,__metatable='BaseSystemECS'}

function private.new_inter <t0,t1> (to: t0, up: t1)
	setmetatable(to::unknown, private.mt)-- :: setmetatable<t0,typeof(private.mt)>
	return to :: typeof(public) & t0 & {Update: t1} 
end

-- Base constructor that is used for creating new systems for our ECS engine instances.
function private.new <t0,t1> (system: t0, update: typeof(public.Update), name: t1?)
	local inter = private.new_inter(system :: t0, update)
	local inst = int.New(inter, name)
	return inst
end

-- Main update function that ECS uses for updating all systems.
function private:update (EntityUD: any, Variative: {[string]: {[string]: {any}}}) : ()
	error('Update function not found.', 2)	
end

public.Update = private.update
class.new = private.new

table.freeze(class)
table.freeze(public)

return class