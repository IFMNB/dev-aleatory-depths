local Libs = require('../interface/src_library')
local Enum = Libs:Libs().Hexagon.Classes.HxLocalEnum()

local Sad_Enums = table.freeze({
	Null = Enum.new('Null'::'Null');
	Client = Enum.new('Client'::'Client');
	Server = Enum.new('Server'::'Server');
	
	UseDefined = Enum.new('UseDefined'::'UseDefined');
	UseDefault = Enum.new('UseDefault'::'UseDefault');

	UseBufferedTransport = Enum.new('UseSadPackages'::'UseSadPackages');
	
	Replicate = Enum.new('Replicate'::'Replicate'),
	Unreplicate = Enum.new('Unreplicate'::'Unreplicate'),
	
	AllowEvery = Enum.new('AllowEvery'::'AllowEvery'),
	AllowEnemy = Enum.new('AllowEnemy'::'AllowEnemy'),
	AllowChanges = Enum.new('AllowChanges'::'AllowChanges'),
	
	DenyEvery = Enum.new('DenyEvery'::'DenyEvery'),
	DenyChanges = Enum.new('DenyChanges'::'DenyChanges'),
	
	-- Дополнительно
})

return Sad_Enums