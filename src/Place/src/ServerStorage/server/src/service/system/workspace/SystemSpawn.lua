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
	
	spawn:DoCatchFromWorld(World, function(ComSpawn)
		spawn:DoDestroyFromWorld(World)
		
		model:DoCatchFromWorld(World, function(ComMod) 
			private.action_model_spawn(World, ComSpawn, ComMod)
			private.action_csphysic_spawn(World, ComMod)
		end)	
	end)
end


function private.action_model_spawn (World,  ComSpawn: typeof(spawn.Value), ComMod: typeof(model.Value))
	local IsValideComponent = CodeUtility.GetInstanceFrom(ComMod.Path)
	
	if not IsValideComponent then
		local Source = Mapping.Exception.NullPointerException:Assert(CodeUtility.GetInstanceFrom(ComMod.Source)) :: PVInstance
		local Path = Mapping.Exception.TechicalException:Assert(CodeUtility.GetInstanceFrom(ComSpawn.ToPath)) :: Instance
		
		CodeUtility.DoCallContextSync(function(...) 
			local clone = Source:Clone()
			for i,v in clone:GetTags() do clone:RemoveTag(v) end
			local identity = CodeUtility.GetInstanceIdentity(clone)
			clone.Parent = Path
			clone.Name = identity
			ComMod.Path = identity
			return clone
		end)
		
	end
end

function private.action_csphysic_spawn (World, ComMod: typeof(model.Value))
	cstphysic:DoCatchFromWorld(World, function(ComCPhys: typeof(cstphysic.Value)) 
		local IsValideComponent = CodeUtility.GetInstanceFrom(ComCPhys.AttachmentPath)
		
		if not IsValideComponent then
			local ToPath = Mapping.Exception.NullPointerException:Assert(CodeUtility.GetInstanceFrom(ComMod.Path)) :: Model|PVInstance
			local Coordinate = CFrame.new()
			
			position:DoCatchFromWorld(World, function(Component: { Value: Vector3 }) 
				Coordinate = CFrame.new(Component.Value) * Coordinate.Rotation
			end)
			
			rotation:DoCatchFromWorld(World, function (Component)
				Coordinate *= Component.Value
			end)
			
			CodeUtility.DoCallContextSync(function(...) 
				local attachment = Instance.new('Attachment')
				local path = CodeUtility.GetInstanceIdentity(attachment)
				if ToPath:IsA('Model') then
					attachment.Parent = ToPath.PrimaryPart or ToPath
				else
					attachment.Parent = ToPath
				end
				
				attachment.Name = path
				attachment.WorldCFrame = Coordinate
				ComCPhys.AttachmentPath = path
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