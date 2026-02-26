local src_b=require('./src_base')
local root = {}
root.Classes = setmetatable({},{__index=src_b.Classes})
root.Abstract = setmetatable({},{__index=src_b.Abstract})
root.Interface = setmetatable({}, {__index=src_b.Interface});

function root.Classes.EcsEntity ()
	return require('..//object/__EcsBase/EcsEntity').EcsEntity
end

function root.Classes.EcsComponent ()
	return require('..//object/__EcsBase/EcsComponent').EcsComponent
end

function root.Classes.EcsSystem ()
	return require('..//object/__EcsBase/__EcsBaseSystem/EcsSystem').EcsSystem
end

function root.Classes.EcsSystemIO ()
	return require('..//object/__EcsBase/__EcsBaseSystem/EcsSystemIO').EcsSystemIO
end

function root.Classes.EcsWorld ()
	return require('..//object/__EcsBase/EcsWorld').EcsWorld
end

function root.Abstract.EcsAbstractECS ()
	return require('..//object/__EcsBase').__EcsBase
end

function root.Abstract.EcsAbstractSystem ()
	return require('..//object/__EcsBase/__EcsBaseSystem').__EcsBaseSystem
end

return root