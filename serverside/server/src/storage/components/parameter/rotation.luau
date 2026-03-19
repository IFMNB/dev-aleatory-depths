local main = require('../../../');
local component = table.freeze(main.Core.Classes.SadComponentFabric().new(
	script.Name,
	{
		Value = CFrame.new();
		Previous = CFrame.new();
	}
))

return component