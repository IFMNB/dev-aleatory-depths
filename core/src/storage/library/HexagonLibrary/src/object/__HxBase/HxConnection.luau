local main = require('./');

local private = {};
local class = {}; setmetatable(class, class);
local interface = {};

type HxConnection = typeof(class)
type Pulsar = (HxConnection: HxConnection) -> ()

--[[
	Creates a new default connection.

	If a Pulsar is given, it will be called when the connection is disconnected.

	@class HxConnection
	@return Instance (@P HxConnection)
]]
function private.new (Pulsar: Pulsar?)
	return main.new({
		Connected = true;
		Disconnect = function (self: HxConnection)
			if not self.Connected then return end;
			class.Disconnect(self);
			if Pulsar then Pulsar(self) end
			return
		end :: typeof(class.Disconnect),
	}, class)
end

--[[
	Disconnects the connection.

	If the connection is already disconnected, this function does nothing.
	If a Pulsar was given to the constructor, it will be called now.
	
	@class HxConnection
	@return ()
]]
function private:disconnect ()
	local self = self :: HxConnection;
	self.Connected = false;
	table.freeze(self);
end

class.__index = main.__HxBase.class;
class.ClassName = main.ClassNames.HxConnection;
class.Source = script;
class.Connected = false;
class.Output = nil :: unknown;
class.Disconnect = private.disconnect;

interface.class = class;
interface.new = private.new;

return main:expand({HxConnection = interface})