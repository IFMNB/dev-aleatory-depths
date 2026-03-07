local interface = setmetatable({}, {__index=require('@self/src_base')})
interface.ClassMapping = require('./map')
-- Source utilities that used inside the library
function interface:Source () return require('./') end
-- Default network transporter that used for communicating between server and client. Allow to send and receive objects with their metadata.
function interface:Transcript () return require('./class_transcript') end

return interface