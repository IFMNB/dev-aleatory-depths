local main = require('../../');
local component = table.freeze(main.Core.Classes.SadComponentFabric().new(
    script.Name,
    {
        Value = 2
    }
    ))

return component