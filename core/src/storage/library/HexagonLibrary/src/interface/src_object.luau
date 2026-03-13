local src = {};
src.Classes = {};
src.Abstract = {};
src.Interface = {}

function src.Classes.HxObject ()
	return require('../object/').Objects
end

function src.Classes.HxLocalEnum ()
	return require('../object/INet/HxLocalEnum').LocalEnum
end

function src.Classes.HxRuntimeException ()
	return require('../object/INet/HxRuntimeException').HxRuntimeException
end

function src.Classes.HxSnapshot ()
	return require('../object/HxSnapshot').Snapshot
end

function src.Interface.INet ()
	return require('../object/INet')._INet
end


return src