local main = require('../../');

local private = {};
local class = {}; setmetatable(class,class);
local subclass = {}; setmetatable(subclass, subclass);
local interface = {};

local HxEvent = main.Core.Classes.HxEvent();
local HxNumberModifier = main.Core.Classes.HxNumberModifier();

private.HxNumberModFreeze = table.freeze(HxNumberModifier.new())
private.HxEventModFreeze, private.c0 = HxEvent.new(); private.c0:Destroy();

type SadGameEffect = typeof(interface.new())
type SadGameEffectProcess <Yota=SadGameEffect, Teta=HxNumberModifier, Alpha=any> = typeof(private.new_sub(nil::Yota, nil::Teta, nil::Alpha))
type EnumType = index<typeof(subclass.Enums), keyof<typeof(subclass.Enums)>>

--[[
	Субкласс для обозначения текущей процедуры эффекта. То бишь, это по сути экземпляр выполнения заданного эффекта.
	
	@class SadGameEffectProcess
	@side all
	@return Instance (@P SadGameEffectProcess)
]]
function private.new_sub <Y, T> (effect: SadGameEffect, target: T, enum_type: EnumType)
	local e0,c0 = HxEvent.new();
	local this = main.new({
		ThisEffect = effect,
		ThisTarget = target,
		ProcessType = enum_type,
		
		Duration = effect.Time.Value;
		
		Alive = true,
		OnLifeEndedEvent = e0,
	}, subclass)
	
	this.Cancel = function ()
		if not this.Alive then return end
		
		this.Alive = false
		c0.Call();
		return c0:Destroy();
	end :: typeof(subclass.Cancel)
	
	return this, c0
end

subclass.__index = main.Core.Classes.SadObject().class;
subclass.ClassName = main.Mapping.Class.SadGameEffectProcess;
subclass.Source = script;
subclass.ThisTarget = nil :: unknown;
subclass.ThisEffect = nil :: SadGameEffect?;
subclass.Duration = 0;
subclass.Alive = false;
subclass.OnLifeEndedEvent = private.HxEventModFreeze;
subclass.Cancel = private.c0.Destroy;
subclass.Enums = main.Mapping.Enum.ProcessEffectType;
subclass.ProcessType = nil :: EnumType?;


type HxNumberModifier = typeof(HxNumberModifier.new())

--[[
	Конструктор экземпляра класса SadGameEffect.

	@class SadGameEffect
	@side all
	@return Instance (@P SadGameEffect)
]]
function private.new (Time: number?, Health: number?, Speed: number?)
	local this = main.new({
		Time = HxNumberModifier.new(Time),
	}, class)
	
	return this
end

--[[
	Этот эффект будет самостоятельно выполняться для цели в течение указанного ранее времени.
	
	После окончания отведенного времени жизни, эффект перестанет функционировать.

	@class SadGameEffect
	@side all
	@return Instance (@P SadGameEffectProcess)
]]
function private:do_effect (target: HxNumberModifier, origin: number?, previous: number?,  ...)
	local self = self :: SadGameEffect;
	local this = private.new_sub(self, target, subclass.Enums.ChangeTarget);
	local package = {...};
	
	local lambdatask = task.spawn(function ()
		while task.wait(this.Duration) do
			target.Value = private.callOr(self, origin, previous, unpack(package));
			target:ApplyMod();
		end
	end)
	
	this.OnLifeEndedEvent:Once(function(...) 
		task.cancel(lambdatask);
	end)
	
	return this
end

function private.callOr (this: SadGameEffect, origin: number?, previous: number?, ...) : number
	return this:Effect(origin, previous, ...) or previous or origin or 1
end

--[[
	Этот эффект будет учитываться для цели в течение указанного ранее времени.
	
	После окончания отведенного времени жизни, эффект перестанет функционировать.

	@class SadGameEffect
	@side all
	@return Instance (@P SadGameEffectProcess)
]]
function private:mod_effect (target: HxNumberModifier, ...)
	local self = self :: SadGameEffect;
	local this = private.new_sub(self, target, subclass.Enums.TargetChanges);
	local package = {...};
	
	local labmda = function(origin: number, previous: number): number 
		return private.callOr(self, origin, previous, unpack(package));
	end;
	local priority = #target.Modificators;
	target:AddMod(priority, labmda);
	
	local labmdawait = task.spawn(function ()
		
		task.wait(this.Duration);
		this:Cancel();
	end);
	
	this.OnLifeEndedEvent:Once(function(...) 
		target:RemoveMod(priority, labmda);
		task.cancel(labmdawait);
	end);
	
	return this
end





class.__index = main.Core.Classes.SadObject().class;
class.ClassName = main.Mapping.Class.SadGameEffect;
class.Source = script;
class.Time = private.HxNumberModFreeze;

class.DoEffectChanges = private.do_effect;
class.DoEffectModifictator = private.mod_effect;

class.Effect = warn :: (SadGameEffect: SadGameEffect, origin: number?, previous: number?, ...any) -> number?;

interface.class = class;
interface.subclass = subclass;
interface.new = private.new;


table.freeze(class)
table.freeze(subclass)
table.freeze(private)
table.freeze(interface)

return main:expand({SadGameEffect = interface})