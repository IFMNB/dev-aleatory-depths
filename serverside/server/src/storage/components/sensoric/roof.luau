local main = require('../../../');

type RayRes = {
	Instance: string;
	Position: Vector3,
	Distance: number,
	Material: Enum.Material,
	Normal: Vector3
}

local component = main.Core.Classes.SadComponentFabric().new(script.Name,
	{
		Value = nil :: RayRes?;
		Previous = nil :: RayRes?;
		
		IsLocalCoordinate = true;
	}
)


return component