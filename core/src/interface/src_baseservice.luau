local src_network = require('./src_base')
local src = setmetatable({}, {__index=src_network})

src.Classes = setmetatable({}, {__index=src_network.Classes});
src.Abstracts = setmetatable({}, {__index=src_network.Abstracts});
src.Interfaces = setmetatable({}, {__index=src_network.Interfaces});

function src.Classes.SadGameService ()
	return require('../object/__SadAbstractService/SadGameService').SadGameService
end

function src.Classes.SadGuiService ()
	return require('../object/__SadAbstractService/SadGuiService').SadGuiService
end

function src.Classes.SadDataService ()
	return require('../object/__SadAbstractService/SadDataService').SadDataService
end

function src.Classes.SadCoreService ()
	return require('../object/__SadAbstractService/SadCoreService').SadCoreService
end

function src.Classes.SadSystemService ()
	return require('../object/__SadAbstractService/SadSystemService').SadSystemService
end

function src.Classes.SadNetService ()
	return require('../object/__SadAbstractService/SadNetService').SadNetService
end



function src.Interfaces.ISadService ()
	return require('../object/__SadAbstractService').__SadAbstractService
end


return src