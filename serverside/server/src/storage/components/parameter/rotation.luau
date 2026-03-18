local main = require('../../../');
local component = table.freeze(main.Core.Classes.SadComponentFabric().new(
	script.Name,
	{
		Up = Vector3.zero,
		Look = Vector3.zero,
		Right = Vector3.zero,
		
		DeltaUp = Vector3.zero,
		DeltaLook = Vector3.zero,
		DeltaRight = Vector3.zero,
	}
))

return component