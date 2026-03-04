local main = require('..//');

local private = {};
local class = {}; setmetatable(class,class);
local subclass = {}; setmetatable(subclass, subclass);
local interface = {};

local protected = setmetatable({}, main.__SACS_protected);
protected.__index = protected;

local HxEvent = main.Core.Classes.HxEvent();
local HxNumberModifier = main.Core.Classes.HxNumberModifier();

private.use_health = setmetatable({} :: {[SadCharacterEffect]: boolean}, {__mode='k'});
private.use_speed = setmetatable({} :: {[SadCharacterEffect]: boolean}, {__mode='k'});




subclass.__index = main.Core.Classes.SadObject().class;
subclass.ClassName = main.Mapping.Class.SadCharacterEffect;
subclass.Source = script;
subclass.Target = nil :: unknown;

type SadCharacterEffect = typeof(interface.new())
type HxNumberModifier = typeof(HxNumberModifier.new())

--[[
	Конструктор экземпляра класса SadCharacterEffect.

	Этот класс является наследником SadAbstractCharacterStats,
	поскольку ему требуется синхронизация с данными всех свойств сущности.

	@class SadCharacterEffect
	@side all
	@return Instance (@P SadCharacterEffect)
]]
function private.new (Time: number?, Health: number?, Speed: number?)
	local this = main.new(protected.constr({
		Time = HxNumberModifier.new(Time),
	}, Health, Speed), class)
	
	private.use_speed[this] = false
	private.use_health[this] = false
	
	return this
end

function private:get_health_use ()
	local self = self :: SadCharacterEffect;
	return not not private.use_health[self]
end

function private:get_speed_use ()
	local self = self :: SadCharacterEffect;
	return not not private.use_speed[self]
end

function private:set_health_use (value: boolean)
	local self = self :: SadCharacterEffect;
	private.use_health[self] = value
end

function private:set_speed_use (value: boolean)
	local self = self :: SadCharacterEffect;
	private.use_speed[self] = value;
end

function private:do_effect (...: any)
	local self = self :: SadCharacterEffect;
	
	return task.spawn(function (...)
		while task.wait(self.Time.Value) do
			self.Effect(self, ...)
		end
	end, ...)
end

function private.callOr (this: SadCharacterEffect, origin: number, previous: number) : number
	return this:Effect(origin, previous) or previous or origin or 1
end

function private:mod_effect_health (target)
	local self = self :: SadCharacterEffect;
	local Health : HxNumberModifier = target.Health;
	local Speed : HxNumberModifier = target.Speed;
	
	if self:IsHealthUse() then
		Health:AddMod(#Health.Modificators, function(...): number 
			return private.callOr(self, ...)
		end)
	end
	
	if self:IsSpeedUse() then
		Speed:AddMod(#Speed.Modificators, function(...): number 
			return private.callOr(self, ...)
		end)
	end
end





class.__index = main.__SadAbstractCharacterStats.class;
class.ClassName = main.Mapping.Class.SadCharacterEffect;
class.Source = script;
class.Time = protected.HxNumberModFreeze;
class.SetHealthUse = protected.HxNumberModFreeze;
class.SetSpeedUse = protected.HxNumberModFreeze;
class.IsHealthUse = private.get_health_use;
class.IsSpeedUse = private.get_speed_use;
class.DoEffect = private.do_effect;
class.Effect = warn :: (SadCharacterEffect: SadCharacterEffect, ...any) -> number?;


interface.class = class;
interface.subclass = subclass;
interface.new = private.new;

return main:expand({SadCharacterEffect = interface})