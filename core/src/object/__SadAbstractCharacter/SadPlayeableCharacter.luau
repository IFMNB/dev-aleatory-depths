local main = require('./');

local Hx = main.Libs.Hexagon
local HxEvent = Hx.Classes.HxEvent()

local private = {};
local class = {}; setmetatable(class, class);
local interface = {};

function private.new (Character: Model, Player: Player?)
	local Root,Character,Humanoid = main.__SadAbstractCharacter_protected.NewNode(Character)
	local e0, c0 = HxEvent.new();
	local e1, c1 = HxEvent.new();
	local e2, c2 = HxEvent.new();
	local e3, c3 = HxEvent.new();
	local e4, c4 = HxEvent.new();
	

	return main.new({
		Root = Root,
		Humanoid = Humanoid,
		Model = Character,
		Player = Player,
		
		SetTeam = main.Abstract.Wrap(c4.Call,class.SetTeam);
		SetController = main.Abstract.Wrap(c0.Call,class.SetController);
		SetControllerActive = main.Abstract.Wrap(c2.Call,class.SetControllerActive);
		SetDowned = main.Abstract.Wrap(c3.Call,class.SetDowned);
		
		OnControllerChangedEvent = e0,
		OnDownedEvent = e1,
		OnReviveEvent = e2,
		OnDiedEvent = e3,
		OnTeamChangeEvent = e4,
		
	}, class)
end

class.__index = main.__SadAbstractCharacter.class;
class.ClassName = main.Mapping.Class.SadPlayableCharacter
class.Source = script;

class.Player = nil :: Player?

interface.class = class;

return main:expand({__SadAbstractCharacter = interface})