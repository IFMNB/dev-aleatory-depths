local private = {};
local interface = {};

private.LightSpeed = 299792458;

-- Вычисляет ускорение, необходимое для удержания целевой высоты. Гравитация не учитывается
function private.Glide (targetHeight: number, currentHeight: number, velocity: number?, elastic: number?, damper: number?)
	return (elastic or 1) * (targetHeight - currentHeight) - (damper or 1) * (velocity or 1)
end
-- Формула Glide, учитывающая гравитацию на тело. 
function private.GlideG (mass: number, targetHeight: number, currentHeight: number, velocity: number?, elastic: number?, damper: number?)
	return mass * ((elastic or 1) * (targetHeight - currentHeight) - (damper or 1) * (velocity or 1) + workspace.Gravity)
end

-- Дает противодействие ускорению свободного падения
function private.AntiGravity (Mass: number?)
	return (Mass or 1) * workspace.Gravity
end

-- Вычисляет энергию, полученную из массы, согласно теореме Эйнштейна
function private.EnergyFrom (Mass: number?)
	return (Mass or 1) * (private.LightSpeed ^ 2)
end

-- Вычисляет баллистику снаряда для попадания в цель в течении заданного времени
function private.BallisticTimed (Origin: Vector3, To: Vector3, Time: number?)
	local t = Time or 1
	local g = workspace.Gravity
	
	local dX = To.X - Origin.X
	local dY = To.Y - Origin.Y
	local dZ = To.Z - Origin.Z
	
	local vX = dX / t
	local vZ = dZ / t
	local vY = (dY + (g/2) * t^2) / t
	
	return Vector3.new(vX, vY, vZ)
end

-- Сопротивление воздуха
function private.Drag(velocity: Vector3, k: number)
	return -k * velocity.Magnitude * velocity
end
-- Ускорение к цели
function private.Seek(from: Vector3, to: Vector3, currentVelocity: Vector3, maxSpeed: number, force: number)
	local desired = (to - from).Unit * maxSpeed
	return (desired - currentVelocity) * force
end
-- Применяет вектор силы относительно deltaTime. Эквивалент VectorForce
function private.VectorForce(mass: number, deltaVelocity: Vector3, deltaTime: number?)
	return (mass * deltaVelocity) * (deltaTime or 1)
end
-- Упреждение снаряда 
function private.LeadShot(origin: Vector3, targetPos: Vector3, targetVel: Vector3, projectileSpeed: number)
	local dir = targetPos - origin
	local a = targetVel:Dot(targetVel) - projectileSpeed^2
	local b = 2 * dir:Dot(targetVel)
	local c = dir:Dot(dir)
	
	local r0 : Vector3?
	local disc = b*b - 4*a*c
	if disc < 0 then
		return r0
	end
	
	local t = (-b - math.sqrt(disc)) / (2*a)
	r0 = targetPos + targetVel * t
	return r0
end

function private.GravityBetween(Mass1: number, Mass2: number, pos1: Vector3, pos2: Vector3, G: number)
	local dir = pos2 - pos1
	local r2 = dir.Magnitude^2
	return dir.Unit * (G * Mass1 * Mass2 / r2)
end


function private.OrbitVelocity(center: Vector3, position: Vector3, mass: number, G: number)
	local r = (position - center).Magnitude
	return math.sqrt(G * mass / r)
end

-- Рикошет
function private.Reflect(velocity: Vector3, normal: Vector3, restitution: number)
	return velocity - (1 + restitution) * velocity:Dot(normal) * normal
end

interface.GlideFor = private.Glide;
interface.GlideForcedFor = private.GlideG;
interface.AntiGravityFor = private.AntiGravity;
interface.EnergyFrom = private.EnergyFrom;
interface.BallisticFor = private.BallisticTimed;
interface.Drag = private.Drag;
interface.Seek = private.Seek;
interface.Force = private.VectorForce;
interface.LeadShot = private.LeadShot;
interface.GravityBetween = private.GravityBetween;
interface.OrbitVelocity = private.OrbitVelocity;
interface.Reflect = private.Reflect;

table.freeze(private);
table.freeze(interface);

return interface