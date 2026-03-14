local main = require('../../');
local component = table.freeze(main.Core.Classes.SadComponentFabric().new(
    script.Name,
    {
        SubType = 'Entity';
    }
    ))

return component