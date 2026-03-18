local main = require('../../../');
local component = main.Core.Classes.SadComponentFabric().new(script.Name,
	{
		Value = 1;
		Previous = 0;
		Delta = 0;
	}
)


return component