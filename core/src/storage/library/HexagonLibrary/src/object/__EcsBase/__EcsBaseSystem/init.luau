local main = require('./EcsEntity')

local class = {};
class.__index=main.__EcsBase.class;
setmetatable(class,class);
local interface = {};

class.ClassName=main.ClassNames.EcsBaseSystem;
class.Source=script;
class.SystemCall = main.Abstract.ShouldOverrided;
class.SystemId = '';
class.Dependencies = {} :: {[any]:any};

interface.class = class;
return main:expand({__EcsBaseSystem = interface})