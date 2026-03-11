local main = require('../../')
local SadEntityFabric = main.Core.Classes.SadEntityFabric()

local storage = script.Parent.Parent
local components = require('../../interface/src_components')
local fabrics = {}
fabrics.health = components.Health()
fabrics.position = components.Position();
fabrics.rotation = components.Rotation();
fabrics.velocity = components.Velocity();
fabrics.model = components.Model();
fabrics.form = components.Form();
fabrics.surface = components.Surface();
fabrics.height = components.Height();

local model_component = fabrics.model:DoCloneValue()
model_component.Path = storage.models.characters.Fortuna:GetFullName()
local form_component = fabrics.form:DoCloneValue()
form_component.Path = main.Mapping.Exception.TechicalException:Assert(storage.models.characters.Fortuna.PrimaryPart):GetFullName()

local Fortuna = SadEntityFabric.new({},{
    [fabrics.health.Name]=fabrics.health:DoCloneValue();
    [fabrics.position.Name] = fabrics.position:DoCloneValue();
	[fabrics.rotation.Name] = fabrics.rotation:DoCloneValue();
	[fabrics.velocity.Name] = fabrics.velocity:DoCloneValue();
	[fabrics.surface.Name] = fabrics.surface:DoCloneValue();
	[fabrics.model.Name] = model_component;
	[fabrics.height.Name] = fabrics.height:DoCloneValue();
	[fabrics.form.Name] = form_component;
}, fabrics)

return Fortuna 