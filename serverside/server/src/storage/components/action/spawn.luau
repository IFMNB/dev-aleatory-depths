local main = require('../../../');
local component = table.freeze(main.Core.Classes.SadComponentFabric().new(
	script.Name,
	{
		ToPath = main.Libs.CodeUtility.GetInstanceIdentity(workspace);
	}
	))

return component