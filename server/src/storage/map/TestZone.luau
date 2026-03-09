local storage = script.Parent.Parent.models
local map : Model = storage.maps.test_map or storage.err_mdl

local class = require('../../interface/src_class')
local map = class.Classes.SadMap().new({
	Name = 'TestZone',
	SpawnPoints = {
		Vector3.new(417.712, -32.183, -555.961),
		Vector3.new(366.479, -115.549, -179.445),
		Vector3.new(476.176, 10.198, 241.603)
	},
	Map = map
})

return map