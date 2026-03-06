local main = require('../..');
local Mapping = main.Mapping;

local Hx = main.Libs.Hexagon
local HxEvent = Hx.Classes.HxEvent()

local private = {};
local class = {}; setmetatable(class,class)
local protected = {};
local interface = {};

private.e0, private.c0 = HxEvent.new();private.c0:Destroy()
type Abilities = index<typeof(Mapping.Enum.AbilityType), keyof<typeof(Mapping.Enum.AbilityType)>>
export type SadCharacterProperties = typeof(require('./__SadAbstractCharacterStats/SadCharacterProperties').SadCharacterProperties.new())
export type SadCharacterReference <DM = Model> = typeof(require('./SadCharacterReference').SadCharacterReference.new(nil::DM))
type SadAbility = typeof(interface.new())

private.mode = {__mode='k'}
private.reload = setmetatable({},private.mode)

function private.new (Ability: typeof(class.Ability)?, Type: Abilities?, ReloadDuration: number?, DamageValue: number?, StunDuration: number?)
	local e0, c0 = HxEvent.new();
	local e1, c1 = HxEvent.new();
	local e2, c2 = HxEvent.new();
	
	return main.new({
		Ability = Ability :: typeof(class.Ability);
		DoCall = main.Abstract.Wrap(c0.Call, class.DoCall :: any, c1.Call) :: typeof(class.DoCall);
		OnCallEvent = e0;
		OnEndEvent = e1;
		DoReload = main.Abstract.Wrap(c2.Call, class.DoReload);
		OnReloadEvent = e2;
		
		Type = Type;
		ReloadDuration = ReloadDuration;
		DamageValue = DamageValue;
		StunDuration = StunDuration;
	}, class)
end

--[[
	Возвращает состояние перезарядки.
	
	@class SadAbility
	@side all
	@return boolean
]]
function private:IsReloading ()
	local self = self :: SadAbility;
	return not not private.reload[self]
end


--[[
	Вызывает перезарядку этой способности.
	
	Записывает временной штамп внутри и автоматически прерывает состояние перезарядки, если штамп совпадает.
	
	@class SadAbility
	@side all
	@return ()
]]
function private:Reload ()
	local self = self :: SadAbility;
	local stamp = tick()
	private.reload[self] = stamp;
	
	task.spawn(function ()
		task.wait(self.ReloadDuration)
		if private.reload[self] == stamp then
			private.reload[self] = nil
		end
	end)
	
end

--[[
	Вызывает выполнение способности, проверяя ее перезарядку при этом

	@class SadAbility
	@side all
	@exception CodeException, GameException
	@return ()
]]
function private:Call (Properties: SadCharacterProperties, Target: SadCharacterReference, ...: any)
	local self = self :: SadAbility;
	
	if self:IsReloading() then
		return
	end
	
	self:Ability(Properties, Target, ...)
end


--[[
	Защищенный конструктор выполняет условия контракта для класса наследника, декларируя общий список полей для всех наследников.
	
	Этот конструктор не предназначен для использование вне наследников.
	
	@class SadAbility
	@side all
	@return Instance (@P SadAbility)
]]
function private.constructor <T,C,U> (F: T, childClass: C, element: U)
	local this = main.new(element, childClass)
	local nolint = this :: any
	
	local e0, c0 = HxEvent.new()
	local e1, c1 = HxEvent.new()
	local e2, c2 = HxEvent.new()
	
	nolint.DoReload = main.Abstract.Wrap(c2.Call, class.DoReload)
	nolint.DoCall = main.Abstract.Wrap(c0.Call, F, c1.Call)
	nolint.OnCallEvent = e0;
	nolint.OnEndEvent = e1;
	nolint.OnReloadEvent = e2;
	
	return this
end



class.__index = main.Core.Classes.SadObject().class;
class.ClassName = Mapping.Class.SadAbility;
class.Source = script;

class.ReloadDuration = 0;
class.DamageValue = 0;
class.StunDuration = 0;
class.Enums = Mapping.Enum.AbilityType;
class.Type = class.Enums.Ignore :: Abilities;
class.Ability = warn :: (self: SadAbility, Properties: SadCharacterProperties, Reference: SadCharacterReference, ...any) -> ();

class.IsReloading = private.IsReloading;
class.Priority = 0;

class.DoReload = private.Reload;
class.DoCall = private.Call;

class.OnReloadEvent = private.e0
class.OnCallEvent = private.e0
class.OnEndEvent = private.e0


interface.class = class;
interface.new = private.new;

return main:expand({SadAbility = interface})