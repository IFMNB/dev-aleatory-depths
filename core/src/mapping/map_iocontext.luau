local function context <T> (IO: any|EnumItem, Name: string)
	return table.freeze({
		DefaultIO = IO;
		Name = Name;
	})
end

local InputContextMap = table.freeze({
	AbilitySlot0 = context(Enum.KeyCode.One, 'AbilitySlot0');
	--AbilitySlot1 = 'AbilitySlot1' :: 'AbilitySlot1';
	--AbilitySlot2 = 'AbilitySlot2' :: 'AbilitySlot2';
	--AbilitySlot3 = 'AbilitySlot3' :: 'AbilitySlot3';
	--AbilitySlot4 = 'AbilitySlot4' :: 'AbilitySlot4';
	--AbilitySlot5 = 'AbilitySlot5' :: 'AbilitySlot5';;
	
	--MovementForward = 'MovementForward' :: 'MovementForward';;
	--MovementBackward = 'MovementBackward' :: 'MovementBackward';;;
	--MovementLeft = 'MovementLeft' :: 'MovementLeft';;
	--MovementRight = 'MovementRight' :: 'MovementRight';;
	--MovementJump = 'MovementJump' :: 'MovementJump';;;
	--MovementShift = 'MovementShift' :: 'MovementShift';;;
	
	--RadialMessage
})

return InputContextMap