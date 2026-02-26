local main = require('../..')

local NetPackageService = require('./')

local private = {}
local interface = {}




interface.Enums = table.freeze({
	Null = main.Mapping.Enum.Null
})
interface.Exceptions = table.freeze({
	
})
interface.Service = main.Core.Classes.SadNetService().new({
	Name = 'NetStateService'::'NetStateService';
	Behavior = interface.Enums.Null;
	IsControllable = false;
})




return interface