local main = require('./');

local private = {};
local class = {};
local interface = {};

local SadWorld = require('./SadWorld').SadWorld
type SadEntityFabric <T0=string,T1=typeof(class.Abilities), T2=typeof(class.Components)> = typeof(private.new(nil::T0,nil::T1,nil::T2))
type SadWorld = typeof(SadWorld.new())

--[[
	Создает ткань для создания персонажа.
	
	Эта ткань является базовой структурой для создания той или иной сущности.
	
	@class SadEntityFabric
	@side all
	@return Instance (@P SadEntityFabric)
]]
function private.new <T,U> (Abilities, Components, Fabrics)
	
	Abilities = main.Mapping.Exception.CodeException:Assert(type(Abilities)=='table' and Abilities)
	Components = main.Mapping.Exception.CodeException:Assert(type(Components)=='table' and Components)
	
	local this = main.new({
		Abilities = Abilities;
        Components = Components;
        Fabrics = Fabrics;
	}, class)
	
	return this
end

function private:insert_abilities_indo (World, ...: any)
	local self = self :: SadEntityFabric;
	local Abilities = self.Abilities :: typeof(class.Abilities)
	local Names = {...}

	if not World.Components then return false end
	
	for Position,AbilityName in Names do
		if Abilities[AbilityName] then
			if not SadWorld.class.AddComponent(World, AbilityName,Abilities[AbilityName]) then
				main.Mapping.Exception.TechicalException:Warn(
					string.format('Ability %s already exists in world %s',AbilityName,World.Identity),
					false
				)
			end
		end
	end
	
	return true
end

function private:unpack_abilities_into (World)
	local self = self :: SadEntityFabric;
	local Abilities = self.Abilities :: typeof(class.Abilities)
	
	if not World.Components then return false end
	
	for i,v in Abilities do
		if not SadWorld.class.AddComponent(World,i,v) then
			main.Mapping.Exception.TechicalException:Warn(
				string.format('Ability %s already exists in world %s',i,World.Identity),
				false
			)
		end
	end
	
	return true
end

function private:unpack_components_into (World)
	local self = self :: SadEntityFabric;
	local Components = self.Components ::  typeof(class.Components)
	
	if not World.Components then return false end
	
	for i,v in Components do
		if not SadWorld.class.AddComponent(World,i,v) then
			main.Mapping.Exception.TechicalException:Warn(
				string.format('Component %s already exists in world %s',i,World.Identity),
				false
			)
		end
	end
	
	return true
end

function private:insert_components_into (World, Identity: string, ...: any)
	local self = self :: SadEntityFabric;
	local Components = self.Components :: typeof(class.Components)
	local Names = {...}
	
	if not World.Components then return false end
	
	for Position,ComponentName in Names do
		if not SadWorld.class.AddComponent(World,ComponentName,Components[ComponentName]) then
			main.Mapping.Exception.TechicalException:Warn(
				string.format('Component %s already exists in world %s',ComponentName,World.Identity),
				false
			)
		end
	end

	return true
end

function private:create (World, WithUnpack: boolean?)
	local self = self :: SadEntityFabric;
	local Identity = SadWorld.class.AddWorldNew(World);
	
	if WithUnpack then
		SadWorld.class.DoCallForCatchedWorld(World, Identity, function(World) 
			class.DoAddAbilities(self,World);
			class.DoAddComponents(self,World);
		end)
	end
	
	return Identity
end


class.__index = main.SadObject.class;
class.ClassName = main.Mapping.Class.SadEntityFabric;
class.Source = script;
class.Enums = main.Mapping.Enum.CharacterController

class.Abilities = {} :: {[string]: unknown};
class.Components = {} :: {[string]: unknown};
class.Fabrics = {} :: {[string]: unknown};

class.DoCreate = private.create;

class.DoAddAbilities = private.unpack_abilities_into;
class.DoAddComponents = private.unpack_components_into;
class.DoAddAbility = private.insert_abilities_indo;
class.DoAddComponent = private.insert_components_into;


interface.class = class;
interface.new = private.new;

return main:expand({SadEntityFabric = interface})