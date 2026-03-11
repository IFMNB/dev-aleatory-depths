local main = require('../../');
local component = main.Core.Classes.SadComponentFabric().new(script.Name,
	{
		Value = nil :: RaycastResult?;
	}
)


return component