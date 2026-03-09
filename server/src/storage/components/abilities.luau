local main = require('../../');
local component = table.freeze(main.Core.Classes.SadComponentFabric().new(
	'Velocity'::'Velocity',
	{
		Value = 20
	}
	))

return component