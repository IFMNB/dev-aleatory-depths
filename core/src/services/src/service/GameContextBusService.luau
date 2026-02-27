local main = require('../')
local Mapping = main.Mapping

local HxEvent = main.Core.Classes.HxEvent()

local private = {}
local interface = {}

type HxEvent = typeof(HxEvent.class);
type HxEventProperties = typeof(HxEvent.subclass2)

private.registry = {} :: {[string]: {Event: HxEvent, Properties: HxEventProperties}}


function private:registry (Context: string)
	local e0,c0 = HxEvent.new(Context)
end

interface.Enums = table.freeze({
	Deffered = Mapping.Enum.ActionSignalBehavior.Deffered;
	Immediate = Mapping.Enum.ActionSignalBehavior.Immediate;
});
interface.Exceptions = table.freeze({
	CodeException = Mapping.Exception.CodeException;
});
interface.Service = main.Core.Classes.SadGameService().new({
	Name = 'GameContextBusService' :: 'GameContextBusService';
	Behavior = interface.Exceptions.CodeException;
	IsControllable = false;
})

return interface