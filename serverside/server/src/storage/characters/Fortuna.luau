local main = require('../../')
local SadEntityFabric = main.Core.Classes.SadEntityFabric()

local storage = script.Parent.Parent
local components = require('../../interface/src_components')


local fabrics = {
	Health = components.parameter.Health();
	Rotation = components.parameter.Rotation();
	Position = components.parameter.Position();
	Velocity = components.parameter.Velocity();
	Floor = components.parameter.Floor();
	Roof = components.parameter.Roof();
	Height = components.parameter.Height();
	Spawn = components.action.Spawn();
	Model = components.property.Model();
	Fetch = components.action.Fetch();
}
local components = {}

for i,v in pairs(fabrics) do
	(v::any):DoInsertTo(components)
end
 
fabrics.Model:DoCatchFrom(components, function(Component: { Path: string, Source: string }) 
	Component.Source = storage.models.characters.Fortuna:GetFullName();
end)


local Fortuna = SadEntityFabric.new({},components, fabrics)

-- способность на отбрасывание в радиусе N

return Fortuna 