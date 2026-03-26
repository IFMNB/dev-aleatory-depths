local private = {}
local public = {}

-- Moves that Cframe to the left or right by the given speed and alpha
function private.CFrameMoveSide (tar: CFrame, speed: number, Alpha: number)
	return tar:Lerp(CFrame.new(tar.RightVector.Unit*(speed*Alpha))*tar, Alpha)
end
-- Moves the Cframe forward or backward by the given speed and alpha
function private.CFrameMove (tar: CFrame, speed: number, Alpha: number)
	return tar:Lerp(CFrame.new(tar.LookVector.Unit * (speed*Alpha))*tar, Alpha)
end
-- Moves the Cframe up or down by the given speed and alpha
function private.CFrameMoveVertical (tar: CFrame, speed: number, Alpha: number)
	return tar:Lerp(CFrame.new(0, (speed * Alpha), 0) * tar, Alpha)
end

public.CFrameMoveSide = private.CFrameMoveSide
public.CFrameMove = private.CFrameMove
public.CFrameMoveVertical = private.CFrameMoveVertical

return public