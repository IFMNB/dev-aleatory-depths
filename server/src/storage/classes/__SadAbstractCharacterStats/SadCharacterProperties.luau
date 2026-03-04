local main = require('./');

local private = {};
local class = {}; setmetatable(class,class);
local interface = {};

type SadCharacterProperties = typeof(class);
local SACS_protected = main.__SACS_protected
local HxNumberModifier = main.Core.Classes.HxNumberModifier();



function private.new (Health: number?, Speed: number?, MaxMultiplier: number?, DefenseModifier: number?, SpeedModifier: number?)
	return main.new(SACS_protected.constr({
		DefenseModifier = HxNumberModifier.new(DefenseModifier),
		SpeedModifier = HxNumberModifier.new(SpeedModifier),
		MaxMultiplier = HxNumberModifier.new(MaxMultiplier),
	}, Health, Speed), class)
end

class.__index = main.__SadAbstractCharacterStats.class;
class.ClassName = main.Mapping.Class.SadCharacterProperties;
class.Source = script;



class.MaxMultiplier = SACS_protected.HxNumberModFreeze;
class.DefenseModifier = SACS_protected.HxNumberModFreeze;
class.SpeedModifier = SACS_protected.HxNumberModFreeze;

interface.class = class;
interface.new = private.new;

return main:expand({SadCharacterProperties = interface})