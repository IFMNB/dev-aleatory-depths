local main = require('../')

local private = {}
local interface = {}


local NetworkService = main.Core.Services.NetworkService()

interface.Enums = main.Mapping.Enum.MachineSide;
interface.Exceptions = table.freeze({
	GameException = main.Mapping.Exception.GameException;
});
interface.Service = main.Core.Classes.SadNetService().new({
	Name = 'NetCoordinateService'::'NetCoordinateService';
	LastRead = 0;
	Behavior = interface.Enums.Server :: index<typeof(interface.Enums), keyof<typeof(interface.Enums)>>;
	IsControllable = false;
});

NetworkService.Service:ForEvent(main.Mapping.Event.CoordinateNetwork):Connect(function(Pos:any, Look:any, Up:any) 
	local Pos : Vector3, Look : Vector3, Up :Vector3 = Pos, Look, Up
	
	if not interface.Service:IsActive() then return end
	
	if interface.Service.Behavior == interface.Enums.Client then return end
	if interface.Service:IsLogActive() then
		local time = os.clock()
		interface.Service:PrintLog(string.format('Catched CFrame, diff is %q', tostring(time-interface.Service.LastRead)))
		interface.Service.LastRead = time
	end
	
	game["Run Service"].RenderStepped:Wait()
	
	local character = interface.Exceptions.GameException:Assert(game.Players.LocalPlayer).Character
	if character then
		local Target = CFrame.lookAlong(Pos, Look, Up)
		--character:PivotTo(character:GetPivot():Lerp(Target,.5))
	end
end)

return interface