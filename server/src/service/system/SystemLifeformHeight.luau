local main = require('../../');

local WorldsService = main.Core.Services

local private = {};
local interface = {};

type System = typeof(interface.Service)

interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
});

interface.Service:DoWhileActive(function() 
	
end)

return interface