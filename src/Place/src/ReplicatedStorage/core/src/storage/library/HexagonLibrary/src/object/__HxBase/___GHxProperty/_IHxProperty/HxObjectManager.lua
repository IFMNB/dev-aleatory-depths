local main = require('./');

local private = {};
local class = {}; setmetatable(class,class);
local interface = {};

private.mv=table.freeze({__mode='kv'})

--[[
	Creates a new object manager.

	ObjectManager is a class that used to safely control collections of link-type objects.
	Also can handle the lifecycle of RbxScriptConnections and HxConnections

	@class HxObjectManager
]]
function private.new ()
	local this = {}	
	
	type any_table = {[any]:any}
	type object = thread | any_table | setmetatable<any_table,any_table> | SharedTable | RBXScriptConnection | (...any)->any 
	type F = (object: any)->()
	
	local my_objects_array = setmetatable({}::{object},private.mv) 
	local my_objects_map = setmetatable({}::{[object]:object},private.mv)
	local is_alive = true
	local is_auto_repair = false
	
	--[[
		@class HxObjectManager
	]]
	function this:AddObject(object: object)
		if my_objects_map[object] then return end
		
		local object_type = typeof(object)
		
		assert(object_type == 'table'
			or object_type == 'thread'
			or object_type == 'SharedTable'
			or object_type == 'function'
			or object_type == "RBXScriptConnection"
		)
		
		table.insert(my_objects_array, object)
		my_objects_map[object] = object
	end
	
	--[[
		@class HxObjectManager
	]]
	function this:RemoveObject(object: object)
		if not my_objects_map[object] then return end
		
		local index = table.find(my_objects_array, object)
		if not index then return end
		
		table.remove(my_objects_array, index)
		my_objects_map[object] = nil
	end
	
	--[[
		@class HxObjectManager
	]]
	function this:DoForCatched(object: object, F: F)
		local target = my_objects_map[object]
		if target then
			xpcall(F,warn,target)
			return true
		end
		
		return false
	end
	
		--[[
		Repairs array-part of object manager and removes all nil-values and disconnected connections.
	
		@class HxObjectManager
	]]
	local function DoRemoveGarbage()
		local CanIterate = next(my_objects_array)
		if CanIterate then
			for i,v in table.clone(my_objects_array) do
				local TypeV = typeof(v)
				if TypeV == 'RBXScriptConnection' then
					(v::any):Disconnect()
				elseif TypeV == 'table' then
					if class.IsA(v, 'HxConnection') then
						(v::any):Disconnect()
					end
				elseif v == nil then
					table.remove(my_objects_array, i)
				end
			end
			
			return true
		end
		return false
	end
	
	--[[
		@class HxObjectManager
	]]
	function this:DoForAll (F: F)
		local CanIterate = next(my_objects_array)
		if CanIterate then
			if this:IsAutoRepair() then
				DoRemoveGarbage()
			end
			
			for _, object in my_objects_array do
				xpcall(F,warn,object)
			end
			return true
		end
		return false
	end
	
	
	--[[
		@class HxObjectManager
	]]
	function this:IsAutoRepair ()
		return is_auto_repair
	end
	
	--[[
		@class HxObjectManager
	]]
	function this:SetAutoRepair (value: boolean)
		is_auto_repair = value
	end
	
	--[[
		@class HxObjectManager
	]]
	function this:IsObjectExists(object: object)
		return my_objects_map[object] ~= nil
	end
	
	--[[
		@class HxObjectManager
	]]
	function this:IsAlive ()
		return is_alive
	end
	
	--[[
		@class HxObjectManager
	]]
	function this:Destroy ()
		is_alive = false
		
		for _,v in my_objects_array do
			local TypeV = typeof(v)
			if TypeV == 'RBXScriptConnection' then
				(v::any):Disconnect()
			elseif TypeV == 'table' then
				if class.IsA(v, 'HxConnection') then
					(v::any):Disconnect()
				end
			end
		end
		
		table.clear(my_objects_array)
		table.clear(my_objects_map)
		
		table.freeze(my_objects_map)
		table.freeze(my_objects_array)
	end
	
	
	
	local result = table.freeze(main.new(this, class))
	return result
end

class.__index = main._IHxProperty.class;
class.ClassName = main.ClassNames.HxObjectManager;
class.Source = script;

class.Destroy = main.Abstract.SelfOverride;
class.AddObject = main.Abstract.SelfOverride;
class.RemoveObject = main.Abstract.SelfOverride;
class.DoForCatched = main.Abstract.SelfOverride;
class.DoForAll = main.Abstract.SelfOverride;
class.IsObjectExists = main.Abstract.SelfOverride;
class.IsAlive = main.Abstract.SelfOverride;
class.Destroy = main.Abstract.SelfOverride;
class.IsAutoRepair = main.Abstract.SelfOverride;
class.SetAutoRepair = main.Abstract.SelfOverride;
--class.DoRemoveGarbage = main.Abstract.SelfOverride;

interface.class = class;
interface.new = private.new;

table.freeze(class)
table.freeze(private)
table.freeze(interface)

return main:expand({HxObjectManager=interface})