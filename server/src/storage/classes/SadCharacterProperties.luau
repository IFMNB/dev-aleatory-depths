local main = require('../../');

local private = {};
local class = {}; setmetatable(class,class);
local protected = {};
local interface = {};

type SadCharacterProperties = typeof(class);
local HxNumberModifier = main.Core.Classes.HxNumberModifier();

function private.constr (Health: number?, Speed: number?, MaxMultiplier: number?, DefenseModifier: number?, SpeedModifier: number?)
	return {
		Health = HxNumberModifier.new(Health),
		Speed = HxNumberModifier.new(Speed),
		MaxMultiplier = HxNumberModifier.new(MaxMultiplier),
		DefenseModifier = HxNumberModifier.new(DefenseModifier),
		SpeedModifier = HxNumberModifier.new(SpeedModifier)
	}
end

function private.new (Health: number?, Speed: number?, MaxMultiplier: number?, DefenseModifier: number?, SpeedModifier: number?)
	return main.new(private.constr(Health, Speed, MaxMultiplier, DefenseModifier, SpeedModifier), class)
end

private.HxNumberMod = table.freeze(HxNumberModifier.new());

class.__index = main.Core.Classes.SadObject().class;
class.ClassName = main.Mapping.Class.SadCharacterProperties;
class.Source = script;

-- Dynamic

class.Health = private.HxNumberMod;
class.Speed = private.HxNumberMod;
class.MaxMultiplier = private.HxNumberMod;
class.DefenseModifier = private.HxNumberMod;
class.SpeedModifier = private.HxNumberMod;

-- Constants

class.ReviveTime = 0
class.DownedDieTime = 0
class.Revives = 0


protected.Construct = private.constr;
interface.class = class;
interface.new = private.new;

return main:expand({SadCharacterProperties = interface, SadCharacterProperties_protected = protected})