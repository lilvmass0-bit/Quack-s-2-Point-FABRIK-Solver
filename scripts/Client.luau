local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KinematicsModule = require(ReplicatedStorage.FABRIKSolver)
local Kinematics

task.wait(1.5)

local segmentLengths = table.create(16, 0.25)
local Kinematics = KinematicsModule.new(segmentLengths)

local function getBoneChain(rootBone: Bone): { Bone }
	local chain = { rootBone }
	local current = rootBone
	while true do
		local nextBone
		for _, child in current:GetChildren() do
			if child:IsA("Bone") then
				nextBone = child
				break
			end
		end
		if not nextBone then break end
		chain[#chain + 1] = nextBone
		current = nextBone
	end
	return chain
end

local boneChain
local originalBoneLocals = {}

RunService.Heartbeat:Connect(function(dt)
	local shotgun = workspace:FindFirstChild("Rifle")
	if not shotgun then return end

	if not boneChain then
		local rootBone = shotgun:FindFirstChild("Bone", true)
		if not rootBone then return end

		boneChain = getBoneChain(rootBone)
		Kinematics = KinematicsModule.new(table.create(#boneChain, 0.25))

		for i, bone in ipairs(boneChain) do
			originalBoneLocals[i] = bone.CFrame
			bone.Transform = CFrame.identity
		end
	end

	for _, bone in ipairs(boneChain) do
		bone.Transform = CFrame.identity
	end

	local originPosition = shotgun.Origin.Position
	local targetPosition = shotgun.End.Position

	Kinematics:Solve(originPosition, targetPosition, {
		delta_time = dt,
		enable_physics = true,
		enable_collisions = true,
		max_iterations = 15,
		tolerance = 0.01,
	})

	local cframes = Kinematics:getBoneCframes()
	local desiredWorldCFrames = {}

	for i = 1, #cframes do
		desiredWorldCFrames[i] = cframes[i]
	end

	local lastBoneIndex = #boneChain
	local lastCFrameIndex = #cframes

	desiredWorldCFrames[lastBoneIndex] = CFrame.new(targetPosition) * cframes[lastCFrameIndex].Rotation

	for i, bone in ipairs(boneChain) do
		local parent = bone.Parent
		local parentWorld = parent:IsA("Bone") and desiredWorldCFrames[i - 1] or parent.CFrame
		local desiredLocal = parentWorld:ToObjectSpace(desiredWorldCFrames[i])

		bone.Transform = originalBoneLocals[i]:ToObjectSpace(desiredLocal)
	end
end)