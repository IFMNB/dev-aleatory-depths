local main = require('../..')
local Mapping = main.Mapping
local private = {}
local interface = {}

local HxEventCore = main.Core.Classes.HxEventCore()
local NetOwnerService = require('./')
local DebrisService = game:GetService('Debris')

type GameStunService = typeof(interface.Service);

function private:Stun (Character: Model, Time: number?, knockback: Vector3?)
	local self = self :: GameStunService;
	if not self:IsActive() then return end
	
	NetOwnerService.Service:OwnerSwapDo(Character, function(Model: Model, Primary: BasePart) 
		local Humanoid = interface.Exceptions.GameException:Assert(Model:FindFirstChildOfClass('Humanoid'))
		
		Humanoid.EvaluateStateMachine = false
		Humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)
		Primary:ApplyImpulse(knockback or Vector3.new(0,0,-1))
		
		local Attachment = Instance.new('Attachment')
		Attachment.Name = self.Name
		Attachment.CFrame = Primary.CFrame
		Attachment.Parent = Primary

		
		local AlignOrientation = Instance.new('AlignOrientation')
		AlignOrientation.Name = self.Name
		AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		AlignOrientation.Attachment0 = Primary:FindFirstChildOfClass('Attachment')
		AlignOrientation.Parent = Primary
		AlignOrientation.Enabled = true
		AlignOrientation.MaxTorque = math.huge
		AlignOrientation.SecondaryAxis = Vector3.new(0,1,0)
		
		task.wait(Time)
		AlignOrientation.Enabled = false
		DebrisService:AddItem(AlignOrientation)
		Humanoid.EvaluateStateMachine = true
	end)
	
	private.stun:DoCall(Character, Time)
end

function private:Fall (Character: Model, Time: number?, knockbackAngle: Vector3?)
	local self = self :: GameStunService;
	if not self:IsActive() then return end
	
	NetOwnerService.Service:OwnerSwapDo(Character, function(Model: Model, Primary: BasePart) 
		local Humanoid = interface.Exceptions.GameException:Assert(Model:FindFirstChildOfClass('Humanoid'))
		
		Humanoid.EvaluateStateMachine = false
		Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
		Primary:ApplyAngularImpulse(knockbackAngle or Vector3.new(0,0,-1))
		
		task.wait(Time)
		Humanoid.EvaluateStateMachine = true
	end)
	
	private.fall:DoCall(Character, Time)
end

function private:PlrStun (Player: Player, Time: number?, knockback: Vector3?)
	local self = self :: GameStunService;
	return self:DoModelStun(interface.Exceptions.GameException:Assert(Player.Character), Time, knockback)
end

function private:PlrFall (Player: Player, Time: number?, knockbackAngle: Vector3?)
	local self = self :: GameStunService;
	return self:DoModelFall(interface.Exceptions.GameException:Assert(Player.Character), Time, knockbackAngle)
end

type DF = (Character: Model, Time: number)->()
private.stun = HxEventCore.new(warn::DF);
private.fall = HxEventCore.new(warn::DF);

private.e0 = private.stun:AddEvent()
private.e1 = private.fall:AddEvent()
interface.Enums = table.freeze({
	Null = Mapping.Enum.Null;
});
interface.Exceptions = table.freeze({
	GameException = main.Mapping.Exception.GameException;
	CodeException = main.Mapping.Exception.CodeException;
});
interface.Service = main.Core.Classes.SadNetService().new({
	DoModelStun = private.Stun;
	DoModelFall = private.Fall;
	
	DoPlayerStun = private.PlrStun;
	DoPlayerFall = private.PlrFall;
	
	OnStunEvent = private.e0;
	OnFallEvent = private.e1;
	
	
	Name = 'GameStunService'::'GameStunService';
	IsControllable = false;
	Behavior = interface.Enums.Null :: index<typeof(interface.Enums), keyof<typeof(interface.Enums)>>;
})



return interface