local main = require('../')
local Mapping = main.Mapping
local private = {}
local interface = {}

local PhysicsService = game:GetService('PhysicsService')
local SadPhysicGroup = main.Core.Classes.SadPhysicGroup()
local HxSnapshot = main.Core.Classes.HxSnapshot()

type SadPhysicGroup <T=string> = typeof(SadPhysicGroup.new(nil::T))
type GameCollisionService = typeof(interface.Service)

private.count = 0
private.groups = {}
function private:new_group (name: string) : SadPhysicGroup
	local self = self :: GameCollisionService;

	
	interface.Exceptions.CodeException:Assert(not private.groups[name])
	local group = SadPhysicGroup.new(name)
	private.groups[name] = group
	private.count+=1
	return group
end

function private:DestroyGroup (name: string)
	local self = self :: GameCollisionService;

	
	local group = interface.Exceptions.CodeException:Assert(private.groups[name]);
	PhysicsService:UnregisterCollisionGroup(group.Name);
	private.groups[name] = nil
	private.count-=1
end

function private:GetGroup (RegisterName: PreRegisteredGroups | string) : SadPhysicGroup
	return interface.Exceptions.CodeException:Assert(private.groups[RegisterName])
end

function private:getgroups ()
	return HxSnapshot.new(private.groups)
end

function private:get_Count ()
	return private.count
end



interface.Enums = table.freeze({
	Null = Mapping.Enum.Null;
});
interface.Exceptions = table.freeze({
	CodeException = Mapping.Exception.CodeException;
});
interface.Service = main.Core.Classes.SadGameService().new({
	RemoveGroup = private.DestroyGroup;
	GetGroup = private.GetGroup;
	NewGroup = private.new_group;
	GetGroups = private.getgroups;
	GetGroupCount = private.get_Count;
	
	Name = 'GameCollisionService'::'GameCollisionService';
	IsControllable = false;
	Behavior = interface.Enums.Null :: index<typeof(interface.Enums), keyof<typeof(interface.Enums)>>;
})

export type PreRegisteredGroups = 'SurvivorCollision' | 'WeaponCollision' | 'EnvironmentCollision' | 'EnemyCollision' | 'DebrisCollision' | 'IgnoreCollision'

private.groups.SurvivorCollision = private:new_group('SurvivorCollision');
private.groups.WeaponCollision = private:new_group('WeaponCollision');
private.groups.EnvironmentCollision = private:new_group('EnvironmentCollision');
private.groups.EnemyCollision = private:new_group('EnemyCollision');
private.groups.DebrisCollision = private:new_group('DebrisCollision');
private.groups.IgnoreCollision = private:new_group('IgnoreCollision');


return interface