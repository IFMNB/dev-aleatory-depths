local main = require('./');

local private = {};
local class = {}; setmetatable(class,class);
local interface = {};

type SadComponentFabric <U=string,T=any> = typeof(private.new(nil::U,nil::T))

--[[
	Создает новый компонент.

	@class SadComponentFabric
	@side all
	@return Instance (@P SadComponentFabric)
]]
function private.new <T, tbl, i, v> (Name: T & string, Component)
	type function tostring (t0: type)
		local types = types
		return t0:is('singletone') and t0 or types.string;
	end
	
	local raw = {
		Name = tostring(Name) :: tostring<T>;
		Value = Component;
	}
	
	return main.new(raw,class)
end

function private.clone_value (self: SadComponentFabric)
	return type(self) == 'table' and table.clone(self.Value) or self.Value;	
end

--[[
	Встраивает в цель объект компонента.

	Если требуется встраивание в любую другую среду, которая здесь не поддерживается,
	то сделайте это вручную.

	@class SadComponentFabric
	@side all
	@return boolean
]]
function private:create <T> (To)
	local self = self :: SadComponentFabric;
	local AddComponent : ((unknown, string, any)->any)? = To.AddComponent;
	local Components : {[string]: any} = To.Components
	
	
	local result = pcall(function(...) 
		if AddComponent then
			To:AddComponent(self.Name, private.clone_value(self))
			return true
		end
		
		Components[self.Name :: string] = private.clone_value(self)
		return true
	end)

	return result
end

--[[
	Возвращает компонент из мира.
	
	@class SadComponentFabric
	@side all
	@exception RaceConditionException
	@return *unknown*
]]
function private:get_from (To)
	local Components : {[string]:any} = To.Components
	return main.Mapping.Exception.RaceConditionException:Assert(Components[self.Name::string]) :: typeof(self.Value)
	
	-- здесь self ~= type SadComponentFabric потому что добиться возврата типа self.Value и правильного отображения self:GetFrom(...) в редакторе нельзя
end

--[[
	Ищет собственный компонент в объекте.
	
	Если требуется поиск в любой другой среде, которая здесь не поддерживается,
	то сделайте это вручную.
	
	@class SadComponentFabric
	@side all
	@return boolean
]]
function private:is_exists (To)
	local self = self :: SadComponentFabric;
	local Components : {[string]:any} = To.Components
	return Components[self.Name::string] ~= nil
end


class.__index=main.SadObject.class;
class.ClassName = main.Mapping.Class.SadComponentFabric;
class.Source = script;

class.DoInsert = private.create;
class.GetFrom = private.get_from;
class.IsExistsIn = private.is_exists;

interface.class = class;
interface.new = private.new;

table.freeze(private);
table.freeze(class);
table.freeze(interface)

return main:expand({SadComponentFabric=interface})