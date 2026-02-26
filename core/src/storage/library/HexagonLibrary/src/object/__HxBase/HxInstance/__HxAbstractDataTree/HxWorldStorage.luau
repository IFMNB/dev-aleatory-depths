local main = require('./')



local private = {};
local class = {}; class.__index=main.__HxAbstractDataTree.class; setmetatable(class,class);
local interface = {}; interface.class=class

type HxWorldStorage = typeof(private.new())
private.worldChannel = script.WorldChannel
private.channels = {}

function private.new ()
	assert(game:GetService('RunService'):IsServer(), 'HxWorldStorage can created only on server')
	
	local this = main.new({
		
	},class)
	
	
	return this
end

function private.get (ChannelName: string)
	
end

class.ClassName=main.ClassNames.HxWorldStorage
class.Source=script
class.Channel = nil :: RemoteEvent?

interface.new = private.new
interface.get = private.get

return main:expand({HxWorldStorage=interface})