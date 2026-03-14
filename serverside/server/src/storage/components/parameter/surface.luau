local main = require('../../../');
local component = main.Core.Classes.SadComponentFabric().new(script.Name,
	{
		Value = nil :: {
			Instance: string;
			Position: Vector3,
			Distance: number,
			Material: Enum.Material,
			Normal: Vector3
		}?;
	}
)


return component