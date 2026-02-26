

local main = require('./')

local private = {}
local class = {};class.__index=main.__HxAbstractPrimetive.class;setmetatable(class,class);class.ClassName=main.ClassNames.HxNumber;
local interface = {};

private.default = 0

type NumberObject = typeof(private.new())

-- 
function private.new (value: number?)
	return main.__HxAbstractPrimetive.new(value or private.default, class)
end

-- Post-increment (aka i++)
function private:ipp ()
	local self = self :: NumberObject
	local value = self.Value
	self.Value+=1
	return value
end
-- 	Post-decrement (aka i--)
function private:imm ()
	local self = self :: NumberObject
	local value = self.Value
	self.Value-=1
	return value
end
-- Smootly lerping that NumberObject to target value.
function private:smoothLerp (to: number)
	local self = self :: NumberObject
	local c0 : RBXScriptConnection
	local runservice = game:GetService('RunService')
	c0 = runservice.Heartbeat:Connect(function(deltaTime: number) 
		self.Value=math.lerp(self.Value,to,deltaTime)
		if math.round(self.Value)==math.round(to) then
			c0:Disconnect()
		end
	end)
end


class.Source=script
class['i++']=private.ipp
class['i--']=private.imm
class.Glide = private.smoothLerp
interface.class=class;
interface.new = private.new

return main:expand({Number=interface})