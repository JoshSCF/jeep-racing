repeat wait() until game.Players.LocalPlayer
local player = game.Players.LocalPlayer
repeat wait() until player.Character
local character = player.Character
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local car
local Raycast = require(script.RaycastModule)
local UserInputService = game:GetService("UserInputService")
local Stepped = game:GetService("RunService").Stepped
local Repl = game.ReplicatedStorage

local RP = script.Parent.HUD.RightPrevention
local Coins = RP.Coins.CoinCount
local Sounds = script.Parent.HUD.Sounds
local RCount = script.Parent.RaceCountdown
local HasUpgrade = Coins.HasCoinUpgrade.Value

local MobileControls = script.Parent.HUD.MobileControls
local AButton = MobileControls.Buttons.RightSide.ForwardButton
local BButton = MobileControls.Buttons.LeftSide.ReverseButton
local jAButton = MobileControls.JoystickButtons.RightSide.ForwardButton
local jBButton = MobileControls.JoystickButtons.LeftSide.ReverseButton
local Dragger = MobileControls.Joystick.Dragger
local DragBackdrop = MobileControls.Joystick.DragBackdrop

local CanChange = true
local ForwardDown = false
local ReverseDown = false
local RunningBoost = false
local ToEnd = false
local IsBoosting = false
local CanBoost = true
local FOV = false
local InCannon = false
local HitWall = false
local IsCounting = false
local JustSet = false
local IncreasingAfterWall = false
local IsRacing = false

local BoostValue = 0
local CurrentBoost = 0
local CoinAmount = 0
local StartBoost = 0

local movement = Vector2.new()
local gamepadDeadzone = 0.14

local LastMovement = tick()

local SpeedChange = {
	W = false,
	S = false
}

local Bounce = 100
local Height = 3
local Speed = 80
local TurnSpeed = 2
local Suspension = 4
local Acceleration = 0.01

local Force = 0
local Damping = 0
local Mass = 0
local DefaultMass = 0
local FlyCount = 0

local Boost
local bodyVelocity
local bodyAngularVelocity
local LastPosition

local function Smoke(Bool)
	if not car then return end
	car.FrontRightWheel.Smoke.Enabled = Bool
	car.BackRightWheel.Smoke.Enabled = Bool
	car.BackLeftWheel.Smoke.Enabled = Bool
	car.FrontLeftWheel.Smoke.Enabled = Bool
end

local ActiveProcesses = {}
local pref, aref
local Processes = {
	A = function(Dir)
		if SpeedChange[Dir] and movement.Y < 1 and (not IsBoosting) and not HitWall then
			movement = Vector2.new(movement.X, movement.Y * 1.01 + Acceleration)
			return true
		end
		HitWall = false
	end,
	B = function(Dir)
		if SpeedChange[Dir] and movement.Y > -0.5 and (not IsBoosting) and not HitWall then
			if movement.Y >= 0 then
				Smoke(true)
				movement = Vector2.new(movement.X, movement.Y / 1.03 - Acceleration)
			else
				Smoke(false)
				movement = Vector2.new(movement.X, movement.Y / 1.01 - Acceleration)
			end
			return true
		end
		HitWall = false
		Smoke(false)
	end,
	C = function()
		if Speed > 80 and CanBoost then
			Speed = Speed / 1.01 - Acceleration
			return true
		end
		if CanBoost then
			IsBoosting = false
			if ForwardDown then
				aref("W", true)
			else
				LastDir = nil
				ActiveProcesses.D = {pref.D, {}}
			end
		end
	end,
	D = function()
		if (not LastDir) and movement.Y > 0 and CanBoost and not ReverseDown then
			movement = Vector2.new(movement.X, movement.Y / 1.01 - (Acceleration / 2))
			return true
		end
		if ReverseDown then
			SpeedChange.S = false
			aref("S")
		elseif movement.Y <= 0 and not LastDir then
			movement = Vector2.new(movement.X, 0)
		end
	end,
	E = function(Count, Cannon, Dist)
		if Count <= 1 then
			car:SetPrimaryPartCFrame(
				Cannon.Start.CFrame:lerp(Cannon.End.CFrame, Count)
			)
			Count = Count + 2 / Dist
			return true
		end
		InCannon = false
		car.PrimaryPart.Anchored = false
	end,
	F = function()
		if not LastDir and movement.Y > 0 and CanBoost then
			movement = Vector2.new(movement.X, movement.Y / 1.01 - (Acceleration / 2))
			return true
		end
		if movement.Y <= 0 and not LastDir then
			movement = Vector2.new(movement.X, 0)
		end
	end,
	G = function()
		if movement.Y < 0 and not LastDir then
			movement = Vector2.new(movement.X, movement.Y / 1.01 + (Acceleration / 2))
			return true
		end
		if not IsBoosting then
			movement = Vector2.new(movement.X, 0)
		end
	end,
	H = function()
		if not LastDir and movement.Y > 0 and CanBoost then
			movement = Vector2.new(movement.X, movement.Y / 1.01 - (Acceleration / 2))
			return true
		end
		if movement.Y <= 0 and not LastDir then
			movement = Vector2.new(movement.X, 0)
		end
	end,
	A2 = function(Dir)
		if SpeedChange[Dir] and movement.Y < 1 and not IsBoosting and IncreasingAfterWall then
			if IsCounting then
				StartBoost = StartBoost + 1
			elseif StartBoost > 0 then
				if not car.PrimaryPart.Anchored then
					if StartBoost > 40 then
						print(StartBoost)
						if StartBoost > 115 then
							warn("spinning out!!")
						else
							ForwardDown = true
							spawn(function()
								wait(1)
								IsRacing = true
							end)
							Boost(StartBoost < 80 and 80 or StartBoost + 35, 0.7)
						end
					end
					StartBoost = 0
				end
			else
				movement = Vector2.new(movement.X, movement.Y * 1.01 + Acceleration)
				spawn(function()
					wait(1)
					IsRacing = true
				end)
				return false
			end
			return true
		end
		HitWall = false
		return false
	end,
	B2 = function()
		if not LastDir and movement.Y > 0 and CanBoost then
			movement = Vector2.new(movement.X, movement.Y / 1.01 - (Acceleration / 2))
			return true
		end
		if movement.Y <= 0 and not LastDir then
			movement = Vector2.new(movement.X, 0)
		end
		return false
	end,
	C2 = function()
		if movement.Y < 0 and not LastDir then
			movement = Vector2.new(movement.X, movement.Y / 1.01 + (Acceleration / 2))
			return true
		end
		if not IsBoosting then
			movement = Vector2.new(movement.X, 0)
		end
		return false
	end,
	E2 = function()
		if not JustSet and ForwardDown and movement.Y < 1 and not IsBoosting then
			movement = Vector2.new(movement.X, movement.Y * 1.01 + Acceleration)
			return true
		end
		return false
	end
}
pref = Processes

local function AlterSpeed(Dir, AfterBoost)
	LastDir = Dir
	--movement = Vector2.new(movement.X, Dir == "W" and 1 or -1)
	if not SpeedChange[Dir] then
		local Opposite = Dir == "W" and "S" or "W"
		SpeedChange[Dir] = true
		if Dir == "W" then
			movement = Vector2.new(movement.X, AfterBoost and movement.Y or (movement.Y < 0 and 0 or (movement.Y + 0.1 > 1 and 1 or movement.Y + 0.1)))
			if IsCounting then
				ActiveProcesses.A2 = {Processes.A2, {Dir}}
			else
				ActiveProcesses.A = {Processes.A, {Dir}}
			end
		elseif Dir == "S" then
			--movement = Vector2.new(movement.X, movement.Y >= 0 and 0 or movement.Y)
			ActiveProcesses.B = {Processes.B, {Dir}}
		end
		HitWall = false
	end
end
aref = AlterSpeed

function Boost(NewSpeed, WaitTime)
	SpeedChange.W = false
	SpeedChange.S = false
	local CurrentBoost = BoostValue + 1
	IsBoosting = true
	movement = Vector2.new(movement.X, 1)
	BoostValue = CurrentBoost
	car.Exhaust1.Fire.Enabled = true
	car.Exhaust2.Fire.Enabled = true
	Speed = NewSpeed or 170
	CanChange = false
	if CanBoost then
		CanBoost = false
		if math.floor(workspace.CurrentCamera.FieldOfView + 0.5) == 80 and not FOV then
			FOV = true
			spawn(function()
				for i = 80, 90 do
					workspace.CurrentCamera.FieldOfView = i
					wait()
				end
			end)
		end
	end
	wait(WaitTime or 0.85)
	if CurrentBoost ~= BoostValue then return end
	spawn(function()
		if math.floor(workspace.CurrentCamera.FieldOfView + 0.5) == 90 and FOV and CurrentBoost == BoostValue then
			FOV = false
			for i = 90, 80, -1 do
				workspace.CurrentCamera.FieldOfView = i
				wait()
			end
		end
		car.Exhaust1.Fire.Enabled = false
		car.Exhaust2.Fire.Enabled = false
		workspace.CurrentCamera.FieldOfView = 80
	end)
	CanChange = true
	CanBoost = true
	ActiveProcesses.C = {Processes.C, {}}
end

local function StartCannon(Cannon)
	if InCannon and Cannon then
--		local Info = TweenInfo.new(
--			(Cannon.Start.Position - Cannon.End.Position).Magnitude
--		)
--		local Tween = TweenService:Create(car.PrimaryPart, Info, {Position = Cannon.End.Position})
--		Tween:Play()
		Repl.InCannon:FireServer()
		local Count = 0
		local Dist = (Cannon.Start.Position - Cannon.End.Position).Magnitude
		ActiveProcesses.E = {Processes.E, {}}
	end
end

local function Forward()
	ForwardDown = true
	AlterSpeed("W")
	--movement = Vector2.new(movement.X, 1)
end

local function Reverse()
	ReverseDown = true
	if CanChange then
		AlterSpeed("S")
	end
	--movement = Vector2.new(movement.X, -1)
end

local function ForwardEnd()
	SpeedChange.W = false
	ForwardDown = false
	if movement.Y >= 0 and not IsBoosting then
		LastDir = nil
		ActiveProcesses.B2 = {Processes.B2, {}}
		--movement = Vector2.new(movement.X, 0)
	end
end

local function ReverseEnd()
	SpeedChange.S = false
	ReverseDown = false
	if movement.Y < 0 then
		LastDir = nil
		ActiveProcesses.C2 = {Processes.C2, {}}
		
	else
		LastDir = nil
		ActiveProcesses.B2 = {Processes.B2, {}}
	end
end

local function ChangeMovement(inputObject)
	if inputObject.KeyCode ~= Enum.KeyCode.Unknown then
		LastMovement = tick()
		if inputObject.KeyCode == Enum.KeyCode.W or inputObject.KeyCode == Enum.KeyCode.Up or inputObject.KeyCode == Enum.KeyCode.ButtonR2 then
			Forward()
		elseif inputObject.KeyCode == Enum.KeyCode.A or inputObject.KeyCode == Enum.KeyCode.Left then
			movement = Vector2.new(-1, movement.Y)
		elseif inputObject.KeyCode == Enum.KeyCode.S or inputObject.KeyCode == Enum.KeyCode.Down or inputObject.KeyCode == Enum.KeyCode.ButtonL2 then
			Reverse()
		elseif inputObject.KeyCode == Enum.KeyCode.D or inputObject.KeyCode == Enum.KeyCode.Right then
			movement = Vector2.new(1, movement.Y)
		end
		if inputObject.KeyCode == Enum.KeyCode.Thumbstick1 then
			if inputObject.Position.magnitude >= gamepadDeadzone then
				movement = Vector2.new(inputObject.Position.X, movement.Y)
			else
				movement = Vector2.new(0, movement.Y)
			end
		end
	end
end

--car.Configurations.Speed:GetPropertyChangedSignal("Value"):Connect(function()
--	if car.Configurations.Speed.Value > 80 then
--		movement = Vector2.new(movement.X, 1)
--		CanChange = false
--		if math.floor(workspace.CurrentCamera.FieldOfView + 0.5) == 80 and not FOV then
--			FOV = true
--			for i = 80, 90 do
--				workspace.CurrentCamera.FieldOfView = i
--				wait()
--			end
--		end
--	elseif car.Configurations.Speed.Value == 80 then
--		if not SpeedChange.W then --ForwardDown then
--			movement = Vector2.new(movement.X, 0)
--		end
--		CanChange = true
--		if math.floor(workspace.CurrentCamera.FieldOfView + 0.5) == 90 and FOV then
--			FOV = false
--			for i = 90, 80, -1 do
--				workspace.CurrentCamera.FieldOfView = i
--				wait()
--			end
--		end
--		workspace.CurrentCamera.FieldOfView = 80
--	end
--end)

Dragger:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
	LastMovement = tick()
	movement = Vector2.new(
		((Dragger.AbsolutePosition.X + Dragger.AbsoluteSize.X / 2) - (DragBackdrop.AbsolutePosition.X + DragBackdrop.AbsoluteSize.X / 2)) / 45,
		movement.Y
	)
end)

AButton.InputBegan:Connect(Forward)
jAButton.InputBegan:Connect(Forward)
BButton.InputBegan:Connect(Reverse)
jBButton.InputBegan:Connect(Reverse)
AButton.InputEnded:Connect(ForwardEnd)
jAButton.InputEnded:Connect(ForwardEnd)
BButton.InputEnded:Connect(ReverseEnd) 
jBButton.InputEnded:Connect(ReverseEnd) 

UserInputService.InputBegan:Connect(ChangeMovement)
UserInputService.InputChanged:Connect(ChangeMovement)

UserInputService.InputEnded:Connect(function(inputObject)
	if inputObject.KeyCode ~= Enum.KeyCode.Unknown then
		LastMovement = tick()
		if inputObject.KeyCode == Enum.KeyCode.W or inputObject.KeyCode == Enum.KeyCode.Up or inputObject.KeyCode == Enum.KeyCode.ButtonR2 then
			ForwardEnd()
		elseif inputObject.KeyCode == Enum.KeyCode.A or inputObject.KeyCode == Enum.KeyCode.Left then
			if movement.X == -1 then
				movement = Vector2.new(0, movement.Y)
			end
		elseif inputObject.KeyCode == Enum.KeyCode.S or inputObject.KeyCode == Enum.KeyCode.Down or inputObject.KeyCode == Enum.KeyCode.ButtonL2 then
			ReverseEnd()
		elseif inputObject.KeyCode == Enum.KeyCode.D or inputObject.KeyCode == Enum.KeyCode.Right then
			if movement.X == 1 then
				movement = Vector2.new(0, movement.Y)
			end
		end
	end
end)

game.ReplicatedStorage.Respawning.OnClientEvent:Connect(function()
	print"RESPAWNING"
	car.PrimaryPart.Anchored = true
	Mass = DefaultMass
	Force = Mass * Suspension
	Damping = Force / Bounce
	bodyVelocity.velocity = Vector3.new(0, 0, 0)
	bodyVelocity.maxForce = Vector3.new(0, 0, 0)
	bodyAngularVelocity.angularvelocity = Vector3.new(0, 0, 0)
	bodyAngularVelocity.maxTorque = Vector3.new(0, 0, 0)
	wait(3)
	car.PrimaryPart.Anchored = false
end)

script.Parent.RaceCountdown.Event:Connect(function(Arg)
	if not car then return end
	IsCounting = Arg
	if Arg then
		StartBoost = 0
	elseif (not car.PrimaryPart.Anchored) and (StartBoost < 40 or not ForwardDown) then
		StartBoost = 0
		movement = Vector2.new(movement.X, 0)
	end
end)

UserInputService.DeviceRotationChanged:Connect(function(_, Rotation)
	if MobileControls.Buttons.Visible then
		local X, Y, Z = Rotation:ToOrientation()
		movement = Vector2.new(-(math.deg(Y) / 70), movement.Y)
	end
end)

script.Car.Changed:Connect(function()
car = script.Car.Value

for i, v in pairs(car:GetChildren()) do
	pcall(function()
		v.Touched:Connect(function(Part)
			
			if v.Name:find("Wheel") then
				if Part.Name == "BoostPanel" or Part.Name == "Assist" then
--					if not RunningBoost then
--						RunningBoost = true
--						spawn(function()
--							car.Exhaust1.Fire.Enabled = true
--							car.Exhaust2.Fire.Enabled = true
--							car.Configurations.Speed.Value = 180
--							if Part.Name == "Assist" then
--								car.Configurations.TurnSpeed.Value = 0
--							else
--							car.Configurations.TurnSpeed.Value = 0.9
--							end
--							wait(0.85)
--							car.Exhaust1.Fire.Enabled = false
--							car.Exhaust2.Fire.Enabled = false
--							car.Configurations.Speed.Value = 80
--							car.Configurations.TurnSpeed.Value = 1.9
--						end)
--						wait(0.5)
--						RunningBoost = false
--					end
					Boost()
				end
			end
			
			if Part.Name == "Start" then
				if Part.Parent.Name == "Cannon" and not InCannon then
					car.PrimaryPart.Anchored = true
					car:SetPrimaryPartCFrame(CFrame.new(car.PrimaryPart.Position, Part.Parent.End.Position))
					InCannon = true
					StartCannon(Part.Parent)
				end
			end
			
			if Part.Name == "End" then
				if Part.Parent.Name == "Cannon" and InCannon then
					print"ok"
					InCannon = false
					car.PrimaryPart.Anchored = false 
				end
			end
			
			if Part.Name == "Coin" then
				if Part:FindFirstChild("Front").Transparency == 0 then
					Sounds.Coin:Play()
					if CoinAmount < 10 then
						CoinAmount = CoinAmount + 1
						Coins.Text = CoinAmount
						if CoinAmount == 9 then
							Coins.TextColor3 = Color3.fromRGB(252, 30, 0)
						end
					elseif CoinAmount < 20 and HasUpgrade then
						CoinAmount = CoinAmount + 1
						Coins.Text = CoinAmount
						if CoinAmount == 19 then
							Coins.TextColor3 = Color3.fromRGB(252, 30, 0)
						end
					end
					
					for i, v in pairs(Part:GetChildren()) do
						if v:IsA("Texture") then
							v.Transparency = 1
						end
					end
					wait(7.5)
					for i, v in pairs(Part:GetChildren()) do
						if v:IsA("Texture") then
							v.Transparency = 0
						end
					end
				end
			
			elseif Part.Name == "ItemBox" then
				if Part:FindFirstChild("Texture").Transparency ~= 1 then
					for i, v in pairs(Part:GetChildren()) do
						if v.Name == "Texture" then
							v.Transparency = 1
						end
					end
				end
			end
			
		end)
	end)
end

Force = 0
Damping = 0
Mass = 0
DefaultMass = 0

for i, v in pairs(car:GetDescendants()) do
	if v:IsA("BasePart") then--and not v.Name:find("Sphere") and not
		DefaultMass = DefaultMass + (v:GetMass() * 196.2)
	end
end

Mass = DefaultMass
Force = Mass * Suspension
Damping = Force / Bounce

bodyVelocity = Instance.new("BodyVelocity", car.Chassis)
bodyVelocity.velocity = Vector3.new(0, 0, 0)
bodyVelocity.maxForce = Vector3.new(0, 0, 0)

bodyAngularVelocity = Instance.new("BodyAngularVelocity", car.Chassis)
bodyAngularVelocity.angularvelocity = Vector3.new(0, 0, 0)
bodyAngularVelocity.maxTorque = Vector3.new(0, 0, 0)

local rotation = 0

local function UpdateThruster(thruster)
	--Make sure we have a bodythrust to move the wheel
	local bodyThrust = thruster:FindFirstChild("BodyThrust")
	if not bodyThrust then
		bodyThrust = Instance.new("BodyThrust", thruster)
	end
	--Do some raycasting to get the height of the wheel
	local hit, position = Raycast.new(thruster.Position, thruster.CFrame:vectorToWorldSpace(Vector3.new(0, -1, 0)) * Height, script, car)
	if hit == "END" then
		ToEnd = true
		print("ending lol")
		return "END"
	end
	if hit or position then
	local thrusterHeight
	if position then
		thrusterHeight = (position - thruster.Position).magnitude
	end
	if hit and hit.CanCollide and position then
		--If we're on the ground, apply some Forces to push the wheel up
		local NewForce = Vector3.new(0, ((Height - thrusterHeight)^2) * (Force / Height ^ 2), 0)
		bodyThrust.Force = NewForce
		local thrusterDamping = thruster.CFrame:toObjectSpace(CFrame.new(thruster.Velocity + thruster.Position)).p * Damping
		bodyThrust.Force = NewForce - Vector3.new(0, thrusterDamping.Y, 0)
	else
		bodyThrust.Force = Vector3.new(0, 0, 0)
	end
	
	--Wheels
	local wheelWeld = thruster:FindFirstChild("WheelWeld")
	if wheelWeld and thrusterHeight then
		wheelWeld.C0 = CFrame.new(0, -math.min(thrusterHeight, Height * 0.8) + (wheelWeld.Part1.Size.Y / 2), 0)
		-- Wheel turning
		local cCFrame = car.Chassis.CFrame
		local offset = cCFrame:inverse() * thruster.CFrame
		local speed = cCFrame:vectorToObjectSpace(car.Chassis.Velocity)
		if offset.Z < 0 then
			local direction = 1
			if speed.Z > 0 then
				direction = -1
			end
			wheelWeld.C0 = wheelWeld.C0 * CFrame.Angles(0, (car.Chassis.RotVelocity.Y / 2) * direction, 0)
		end
		wheelWeld.C0 = wheelWeld.C0 * CFrame.Angles(rotation, 0, 0)
	end
	end
end

--A simple function to check if the car is grounded
local function IsGrounded()
	local hit, position = Raycast.new(
		(car.Chassis.CFrame * CFrame.new(0, 0, (car.Chassis.Size.Z / 2) - 1)).p,
		car.Chassis.CFrame:vectorToWorldSpace(Vector3.new(0, -1, 0)) * (Height + 0.2),
		script,
		car
	)
	if hit and hit.CanCollide then
		FlyCount = 0
		return(true)
	end
	return(false)
end

local function IsTouchingWall()
	local hit, position = Raycast.new(
		(car.Chassis.CFrame * CFrame.new(0, 3, (-car.Chassis.Size.Z) + 4)).p,
		car.Chassis.CFrame:vectorToWorldSpace(Vector3.new(0, 0, -2.5)), --* (20.2),
		script,
		car
	)
	if hit and hit.CanCollide then
		return true
	end
	return(false)
end

--spawn(function()
--	while wait(0.5) do
--		if tick() - LastMovement >= 30 then
--			game:GetService("TeleportService"):Teleport(1447126523)
--			break
--		end
--	end
--end)

--local oldCameraType = camera.CameraType
--camera.CameraType = cameraType

local function ExecuteRunningProcesses()
	local RemoveAfter = {}
	local CurrentActiveProcesses = {}
	local Active = ""
	
	for i, v in pairs(ActiveProcesses) do
		CurrentActiveProcesses[i] = v
		Active = Active .. i
	end
	
	--print(Active)
	
	for i, v in pairs(CurrentActiveProcesses) do
		if not v[1](unpack(v[2])) then
			RemoveAfter[#RemoveAfter + 1] = i
		end
	end
	
	for i, v in pairs(RemoveAfter) do
		ActiveProcesses[v] = nil
	end
end

--spawn(function()
Stepped:Connect(function()
	if car and not ToEnd then
		ExecuteRunningProcesses()
		if IsRacing then
			local NewPosition = Vector2.new(humanoidRootPart.Position.X, humanoidRootPart.Position.Z)
			if LastPosition then
				local Magnitude = (NewPosition - LastPosition).Magnitude
				local Wall = IsTouchingWall()
				if (Magnitude < 0.1 and not JustSet) or Wall then
					if movement.Y >= 0 and math.floor(movement.Y * 10) / 10 ~= 0.1 and (ForwardDown or IsBoosting) then
						movement = Vector2.new(movement.X, 0.1)
					end
					JustSet = true
				elseif JustSet then
					if Magnitude >= 0.1 then
						JustSet = false
						IncreasingAfterWall = true
						spawn(function()
							ActiveProcesses.E2 = {Processes.E2, {}}
						end)
						IncreasingAfterWall = false
					end
				end
			end
			LastPosition = NewPosition
		end
		--30fps
--		local t0 = tick()
--		Heartbeat:Wait()
--		debug.profilebegin("30 FPS Cap")
--		repeat until (t0+0.0325) < tick()
--		debug.profileend()
		--30fps
		if not character.Humanoid.SeatPart == car.DriveSeat then
			car.DriveSeat:Sit(character.Humanoid)
		end
		if Speed > 0 then
		--print(math.floor(character.Torso.Position.Y))
		
		local Hit = IsGrounded()
		local hCFrame = humanoidRootPart.CFrame
		if Hit then
			if movement.Y ~= 0 then
				local velocity = humanoidRootPart.CFrame.lookVector * movement.Y * Speed
				humanoidRootPart.Velocity = humanoidRootPart.Velocity:Lerp(velocity, 0.1)
				bodyVelocity.maxForce = Vector3.new(0, 0, 0)
			else
				bodyVelocity.maxForce = Vector3.new(Mass / 2, Mass / 4, Mass / 2)
			end
			local hRotVel = humanoidRootPart.RotVelocity
			local rotVelocity = hCFrame:vectorToWorldSpace(Vector3.new(movement.Y * Speed / 50, 0, -hRotVel.Y * 5 * movement.Y))
			local speed = -hCFrame:vectorToObjectSpace(humanoidRootPart.Velocity).unit.Z
			rotation = rotation + math.rad((-Speed / 5) * movement.Y)
			if math.abs(speed) > 0.1 then
				rotVelocity = rotVelocity + hCFrame:vectorToWorldSpace((Vector3.new(0, -movement.X * speed * (TurnSpeed), 0)))-- * math.abs(movement.Y)), 0)))
				bodyAngularVelocity.maxTorque = Vector3.new(0, 0, 0)
			else
				bodyAngularVelocity.maxTorque = Vector3.new(Mass / 4, Mass / 2, Mass / 4)
			end
			humanoidRootPart.RotVelocity = hRotVel:Lerp(rotVelocity, 0.1)
			--bodyVelocity.maxForce = Vector3.new(Mass / 3, Mass / 6, Mass / 3)
			--bodyAngularVelocity.maxTorque = Vector3.new(Mass / 6, Mass / 3, Mass / 6)
			
		else
--			if FlyCount == 0  then
--				car.PrimaryPart.Anchored = true
--				wait(1)
--				car.PrimaryPart.Anchored = false
--			end
			FlyCount = (FlyCount >= 1) and 1 or (FlyCount + 1 / 60)
			local X, Y, Z = humanoidRootPart.CFrame:ToOrientation()
			humanoidRootPart.CFrame = hCFrame:ToWorldSpace(CFrame.Angles(-(X*FlyCount), 0, -(Z*FlyCount)))
			--humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(180), 0), FlyCount)
			bodyVelocity.maxForce = Vector3.new(0, 0, 0)
			bodyAngularVelocity.maxTorque = Vector3.new(0, 0, 0)
			--humanoidRootPart.RotVelocity = humanoidRootPart.RotVelocity:Lerp(Vector3.new(), FlyCount)
			--local RotX, RotY, RotZ = car.PrimaryPart.CFrame:toEulerAnglesXYZ()
			--local DegX, DegY, DegZ = math.deg(RotX), math.deg(RotY), math.deg(RotZ)
--			if math.abs(DegX) >= LevelMax then
--				print("modifying!")
--				car.PrimaryPart.CFrame = car.PrimaryPart.CFrame * CFrame.Angles(math.rad(DegX > 0 and 2 or -2), 0, 0)
--			end
			--car.PrimaryPart.CFrame = car.PrimaryPart.CFrame * CFrame.Angles(0, 0, -(RotZ/30))
			--print("NOT GROUNDED")
		end
		
		for i, part in pairs(car:GetChildren()) do
			if part.Name == "Thruster" then
				if UpdateThruster(part) == "END" then
					break
				end
			end
		end
	end
else

	print("STOPPED")
	for i, v in pairs(car:GetChildren()) do
		if v:FindFirstChild("BodyThrust") then
			v.BodyThrust:Destroy()
		end
	end
	bodyVelocity:Destroy()
	bodyAngularVelocity:Destroy()
	--camera.CameraType = oldCameraType
end
end)

end)