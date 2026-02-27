local main = require('./');

local Hx = main.Libs.Hexagon
local HxEvent = Hx.Classes.HxEvent()

local private = {};
local class = {}; setmetatable(class, class);
local interface = {};

--[[
	Создает референс на персонажа, хранящий экземпляры роблокса

	@class SadCharacterReference
	@side all
	@exception CodeException
	@return SadCharacterReference
]]
function private.new (Character: Model)
	local CodeException = main.Mapping.Exception.CodeException
	local player = game.Players:GetPlayerFromCharacter(Character)
	return main.new({
		Root = CodeException:Assert(Character.PrimaryPart);
		Humanoid = CodeException:Assert(Character:FindFirstChildOfClass('Humanoid'));
		Model = CodeException:Assert(Character);
		HumanoidRoot = CodeException:Assert(Character:FindFirstChild('HumanoidRootPart'));
		Player = player;
	}, class)
end

class.__index = main.SadObject.class;
class.ClassName = main.Mapping.Class.SadCharacterReference;
class.Source = script;

class.Root = nil :: BasePart?
class.Model = nil :: Model?
class.Humanoid = nil :: Humanoid?
class.Player = nil :: Player?

interface.class = class;
interface.new = private.new;

return main:expand({SadCharacterReference = interface})