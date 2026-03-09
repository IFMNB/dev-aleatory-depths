local main = require('../../');
local component = table.freeze(main.Core.Classes.SadComponentFabric().new(
	'Model'::'Model',
	{
		Path = workspace:GetFullName()
	}
))

return component