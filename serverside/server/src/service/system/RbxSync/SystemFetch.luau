local main = require('../../../');
local components = require('../../../interface/src_components')
local WorldsService = main.Core.Services.WorldsService()

local CodeUtility = main.Libs.CodeUtility
local Mapping = main.Mapping

local model = components.property.Model()
local fetch = components.action.Fetch()
local cstphysic = components.property.CustomPhysics()
local position = components.parameter.Position()

local private = {};
local interface = {};

type System = typeof(interface.Service)

interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world');
});

private.attachments = {} :: {[PVInstance]: Attachment}


interface.Service:DoWhileActive():ConnectParallel(function(deltaTime: number, NewCycle: boolean) 
	interface.Service.TargetWorld:DoForWorlds(private.main)
end)

return interface