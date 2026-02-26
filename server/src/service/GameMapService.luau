local main = require('../')

local Mapping = main.Mapping
local Maps = require('../interface/src_maps')

local private = {}
local interface = {}

type GameMapService = typeof(interface.Service)

function private:get <name> (MapName: keyof<typeof(Maps)> | name ): index<typeof(Maps), name>
	return (Maps::any)[MapName]
end



interface.Enums = table.freeze({
	Null = Mapping.Enum.Null;
})
interface.Service = main.Core.Classes.SadGameService().new({
	Name = 'GameMapService' :: 'GameMapService';
	GetMap = private.get;
	IsControllable = false;
	Behavior = interface.Enums.Null :: index<typeof(interface.Enums), keyof<typeof(interface.Enums)>>;
});

return interface