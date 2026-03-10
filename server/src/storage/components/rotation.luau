local main = require('../../');
local component = table.freeze(main.Core.Classes.SadComponentFabric().new(
	script.Name,
	{
		Up = Vector3.zero,
		Look = Vector3.zero,
		Right = Vector3.zero,
	}
))

return component