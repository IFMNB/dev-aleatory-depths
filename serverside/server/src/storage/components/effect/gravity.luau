local main = require('../../../');
local component = main.Core.Classes.SadComponentFabric().new(script.Name,
	{
		Direction = Vector3.new(0, 0, 0);
		Path = '';
	}
)


return component