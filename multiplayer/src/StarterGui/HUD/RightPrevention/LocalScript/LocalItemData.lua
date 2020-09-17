local LocalPlayer
repeat LocalPlayer = game.Players.LocalPlayer wait() until LocalPlayer

local Heartbeat = game:GetService("RunService").Heartbeat
local WarningUI = script.Parent.Parent.Warning.UI
local ItemHolder = script.Parent.Parent.ItemHolder
local Warned = false
local CurrentItems = {}

local function Weld(Car, Item)
	local NewWeld = Instance.new("WeldConstraint")
	NewWeld.Part0 = Item
	NewWeld.Part1 = Car.ItemArea
	NewWeld.Parent = Item
	NewWeld.Name = "Weld"
	return NewWeld
end

local function IsTouching(Block, LookVector, Value)
	local RayValue = Ray.new(Block.Position, LookVector * 5)
	local Hit, Position, Normal = workspace:FindPartOnRayWithIgnoreList(RayValue, {Block})
	if Hit then
		print"HIT"
		if Hit.Parent.Name:find("Parts") then
			print"BOUNCE"
			return "Bounce", Normal
		elseif Hit.Parent.DriveSeat.Occupant == LocalPlayer.Character.Humanoid then
			return "Hit"
		end
	end
end

local module = {
	
	["FakeItemBox"] = function(Car, Player)
		local NewItem = script.FakeItemBox:Clone()
		CurrentItems[Player] = NewItem
		NewItem.Parent = workspace.LocalItems
		local CarPos = Car.ItemArea.Position
		NewItem.CFrame = CFrame.new(
			CarPos
		)
		NewItem.Size = Vector3.new(1.25, 1.25, 1.25)
		Weld(Car, NewItem)
		wait()
		NewItem.Size = Vector3.new(2.5, 2.5, 2.5)
		Weld(Car, NewItem)
	end,
	
	["GreenBlock"] = function(Car, Player)
		local NewItem = script.GreenBlock:Clone()
		CurrentItems[Player] = NewItem
		NewItem.Parent = workspace.LocalItems
		local CarPos = Car.ItemArea.Position
		NewItem.CFrame = CFrame.new(
			CarPos
		)
		NewItem.Size = Vector3.new(1.25, 1.25, 1.25)
		Weld(Car, NewItem)
		wait()
		NewItem.Size = Vector3.new(2.5, 2.5, 2.5)
		Weld(Car, NewItem)
	end,
	
	["SpikeTrap"] = function(Car, Player)
		local NewItem = script.SpikeTrap:Clone()
		CurrentItems[Player] = NewItem
		NewItem.Parent = workspace.LocalItems
		local CarPos = Car.ItemArea.Position
		NewItem.PrimaryPart.CFrame = CFrame.new(
			CarPos
		)
		NewItem.PrimaryPart.Size = Vector3.new(1.93, 0.25, 1)
		Weld(Car, NewItem.PrimaryPart)
		wait()
		NewItem.PrimaryPart.Size = Vector3.new(3.86, 0.5, 2)
		Weld(Car, NewItem.PrimaryPart)
	end,
	
	["SingleNitro"] = function(Car)
		Car.Exhaust1.Fire.Enabled = true
		Car.Exhaust2.Fire.Enabled = true
		Car.Configurations.Speed.Value = 170
		Car.Configurations.TurnSpeed.Value = 0.9
		wait(0.85)
		Car.Exhaust1.Fire.Enabled = false
		Car.Exhaust2.Fire.Enabled = false
		for i = 170, 80, -8 do
			Car.Configurations.Speed.Value = i
			Car.Configurations.TurnSpeed.Value = (40 / i) * 3.8
			wait()
		end
		Car.Configurations.Speed.Value = 80
		Car.Configurations.TurnSpeed.Value = 1.9
	end,
	
	["Switch"] = function(Car)
		
	end,
	
	["Rocket"] = function(Car)
		local Rocket = script.Rocket:Clone()
		Rocket.Parent = Car
		Rocket.Color = Car.EngineBlock.Color
		Rocket.Position = Car.PrimaryPart.Position
		Rocket.Orientation = Vector3.new(135, Car.PrimaryPart.Orientation.Y, 0)
		local LookVector = Rocket.CFrame.upVector
		for i = -0.4, -6, -0.1 do
--			Rocket.Position = Rocket.Position + Vector3.new(
--				0,
--				i,
--				-i
--			)
			Rocket.CFrame = Rocket.CFrame + LookVector * i
			Heartbeat:wait()
		end
		Rocket:Destroy()
	end,
	
	["Robbie"] = function(Car)
		-- robbie
	end,
	
	Drop = {
		["FakeItemBox"] = function(Car, Player)
			pcall(function()
				local FIB = CurrentItems[Player]
				CurrentItems[Player] = nil
				FIB.Anchored = true
				for i, v in pairs(FIB:GetChildren()) do
					if v.Name == "Weld" then
						v:Destroy()
					end
				end
			end)
		end,
		["SpikeTrap"] = function(Car, Player)
			pcall(function()
				local Trap = CurrentItems[Player]
				CurrentItems[Player] = nil
				Trap.PrimaryPart.Anchored = true
				for i, v in pairs(Trap:GetDescendants()) do
					if v.Name == "Weld" then
						v:Destroy()
					end
				end
			end)
		end,
		["GreenBlock"] = function(Car, Player)
			pcall(function()
				local Block = CurrentItems[Player]
				CurrentItems[Player] = nil
				Block.Anchored = true
				for i, v in pairs(Block:GetChildren()) do
					if v.Name == "Weld" then
						v:Destroy()
					end
				end
				Block.Touched:Connect(function() end)
				Block.Position = Car.PrimaryPart.Position
				Block.Orientation = Vector3.new(0, Car.PrimaryPart.Orientation.Y, 0)
				
				local LookVector = Block.CFrame.LookVector
				local Bounces = 0
				Block.CFrame = Block.CFrame - LookVector * -8
				local Value = -1.5 - (Car.DriveSeat.Velocity.Magnitude / 120)
				local TouchState
				local Normal
				
				while true do
					while not TouchState do
						Heartbeat:Wait()
						_, TouchState, Normal = pcall(IsTouching, Block, LookVector, Value)
						Block.CFrame = Block.CFrame - LookVector * Value
					end
					
					if TouchState == "Bounce" then
						Bounces = Bounces + 1
						if Bounces == 10 then
							break
						end
						LookVector = -(LookVector - (2 * LookVector:Dot(Normal) * Normal))
						Value = -Value
						Block.CFrame = Block.CFrame - LookVector * (Value * 2)
						TouchState = nil
					elseif TouchState == "Hit" then
						break
					else
						TouchState = nil
					end
				end
			end)
		end,
	}
	
}

game.ReplicatedStorage.FireRocket.OnClientEvent:Connect(function(Target, Player)
	local NewRocket = script.Rocket:Clone()
	NewRocket.Parent = workspace
	NewRocket.Orientation = Vector3.new()
	for i = 100, 0, -1.5 do
		Heartbeat:wait()
		NewRocket.Position = Target.EngineBlock.Position + Vector3.new(0, i, 0)
	end
	if Player == LocalPlayer then
		Target.PrimaryPart.Anchored = true
	end
	Warned = false
	local E = Instance.new("Explosion")
	E.Parent = Target
	E.BlastRadius = 0
	E.BlastPressure = 0
	E.DestroyJointRadiusPercent = 0
	E.Position = NewRocket.Position
	NewRocket:Destroy()
	wait(1.5)
	E:Destroy()
	pcall(function()
		Target.PrimaryPart.Anchored = false
	end)
end)

game.ReplicatedStorage.RocketFired.OnClientEvent:Connect(function(Player, Car)
	if LocalPlayer ~= Player then
		module.Rocket(Car)
	end
end)

local function AlterTransparency(NewValue)
	local Trans = WarningUI.ImageTransparency
	for i = Trans, NewValue, (NewValue - Trans) / 5 do
		WarningUI.ImageTransparency = i
		WarningUI.Item.ImageTransparency = i
		wait()
	end
	WarningUI.ImageTransparency = NewValue
	WarningUI.Item.ImageTransparency = NewValue
end

game.ReplicatedStorage.WarnPlayer.OnClientEvent:Connect(function(Item)
	Warned = true
	WarningUI.Item.Image = ItemHolder.Item.Rocket.Image
	AlterTransparency(0.2)
	while Warned do
		AlterTransparency(0.6)
		AlterTransparency(0.2)
	end
	AlterTransparency(1)
end)

game.ReplicatedStorage.HoldItem.OnClientEvent:Connect(function(Car, Player, Item)
	if module[Item] then
		module[Item](Car, Player)
	end
end)

game.ReplicatedStorage.DropItem.OnClientEvent:Connect(function(Car, Player, Item)
	if module.Drop[Item] then
		module.Drop[Item](Car, Player)
	end
end)

return module
