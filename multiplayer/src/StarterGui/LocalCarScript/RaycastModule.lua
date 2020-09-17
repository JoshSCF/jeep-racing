--local module = {}
--
--function module.new(startPosition, startDirection)
--	local maxDistance = startDirection.magnitude
--	local direction = startDirection.unit
--	local lastPosition = startPosition
--	local distance = 0
--	local ignore = {}
--	
--	local hit, position, normal
--	
--	repeat
--		local ray = Ray.new(lastPosition, direction * (maxDistance - distance))
--		hit, position, normal = game.Workspace:FindPartOnRayWithIgnoreList(ray, ignore, false, true)
--		if hit then
--			if not hit.CanCollide then
--				table.insert(ignore, hit)
--			end
--		end
--		distance = (startPosition - position).magnitude
--		lastPosition = position
--	until distance >= maxDistance - 0.1 or (hit and hit.CanCollide)
--	return hit, position, normal
--end
--
--return module

local module = {}

function module.new(startPosition, startDirection, Script, Car)
	local maxDistance = startDirection.magnitude
	local direction = startDirection.unit
	local lastPosition = startPosition
	local distance = 0
	local Count = 0
	local ignore = {}
	
	local hit, position, normal
	
	repeat
		local ray = Ray.new(lastPosition, direction * (maxDistance - distance))
		Count = Count + 1
		hit, position, normal = game.Workspace:FindPartOnRayWithIgnoreList(ray, ignore, false, true)
		if hit then
			if not hit.CanCollide then
				table.insert(ignore, hit)
			end
		end
		distance = (startPosition - position).magnitude
		lastPosition = position
		if Count == 16 then
			--game.ReplicatedStorage.ReloadJeep:FireServer(Car, Car.PrimaryPart.CFrame)
			--Car:SetPrimaryPartCFrame(CFrame.new(Car.PrimaryPart.Position + Vector3.new(0, 10, 0)))
			local Humanoid = Car.DriveSeat.Occupant
			Humanoid.JumpPower = 50
			Humanoid.Jump = true
			Humanoid.JumpPower = 0
			print("ISSUE HERE")
			--local LocalPlayer = game.Players:GetPlayerFromCharacter(Humanoid.Parent)
			--LocalPlayer:LoadCharacter()
			--wait(1)
			Car.DriveSeat:Sit(Humanoid)
			return "END"
		end
	until distance >= maxDistance - 0.1 or (hit and hit.CanCollide)
	return hit, position, normal
end

return module
