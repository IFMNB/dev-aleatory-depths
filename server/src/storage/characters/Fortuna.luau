local main = require('../../')
local SadEntityFabric = main.Core.Classes.SadEntityFabric()

local storage = script.Parent.Parent
local components = storage.components
local fabrics = {}
fabrics.health = require(components.health);
fabrics.position = require(components.position);
fabrics.rotation = require(components.rotation);
fabrics.velocity = require(components.velocity);
fabrics.model = require(components.model);


local model_component = fabrics.model:DoCloneValue()
model_component.Path = storage.models.characters.Fortuna:GetFullName()

local Fortuna = SadEntityFabric.new({},{
    [fabrics.health.Name]=fabrics.health:DoCloneValue();
    [fabrics.position.Name] = fabrics.position:DoCloneValue();
	[fabrics.rotation.Name] = fabrics.rotation:DoCloneValue();
    [fabrics.velocity.Name] = fabrics.velocity:DoCloneValue();
	[fabrics.model.Name] = model_component;
}, fabrics)

return Fortuna 