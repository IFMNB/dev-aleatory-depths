local core = require('../interface/src_baseservice')
local src = setmetatable({}, {__index=core:Source()})
src.Core = core
src.ServiceMapping = require('../mapping')
src.ServiceLibs = require('@self/interface/src_libs'):Libs()

return src