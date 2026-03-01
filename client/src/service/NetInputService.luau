local main = require('../')
local Mapping = main.Mapping

local private = {}
local interface = {}

local UIS = game:GetService('UserInputService')
local NetPackageService = main.Core.Services.NetPackageService()

function private.PrintInput (Input: InputObject, state: Enum.UserInputState)
	local self = interface.Service;
	if not self:IsLogActive() then return end
	self:PrintLog(string.format('Input from the device has been sent, keycode - %q, UserInput - %q, state - %s',
		Input.KeyCode.Name, Input.UserInputType.Name, tostring(state)
		))
end

function private.PrintEnum (Enum: Enum.KeyCode | Enum.UserInputType, state: boolean)
	local self = interface.Service;
	if not self:IsLogActive() then return end
	self:PrintLog(string.format('Enum from the device has been sent, Enum - %q, state - %s', Enum.Name, tostring(state)))
end

function private:KeyInputBegan (Input: InputObject)
	if not interface.Service:IsActive() then return end
	if Input.KeyCode == Enum.KeyCode.Unknown then return end
	private.PrintInput(Input, Input.UserInputState)
	NetPackageService.Service:SendServer(Mapping.Event.KeyCodeNetwork, Input.KeyCode, Input.UserInputState)
end

function private:KeyInputEnded (Input: InputObject)
	if not interface.Service:IsActive() then return end
	if Input.KeyCode == Enum.KeyCode.Unknown then return end
	private.PrintInput(Input, Input.UserInputState)
	NetPackageService.Service:SendServer(Mapping.Event.KeyCodeNetwork, Input.KeyCode, Input.UserInputState)
end

function private:UserInputBegan (Input: InputObject)
	if not interface.Service:IsActive() then return end
	if Input.UserInputType ~= Enum.UserInputType.None then
		private.PrintInput(Input, Input.UserInputState)
		NetPackageService.Service:SendServer(Mapping.Event.UserInputNetwork, Input.UserInputType, Input.UserInputState)
	end
end

function private:UserInputEnded (Input: InputObject)
	if not interface.Service:IsActive() then return end
	if Input.UserInputType ~= Enum.UserInputType.None then
		private.PrintInput(Input, Input.UserInputState)
		NetPackageService.Service:SendServer(Mapping.Event.UserInputNetwork, Input.UserInputType, Input.UserInputState)
	end
end

function private:Keycode (EnumKeycode: Enum.KeyCode, State: boolean)
	if not interface.Service:IsActive() then return end
	private.PrintEnum(EnumKeycode, State)
	NetPackageService.Service:SendServer(Mapping.Event.KeyCodeNetwork, EnumKeycode, State)
end

function private:Mousecode (EnumUserInput: Enum.UserInputType, State: boolean)
	if not interface.Service:IsActive() then return end
	private.PrintEnum(EnumUserInput, State)
	NetPackageService.Service:SendServer(Mapping.Event.UserInputNetwork, EnumUserInput, State)
end

private.prev = nil :: CFrame?

function private:Camera ()
	if not interface.Service:IsActive() then end
	local cframe = Mapping.Exception.PermissionException:Assert(workspace.CurrentCamera).CFrame
	private.prev = cframe
	NetPackageService.Service:SendServer(Mapping.Event.CameraNetwork, cframe)
end

interface.Enums = table.freeze({
	Null = Mapping.Enum.Null;
});
interface.Exceptions = table.freeze({
	GameException = main.Mapping.Exception.GameException;
});
interface.Service = main.Core.Classes.SadNetService().new({
	Name = 'NetInputService'::'NetInputService';
	
	SendKeyBegan = private.KeyInputBegan;
	SendKeyEnded = private.KeyInputEnded;
	UserInputBegan = private.UserInputBegan;
	UserInputEnded = private.UserInputEnded;
	
	CurrentCameraCFrame = private.prev;
	
	SendKeycode = private.Keycode;
	SendMousecode = private.Mousecode;
	SendCamera = private.Camera;
	
	Behavior = interface.Enums.Null :: index<typeof(interface.Enums), keyof<typeof(interface.Enums)>>;
	IsControllable = true;
});
	
UIS.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if not interface.Service:IsActive() then return end
	if not interface.Service:IsAuto() then return end
	if gameProcessedEvent then return end
	
	interface.Service:SendKeyEnded(input)
	interface.Service:UserInputEnded(input)
end)

game["Run Service"].Heartbeat:Connect(function(deltaTime: number)
	if not interface.Service:IsActive() then return end
	if not interface.Service:IsAuto() then return end
	local cframe = Mapping.Exception.PermissionException:Assert(workspace.CurrentCamera).CFrame
	
	if private.prev then
		local st = false
		local oldcom = {private.prev:GetComponents()}
		for i,v in {cframe:GetComponents()} do
			if math.round(v) ~= math.round(oldcom[i]) then
				st = true
			end
		end
		
		if not st then return end
		if cframe == private.prev then return end
	end
	interface.Service:SendCamera()
end)

UIS.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if not interface.Service:IsActive() then return end
	if not interface.Service:IsAuto() then return end
	if gameProcessedEvent then return end
	
	interface.Service:SendKeyBegan(input)
	interface.Service:UserInputBegan(input)
end)

return interface