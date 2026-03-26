local interface = setmetatable({}, {__index=require(game.ReplicatedStorage.core)})

interface.Services = require('@self/src_services')

return interface