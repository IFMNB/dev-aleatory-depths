
-- About Quant architecture

--[[

plg - plugins
svc - services
com - components
cls - classes

]]


local QuServiceClass = require('@self/svc/QuService')

local private = {}
local classes = {}
local framework = {}

classes.service = {} -- public for services
classes.component = {} -- public for components

private.metatableglobal = {}
private.metatableglobal.__metatable = 'Quant Framework' :: 'Quant Framework'

private.constr ={}
private.constr.Service = QuServiceClass
private.constr.Component = {}

type Constructors = {
	Service: typeof(private.constr.Service),
	Component: typeof(private.constr.Component)
}

function private:GetConstructor  <t0> (Do: keyof<Constructors> | t0) : index<Constructors,t0>
	return assert(private.constr[Do], 'Unknown constructor')::any
end





framework.Constructor = private.GetConstructor
framework.StarterServicesCount = 0
framework.StarterComponentsCount = 0

return framework