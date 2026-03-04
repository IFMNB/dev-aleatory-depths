local main = require('../../')

local private = {};
local class = {}; setmetatable(class,class);
local protected = {};
local interface = {};

local HxNumberModifier = main.Core.Classes.HxNumberModifier();
private.HxNumberMod = table.freeze(HxNumberModifier.new());



function private.constr <T> (element: T, Health: number?, Speed: number?)
	return {
		Health = HxNumberModifier.new(Health),
		Speed = HxNumberModifier.new(Speed),
	} :: T
end

class.__index = main.Core.Classes.SadObject().class;
class.ClassName = main.Mapping.Class.SadAbstractCharacterStats;
class.Source = script;


class.Health = private.HxNumberMod;
class.Speed = private.HxNumberMod;
class.ReviveTime = 0
class.DownedDieTime = 0
class.Revives = 0

protected.__index = protected;
protected.HxNumberModFreeze = private.HxNumberMod;
protected.constr = private.constr;
interface.class = class;

table.freeze(class)
table.freeze(interface)
table.freeze(private)
table.freeze(protected)

return main:expand({__SadAbstractCharacterStats = interface, __SACS_protected = protected})