local Libs = require('../interface/src_library')
local exception = Libs:Libs().Hexagon.Classes.HxRuntimeException()

return table.freeze({
	NetworkException = exception.new(
		'NetworkException'::'NetworkException',
		'The error occurs when there are irreversible network information transmission problems.'
		::'The error occurs when there are irreversible network information transmission problems.'
	),
	
	PermissionException = exception.new(
		'PermissionException'::'PermissionException',
		'The error occurs when the access level to the protected parameter is insufficient.'
		::'The error occurs when the access level to the protected parameter is insufficient.'
	),
	
	ServerException = exception.new(
		'ServerException' :: 'ServerException',
		'The error occurs when there is no or irreversible loss of information on the server. This can happen for various reasons.'
		::'The error occurs when there is no or irreversible loss of information on the server. This can happen for various reasons.'
	),
	
	ClientException = exception.new(
		'ClientException' :: 'ClientException',
		'The error occurs when interacting incorrectly with information from the server.'
		::'The error occurs when interacting incorrectly with information from the server.'
	),
	
	GameException = exception.new( -- Usually, it means a crooked developer's code.
		'GameException' :: 'GameException',
		"The error occurs when the game services are not working properly or the world is not being processed correctly."
		::"The error occurs when the game services are not working properly or the world is not being processed correctly."
	),
	
	MachineWaitException = exception.new(
		'MachineWaitException' :: 'MachineWaitException',
		'The error occurs when waiting too long for a response from the interviewee.'
		::'The error occurs when waiting too long for a response from the interviewee.'
	),
	
	TimeoutException = exception.new(
		'TimeoutException' :: 'TimeoutException',
		'The error occurs when the time limit for processing a certain operation is exceeded.'
		::'The error occurs when the time limit for processing a certain operation is exceeded.'
	),
	
	CodeException = exception.new(
		'CodeException' :: 'CodeException',
		'An error occurs when the code does not handle its tasks correctly or poses a threat to other work.'
		::'An error occurs when the code does not handle its tasks correctly or poses a threat to other work.'
	),
	
	SafetyException = exception.new(
		'SafetyException' :: 'SafetyException',
		'The program cannot be executed due to security issues with its code.'
		::'The program cannot be executed due to security issues with its code.'
	),
	
	TechicalException = exception.new(
		'TechnicalException' :: 'TechnicalException',
		'The error occurs when the code tries to execute in an environment for which it is not intended.'
		::'The error occurs when the code tries to execute in an environment for which it is not intended.'
	),
	
	RaceConditionException = exception.new(
		'RaceConditionException' :: 'RaceConditionException',
		'The error occurs when the code tries to perform an operation that can only be performed in the future tense due to a lack of data in the present.'
		::'The error occurs when the code tries to perform an operation that can only be performed in the future tense due to a lack of data in the present.'
	),
})