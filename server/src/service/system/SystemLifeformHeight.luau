local main = require('../../');

local WorldsService = main.Core.Services.WorldsService()
local world = WorldsService.Service:GetWorld('game.world')
local components = require('../../interface/src_components')

local position = components.Position()

local private = {};
local interface = {};

type System = typeof(interface.Service)

interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
});

interface.Service:DoWhileActive(function() 
	world:DoForShared(function(RawWorld) 
		position:DoCatchFrom(RawWorld, function(Component2) 

		end)
	end)
end)

return interface