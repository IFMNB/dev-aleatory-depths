local main = require('../..');

local private = {};
local class = {}; setmetatable(class,class);
local interface = {};

private.cfgservice = game:GetService('ConfigService')

type SadConfigSnapshot = typeof(interface.new())

function private.get_Cfg ()
	local state, result = pcall(function () return private.cfgservice:GetConfigAsync() end)
	return state and result or nil
end

function private.fetch (try: number?)
	if try == math.huge then
		while true do
			local config = private.get_Cfg()
			if config then
				return config
			end
			task.wait(2)
		end
	else
		for i = 1, try or 3 do
			local config = private.get_Cfg()
			if config then
				return config
			end
			task.wait(1*(i*i))
		end
	end
		
	return main.Mapping.Exception.TechicalException:Throw()
end

function private:refresh ()
	local self = self :: SadConfigSnapshot;
	
	self.LocalSnapshot:Refresh()
	
	return self
end

function private:get (name: string)
	local self = self :: SadConfigSnapshot;
	
	if self.AlreadyValue[name] then
		return self.AlreadyValue[name]
	end
	
	local value = self.LocalSnapshot:GetValue(name)
	local HxObjectRef = main.Core.Classes.HxString().new(tostring(value))
	self.AlreadyValue[name]=HxObjectRef
	
	local signal : RBXScriptConnection
	signal = self.LocalSnapshot:GetValueChangedSignal(name):Connect(function(...) 
		if self.AlreadyValue[name] then
			self.AlreadyValue[name].Value = tostring(self.LocalSnapshot:GetValue(name))
		else
			signal:Disconnect()
		end
	end)
	
	return HxObjectRef
end

-- This class used as a wrapper to ConfigService:GetConfigAsync(). Can throw exception if your try value is not a math.huge. Yields until config loaded or exception thrown.
function private.new (try: number?)
	local LocalSnapshot = private.fetch(try)
	local SCS = main.new({
		LocalSnapshot = LocalSnapshot,
		AlreadyValue = setmetatable({}::{[string]:typeof(main.Core.Classes.HxString().new())}, {__mode='v'::'v'})
	}, class)
	
	LocalSnapshot.UpdateAvailable:Connect(function() 
		if SCS.AutoUpdate then
			SCS:Update()
		end
	end)
	
	return SCS
end

class.__index = main.Core.Classes.SadObject().class;
class.ClassName = main.Mapping.Class.SadConfigSnapshot
class.Source = script;
class.AutoUpdate = false;
class.LocalSnapshot = nil :: ConfigSnapshot?;
class.AlreadyValue = {}

class.Update = private.refresh;
class.Get = private.get;

interface.class = class;
interface.new = private.new;

return main:expand({SadConfigSnapshot = class})