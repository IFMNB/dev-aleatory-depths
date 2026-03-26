local gl = require('../')

local obj = gl.Hexagon.Classes.Object()
local ev = gl.Hexagon.Classes.Events()
local shadow = gl.CodeBox.Tables.Shadow()
local tbl = gl.CodeBox.Tables.Table()

local private = {}
local public = {}
local class = {}

private.mv = {__mode='v'} :: modev
private.mk = {__mode='k'} :: modek

type userdata = any
type modev = {__mode: 'v'}
type modek = {__mode: 'k'}
type sys_alias_userdata = userdata
type components_names = {string}

type basesys =  typeof(require('@self/basesystem'))
type basecomp = typeof(require('@self/basecomponent'))

type comdef = typeof(((nil::any)::basecomp).new({}::{[string]:any}, (nil::any)::string))
type sysdef = typeof(((nil::any)::basesys).new({},nil::any,(nil::any)::string))


type function typecheck <t0> (reg: t0 & type)
	local types = types

	assert(reg:is('table'), 'Register must be a table')

	for i,v in reg:properties() do
		assert(i:is('singleton') and typeof(i:value()) == 'string', 'Register cannot have a non-singleton-strings indexes')
		if not v.read then
			print('Register cannot have a non-readable values')
		else
			if not v.read:is('table') then
				print('Register cannot have a non-table values')
			
			end
		end
		
	end

	return reg
end

function private.new_inter <t0,t1> (base: t0, registr: t1)
	local inter = {}
	inter.Components = registr :: typecheck<t1>
	
	setmetatable(inter :: unknown, {
		__index = function (s, i) return (base::any)[i] or (public::any)[i] end,
		__metatable = 'BaseSystemECS',
		__newindex = base,
		__call = function (s,...)return (base::any)(...) end,
		__iter = function ()
			return next, tbl.Merge(inter, base,'pairs',true)
		end, 
	})
	
	return inter :: typeof(inter) & typeof(public) & t0
end

function private.new_shade (obj: unknown)
	type shade_ecs = {
		_sys_al: 					{ [sys_alias_userdata]: sysdef },
		_sys: 		setmetatable <	{ sys_alias_userdata },						 modev >,
		_ent: 						{ userdata },
		_alias: 	setmetatable <	{ [sys_alias_userdata]: components_names },	 modek >
	}
	
	local shade : shade_ecs = shadow.New(obj, 'BaseSystemECS')
	
	shade._sys_al = {}
	shade._sys = setmetatable({}, private.mv)
	shade._ent = {}
	shade._alias = setmetatable({}, private.mk)
	
	return shade
end

function private.new <t0,t1> (base: t0, registr: t1)
	local inter = private.new_inter(base, registr)
	local object = obj.New(inter, 'QuarkECS' :: 'QuarkECS')
	local shade = private.new_shade(object)
	return object
end





local a = private.new({}, {})

return class