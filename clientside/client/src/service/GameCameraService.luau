local main = require('../')
local Camera = workspace.Camera :: Camera

local TweenService = game:GetService('TweenService')

local private = {};
local interface = {};

type GameCameraService = typeof(interface.Service)

private.watched = {}
private.list = {} :: {CFrame?}

function private.Equal (a: CFrame, b: CFrame)
	return private.EquapV(a.Position,b.Position) and private.EquapV(a.LookVector,b.LookVector)
end

function private.EquapV (a: Vector3, b: Vector3)
	return a.Magnitude == b.Magnitude
end

function private.Watch (action: string, f: (deltaTime: number, Camera: Camera, Connection: RBXScriptConnection)->CFrame|nil)
	local con : RBXScriptConnection
	con = game["Run Service"].PreRender:Connect(function(deltaTime: number)
		table.insert(private.list, f(deltaTime, Camera, con))
		if not con.Connected then
			(private::any).watched[action] = nil
		end
	end)
	private.watched[action] = {
		con = con
	}
	
	return private.watched[action].con
end

function private:Push ()
	local self = self :: GameCameraService;
	if not self:IsActive() then return end
	
	if self:IsLogActive() then
		self:PrintLog(string.format('Pushing %s elements', tostring(#private.list)))
	end
	
	local out = Camera.CFrame
	for i=1, #private.list do
		local cframe = private.list[i] :: CFrame
		
		out=out:Lerp(cframe, 0.01)
	end
	
	table.clear(private.list)
	
	Camera.CFrame = out
end

function private:ChangeFov (To: number, time: number?) : Tween?
	local self = self :: GameCameraService;
	if not self:IsActive() then return nil end
	
	local TweenInfo = TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	local Tween = TweenService:Create(Camera, TweenInfo, {FieldOfView=To})
	Tween:Play()
	
	if self:IsLogActive() then
		self:PrintLog(string.format('Changing fov from %s to %s, time %s', tostring(Camera.FieldOfView), tostring(To), tostring(time)))
	end
	
	return Tween
end

function private:MoveTo (Position: Vector3)
	local self = self :: GameCameraService;
	
	return private.Watch('MoveTo',function(deltaTime: number, Camera: Camera, Connection: RBXScriptConnection): CFrame? 
		if not self:IsActive() then return nil end
		local this = Camera.CFrame.Position:Lerp(Position, deltaTime)
		
		if private.EquapV(this, Position) then
			Connection:Disconnect()
		end
		
		return CFrame.new(this)
	end)
end

function private:Move (Direction: Vector3)
	local self = self :: GameCameraService;

	return private.Watch('Move',function(deltaTime: number, Camera: Camera, Connection: RBXScriptConnection): CFrame? 
		if not self:IsActive() then return nil end
		local this = Camera.CFrame.Position+Direction*deltaTime
		
		return CFrame.new(this)
	end)
end

function private:RotateTo (Direction: Vector3)
	local self = self :: GameCameraService;
	
	return private.Watch('RotateTo',function(deltaTime: number, Camera: Camera, Connection: RBXScriptConnection): CFrame? 
		if not self:IsActive() then return nil end
		local this = Camera.CFrame.LookVector:Lerp(Direction, deltaTime)
		
		if private.EquapV(this, Direction) then
			Connection:Disconnect()
		end
		
		return CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position+this)
	end)
end

function private:Rotate (Direction: Vector3)
	local self = self :: GameCameraService;
	
	return private.Watch('Rotate',function(deltaTime: number, Camera: Camera, Connection: RBXScriptConnection): CFrame? 
		if not self:IsActive() then return nil end
		local this = Camera.CFrame.LookVector+Direction*deltaTime
		
		return CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position+this)
	end)
end

interface.Enums = table.freeze({
	
});
interface.Exceptions = table.freeze({
	
});
interface.Service = main.Core.Classes.SadNetService().new({
	MoveTo = private.MoveTo;
	Move = private.Move;
	
	RotateTo = private.RotateTo;
	Rotate = private.Rotate;
	
	ChangeFov = private.ChangeFov;
	Push = private.Push;
	
	Camera = Camera;
	
	Name = 'GameCameraService';
	IsControllable = true;
	Behavior = {};
});

game["Run Service"]:BindToRenderStep('GameCameraService', Enum.RenderPriority.Camera.Value, function ()
	local self = interface.Service;
	if not self:IsAuto() then return end

	self:Push()
end)

return interface;