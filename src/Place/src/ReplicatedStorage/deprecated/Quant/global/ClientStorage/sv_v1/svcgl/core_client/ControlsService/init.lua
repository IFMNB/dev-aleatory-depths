--[[ ControlService

	Used inside mappers to avoid roblox basic controls and give any player ability to set
	his own controls.

]]

local UIS = game:GetService('UserInputService')

local gl = require('../')
local hxc = gl.Library.Hexagon.Classes
local int = hxc.Instance()
local ev = hxc.Events()
local shadow = gl.Library.CodeBox.Tables.Shadow()

local private = {}

private.svc = {}
private.cl = {}

private.ev_name = 'ControlEvent' :: 'ControlEvent'
private.svc.OnControlChangedEvent,private.cl.OnControlChanged = ev.new(private.ev_name)

type F = (input: InputObject) -> ()

function private:OnInput (keycode: Enum.KeyCode, Start: F, End: F?)
	return UIS.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean) 
		if gameProcessedEvent then return end
		
		if End then
			local onEnd : RBXScriptConnection
			onEnd = UIS.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean) 
				if gameProcessedEvent then return end
				
				if input.KeyCode == keycode then
					(End::F)(input)
					onEnd:Disconnect()
				end
			end)
		end
		
		if input.KeyCode == keycode then
			Start(input)
		end
	end)
end

function private:OnUserInputType (inputType: Enum.UserInputType, Start: F, End: F?)
	return UIS.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean) 
		if End then
			local onEnd : RBXScriptConnection
			onEnd = UIS.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
				if gameProcessedEvent then return end
				
				if input.UserInputType == inputType then
					(End::F)(input)
					onEnd:Disconnect()
				end
			end)
		end

		if input.UserInputType == inputType then
			Start(input)
		end
	end)
end

function private:OnInputGL (Start: F, End: F?)
	return UIS.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent then return end
		local keycode = input.KeyCode
		
		if End then
			local onEnd : RBXScriptConnection
			onEnd = UIS.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean) 
				if gameProcessedEvent then return end
				if input.KeyCode == keycode then
					(End::F)(input)
					onEnd:Disconnect()
				end
			end)
		end

		Start(input)
	end)
end

private.reactiongroups = {} :: {[string]: typeof(private:NewReactionGroup(''))}
private.react_gr = {} -- public
private.mt_r_gr = {__index=private.react_gr}

-- Группа уничтожается, отключая все соединения, и удаляется из списка.
function private:Destroy ()
	local myname : string = (self::any).Group
	local shade : any = assert(shadow.Get(self), 'uh?')
	for i,v in shade.cons do
		v:Disconnect()
	end
	private.reactiongroups[myname] = nil
	private.cl.OnRemovedGroupEvent(myname)
	return
end

private.react_gr.Destroy = private.Destroy

private.ispressed = {} :: {[Enum.KeyCode]: boolean}
private.reactions = {}
private.reactions.NewGroup = private.NewReactionGroup
private.reactions.GetGroup = private.GetGroup
private.reactions.Map = {} :: {[Enum.KeyCode]: true? }
private.reactions.OnNewEvent, private.cl.OnNewEvent = ev.new(private.ev_name)
private.reactions.OnRemEvent, private.cl.OnRemEvent = ev.new(private.ev_name)
private.reactions.OnAddedGroupEvent, private.cl.OnAddedGroupEvent = ev.new(private.ev_name)
private.reactions.OnRemovedGroupEvent, private.cl.OnRemovedGroupEvent = ev.new(private.ev_name)
private.reactions.IsPressedEver = private.IsPressedEver
local reaction = int.New(private.reactions, 'ReactionObject' :: 'ReactionObject')

-- Проверяет, была ли нажата клавиша вообще когда-либо за сеанс.
function private:IsPressedEver (Key: Enum.KeyCode)
	return private.ispressed[Key]
end

-- Создает в адресном пространстве локальную группу реактивов.
function private:NewReactionGroup <t0> (Name: string | t0, ...: Enum.KeyCode)
	assert(not private.reactiongroups[Name], 'this name is already in use')
	local list = assert(#{...} > 0, 'you must specify at least one key') and {...}
	
	local out = int.New(setmetatable({
		Group = Name :: t0,
	}, private.mt_r_gr), 'ReactionGroup' :: 'ReactionGroup')
	
	local shade = shadow.New(out)
	shade.cons = {}
	
	for i,v in list do
		out[v]=false
		
		local con = private:OnInput(v, function(input: InputObject) 
			out[input.KeyCode]=true
		end, function(input: InputObject) 
			out[input.KeyCode]=false
		end)
		
		table.insert(shade.cons, con)
	end
	
	
	private.reactiongroups[Name] = out
	private.cl.OnAddedGroupEvent(Name)
	return out
end
-- Возвращает локальную группу реактивов с указанным именем.
function private:GetGroup <t0> (Name: string | t0)
	return assert(private.reactiongroups[Name], 'this name is not in use') :: typeof(private:NewReactionGroup(Name))
end


private:OnInputGL(function(input: InputObject)
	if input.KeyCode == Enum.KeyCode.Unknown then return end
	private.reactions.Map[input.KeyCode]=true
	private.ispressed[input.KeyCode]=true
	private.cl.OnNewEvent(input.KeyCode)
end,function(input: InputObject) 
	if input.KeyCode == Enum.KeyCode.Unknown then return end
	private.reactions.Map[input.KeyCode]=nil
	private.cl.OnRemEvent(input.KeyCode)
end)

-- Объект с автоматическим маппингом текущих нажатых клавиш.
function private:GetReact ()
	return reaction
end

local service = int.New(private.svc, 'ControlsService' :: 'ControlsService')

private.svc.GetReaction = private.GetReact
private.svc.OnInput = private.OnInputGL
private.svc.OnKeyInput = private.OnInput
private.svc.OnUserInput = private.OnUserInputType

return service