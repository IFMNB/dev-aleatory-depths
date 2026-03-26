local main = require('../../../');
local component = table.freeze(main.Core.Classes.SadComponentFabric().new(
	script.Name,
	{
		Elasticity = 2;
		Damper = 2;
		HeightDiff = 1.1;
	}
	))

return component