local path = script.Parent.Parent.storage.config
local config = {}

config.Services = require(path.service)

return config