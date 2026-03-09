local main = require('../../');
local component = table.freeze(main.Core.Classes.SadComponentFabric().new('HealthComponent'::'HealthComponent', {Value = 100}))

return component