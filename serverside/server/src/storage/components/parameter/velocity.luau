local main = require('../../../');
local component = table.freeze(main.Core.Classes.SadComponentFabric().new(
	script.Name,
	{
		Value = Vector3.zero;
		Previous = Vector3.zero;
	}
))

return component