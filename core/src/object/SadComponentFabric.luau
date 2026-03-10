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
		DoCatchFrom = (nil::any)::<T>(self: unknown, To: T,F: Func<typeof(Component)>)->()
	}
	
	return main.new(raw,class)
end

type Func <T=unknown> = (Component: T)->()

--[[
	Возвращает клон значения этой ткани.
	
	@class SadComponentFabric
	@side all
	@return *unknown*
]]
function private:clone_value ()
	return (type(self) == 'table' and table.clone(self.Value) or self.Value) :: typeof(self.Value)
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
	local Components = To.Components
	
	
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
	Выполняет операцию с компонентом, если он существует.
	
	@class SadComponentFabric
	@side all
	@return boolean
]]
function private:get_from (To, F: Func)
	local Components = To.Components
    local TargetComponent = Components[self.Name]
    if TargetComponent then
        xpcall(F,warn,TargetComponent)
        return true
    end
    return false
end

--[[
	Ищет собственный компонент в объекте, и возвращает true, если он существует.
	
	Если требуется поиск в любой другой среде, которая здесь не поддерживается,
	то сделайте это вручную.
	
	@class SadComponentFabric
	@side all
	@return boolean
]]
function private:is_exists (To)
	local self = self :: SadComponentFabric;
	local Components  = To.Components
	return Components[self.Name::string] ~= nil
end


class.__index=main.SadObject.class;
class.ClassName = main.Mapping.Class.SadComponentFabric;
class.Source = script;

class.DoInsert = private.create;
class.DoCatchFrom = private.get_from;
class.IsExistsIn = private.is_exists;
class.DoCloneValue = private.clone_value;

interface.class = class;
interface.new = private.new;

table.freeze(private);
table.freeze(class);
table.freeze(interface)

return main:expand({SadComponentFabric=interface})