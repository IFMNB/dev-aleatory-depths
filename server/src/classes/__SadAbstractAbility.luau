local main = require('../')
local Mapping = main.Mapping;

local Hx = main.Libs.Hexagon
local HxEvent = Hx.Classes.HxEvent()

local private = {};
local class = {}; setmetatable(class,class)
local protected = {};
local interface = {};

private.e0, private.c0 = HxEvent.new();private.c0:Destroy()
type Abilities = index<typeof(Mapping.Enum.AbilityType), keyof<typeof(Mapping.Enum.AbilityType)>>
type SadAbstractAbility = typeof(class)

private.mode = {__mode='k'}
private.reload = setmetatable({},private.mode)

--[[
	Возвращает состояние перезарядки.
	
	@class SadAbstractAbility
	@side all
	@return boolean
]]
function private:IsReloading ()
	local self = self :: SadAbstractAbility;
	return not not private.reload[self]
end


--[[
	Вызывает перезарядку этой способности.
	
	Записывает временной штамп внутри и автоматически прерывает состояние перезарядки, если штамп совпадает.
	
	@class SadAbstractAbility
	@side all
	@return ()
]]
function private:Reload ()
	local self = self :: SadAbstractAbility;
	local stamp = tick()
	private.reload[self] = stamp;
	
	task.spawn(function ()
		task.wait(self.Reload)
		if private.reload[self] == stamp then
			private.reload[self] = nil
		end
	end)
	
end

--[[
	Вызывает выполнение способности, активируя все что должен активировать экземпляр этого класса как это было запланировано.

	@class SadAbstractAbility
	@side all
	@exception CodeException, GameException
	@return ()
]]
function private:Call (...)
	local self = self :: SadAbstractAbility;
	local ability = Mapping.Exception.CodeException:Assert(self.Ability)
	Mapping.Exception.GameException:Assert(not self:IsReloading())
	ability(...)
end


--[[
	Защищенный конструктор выполняет условия контракта для класса наследника, декларируя общий список полей для всех наследников.
	
	Этот конструктор не предназначен для использование вне наследников.
	
	@class SadAbstractAbility
	@side all
	@return Instance (@P SadAbstractAbility)
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
class.ClassName = Mapping.Class.SadAbstractAbility;
class.Source = script;

class.Name = '';
class.Reload = 0;
class.Damage = 0;
class.Stun = 0;
class.Type = Mapping.Enum.AbilityType.Ignore :: Abilities;
class.Ability = warn :: (...any) -> ()?;

class.IsReloading = private.IsReloading;

class.DoReload = private.Reload;
class.DoCall = private.Call;

class.OnReloadEvent = private.e0
class.OnCallEvent = private.e0
class.OnEndEvent = private.e0




interface.class = class;

return main:expand({__SadAbstractAbility = interface})