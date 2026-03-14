--!strict
--!native
--!optimize 2

local main = require('./');

local private = {};
local class = {}; setmetatable(class,class);
local interface = {};

local HxSnapshot = main.Libs.Hexagon.Classes.HxSnapshot()

type SadWorld = typeof(private.new())
type Component = (SharedTable & {[any]:unknown}) | unknown
type SWorlds = SharedTable & {[string]:DWorld}
type SComponents = SharedTable & {[string]: Component}
type SArchetype = SharedTable & {[string]: {DWorld}}
type DWorld = {
	Worlds: {[string]: DWorld},
	Components: {[string]: Component},
	Identity: string,
	Parent: DWorld?
}

function private.new (Identity: string?)
	local this = {}
	this.Worlds = SharedTable.new() :: SWorlds
	this.Components = SharedTable.new() :: SComponents
	this.Identity = Identity or main.Libs.CodeUtility.RandomStr()
	this.Archetypes = SharedTable.new() :: SArchetype
	this.Parent = nil :: DWorld|SadWorld?
	
	local result = main.new(this, class)
	return result
end

type fc = (Component: Component)->()
type fw = (World: DWorld)->()



function private:DoForWorlds(f: fw)
	local self = self :: SadWorld;
	for i,v in class.GetSnapshotWorlds(self).Value :: any do
		xpcall(f,warn,v)
	end
end

function private:DoCallForCatchedWorld(Identity:string, f: fw)
	local self = self :: SadWorld;
	local target = self.Worlds[Identity]
	if target then
		xpcall(f,warn,target)
		return true
	end	
	return false
end

function private:DoForComponents(f:fc)
	local self = self :: SadWorld;
	for i,v in class.GetSnapshotComponents(self).Value :: any do
		xpcall(f,warn,v)
	end
end

function private:DoCallForCatchedComponent(Name:string, f: fc)
	local self = self :: SadWorld;
	local target = self.Components[Name]
	if target then
		xpcall(f,warn,target)
		return true
	end
	return false
end

function private:GetSnapshotComponents ()
	local self = self :: SadWorld
	return HxSnapshot.new(SharedTable.clone(self.Components))
end

function private:GetSnapshotWorlds ()
	local self = self :: SadWorld
	return HxSnapshot.new(SharedTable.clone(self.Worlds))
end


function private:AddWorldNew(Identity: string?)
	local self = self :: SadWorld;
	local new = interface.new(Identity)
	local result : string
	SharedTable.update(self.Worlds,new.Identity, function(arg) 
		if arg ~= nil then
			result = arg.Identity
			return arg
		end
		result = new.Identity
		new.Parent = self
		return new
	end)
	
	return result
end

function private:AddWorld(World: SadWorld|DWorld)
	local self = self :: SadWorld
	if self.Worlds[World.Identity] == nil then
		local state = true
		SharedTable.update(self.Worlds, World.Identity, function(arg) 
			if arg ~= nil then
				state = false
				return arg
			end
			return World
		end)
		
		local parent = World.Parent
		SharedTable.update(World::any, 'Parent', function(arg) 
			if arg ~= parent then
				return main.Mapping.Exception.ParallelConditionException:Throw()
			end
			return self
		end)
		return state
	end
	return false
end

function private:RemWorld(Identity: string)
	local self = self :: SadWorld
	local World : DWorld? = self.Worlds[Identity]
	if World then
		SharedTable.update(self.Worlds, Identity, function(arg) 
			if arg == World then
				World.Parent = nil
				return nil
			end
			return arg
		end)
		return true
	end
	return false
end

function private:AddComponent(Name:string, Component: Component)
	local self = self :: SadWorld
	if not self.Components[Name] then
		SharedTable.update(self.Components, Name, function(arg) 
			if arg == nil then
				return Component
			end
			return arg
		end)
		return true	
	end	
	return false
end

function private:UpdateComponent(Name: string, Index: any, f: (old: any, current:any)->any)
	return class.DoCallForCatchedComponent(self, Name, function(Component: any)
		local old = Component[Index]
		SharedTable.update(Component :: SharedTable, Index, function(arg) 
			return f(old, arg)
		end)
	end)
end

function private:RemComponent(Name:string)
	local self = self :: SadWorld
	local target = self.Components[Name]
	if target then
		local state = true
		SharedTable.update(self.Components, Name, function(arg) 
			if arg == target then
				return nil
			end
			state = false
			return arg
		end)
		return state
	end
	return false
end

function private:is_component_exists(Name: string)
	local self = self :: SadWorld
	return self.Components[Name] ~= nil
end

function private:is_world_exists(Identity: string)
	local self = self :: SadWorld
	return self.Worlds[Identity] ~= nil
end

class.__index = main.SadObject.class;
class.ClassName = main.Mapping.Class.SadWorld;
class.Source = script;

class.Worlds = SharedTable.cloneAndFreeze(SharedTable.new()) :: SWorlds;
class.Components = class.Worlds :: SComponents;
class.Archetypes = class.Worlds :: SArchetype;
class.Identity = '';
class.Parent = nil :: DWorld?;

class.DoForWorlds = private.DoForWorlds;
class.DoForComponents = private.DoForComponents;
class.DoCallForCatchedWorld = private.DoCallForCatchedWorld;
class.DoCallForCatchedComponent = private.DoCallForCatchedComponent;

class.GetSnapshotComponents = private.GetSnapshotComponents;
class.GetSnapshotWorlds = private.GetSnapshotWorlds;

class.AddWorldNew = private.AddWorldNew;
class.AddWorld = private.AddWorld;
class.RemWorld = private.RemWorld;

class.DoUpdateComponent = private.UpdateComponent;
class.AddComponent = private.AddComponent;
class.RemComponent = private.RemComponent;

class.IsExistsComponent = private.is_component_exists;
class.IsExistsWorld = private.is_world_exists;

interface.class = class;
interface.new = private.new;

table.freeze(class)
table.freeze(private)
table.freeze(interface)

return main:expand({SadWorld = interface})