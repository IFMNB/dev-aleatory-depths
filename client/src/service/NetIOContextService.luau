local main = require('../')
local Mapping = main.Mapping
local private = {};
local interface = {};

type Context = typeof(Mapping.InputContextMap)
type Contexts = keyof<Context>
type ContextThis = index<Context,Contexts>


interface.Enums = table.freeze({
	Null = Mapping.Enum.Null;
});
interface.Exceptions = table.freeze({
	
});
interface.Service = main.Core.Classes.SadNetService().new({
	
	
	Name = 'NetIOContextService'::'NetIOContextService';
	Behavior = interface.Enums.Null :: index<typeof(interface.Enums), keyof<typeof(interface.Enums)>>;
	IsControllable = false;
})

return interface