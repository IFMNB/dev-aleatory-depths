	local main = require('../../');
local component = table.freeze(main.Core.Classes.SadComponentFabric().new(
	script.Name,
	{
		Path = workspace:GetFullName();
		IsTemporal = true;
	}
))

return component