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

--[[
	Экземпляр-гибрид ECS структуры и OOP дизайна.
	А вообще это не ECS, а EC в NodeMap, который еще и самовкладываемый
]]
function src.Classes.SadWorld ()
	return require('../object/SadWorld').SadWorld
end

--[[
	Класс для встраивания в SadWorld компонентов.
	
	Хотя на деле встраивать компоненты в мир можно и без класса чистыми таблицами.
]]
function src.Classes.SadComponentFabric ()
	return require('../object/SadComponentFabric').SadComponentFabric
end

--[[
	Шаблон сущности.
]]
function src.Classes.SadEntityFabric ()
	return require('../object/SadEntityFabric').SadEntityFabric
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