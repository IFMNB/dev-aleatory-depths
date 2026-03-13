local src_object = require('./src_object')
local src = {};
src.Classes = setmetatable({},{__index=src_object.Classes});
src.Abstract = setmetatable({},{__index=src_object.Abstract});
src.Interface = setmetatable({}, {__index=src_object.Interface});

function src.Classes.HxNumber ()
	return require('..//object/__HxBase/___GHxPrimetive/_IHxPrimetive/HxNumber').HxNumber
end

function src.Classes.HxBoolean ()
	return require('..//object/__HxBase/___GHxPrimetive/_IHxPrimetive/HxBoolean').HxBoolean
end

function src.Classes.HxString ()
	return require('..//object/__HxBase/___GHxPrimetive/_IHxPrimetive/HxString').HxString
end

function src.Classes.HxEvent ()
	return require('..//object/__HxBase/HxEvent').HxEvent
end
function src.Classes.HxConnection ()
	return require('..//object/__HxBase/HxConnection').HxConnection
end

function src.Classes.HxMetalinkCreator ()
	return require('..//object/__HxBase/___GHxProperty/_IHxProperty/__HxAbstractMetalink/HxMetalinkCreator').HxMetalinkCreator
end

function src.Classes.HxSignal ()
	return require('..//object/__HxBase/___GHxProperty/_IHxProperty/HxSignal').HxSignal
end

function src.Classes.HxObjectManager ()
	return require('..//object/__HxBase/___GHxProperty/_IHxProperty/HxObjectManager').HxObjectManager
end

function src.Classes.HxActionEmitter ()
	return require('..//object/__HxBase/___GHxProperty/_IHxProperty/HxActionEmitter').HxActionEmitter
end
function src.Classes.HxNode ()
	return require('..//object/__HxBase/HxNode').HxNode
end


function src.Interface.IHxProperty ()
	return require('..//object/__HxBase/___GHxProperty/_IHxProperty')._IHxProperty
end

function src.Abstract.HxAbstractMetalink ()
	return require('../object/__HxBase/___GHxProperty/_IHxProperty/__HxAbstractMetalink').__HxAbstractMetalink
end

function src.Abstract.HxBase ()
	return require('..//object/__HxBase').__HxBase
end

function src.Interface.IHxPrimetive ()
	return require('..//object/__HxBase/___GHxPrimetive/_IHxPrimetive')._IHxPrimetive
end


return src