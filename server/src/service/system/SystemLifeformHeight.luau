local main = require('../../');

local private = {};
local interface = {};

type System = typeof(interface.Service)

interface.Service = main.Core.Classes.SadSystemService().new({
	Name = script.Name;
	IsControllable = false;
});



return interface