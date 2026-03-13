local interface = setmetatable({}, {__index=require('@self/src_base')})
interface.ClassMapping = require('./map')
-- Source utilities that used inside the library
function interface:Source () return require('./') end

return interface