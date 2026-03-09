local main = require('../../');
local component = table.freeze(main.Core.Classes.SadComponentFabric().new(
	'Health'::'Health',
	{
		Value = 20
	}
	))

return component