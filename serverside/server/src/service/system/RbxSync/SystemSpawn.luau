local main = require('../../../');
local components = require('../../../interface/src_components')
local WorldsService = main.Core.Services.WorldsService()
local CodeUtility = main.Libs.CodeUtility
local Mapping = main.Mapping
local spawn = components.action.Spawn()
local model = components.property.Model()
local rotation = components.parameter.Rotation()
local position = components.parameter.Position()
local cstphysic = components.property.CustomPhysics()

local private = {};
local interface = {};

function private.main (World)
	local Service = interface.Service
	local TargetWorld = Service.TargetWorld
	local PhaseLog = Service:DoPhaseLog()
	
	spawn:DoCatchFromWorld(World, function(Component1)
		spawn:DoDestroyFromWorld(World)
		
		private.action_model_spawn(World,Component1)
		private.action_csphysic_spawn(World, Component1)
		
	end)
end


function private.action_model_spawn (World, Component1)
	model:DoCatchFromWorld(World, function(Component2: { Path: string, Source: string })
		local IsValideComponent = Component2.Path ~= '' and CodeUtility.GetInstanceFrom(Component2.Path)
		
		if not IsValideComponent then
			local Source = Mapping.Exception.NullPointerException:Assert(CodeUtility.GetInstanceFrom(Component2.Source)) :: PVInstance
			local Path = Mapping.Exception.TechicalException:Assert(CodeUtility.GetInstanceFrom(Component1.ToPath)) :: Instance
			
			CodeUtility.DoCallContextSync(function(...) 
				local clone = Source:Clone()
				for i,v in clone:GetTags() do clone:RemoveTag(v) end
				local identity = CodeUtility.GetInstanceIdentity(clone)
				clone.Parent = Path
				clone.Name = identity
				Component2.Path = identity
				return clone
			end)
			
		end
	end)
end

function private.action_csphysic_spawn (World, Component1)
	cstphysic:DoCatchFromWorld(World, function(Component: { AttachmentPath: string }) 
		local IsValideComponent = Component.AttachmentPath ~= '' and CodeUtility.GetInstanceFrom(Component.AttachmentPath)
		
		if not IsValideComponent then
			local ToPath
			local Position = Vector3.zero
			local Look = Vector3.one
			local Up = Vector3.one
			
			position:DoCatchFromWorld(World, function(Component: { Value: Vector3 }) 
				Position = Component.Value
			end)
			
			model:DoCatchFromWorld(World, function(Component: { Path: string, Source: string }) 
				local this = CodeUtility.GetInstanceFrom(Component.Path) :: Model?
				if this then
					ToPath = this.PrimaryPart or this
					if Position == Vector3.zero then
						Position = this:GetPivot().Position
					end
				end
			end)
			
			rotation:DoCatchFromWorld(World, function (Component)
				Look = Component.Look
				Up = Component.Up
			end)
			
			CodeUtility.DoCallContextSync(function(...) 
				local attachment = Instance.new('Attachment')
				local path = CodeUtility.GetInstanceIdentity(attachment)
				attachment.Parent = ToPath or workspace
				attachment.Name = path
				attachment.WorldPosition = Position
				attachment.WorldAxis = Look
				Component.AttachmentPath = path
				return attachment
			end)
		end
	end)
end


interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world');
})

interface.Service:DoWhileActive():ConnectParallel(function(deltaTime: number, NewCycle: boolean) 
	local TargetWorld = interface.Service.TargetWorld
	if WorldsService.Service:IsItWorld(TargetWorld) then
		TargetWorld:DoForWorlds(private.main)
	end
end)

return interface