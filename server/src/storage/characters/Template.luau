local main = require('../../')
local SadEntityFabric = main.Core.Classes.SadEntityFabric()

local storage = script.Parent.Parent
local components = storage.components
local health = require(components.health);
local position = require(components.position);
local rotation = require(components.rotation);
local velocity = require(components.velocity);
local model = require(components.model);


local model_component = model:GetValue()
model_component.Path = storage.models.characters.Fortuna:GetFullName()

local Fortuna = SadEntityFabric.new(5,{
	[health.Name]=health:GetValue();
	[position.Name] = position:GetValue();
	[rotation.Name] = rotation:GetValue();
	[velocity.Name] = velocity:GetValue();
	[model.Name] = model:GetValue();
})

if model:IsExistsIn(Fortuna) then
	print('lol')
end

return Fortuna 