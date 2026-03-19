local main = require('../../../');
local component = main.Core.Classes.SadComponentFabric().new(script.Name,
	{
		Value = Vector3.new(0, 0, 0); 
		Delta = Vector3.zero; 
		Path = '';
	}
)


return component