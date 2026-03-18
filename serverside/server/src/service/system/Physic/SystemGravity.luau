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
	mass:DoCatchFromWorld(World, function(ComMass: { Value: number })
		private.gravity_added[World.Identity]=VectorForce
		
		local Velocity = Vector3.zero
		velocity:DoCatchFromWorld(World, function(Component: { Value: Vector3 }) 
			Velocity = Component.Value
		end)
		
		local k = 1
		local GVector = Vector3.new(0, ComMass.Value * workspace.Gravity, 0) - Vector3.new(0,Velocity.Y,0) * k
		CodeUtility.DoCallContextSync(function(...) 
			VectorForce.Force = GVector-- + ComG.Direction
			return
		end)
	end)
end


function private.new_vectorforce (ComCP,ComG) : VectorForce?
	local attachment = CodeUtility.GetInstanceFrom(ComCP.AttachmentPath) :: Attachment
	if attachment then
		return CodeUtility.DoCallContextSync(function(...) 
			local vf = Instance.new 'VectorForce' 
			local Identity = CodeUtility.GetInstanceIdentity(vf)
			vf.Parent = workspace:FindFirstChild('temp') or workspace
			vf.Attachment0 = attachment
			vf.RelativeTo = Enum.ActuatorRelativeTo.World
			vf.Name = Identity
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
	end
	
	private.clear()
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