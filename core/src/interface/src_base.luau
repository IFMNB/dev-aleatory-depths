local src_lib = require('./src_library')
local Hexagon = src_lib:Libs().Hexagon
local src = setmetatable({}, {__index=src_lib})

src.Classes = setmetatable({}, {__index=Hexagon.Classes})
src.Abstracts = setmetatable({}, {__index=Hexagon.Abstract})
src.Interfaces = setmetatable({}, {__index=Hexagon.Interface})

function src.Classes.SadObject ()
	return require('../object').SadObject
end

function src.Classes.SadInstanceGroup ()
	return require('../object/ISadGroup/SadInstanceGroup').SadInstanceGroup
end

function src.Classes.SadPhysicGroup ()
	return require('../object/ISadGroup/SadPhysicGroup').SadPhysicGroup
end





function src.Interfaces.ISadGroup ()
	return require('../object/ISadGroup')._ISadGroup
end



function src.Source ()
	return require('../')
end

function src:Mapping ()
	return require('../mapping')
end

return src