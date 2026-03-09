local main = require('../../');
local world_game = main.Core.Services.GameWorldsService().Service:GetWorld('game')

local private = {};
local class = {};
local interface = {};

type SadEntityFabric <T0=string,T1=typeof(class.Abilities), T2=typeof(class.Components)> = typeof(private.new(nil::T0,nil::T1,nil::T2))

--[[
	Создает ткань для создания персонажа.
	
	Эта ткань является базовой структурой для создания той или иной сущности.
	
	@class SadEntityFabric
	@side all
	@return Instance (@P SadEntityFabric)
]]
function private.new (Abilities, Components)
	local this = main.new({
		Abilities = table.freeze(Abilities);
		Components = table.freeze(Components);
	}, class)
	
	return this
end

function private:unpack_abilities_into (Identity: string)
	local self = self :: SadEntityFabric;
	local Abilities : typeof(class.Abilities) = self.Abilities
	local IsTargetExists = world_game:DoForTarget(Identity, function(World) 
		for i,v in Abilities do
			if not World:AddComponent(i,v) then
				main.Mapping.Exception.TechicalException:Warn(
					string.format('Ability %s already exists in world %s',i,World.Identity),
					false
				)
			end
		end
	end)
	
	return IsTargetExists
end

function private:insert_abilities_indo (Identity: string, ...: any)
	local self = self :: SadEntityFabric;
	local Abilities : typeof(class.Abilities) = self.Abilities
	local Names = {...}
	
	local IsTargetExists = world_game:DoForTarget(Identity, function(World) 
		for Position,AbilityName in Names do
			if self.Abilities[AbilityName] then
				if not World:AddComponent(AbilityName,self.Abilities[AbilityName]) then
					main.Mapping.Exception.TechicalException:Warn(
						string.format('Ability %s already exists in world %s',AbilityName,World.Identity),
						false
					)
				end
			end
		end
	end)
	
	return IsTargetExists
end

function private:unpack_components_into (Identity: string)
	local self = self :: SadEntityFabric;
	local Components : typeof(class.Components) = self.Components
	local IsTargetExists = world_game:DoForTarget(Identity, function(World) 
		for i,v in Components do
			if not World:AddComponent(i,v) then
				main.Mapping.Exception.TechicalException:Warn(
					string.format('Component %s already exists in world %s',i,World.Identity),
					false
				)
			end
		end
	end)
	
	return IsTargetExists
end

function private:insert_components_into (Identity: string, ...: any)
	local self = self :: SadEntityFabric;
	local Components : typeof(class.Components) = self.Components
	local Names = {...}
	
	local IsTargetExists = world_game:DoForTarget(Identity, function(World) 
		for Position,ComponentName in Names do
			if not World:AddComponent(ComponentName,Components[ComponentName]) then
				main.Mapping.Exception.TechicalException:Warn(
					string.format('Component %s already exists in world %s',ComponentName,World.Identity),
					false
				)
			end
		end
	end)
	
	return IsTargetExists
end

function private:create ()
	local self = self :: SadEntityFabric;
	return world_game:AddElement()
end


class.__index = main.Core.Classes.SadObject().class;
class.ClassName = main.Mapping.Class.SadEntityFabric;
class.Source = script;
class.Enums = main.Mapping.Enum.CharacterController

class.Abilities = {} :: {[string]: unknown};
class.Components = {} :: {[string]: unknown};

class.DoCreate = private.create;

class.DoInsertAbilities = private.unpack_abilities_into;
class.DoInsertComponents = private.unpack_components_into;
class.DoAddAbility = private.insert_abilities_indo;
class.DoAddComponent = private.insert_components_into;


interface.class = class;
interface.new = private.new;

return main:expand({SadEntityFabric = interface})