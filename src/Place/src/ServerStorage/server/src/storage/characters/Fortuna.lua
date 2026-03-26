local main = require('../../')
local SadEntityFabric = main.Core.Classes.SadEntityFabric()

local storage = script.Parent.Parent
local components = require('../../interface/src_components')


local fabrics = {
	Model = components.property.Model();
	CustomPhysics = components.property.CustomPhysics();
	Collision = components.property.Collision();
	
	Health = components.parameter.Health();
	Rotation = components.parameter.Rotation();
	Position = components.parameter.Position();
	Velocity = components.parameter.Velocity();
	Height = components.parameter.Height();

	Mass = components.sensoric.Mass();	
	Floor = components.sensoric.Floor();
	Roof = components.sensoric.Roof();
	
	Gravity = components.effect.Gravity();
	Glide = components.effect.Glide();
	
	Spawn = components.action.Spawn();
	Collide = components.action.Collide();
}
local components = {}

for i,v in pairs(fabrics) do
	(v::any):DoInsertTo(components)
end
 
fabrics.Model:DoCatchFrom(components, function(Component) 
	Component.Source = main.Libs.CodeUtility.GetInstanceIdentity(storage.models.characters.Fortuna);
end)
fabrics.Height:DoCatchFrom(components, function(Component) 
	Component.Value = 4.325
end)
fabrics.Gravity:DoCatchFrom(components, function(Component) 
	Component.Value = Vector3.new(0,-workspace.Gravity)
end)
fabrics.Collide:DoCatchFrom(components, function(Component) 
	Component.ColliderGroup = 'Character'
end)

local Fortuna = SadEntityFabric.new({},components, fabrics)

-- способность на отбрасывание в радиусе N

return Fortuna 