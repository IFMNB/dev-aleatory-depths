local main = require('../../');
local Mapping = main.Mapping
local private = {};
local interface = {};

interface.Enums = table.freeze({
	Null = Mapping.Enum.Null;
});
interface.Exceptions = table.freeze({
	
});
interface.Service = main.Core.Classes.SadGameService().new({
	
	
	Name = 'GameAbilityService'::'GameAbilityService';
	IsControllable = true;
	Behavior = interface.Enums.Null :: index<typeof(interface.Enums), keyof<typeof(interface.Enums)>>;
})

return interface