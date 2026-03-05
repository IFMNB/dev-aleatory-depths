local Libs = require('../interface/src_library')
local Enum = Libs:Libs().Hexagon.Classes.HxLocalEnum()

local Sad_Enums = table.freeze({
	Null = Enum.new('Null'::'Null');
	Client = Enum.new('Client'::'Client');
	Server = Enum.new('Server'::'Server');
	
	UseDefined = Enum.new('UseDefined'::'UseDefined');
	UseDefault = Enum.new('UseDefault'::'UseDefault');
	
	NetworkTrasportationType = table.freeze({
--		Direct = Enum.new('Direct' :: 'Direct');
		Buffered = Enum.new('Buffered'::'Buffered');
	});
	
	MathOperationType = table.freeze({
		Add = Enum.new('Add' :: 'Add');
		Sub = Enum.new('Sub' :: 'Sub');
		Mult = Enum.new('Mult' :: 'Mult');
		Div = Enum.new('Div' :: 'Div');
	});
	
	Replicate = Enum.new('Replicate'::'Replicate'),
	Unreplicate = Enum.new('Unreplicate'::'Unreplicate'),
	
	AllowEvery = Enum.new('AllowEvery'::'AllowEvery'),
	AllowEnemy = Enum.new('AllowEnemy'::'AllowEnemy'),
	AllowChanges = Enum.new('AllowChanges'::'AllowChanges'),
	
	DenyEvery = Enum.new('DenyEvery'::'DenyEvery'),
	DenyChanges = Enum.new('DenyChanges'::'DenyChanges'),
	
	ProcessEffectType = table.freeze({
		TargetChanges = Enum.new('DuratedChanges'::'DuratedChanges');
		ChangeTarget = Enum.new('ChangeTarget'::'ChangeTarget');
	});
	
	AbilityType = table.freeze({
		Ranged = Enum.new('Ranged'::'Ranged');
		Melee = Enum.new('Melee'::'Melee');
		Heal = Enum.new('Heal'::'Heal');
		Movement = Enum.new('Movement'::'Movement');
		Ignore = Enum.new('Ignore'::'Ranged');
	});
	
	ContextEventBehavior = table.freeze({
--		Deffered = Enum.new('Global'::'Global');
		Immediate = Enum.new('Local'::'Local');
	});
	
	CharacterController = table.freeze({ -- 
		PlayerSide = Enum.new('PlayerSide'::'PlayerSide'); -- aka only player
		AiSide = Enum.new('AiSide'::'AiSide'); -- aka only ai
		ScenarioSide = Enum.new('ScenarioSide'::'ScenarioSide'); -- aka null aka controlled by every
	});
	
	
	-- Дополнительно
})

return Sad_Enums