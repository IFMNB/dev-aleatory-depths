-- Quark

--[[

	ECS framework, based on Hexagon instances and objects.

]]

-- @aftersky

local lib = {}

lib.BaseSystem = require(script.baseECS.basesystem)
lib.BaseComponent = require(script.baseECS.basecomponent)
lib.BaseECS = require(script.baseECS)

return lib