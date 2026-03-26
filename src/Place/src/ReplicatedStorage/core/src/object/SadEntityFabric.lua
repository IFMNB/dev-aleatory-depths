local main = require('./');

local private = {};
local class = {};
local interface = {};

type SadEntityFabric <T0=string,T1=typeof(class.Abilities), T2=typeof(class.Components)> = typeof(private.new(nil::T0,nil::T1,nil::T2))

--[[
	@class SadEntityFabric
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

function private:unpack_abilities_into(Target)
	local this = self :: SadEntityFabric	
	local abilities : {[any]:unknown} = this.Abilities

	for i,v in abilities do
		class.AddAbilityTo(this, Target, i)
	end
end

function private:insert_ability_into (Target, name: any)
	local self = self :: SadEntityFabric;
	local abilities : {[any]:unknown} = self.Abilities
	local ability = abilities[name]
	local target_components : {[any]:unknown} = Target.Components
	
	if ability then
		target_components[name]=ability
		return true
	end
	
	return false
end

function private:unpack_components_into(Target)
	local self = self :: SadEntityFabric;
	local components : {[any]: unknown} = self.Components
	
	for i,v in components do
		class.AddComponentTo(self, Target, i)
	end
end

function private:insert_component_into (Target, name: any)
	local self = self :: SadEntityFabric;
	local components : {[any]: unknown} = self.Components
	local component = components[name]
	local target_components : {[any]: unknown} = Target.Components
	
	if component then
		target_components[name]= if type(component) == 'table' then table.clone(component) else component
		return true
	end
	
	return false
	
end

function private:unpack_to(Target)
	local self = self :: SadEntityFabric;
	
	class.DoUnpackAbilitiesTo(self,Target);
	class.DoUnpackComponentsTo(self,Target);
end

class.__index = main.SadObject.class;
class.ClassName = main.Mapping.Class.SadEntityFabric;
class.Source = script;
class.Enums = main.Mapping.Enum.CharacterController

class.Abilities = {} :: {[string]: unknown};
class.Components = {} :: {[string]: unknown};
class.Fabrics = {} :: {[string]: unknown};

class.DoUnpackAbilitiesTo = private.unpack_abilities_into;
class.DoUnpackComponentsTo = private.unpack_components_into;
class.DoUnpackTo = private.unpack_to;

class.AddAbilityTo = private.insert_ability_into;
class.AddComponentTo = private.insert_component_into;

interface.class = class;
interface.new = private.new;

return main:expand({SadEntityFabric = interface})