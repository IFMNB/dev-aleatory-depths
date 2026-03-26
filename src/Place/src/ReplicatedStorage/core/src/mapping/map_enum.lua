local Libs = require('../interface/src_library')
local Enum = Libs:Libs().Hexagon.Classes.HxLocalEnum()

local Sad_Enums = table.freeze({
	Null = Enum.new('Null'::'Null');
	
	MachineSide = table.freeze({
		Server = Enum.new('Server'::'Server');
		Client = Enum.new('Client'::'Client');
	});
	
	MathOperationType = table.freeze({
		Add = Enum.new('Add' :: 'Add');
		Sub = Enum.new('Sub' :: 'Sub');
		Mult = Enum.new('Mult' :: 'Mult');
		Div = Enum.new('Div' :: 'Div');
	});
	
	CharacterController = table.freeze({ -- 
		PlayerSide = Enum.new('PlayerSide'::'PlayerSide'); -- aka only player
		AiSide = Enum.new('AiSide'::'AiSide'); -- aka only ai
		ScenarioSide = Enum.new('ScenarioSide'::'ScenarioSide'); -- aka null aka controlled by every
	});
	
	
	-- Дополнительно
})

return Sad_Enums