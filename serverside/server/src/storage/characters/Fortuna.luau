local main = require('../../')
local SadEntityFabric = main.Core.Classes.SadEntityFabric()

local storage = script.Parent.Parent
local components = require('../../interface/src_components')


local fabrics = {
	Health = components.parameter.Health();
	Rotation = components.parameter.Rotation();
	Position = components.parameter.Position();
	Velocity = components.parameter.Velocity();
	Floor = components.sensoric.Floor();
	Roof = components.sensoric.Roof();
	Height = components.parameter.Height();
	Spawn = components.action.Spawn();
	
	
	Model = components.property.Model();
	
	CustomPhysics = components.property.CustomPhysics();
	Mass = components.sensoric.Mass();
	Gravity = components.effect.Gravity();
	Glide = components.effect.Glide();
}
local components = {}

for i,v in pairs(fabrics) do
	(v::any):DoInsertTo(components)
end
 
fabrics.Model:DoCatchFrom(components, function(Component: { Path: string, Source: string }) 
	Component.Source = main.Libs.CodeUtility.GetInstanceIdentity(storage.models.characters.Fortuna);
end)
fabrics.Height:DoCatchFrom(components, function(Component: { Value: number }) 
	Component.Value = 4.325
end)
fabrics.Gravity:DoCatchFrom(components, function(Component) 
	--Component.Value = Vector3.new(0,-workspace.Gravity)
end)

local Fortuna = SadEntityFabric.new({},components, fabrics)

-- способность на отбрасывание в радиусе N

return Fortuna 