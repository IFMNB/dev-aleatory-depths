local main = require('../../../');
local component = table.freeze(main.Core.Classes.SadComponentFabric().new(
    script.Name,
    {
		Value = 2;
		Previous = 0;
		Delta = 0;
    }
    ))

return component