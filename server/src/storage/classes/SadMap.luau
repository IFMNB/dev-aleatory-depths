local main = require('../..');

local SadObject = main.Core.Classes.SadObject()
local HxEvent = main.Core.Classes.HxEvent()

local private = {};
local class = {}; setmetatable(class, class);
local interface = {};

type SadMap <m=MapManifest> = typeof(interface.new(nil::m))
type MapManifest <q=string, m=Model> = {
	Name: q,
	SpawnPoints: {Vector3},
	Map: m
}

function private.new <map, q> (Manifest: MapManifest<q> )
	local e0, c0 = HxEvent.new(class.ClassName)
	local e1, c1 = HxEvent.new(class.ClassName)
	
	return main.new({
		InGame=SadObject.new(Manifest);
		OnLoadedEvent = e0;
		OnSpawnedEvent = e1;
		MapLoad = function (...) class.MapLoad(...) c0.Call(...) end :: typeof(class.MapLoad);
		MapSpawn = function (...) c1.Call(class.MapSpawn(...)) end :: typeof(class.MapSpawn);
	}, class)
end


function private:MapLoad ()
	local self = self :: SadMap;
	local Map = main.Mapping.Exception.GameException:Assert(self.InGame.Map):Clone();
	Map.Parent = workspace;
	return Map
end

function private:PlayerTp (Survivors: {Player}, Killers: {Player})
	local self = self :: SadMap;
	main.Mapping.Exception.GameException:Assert(#self.InGame.SpawnPoints > 1)
	local killerspawn = math.random(1, #self.InGame.SpawnPoints)
	local survivorspawn = table.clone(self.InGame.SpawnPoints)
	table.remove(survivorspawn, killerspawn)
	
	
	--main.Mapping.Exception.GameException:Assert(#Survivors > 0)
	--main.Mapping.Exception.GameException:Assert(#Killers > 0)
	
	for i=1, #Survivors do
		local player = Survivors[i]
		local character = player.Character
		local spawnpoint = survivorspawn[math.random(1, #survivorspawn)]
		if not character then 
			main.Mapping.Exception.GameException:Warn('Player '..player.Name..' has no character')
			continue
		else
			character:PivotTo(CFrame.new(spawnpoint))
		end
	end
	
	for i=1, #Killers do
		local player = Killers[i]
		local character = player.Character
		local spawnpoint = self.InGame.SpawnPoints[killerspawn]
		if not character then 
			main.Mapping.Exception.GameException:Warn('Player '..player.Name..' has no character')
			continue
		else
			character:PivotTo(CFrame.new(spawnpoint))
		end
	end
end

class.__index = main.Core.Classes.SadObject().class;
class.ClassName = main.Mapping.Class.SadMap
class.Source = script;

class.OnLoadedEvent, private.OLE = HxEvent.new(class.ClassName);
class.OnSpawnedEvent, private.OSE = HxEvent.new(class.ClassName);

class.MapLoad = private.MapLoad;
class.MapSpawn = private.PlayerTp;
class.InGame = SadObject.new({})
class.InGame.Name = '';
class.InGame.SpawnPoints = {} :: {Vector3};
class.InGame.Map = nil :: Model?;

interface.class = class;
interface.new = private.new;

return main:expand({SadMap = interface})