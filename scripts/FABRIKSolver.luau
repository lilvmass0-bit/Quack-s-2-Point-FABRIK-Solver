--[[
======================================================================
	Quack's 2 Point FABRIK Solver
    WOW free! yes free.
    
    this is a prototype so its kinda messy and shit
    didnt use connectparallel because its lightweight as fuck and 
    its not very scalable yet.
    
    just ask ai to make it scalable by searching for models or 
    instances with attributes or tag.

    Copyright (c) 2026 lilvmass0-bit
	Licensed under the MIT License (See root LICENSE file)
======================================================================
]]

local Kinematics = {}
Kinematics.__index = Kinematics

local CollectionService = game:GetService("CollectionService")

-- settings
local COLLIDER_TAG = "SmartCollider2" -- this the uhm tags for collision parts
local GRAVITY = Vector3.new(0, -25, 0) -- -25 gravity for -y axis boi
local DAMPING = 0.92 -- higher = faster
local COLLISION_RADIUS = 0.1 -- dont need to touch ngl
local COLLISION_STEPS = 2 -- dont need to touch too ngl

function Kinematics.new(arm_configs)
	local self = setmetatable({}, Kinematics)

	self.arm = {}
	self.velocities = {}
	self.last_target = Vector3.zero

	for i, config in ipairs(arm_configs) do
		local pos = Vector3.zero
		local length = 0

		if typeof(config) == "Vector3" then
			pos = config
		elseif typeof(config) == "number" then
			length = config
		else
			pos = config[1]
			length = config[2]
		end

		self.arm[i] = {pos, length}
		self.velocities[i] = Vector3.zero
	end

	return self
end

local function getDirection(vec)
	if vec.Magnitude > 0.001 then
		return vec.Unit
	end
	return Vector3.zero
end

local function Y_Vector(last_up, dir)
	local up = last_up - dir * last_up:Dot(dir)
	if up.Magnitude > 0.001 then
		return up.Unit
	end

	local axis = math.abs(Vector3.xAxis:Dot(dir)) > 0.95 and Vector3.zAxis or Vector3.xAxis
	up = axis - dir * axis:Dot(dir)
	return up.Unit
end

function Kinematics:Physics(dt)
	local arm = self.arm
	local velocities = self.velocities
	local damping = math.clamp(1 - (1 - DAMPING) * dt * 60, 0, 1)

	for i = 2, #arm - 1 do
		local vel = (velocities[i] + GRAVITY * dt) * damping
		local new_pos = arm[i][1] + vel * dt
		local prev_pos = arm[i - 1][1]
		local max_dist = arm[i - 1][2] * 1.5

		if (new_pos - prev_pos).Magnitude > max_dist then
			new_pos = prev_pos + getDirection(new_pos - prev_pos) * max_dist
		end

		arm[i][1] = new_pos
		velocities[i] = vel
	end
end

function Kinematics:Collisions()
	local arm = self.arm
	local parts = CollectionService:GetTagged(COLLIDER_TAG)

	for i = 2, #arm - 1 do
		local pos = arm[i][1]
		for _, part in ipairs(parts) do
			local closest = part:GetClosestPointOnSurface(pos)
			local offset = pos - closest
			local dist = offset.Magnitude

			if dist < COLLISION_RADIUS then
				local push = dist > 0.001 and offset.Unit or Vector3.yAxis
				arm[i][1] = closest + push * COLLISION_RADIUS
			end
		end
	end
end

function Kinematics:Solve(origin, target, config)
	self.last_target = target
	local arm = self.arm
	local count = #arm

	local max_reach = 0
	for i = 1, count - 1 do
		max_reach += arm[i][2]
	end

	if (target - origin).Magnitude > max_reach then
		local dir = getDirection(target - origin)
		arm[1][1] = origin
		for i = 2, count do
			arm[i][1] = arm[i - 1][1] + dir * arm[i - 1][2]
		end
		return
	end

	if config.enable_physics then
		self:Physics(config.delta_time)
	end

	local function pass()
		arm[count][1] = target
		for i = count - 1, 1, -1 do
			local dir = getDirection(arm[i][1] - arm[i + 1][1])
			arm[i][1] = arm[i + 1][1] + dir * arm[i][2]
		end

		arm[1][1] = origin
		for i = 2, count do
			local prev_pos = arm[i - 1][1]
			local dir = getDirection(arm[i][1] - prev_pos)
			arm[i][1] = prev_pos + dir * arm[i - 1][2]
		end
	end

	for _ = 1, config.max_iterations do
		pass()

		if (arm[count][1] - target).Magnitude < config.tolerance then
			break
		end
	end

	if config.enable_collisions then
		for _ = 1, COLLISION_STEPS do
			self:Collisions()
			pass()
		end
	end
end

function Kinematics:getBoneCframes()
	local arm = self.arm
	local result = {}
	local bone_count = #arm - 1

	local up = Vector3.yAxis
	for i = 1, bone_count do
		local pos = arm[i][1]
		local next_pos = (i == bone_count) and self.last_target or arm[i + 1][1]
		local dir = getDirection(next_pos - pos)

		if dir == Vector3.zero then
			dir = Vector3.zAxis
		end

		up = Y_Vector(up, dir)
		local right = up:Cross(dir)
		local back = dir:Cross(right)

		result[i] = CFrame.fromMatrix(pos, right, dir, back)
	end

	return result
end

return Kinematics