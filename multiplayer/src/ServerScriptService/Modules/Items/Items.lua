local Items = game.ServerStorage.Items
local Stepped = game:GetService("RunService").Stepped

local Main = script.Parent.Parent.Parent.Main

local CanUseRocket = true
local CurrentItems = {}

local function Weld(Car, Item)
	local NewWeld = Instance.new("WeldConstraint")
	NewWeld.Name = "Weld"
	NewWeld.Part1 = Car.ItemArea
	NewWeld.Part0 = Item
	NewWeld.Parent = Item
	return NewWeld
end

local function SpinOut(Player, Car)
	--[[
	for i = 80, 0, -5 do
		Car.Configurations.Speed.Value = i
		Car.Configurations.TurnSpeed.Value = i / 40
		wait()
	end
	--Car.PrimaryPart.Anchored = true
	for i = 1, 45 do
		Car:SetPrimaryPartCFrame((Car.PrimaryPart.CFrame + Vector3.new(0, 0, 1)) * CFrame.fromEulerAnglesXYZ(0, -.5, 0))
		wait()
	end
	wait(0.5)
	for i = 0, 80, 4 do
		Car.Configurations.Speed.Value = i
		Car.Configurations.TurnSpeed.Value = i / 40
		wait()
	end]]
	if Car.Name == "Car" then
		Car.PrimaryPart.Anchored = true
		wait(1.5)
		Car.PrimaryPart.Anchored = false
	end
end

---------

local function RunFake(Player, Item, Map, Car)
--	local NewItem = Items[Item]:Clone()
--	CurrentItems[Player] = NewItem
--	NewItem.Anchored = false
--	NewItem.Parent = Map.Items
--	local CarPos = Car.ItemArea.Position
--	NewItem.CFrame = CFrame.new(
--		CarPos
--	)
--	--Weld(Car, NewItem)
--	NewItem.Touched:Connect(function(Player)
--		if Player.Name ~= "ItemArea" and Player.Name ~= "Sphere" then
--			NewItem:Destroy()
--			SpinOut(Player, Player.Parent)
--		end
--	end)
	for i, v in pairs(game.Players:GetPlayers()) do
		if v ~= Player then
			game.ReplicatedStorage.HoldItem:FireClient(v, Car, Player, "FakeItemBox")
		end
	end
end

local function RunTrap(Player, Item, Map, Car)
	for i, v in pairs(game.Players:GetPlayers()) do
		if v ~= Player then
			game.ReplicatedStorage.HoldItem:FireClient(v, Car, Player, "SpikeTrap")
		end
	end
end

local function RunNitro(Player, Item, Map, Car, Type)
	Car.Exhaust1.Fire.Enabled = true
	Car.Exhaust2.Fire.Enabled = true
	wait(0.85)
	Car.Exhaust1.Fire.Enabled = false
	Car.Exhaust2.Fire.Enabled = false
--	if Type ~= "Assist" then
--		Car.Exhaust1.Fire.Enabled = true
--		Car.Exhaust2.Fire.Enabled = true
----		Car.Configurations.Speed.Value = 170
----		Car.Configurations.TurnSpeed.Value = 0.9
--		wait(0.85)
--		Car.Exhaust1.Fire.Enabled = false
--		Car.Exhaust2.Fire.Enabled = false
----		for i = 170, 80, -8 do
----			Car.Configurations.Speed.Value = i
----			Car.Configurations.TurnSpeed.Value = (40 / i) * 3.8
----			wait()
----		end
----		Car.Configurations.Speed.Value = 80
----		Car.Configurations.TurnSpeed.Value = 1.9
--	else
--		Car.Exhaust1.Fire.Enabled = true
--		Car.Exhaust2.Fire.Enabled = true
--		Car.Configurations.Speed.Value = 170
--		Car.Configurations.TurnSpeed.Value = 0
--		wait(0.85)
--		Car.Exhaust1.Fire.Enabled = false
--		Car.Exhaust2.Fire.Enabled = false
--		Car.Configurations.Speed.Value = 80
--		Car.Configurations.TurnSpeed.Value = 1.9
--	end
end

local function RunRocket(Player, Item, Map, Car, FirstPlace, PlayerCars)
	CanUseRocket = false
	game.ReplicatedStorage.RocketFired:FireAllClients(Player, Car)
	wait(3)
	FirstPlace = Main.GetFirstPlace:Invoke()
	game.ReplicatedStorage.WarnPlayer:FireClient(FirstPlace, "Rocket")
	wait(3)
	pcall(function()
		game.ReplicatedStorage.FireRocket:FireAllClients(PlayerCars[FirstPlace.Name], FirstPlace)
	end)
	spawn(function()
		wait(40)
		CanUseRocket = true
	end)
end

local function RunMagnet(Player, Item, Map, Car)
	local MagnetInfo = Instance.new("BoolValue")
	MagnetInfo.Parent = script.Parent.MagnetInfo
	MagnetInfo.Name = Player.Name
	wait(7.5)
	MagnetInfo:Destroy()
end

local function RunSwitch(Player, Item, Map, Car)
	--local 
end

local function RunRobbie(Player, Item, Map, Car)
	--for i, v in pairs()
end

local function RunGreen(Player, Item, Map, Car)
	for i, v in pairs(game.Players:GetPlayers()) do
		if v ~= Player then
			game.ReplicatedStorage.HoldItem:FireClient(v, Car, Player, "GreenBlock")
		end
	end
end

game.ReplicatedStorage.ItemDropped.OnServerEvent:Connect(function(Player, Car)
	if CurrentItems[Player] then
		for i, v in pairs(game.Players:GetPlayers()) do
			game.ReplicatedStorage.DropItem:FireClient(v, Car, Player, CurrentItems[Player])
		end
		CurrentItems[Player] = nil
	end
end)

Main.SendPrevItem.Event:Connect(function(Player, Item)
	CurrentItems[Player] = Item
end)

--return {
--	["FakeItemBox"] = {
--		Name = "FakeItemBox",
--		Avail = {0, 30},
--		Run = RunFake,
--		CanUse = true
--	},
--	["SingleNitro"] = {
--		Name = "SingleNitro",
--		Avail = {20, 60},
--		Run = RunNitro,
--		CanUse = true
--	},
--	["Switch"] = {
--		Name = "Switch",
--		Avail = {50, 80},
--		Run = RunSwitch,
--		CanUse = true
--	},
--	["Rocket"] = {
--		Name = "Rocket",
--		Avail = {51, 65},
--		Run = RunRocket,
--		CanUse = CanUseRocket
--	},
--	["Robbie"] = {
--		Name = "Robbie",
--		Avail = {50, 70},
--		Run = RunRobbie,
--		CanUse = false
--	}
--}

return {
	["FakeItemBox"] = {
		Name = "FakeItemBox",
		Avail = {0, 26},
		Run = RunFake,
		CanUse = true
	},
	["SingleNitro"] = {
		Name = "SingleNitro",
		Avail = {26, 76},
		Run = RunNitro,
		CanUse = true
	},
	["Switch"] = {
		Name = "Switch",
		Avail = {50, 80},
		Run = RunSwitch,
		CanUse = false
	},
	["Rocket"] = {
		Name = "Rocket",
		Avail = {0, 100},
		Run = RunRocket,
		CanUse = CanUseRocket
	},
	["Robbie"] = {
		Name = "Robbie",
		Avail = {50, 70},
		Run = RunRobbie,
		CanUse = true
	},
	["SpikeTrap"] = {
		Name = "SpikeTrap",
		Avail = {0, 26},
		Run = RunTrap,
		CanUse = true
	},
	["GreenBlock"] = {
		Name = "GreenBlock",
		Avail = {0, 100},
		Run = RunGreen,
		CanUse = false
	}
}