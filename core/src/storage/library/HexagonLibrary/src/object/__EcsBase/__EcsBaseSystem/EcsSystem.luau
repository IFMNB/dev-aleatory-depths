local main = require('./')

local private = {};
local class = {};
class.__index=main.__EcsBaseSystem.class;
setmetatable(class,class);
local interface = {};

type EcsEntity = typeof(main.EcsEntity.new())
type EcsSystem = typeof(interface.new())
type SystemCall = (EcsSystem: EcsSystem, EcsEntity: EcsEntity)->()

function private.new <self, Dependencies> (SystemCall: SystemCall?, Dependencies: Dependencies?)
	return main.new({
		SystemId = tostring(tick()),
		Dependencies = Dependencies :: Dependencies,
		SystemCall = SystemCall or warn :: SystemCall
	},class)
end

class.ClassName = main.ClassNames.EcsSystem;
class.Source = script;

interface.new = private.new;
interface.class = class;

table.freeze(class)
table.freeze(interface)
table.freeze(private)

return main:expand({EcsSystem = interface})