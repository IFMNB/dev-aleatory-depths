local main = require('../../../');
local components = require('../../../interface/src_components')
local WorldsService = main.Core.Services.WorldsService()
local CollectionService = game:GetService('CollectionService')

local model = components.property.Model()
local fetch = components.action.Fetch()
local cstphysic = components.property.CustomPhysics()
local position = components.parameter.Position()

local private = {};
local interface = {};

type System = typeof(interface.Service)

interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	TargetWorld = WorldsService.Service:GetWorld('game.world');
});

private.attachments = {} :: {[PVInstance]: Attachment}

function private.sub_action_cstphysic_new (World, this: PVInstance, Component3: { AttachmentPath: string })
	local Position = Vector3.zero
	
	position:DoCatchFromWorld(World, function(Component: { Value: Vector3 }) 
		Position = Component.Value
	end)
	
	if main.Libs.CodeUtility.IsParallelContext() then
		task.synchronize()
	end

	local attachment = Instance.new('Attachment')

	attachment.Name = cstphysic.Name..'_'..World.Identity::string
	attachment.Parent = (this::Model).PrimaryPart or this
	attachment.WorldCFrame = CFrame.new(Position)
	Component3.AttachmentPath = attachment:GetFullName()
	local t0 = this.Destroying:Once(function() private.attachments[this]=nil end)
	attachment.Destroying:Once(function() 
		t0:Disconnect()
		private.attachments[this]=nil
	end)
	private.attachments[this] = attachment
end

function private.sub_action_attachment_parent_fix (World, this: PVInstance, Attachment: Attachment)
	if this:IsA('Model') then
		local primary = this.PrimaryPart
		if primary then
			if Attachment.Parent ~= primary then
				if main.Libs.CodeUtility.IsParallelContext() then
					task.synchronize()
				end
				Attachment.Parent = primary
				task.desynchronize()
			end
		end
	end
end

function private.action_cstphysic (World, this: PVInstance)
	local IsCstPhysic = cstphysic:DoCatchFromWorld(World, function(Component3: { AttachmentPath: string }) 
		local attachment
		if Component3.AttachmentPath == '' then
			attachment = private.attachments[this]
			if attachment then
				private.sub_action_attachment_parent_fix(World, this, attachment)
				Component3.AttachmentPath = attachment:GetFullName()
			else
				return private.sub_action_cstphysic_new(World, this, Component3)
			end
		else
			attachment = main.Libs.RbxUtility.FromPath(Component3.AttachmentPath) :: Attachment?
			if not attachment then
				attachment = private.attachments[this]
				if attachment then
					private.sub_action_attachment_parent_fix(World, this, attachment)
					Component3.AttachmentPath = attachment:GetFullName()
				else
					return private.sub_action_cstphysic_new(World, this, Component3)
				end
			end
		end
	end)
end

function private.generate_fetch (World, Component1, Component2)
	local Service = interface.Service
	local PhaseLog = Service:DoPhaseLog()
	
	local this : PVInstance?
	if Component1.FetchTag == '' then
		PhaseLog.Insert(1, true)
		if Component2.Path ~= '' then
			PhaseLog.Insert(2, true)
			this = main.Libs.RbxUtility.FromPath(Component2.Path) :: PVInstance?
			if this then
				Component1.FetchTag = main.Libs.CodeUtility.RandomStr()
				if main.Libs.CodeUtility.IsParallelContext() then
					task.synchronize()
					CollectionService:AddTag(this, Component1.FetchTag)
					task.desynchronize()
				end
				PhaseLog.Insert(3, true)
			end
			PhaseLog.Insert(4, this ~= nil)
		end
	end
	
	PhaseLog.EndLog(string.format('Generate fetch for %s', World.Identity))
	
	return this
end

function private.catch_fetched (World, Component1, Component2)
	local Service = interface.Service
	local PhaseLog = Service:DoPhaseLog()
	
	local this = CollectionService:GetTagged(Component1.FetchTag)[1] :: PVInstance?
	if this then
		local name = this:GetFullName()
		if Component2.Path ~= name then
			PhaseLog.Insert(-3, true)
			Component2.Path = name
		end
	end
	
	PhaseLog.Insert(-2, this ~= nil)
	PhaseLog.EndLog(string.format('CatchFetched with %s', World.Identity))
	return this
end

function private.main (World)
	local Service = interface.Service

	fetch:DoCatchFromWorld(World, function(Component1: { FetchTag: string }) 
		local PhaseLog = Service:DoPhaseLog()
		
		local IsModel = model:DoCatchFromWorld(World, function(Component2: { Path: string, Source: string }) 
			local this = private.generate_fetch(World, Component1, Component2) or private.catch_fetched(World, Component1, Component2)
			if this then
				private.action_cstphysic(World, this)
			end
		end)
			
	end)

end


interface.Service:DoWhileActive():ConnectParallel(function(deltaTime: number, NewCycle: boolean) 
	interface.Service.TargetWorld:DoForWorlds(private.main)
end)

return interface