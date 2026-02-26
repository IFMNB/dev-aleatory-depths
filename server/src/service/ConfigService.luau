local main = require('../')

local Mapping = main.Mapping

local private = {}
local interface = {}

private.attempts = 3

--local CoordinateNetEvent = main.Classes.SadNetworkEvent().new(Mapping.Event.CoordinateNetwork)
type NetCoordinateService = typeof(interface.Service)

function private.GetConfig ()
	local Service = game:GetService('ConfigService')
	local state, result = pcall(function(...) 
		return Service:GetConfigAsync()
	end)
	
	return state and result or nil
end

function private.FetchTry () : ConfigSnapshot?
	for i=1, private.attempts do
		local config = private.GetConfig()
		if config then
			private.fetch = true
			if interface.Service then
				interface.Service.FetchActual = true
			end
			return config
		end
		task.wait(1*(i^i))
	end
	
	private.c0.Call()
	private.DefaultBehavior = interface.Enums.UseDefault
	return nil
end

function private.refresh ()
	if private.CFG then
		private.CFG:Refresh()
	else
		private.CFG = private.FetchTry()
	end
	
	task.delay(interface.Service.RefreshTime, private.refresh)
end

private.fetch = false
private.e0, private.c0 = main.Core.Classes.HxEvent().new()
private.CFG = private.FetchTry()





















interface.Enums = table.freeze({
	UseDefault = Mapping.Enum.UseDefault;
	UseDefined = Mapping.Enum.UseDefined;
})
interface.Service = main.Core.Classes.SadNetService().new({
	
	
	Name = 'ConfigService' :: 'ConfigService';
	IsControllable = false;
	Behavior = interface.Enums.UseDefault;
});

task.delay(interface.Service.RefreshTime, function ()
	
end)



return interface