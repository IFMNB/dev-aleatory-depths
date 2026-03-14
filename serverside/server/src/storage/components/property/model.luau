local main = require('../../../');
local component = table.freeze(main.Core.Classes.SadComponentFabric().new(
	script.Name,
	{
		Path = '';
		Source = workspace:GetFullName();
	}
))

return component