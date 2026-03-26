local gl = require('./')

local instance = gl.Library.Hexagon.Classes.Instance()

local private = {}
local service

private.service = {}
service = instance.new(private.service, 'HitboxService'::'HitboxService')

private.register = {} :: {[Instance]: Part}
private.service.HitboxDefaultSize = Vector3.new(1, 1, 1) * 2.5
private.service.HitboxTag = 'HitboxServiceTag'

function private:HitboxCreate (Size: Vector3?)
	local hitbox = Instance.new('Part')
	hitbox.Name = 'Hitbox'
	hitbox.CanCollide = false
	hitbox.Size = Size or private.service.HitboxDefaultSize
	hitbox.Transparency = 1
	hitbox:AddTag(private.service.HitboxTag)
	hitbox.Shape = Enum.PartType.Ball
	hitbox.Material = Enum.Material.Neon
	
	if game["Run Service"]:IsStudio() then
		hitbox.Transparency = 0.7
	end
	
	return hitbox
end

function private:WeldCreate (Root: BasePart, Hitbox: BasePart)
	local weld = Instance.new('WeldConstraint')
	weld.Name = 'HitboxWeldConstaint'
	weld.Part0 = Root
	weld.Part1 = Hitbox
	weld.Parent = Hitbox
	return weld
end

-- Creates a hitbox for a humanoid.
function private:HitHumanoid <t0> (Humanoid: Humanoid & t0, Size: Vector3?)
	local root = assert(Humanoid.RootPart, 'Humanoid does not have a root part')
	
	local hitbox = private:HitboxCreate(Size)
	local weld = private:WeldCreate(root, hitbox)
	hitbox:PivotTo(root:GetPivot())
	hitbox.Parent = root
	
	root.Destroying:Once(function() 
		if private.register[root] then
			private.register[root]:Destroy()
			private.register[root] = nil
		end
	end)
	
	if private.register[root] then
		private.register[root]:Destroy()
		private.register[root] = nil
	end
	
	private.register[root] = hitbox
	return hitbox
end

-- Returns a hitbox for a humanoid.
function private:GetHitboxHumanoid <t0> (Humanoid: Humanoid & t0, Size: Vector3?)
	return private.register[assert(Humanoid.RootPart, 'Humanoid does not have a root part')]
end

-- Removes a hitbox for a humanoid.
function private:RemoveHumanoid <t0> (Humanoid: Humanoid & t0)
	local root = assert(Humanoid.RootPart, 'Humanoid does not have a root part')
	if private.register[root] then
		private.register[root]:Destroy()
		private.register[root] = nil
	end
	
	return Humanoid :: t0
end

-- Returns all existed hitboxes for all humanoids
function private:GetAllHumanoidHitboxes (Ecxlude: {Humanoid}?)
	local hitboxes = {}
	local parts
	
	if Ecxlude then
		parts = {}
		for i,v in Ecxlude do
			local root = private:GetHitboxHumanoid(v)
			if root then
				table.insert(parts,root)
			end
		end
	end
	
	for i,v in private.register do
		if parts then if table.find(parts, v) then continue end end
		
		table.insert(hitboxes, v)
	end
	
	return hitboxes
end

private.service.CreateHumanoidHitbox = private.HitHumanoid
private.service.GetHumanoidHitbox = private.GetHitboxHumanoid
private.service.RemoveHumanoidHitbox = private.RemoveHumanoid
private.service.GetAllHumanoidHitboxes = private.GetAllHumanoidHitboxes

table.freeze(private)
table.freeze(private.service)

return service