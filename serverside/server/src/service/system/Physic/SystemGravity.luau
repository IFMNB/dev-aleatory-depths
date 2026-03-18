local main = require('../../../');
local components = require('../../../interface/src_components')
local WorldsService = main.Core.Services.WorldsService()
local CodeUtility = main.Libs.CodeUtility
local Mapping = main.Mapping

local cphysic = components.property.CustomPhysics()
local gravity = components.effect.Gravity()
local mass = components.property.Mass()
local velocity = components.parameter.Velocity()

local private = {}
local interface = {}

private.gravity_added = {} :: {[string]: VectorForce}
private.check = {} :: {[string]: true}

function private.main (World)
	local Service = interface.Service
	
	cphysic:DoCatchFromWorld(World, function(ComCP: { AttachmentPath: string }) 
		private.action_gravity(World,ComCP)
	end)
end

function private.action_gravity (World, ComCP)
	gravity:DoCatchFromWorld(World, function(ComG: { Direction: Vector3, Path: string }) 
		local this = (CodeUtility.GetInstanceFrom(ComG.Path) or private.new_vectorforce(ComCP, ComG)) :: VectorForce?
		private.check[World.Identity]=true
		if this then
			private.set_vectorforce(World, ComG, this)
		end
	end)
end

function private.set_vectorforce (World, ComG: { Direction: Vector3, Path: string }, VectorForce: VectorForce)
	private.gravity_added[World.Identity]=VectorForce
	CodeUtility.DoCallContextSync(function(...) 
		local vY = Vector3.zero.Y
		local k = 0
		local g = workspace.Gravity
		local m = 1
		
		velocity:DoCatchFromWorld(World, function(Component: { Value: Vector3 }) 
			vY = Component.Value.Y
		end)
		
		mass:DoCatchFromWorld(World, function(ComMass: { Value: number })
			m = ComMass.Value	
		end)
		
		local GVector = Vector3.new(0, m*g, 0) - Vector3.new(0,vY,0) * k
		VectorForce.Force = GVector + ComG.Direction
		return
	end)
end


function private.new_vectorforce (ComCP,ComG) : VectorForce?
	local attachment = CodeUtility.GetInstanceFrom(ComCP.AttachmentPath) :: Attachment
	if attachment then
		return CodeUtility.DoCallContextSync(function(...) 
			local vf = Instance.new 'VectorForce' 
			local Identity = CodeUtility.GetInstanceIdentity(vf)
			vf.Parent = attachment
			vf.Attachment0 = attachment
			vf.RelativeTo = Enum.ActuatorRelativeTo.World
			vf.Name = interface[('Service'::any)].Name
			vf.ApplyAtCenterOfMass = true
			ComG.Path = Identity
			
			
			return vf
		end)
	end
	
	return nil
end


interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world')
})

interface.Service:DoWhileActive():ConnectParallel(function (delta, first)
	local TargetWorld = interface.Service.TargetWorld
	if WorldsService.Service:IsItWorld(TargetWorld) then
		TargetWorld:DoForWorlds(private.main)
		private.clear()
	end
end)

function private.clear ()
	for i,v in private.gravity_added do
		if not private.check[i] then
			game.Debris:AddItem(private.gravity_added[i])
			private.gravity_added[i]=nil
		end
	end
	table.clear(private.check)
end


return interface