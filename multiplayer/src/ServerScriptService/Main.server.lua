math.randomseed(tick())

local GetModule = require(game.ReplicatedStorage:WaitForChild("MainModule"))

local Storage = game.ServerStorage
local Repl = game.ReplicatedStorage
--local DataStore = game:GetService("DataStoreService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local Chat = game:GetService("Chat")
local DataStore = GetModule("DataStore")
local Items = GetModule("Items")
local XP = GetModule("xpFormula")
local Accessory = GetModule("Accessory")
local ChatCommands = GetModule("ChatCommands")
local RubberBand = GetModule("RubberBand")
local ProcessMessage = GetModule("ProcessMessage")
local ItemUsed = GetModule("ItemUsed")
local Camera = workspace.SpectateCam

local GettingPlayers = true
local DoingCountdown = false
local GameInProgress = false
local FinishCountdown = false
local GameEnded = false
local NeedsRestart = false
local Choosing = false
local EndingGame = false
local PlayerHasStats = false
local CanJoin = true

local RunningBoost = {}
local PossibleTracks = {}
local Finishers = {}
local PlayersChosen = {}
local PlayersCoinMax = {}
local CurrentPlayers = {}

_G.PlayerCars = {}
_G.PlayerData = {}
_G.GamePlayers = {}

local CountdownValue
local ChosenTrack
local AccessPreVote
local PlayersNeeded

local Iteration = 0

local Developers = {
	["JoshRBX"] = true
}

local Helpers = {
	["Player1"] = true,
	["MachiavelRebirth"] = true,
	["UltraSkiMask"] = true,
	["NotSoBloxy"] = true,
	["Gorozaemon"] = true,
	["Yvxes"] = true,
	["Dankvisky"] = true,
	["CodeTheIdiot"] = true,
	["KrazeyPlayz"] = true,
	["FauXNiiM"] = true,
	["Mr_Octree"] = true,
	["coincision"] = true
}

local function ModeratePlayer(Player, Reason)
	Player:Kick(Reason .. ".\nIf you believe this was an error, please check your network speed and try again later.")
end

local function GetBestPlayer()
	local Best = {13, "PLAYER"}
	for i, v in pairs(_G.GamePlayers) do
		if not v.GameEnded then
			if v.Place < Best[1] then
				Best = {v.Place, i}
			end
		end
	end
	return Best[2]
end

local function GetPlayerFromPlacement(Place)
	if Place == 1 then
		return GetBestPlayer()
	else
		for i, v in pairs(_G.GamePlayers) do
			if v.Place == Place then
				return i
			end
		end
	end
end

--local function ControlCamera()
--	wait(1)
--	local Delay = 0.5
--	local CurrentWinner = game.Players:GetPlayers()[1]
--	local LastWinner
--	while GameInProgress do
--		if _G.GamePlayers[CurrentWinner].Place ~= 1 + #Finishers then
--			CurrentWinner = GetPlayerFromPlacement(1 + #Finishers)
--		end
----		local TweenInformation = TweenInfo.new(
----			Delay, -- Time
----			Enum.EasingStyle.Linear, -- EasingStyle
----			Enum.EasingDirection.Out, -- EasingDirection
----			0, -- RepeatCount (when less than zero the tween will loop indefinitely)
----			false, -- Reverses (tween will reverse once reaching it's goal)
----			0 -- DelayTime
----		)
----		local Anim = TweenService:Create(Camera, TweenInformation, {Position = _G.PlayerCars[CurrentWinner.Name].PrimaryPart.Position})
----		Anim:Play()
--		if LastWinner ~= CurrentWinner then
--			LastWinner = CurrentWinner
--			Camera:ClearAllChildren()
--			Camera.CFrame = CFrame.new(_G.PlayerCars[CurrentWinner.Name].PrimaryPart.Position)
--			--local Weld = Instance.new("Weld")
--			--Weld.Parent = Camera
--			--Weld.Part0 = Camera
--			--Weld.Part1 = Camera.Parent
--		end
--			--,_G.PlayerCars[CurrentWinner.Name].PrimaryPart.Position
--		--)
--		wait(Delay)
----		Anim:Cancel()
--		-- Camera.CFrame = Camera.CFrame:lerp(CFrame.new(_G.PlayerCars[CurrentWinner.Name].PrimaryPart.Position), 2)
--	end
--end

local function DictLen(Dict)
	local Length = 0
	for i, v in pairs(Dict) do
		Length = Length + 1
	end
	return Length
end

local function StopCar(PlayerCar)
--	for i = 80, 0, -4 do
--		wait()
--		PlayerCar.Configurations.Speed.Value = i
--	end
	--y.PrimaryPart.Anchored = true
end

local function ResetStuff()
	CanJoin = true
	CurrentPlayers = {}
	_G.Map:Destroy()
	_G.Map = nil
	for i, v in pairs(game.Players:GetPlayers()) do
		v:LoadCharacter()
	end
	for i, v in pairs(_G.PlayerCars) do
		v:Destroy()
	end
	GettingPlayers = true
	DoingCountdown = true
	_G.GamePlayers = {}
	PossibleTracks = {}
	Finishers = {}
end

local function UpdateXP()
	local PlayersXP = {}
	local PlayersNewXP = {}
	local TotalXP = 0
	for i, v in pairs(_G.PlayerData) do
		print(game.Players:FindFirstChild(i))
		if _G.GamePlayers[game.Players:FindFirstChild(i)] and game.Players:FindFirstChild(i) then
			wait()
			local PlayerXP = v:GetAsync("MultiXP")
			if not PlayerXP or not v:GetAsync("HasPlayed") then
				v:SetAsync("HasPlayed", true)
				v:SetAsync("MultiXP", 2000)
				v:SetAsync("Coins", 0)
				PlayerXP = 2000
			end
			PlayersXP[i] = PlayerXP
			TotalXP = TotalXP + PlayerXP
		end
	end
	for i, v in pairs(_G.PlayerData) do
		if _G.GamePlayers[game.Players:FindFirstChild(i)] and game.Players:FindFirstChild(i) then
			local NewXP = XP.Calculate(_G.GamePlayers[game.Players[i]].Place, PlayersXP[i], TotalXP / DictLen(PlayersXP), DictLen(_G.GamePlayers))
			v:SetAsync("MultiXP", NewXP)
			v:UpdateAsync("Coins", function(Old)
				if tonumber(Old) then
					return Old + _G.GamePlayers[game.Players:FindFirstChild(i)].Coins
				else
					return _G.GamePlayers[game.Players:FindFirstChild(i)].Coins
				end
			end)
			PlayersNewXP[i] = NewXP
		end
	end
--	for i, v in pairs(PlayersXP) do
--		print(i, v)
--		local NewXP = XP.Calculate(_G.GamePlayers[game.Players[i]].Place, v, TotalXP / DictLen(PlayersXP), DictLen(_G.GamePlayers)) -- Index field ? nil val
--		_G.PlayerData[i]:SetAsync("MultiXP", NewXP)
--		PlayersNewXP[i] = NewXP
--	end
	Repl.xpData:FireAllClients(PlayersXP, PlayersNewXP)
end

local function EndingSequence(PlayersToPass)
	UpdateXP()
	Repl.GameEnded:FireAllClients(game.Players:GetPlayers(), PlayersToPass)
	GameInProgress = false
	wait(14)
	ResetStuff()
	NeedsRestart = true
	local Players = {}
	for i, v in pairs(game.Players:GetPlayers()) do
		table.insert(Players, {v, DataStore:GetDataStore("v2PLR_" .. v.UserId):GetAsync("HasVIP")})
	end
	Repl.RestartGame:FireAllClients(Players)
	spawn(AccessPreVote)
end

local function CountdownEnd()
	wait(30)
	if not GameEnded then
		GameEnded = true
		for i, v in pairs(_G.PlayerCars) do
			spawn(function()
				pcall(StopCar, v)
			end)
		end
		FinishCountdown = false 
		local PlayersToPass = {}
		for i, v in pairs(_G.GamePlayers) do
			PlayersToPass[i.Name] = v
		end
		EndingSequence(PlayersToPass)
	end
end

local function TryToEndGame()
	if not GameEnded and PlayerHasStats then
		if (#Finishers >= DictLen(_G.GamePlayers) - 1 and DictLen(_G.GamePlayers) > 1) or (#Finishers == DictLen(_G.GamePlayers)) then
			EndingGame = true
			PlayerHasStats = false
			FinishCountdown = false
			GameEnded = true
			local PlayersToPass = {}
			for i, v in pairs(_G.GamePlayers) do
				PlayersToPass[i.Name] = v
			end
			EndingSequence(PlayersToPass)
		elseif not FinishCountdown then
			FinishCountdown = true
			spawn(CountdownEnd)
		end
	end
end

local function EndGamePlayer(Player)
	local Stats = _G.GamePlayers[Player]
	print(Player, Stats.Coins)
	Stats.GameEnded = true
	table.insert(Finishers, {
		Name = Player.Name,
		PlayerObject = Player
	})
	Repl.PlayerFinished:FireAllClients(Player.Name, Finishers)
	Repl.WatchGame:FireClient(Player, _G.PlayerCars, _G.Map, true)
	--_G.PlayerCars[Player.Name].Configurations.Speed.Value = 0 -- dangerous
	pcall(StopCar, _G.PlayerCars[Player.Name])
	TryToEndGame()
end

local function CheckPoint(Part, Checkpoint)
	local Player = game.Players:GetPlayerFromCharacter(Part.Parent)
	local Stats = _G.GamePlayers[Player]
	print("NEXTPOINT:" .. Stats.NextCheckpoint, "MAX:" .. #_G.Map.Checkpoints:GetChildren(), "CURRENT:"..Checkpoint.Name)
	if Checkpoint.Name == "Checkpoint" .. Stats.NextCheckpoint then
		Stats.NextCheckpoint = Stats.NextCheckpoint + 1
	elseif Stats.NextCheckpoint == #_G.Map.Checkpoints:GetChildren() and Checkpoint.Name == "Checkpoint0" then
		if Stats.Lap == 3 and Stats.Lap < 4 then
			Stats.Lap = 4
			EndGamePlayer(Player)
		else
			Stats.Lap = Stats.Lap + 1
			Stats.NextCheckpoint = 1
			Repl.ChangeLap:FireClient(Player, Stats.Lap)
		end
	end
end

local function PlayerThere(LapI, CheckpointI)
	local Players = {}
	for i, v in pairs(_G.GamePlayers) do
		if v.Lap == LapI and v.NextCheckpoint == CheckpointI then
			table.insert(Players, i)
		end
	end
	return Players
end

local function SortPlayers(PlayersInLap, Placement)
	table.sort(PlayersInLap, function(x, y)
		return x[2] < y[2]
	end)
	for i, v in pairs(PlayersInLap) do
		table.insert(Placement, v[1])
	end
	return Placement
end

local function PlayerHasFinished(Player)
	for i, v in pairs(Finishers) do
		if v == Player then
			return true
		end
	end
	return false
end

local function UpdatePlayerPlace(Placement)
	for i, v in pairs(Placement) do
		--[[if not PlayerHasFinished(v.Name) then
			print(v.Name)
			for x, y in pairs(_G.GamePlayers) do
				print(x, y)
				for a, b in pairs(y) do
					print(a, b)
				end
			end]]
		pcall(function()
			if _G.GamePlayers[v].Place ~= i then
				Repl.ChangePlace:FireClient(v, _G.GamePlayers[v].Place, i)
				_G.GamePlayers[v].Place = i
			end
		end)
	end
end

local function UpdatePlacement()
	local Placement = {}
	for i, v in pairs(Finishers) do
		table.insert(Placement, v.PlayerObject)
	end
	for LapI = 3, 0, -1 do
		for CheckpointI = #_G.Map.Checkpoints:GetChildren(), 1, -1 do
			local PlayersThere = PlayerThere(LapI, CheckpointI)
			if PlayersThere and #PlayersThere > 1 then
				local PlayersInLap = {}
				for i, v in pairs(PlayersThere) do
					local CheckNum = CheckpointI
					if CheckpointI == #_G.Map.Checkpoints:GetChildren() then
						CheckNum = 0
					end
					table.insert(PlayersInLap, {v, v:DistanceFromCharacter(_G.Map.Checkpoints["Checkpoint" .. tostring(CheckNum)].Position)})
				end
				Placement = SortPlayers(PlayersInLap, Placement)
			elseif PlayersThere then
				table.insert(Placement, PlayersThere[1])
			end
		end
	end
	UpdatePlayerPlace(Placement)
end

local function GameStarted()
	GameEnded = false
	for i, v in pairs(_G.Map.Checkpoints:GetChildren()) do
		local Checkpoint = v
		Checkpoint.Touched:Connect(function(Part)
			if Part.Parent:FindFirstChild("Humanoid") and Part.Name == "Head" then
				CheckPoint(Part, Checkpoint)
			end
		end)
	end
end

local function GivePlayerStats()
	_G.GamePlayers = {}
	for i, v in pairs(CurrentPlayers) do
		_G.GamePlayers[v] = {
			Username  = v.Name,
			Lap = 0,
			Coins = 0,
			Place = 1,
			CurrentItem = nil,
			LastPosition = v.Character.Torso.Position,
			NextCheckpoint = #_G.Map.Checkpoints:GetChildren(),
			PrevCheckpoint = #_G.Map.Checkpoints:GetChildren(),
			GameEnded = false,
			Respawning = false,
			IMCounter = 0,
			HasRespawned = false,
			CoinUpgrade = _G.PlayerData[v.Name]:GetAsync("CoinUpgrade"),
			Ready = false
		}
	end
end

local function RestartCarScripts(Car)
	Car.CarScript.Disabled = true
	Car.CarScript.LocalCarScript.Disabled = true
	Car.CarScript.Disabled = false
	Car.CarScript.LocalCarScript.Disabled = false
end

local function ItemCollected(Box, Player)
	pcall(function()
		if not _G.GamePlayers[Player].CurrentItem then
			local PossibleItems = {}
			for i, v in pairs(Items) do
				local Param = (((_G.GamePlayers[Player].Place / DictLen(_G.GamePlayers)) + ((_G.GamePlayers[Player].Place - 1) / DictLen(_G.GamePlayers))) / 2) * 100
				if v.Avail[1] <= Param and Param <= v.Avail[2] and v.CanUse then
					table.insert(PossibleItems, v.Name)
				end
			end
			if #PossibleItems > 0 then
				spawn(function()
					_G.GamePlayers[Player].CurrentItem = PossibleItems[math.random(#PossibleItems)]
					Repl.GiveItem:FireClient(Player, _G.GamePlayers[Player].CurrentItem)
				end)
			end
		end
	end)
	wait(5)
	for i, v in pairs(Box:GetChildren()) do
		pcall(function()
			v.Transparency = 0.2
		end)
	end
end

local function CheckItemBoxes()
	for i, v in pairs(_G.Map.ItemBoxes:GetChildren()) do
		v.Touched:Connect(function(Player)
			if Player.Parent:FindFirstChild("Humanoid") then
				return
			end
			if Player.Parent:FindFirstChild("DriveSeat") then
				if v:FindFirstChild("Texture").Transparency ~= 1 then
					for x, y in pairs(v:GetChildren()) do
						pcall(function()
							y.Transparency = 1
						end)
					end
					--pcall(function()
						ItemCollected(v, game.Players:GetPlayerFromCharacter(Player.Parent.DriveSeat.Occupant.Parent))
					--end)
				end
			end
		end)
	end
end

local function CreateDropPart(Pos)
	local Part = Instance.new("Part")
	Part.Parent = workspace
	Part.Anchored = true
	Part.CFrame = Pos
	local Attachment = Instance.new("Attachment")
	Attachment.Parent = Part
	return Part
end

local function DebugVector(V)
	return(V.X .. V.Y .. V.Z)
end

local function RespawnPlayer(Player, AntiCheat)
	if not _G.GamePlayers[Player].Respawning then
		_G.GamePlayers[Player].Respawning = true
		Repl.Respawning:FireClient(Player)
		wait(1)
		if not AntiCheat then
			_G.GamePlayers[Player].HasRespawned = true
		end
		--local NewCar = Storage.Car:Clone()
		--NewCar.Parent = workspace
		local CurrentPoint = 0
		if _G.GamePlayers[Player].NextCheckpoint == 0 then
			CurrentPoint = #_G.Map.Checkpoints
		else
			CurrentPoint = _G.GamePlayers[Player].NextCheckpoint
		end
		local Part = CreateDropPart(
			CFrame.new(_G.Map.Checkpoints:WaitForChild("Checkpoint" .. CurrentPoint - 1).Position + Vector3.new(0, 60, 0))
		)
		_G.PlayerCars[Player.Name].PrimaryPart.CFrame = CFrame.new(
			_G.Map.Checkpoints:WaitForChild("Checkpoint" .. CurrentPoint - 1).Position + Vector3.new(0, 50, 0)
		) -- dangerous
		local Rope = Instance.new("RopeConstraint")
		Rope.Parent = workspace
		Rope.Length = 25
		Rope.Visible = true
		Rope.Attachment0 = Part.Attachment
		Rope.Attachment1 = _G.PlayerCars[Player.Name].PrimaryPart.Attachment
--		local Weld = Instance.new("WeldConstraint")
--		Weld.Parent = workspace
--		Weld.Part0 = Part
--		Weld.Part1 = _G.PlayerCars[Player.Name].PrimaryPart
		wait(4)
		Part:Destroy()
		--Weld:Destroy()
		_G.GamePlayers[Player].Respawning = false
	end
end

local function CheckDropPoints()
	for i, v in pairs(_G.Map.DropPoints:GetChildren()) do
		v.Touched:Connect(function(Obj)
			pcall(function()
				if v.Name ~= "Baseplate" then
					local Player = game.Players:GetPlayerFromCharacter(Obj.Parent.DriveSeat.Occupant.Parent)
					RespawnPlayer(Player)
				end
			end)
		end)
	end
end

local function CheckBoosts() -- replaced with clientside check for optimisation
	for i, v in pairs(_G.Map.Boosts:GetDescendants()) do
		if v.Name == "BoostPanel" or v.Name == "Assist" then
			v.Touched:Connect(function(Obj)
				if Obj.Parent:FindFirstChild("Humanoid") then
					return
				end
				local Player = game.Players:GetPlayerFromCharacter(Obj.Parent.DriveSeat.Occupant.Parent)
				if not RunningBoost[Player] then
					RunningBoost[Player] = true
					Items.SingleNitro.Run(Player, nil, nil, _G.PlayerCars[Player.Name], v.Name)
					RunningBoost[Player] = false
				end
			end)
		end
	end
end

local function AddCoin(Player)
	local Info = _G.GamePlayers[Player]
	if Info.HasUpgrade then
		if Info.Coins < 20 then
			Info.Coins = Info.Coins + 1
		end
	else
		if Info.Coins < 10 then
			Info.Coins = Info.Coins + 1
		end
	end
	--Repl.GiveCoins:FireClient(Player)
end

local function CheckCoins()
	for i, v in pairs(_G.Map.Coins:GetChildren()) do
		local Coin = v
		local InUse = false
		local UsedByCarPart = false
		
--		Coin.MagnetCheck.Touched:Connect(function(CarPart)
--			pcall(function()
--				if not InUse and not UsedByCarPart then
--					UsedByCarPart = true
--					local Player = game.Players:GetPlayerFromCharacter(CarPart.Parent.DriveSeat.Occupant.Parent)
--					if MagnetInfo:FindFirstChild(Player.Name) then
--						InUse = true
----						local Original = Coin.CFrame
----						local Dist = (Player.Character.PrimaryPart.Position - Coin.Position).magnitude
----						local Direction = CFrame.new(Coin.Position, Player.Character.PrimaryPart.Position).lookVector
----						for x = 0, Dist, 1 do
----							Coin.CFrame = Coin.CFrame + (Direction * (1 / Dist))
----							wait()
----						end
----						Coin.CFrame = Original
--						for x, y in pairs(Coin:GetChildren()) do
--							pcall(function()
--								y.Transparency = 1
--							end)
--						end
--						AddCoin(Player)
--						wait(10)
--						for x, y in pairs(Coin:GetChildren()) do
--							pcall(function()
--								y.Transparency = (y.Name ~= "MagnetCheck" and 0) or 1
--							end)
--						end
--						InUse = false
--					end
--					UsedByCarPart = false
--				end
--			end)
--		end) -- removed due to speed on mobile devicess
		
		Coin.Touched:Connect(function(CarPart)
			pcall(function()
				if not InUse then
					if CarPart.Parent:FindFirstChild("Humanoid") then
						return
					end
					local Player = game.Players:GetPlayerFromCharacter(CarPart.Parent.DriveSeat.Occupant.Parent)
					InUse = true
					for x, y in pairs(Coin:GetChildren()) do
						pcall(function()
							y.Transparency = 1
						end)
					end
					AddCoin(Player)
					wait(7.5)
					for x, y in pairs(Coin:GetChildren()) do
						pcall(function()
							y.Transparency = 0
						end)
					end
					InUse = false
				end
			end)
		end)
		
	end
end

local function Countdown(Cars)
	--spawn(ControlCamera)
	Repl.StartCountdown:FireAllClients()
	wait(4)
	Repl.StartRace:FireAllClients()
	wait(0.3)
	for i, v in pairs(Cars) do
		pcall(function()
			v[1].PrimaryPart.Anchored = false
			--RestartCarScripts(v[1])
		end)
		--v[1].PrimaryPart.Anchored = false;
	end
	CheckItemBoxes()
	CheckDropPoints()
	CheckCoins()
	--CheckBoosts() -- moved to the client side
	GameStarted()
end

local function DoMapIntro()
	print("Starting map intro!")
	for i = 1, 15 do
		print(i)
		wait(1)
		if PlayersNeeded == 0 then
			print("All players ready!")
			break
		end
	end
	Repl.StartIntro:FireAllClients()
end

Repl.ReadyToRace.OnServerEvent:Connect(function(Player)
	if _G.GamePlayers[Player] then
		if not _G.GamePlayers[Player].Ready then
			_G.GamePlayers[Player].Ready = true
			PlayersNeeded = PlayersNeeded - 1
			print(PlayersNeeded .. " more needed")
		end
	end
end)

local function GetBadge(Player, Tag)
	if Developers[Player.Name] then
		Tag.Badge.DevBadge.Visible = true
	elseif Helpers[Player.Name] then
		Tag.Badge.HelperBadge.Visible = true
	elseif DataStore:GetDataStore("v2PLR_" .. Player.UserId):GetAsync("HasVIP") then
		Tag.Badge.VIPBadge.Visible = true
	end
end

local function AddAccessories(Player, Car)
	local AccessoryDS = DataStore:GetDataStore("v2PLR_" .. Player.UserId):GetAsync("Accessories")
	if AccessoryDS then
		if AccessoryDS.Equipped then
			for i, v in pairs({"Flag", "Colour"}) do
				if AccessoryDS.Equipped[v] then
					Accessory["Add" .. v](AccessoryDS.Equipped[v], Car)
				end
			end
			if AccessoryDS.Equipped.NumberPlate then
				Accessory.ApplyPlate(AccessoryDS.Equipped.NumberPlate, Car)
			end
		end
	end
end

local function SetupCarForRace(Position, v)
	local NewCar = Storage.Car:Clone()
	local NewTag = Storage.NameTag:Clone()
	local Info = {NewCar, v}
	local Success = pcall(function()
		NewCar:SetPrimaryPartCFrame(Position)
		NewCar.Parent = workspace.Cars
		NewCar.DriveSeat:Sit(v.Character.Humanoid)
		NewCar.DriveSeat:SetNetworkOwner(v)
		NewCar.PrimaryPart.Anchored = true
		_G.PlayerCars[v.Name] = NewCar
		NewTag.Username.Text = v.Name
		GetBadge(v, NewTag)
		local ID = v.UserId
		if ID < 1 then
			ID = 1
		end
		NewTag.Character.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. ID .. "&width=420&height=420&format=png"
		NewTag.Parent = v.Character.Head
		NewTag.PlayerToHideFrom = v
		AddAccessories(v, NewCar)
--		local localCarScript = NewCar.LocalCarScript:Clone()
--		localCarScript.Parent = v.PlayerGui
--		localCarScript.Car.Value = NewCar
--		localCarScript.Disabled = false
		v.PlayerGui.LocalCarScript.Car.Value = NewCar
		RubberBand:Initiate(NewCar)
	end)
	if not Success then
		pcall(function()
			NewCar:Destroy()
			NewTag:Destroy()
		end)
	end
	return Info
end

local function SetupMinimap()
	Repl.GiveCarInformation:FireAllClients(_G.PlayerCars, _G.Map.MinimapPoint.Position, _G.Map.MinimapPoint2.Position, _G.Map.MinimapPoint)
end

local function GetCars()
	local Cars = {}
	for i, v in pairs(CurrentPlayers) do
		--spawn(function()
			table.insert(
				Cars,
				SetupCarForRace(_G.Map:WaitForChild("StartPoint").Places["Place" .. i].PrimaryPart.CFrame + Vector3.new(0, 4, 7), v)
			)
		--end)
	end
	spawn(SetupMinimap)
	wait(2)
--	for i, v in pairs(Cars) do
--		pcall(function()
--			print("ADDING CAR")
--			print(v[1], v[2])
--			v[1].DriveSeat:Sit(v[2].Character.Humanoid)
--			v[1].Configurations.Speed.Value = 0
--			v[1].Configurations.TurnSpeed.Value = 0
--		end)
--	end
	GameInProgress = true
	spawn(function()
		while GameInProgress do
			wait(0.2)
			UpdatePlacement()
			pcall(function()
				for i, v in pairs(_G.PlayerCars) do
					local plr = game.Players:FindFirstChild(i)
					local Hum = plr.Character.Humanoid
					if v.DriveSeat.Occupant ~= Hum then
--						print(_G.GamePlayers[plr].PrevCheckpoint, _G.GamePlayers[plr].NextCheckpoint)
--						if _G.GamePlayers[plr].PrevCheckpoint ~= _G.GamePlayers[plr].NextCheckpoint then
--							_G.GamePlayers[plr].NextCheckpoint = _G.GamePlayers[plr].PrevCheckpoint
--							print("checkpoint reverted due to illegal movement")
--						end
						v.DriveSeat:Sit(Hum)
					end
--					if math.abs((_G.GamePlayers[plr].LastPosition - plr.Character.Torso.Position).magnitude) >= 60 and not _G.GamePlayers[plr].HasRespawned then
--						_G.GamePlayers[plr].NextCheckpoint = _G.GamePlayers[plr].PrevCheckpoint
--						print(_G.GamePlayers[plr].IMCounter)
--						print(plr.Name, math.abs((_G.GamePlayers[plr].LastPosition - plr.Character.Torso.Position).magnitude))
--						_G.GamePlayers[plr].IMCounter = _G.GamePlayers[plr].IMCounter + 1
--						if _G.GamePlayers[plr].IMCounter >= 3 then
--							ModeratePlayer(plr, "Illegal movement detected too many times")
--						end
--						RespawnPlayer(plr, true)
--					end
					_G.GamePlayers[plr].HasRespawned = false
					_G.GamePlayers[plr].LastPosition = plr.Character.Torso.Position
					_G.GamePlayers[plr].PrevCheckpoint = _G.GamePlayers[plr].NextCheckpoint
				end
			end)
		end
	end)
	GivePlayerStats()
	PlayerHasStats = true
	DoMapIntro()
	Countdown(Cars)
end

local function AddParts(Model, Parent)
	Iteration = Iteration + 1
	if Iteration == 75 then
		Iteration = 0
		wait()
	end
	if Model:IsA("Model") or Model:IsA("Folder") then
		local Category = Instance.new(Model.ClassName)
		Category.Name = Model.Name
		Category.Parent = Parent
		for i, v in pairs(Model:GetChildren()) do
			AddParts(v, Category)
		end
	else
		Model:Clone().Parent = Parent
	end
end

local function PrepareMap(ChosenTrack)
--	Map = ChosenTrack:Clone()
--	Map.Parent = workspace
	CurrentPlayers = game.Players:GetPlayers()
	CanJoin = false
	PlayersNeeded = DictLen(_G.GamePlayers)
	local NewMap = Instance.new("Model")
	NewMap.Name = ChosenTrack.Name
	NewMap.Parent = workspace
	_G.Map = NewMap
	--ChosenTrack.Track:Clone().Parent = Map
	for i, v in pairs(ChosenTrack:GetChildren()) do
		if v.Name ~= "StartPoint" then
			AddParts(v, _G.Map)
		end
	end
	ChosenTrack.StartPoint:Clone().Parent = _G.Map
	GetCars()
end

local function HasVoted(Player, Possible)
	for i, v in pairs(Possible) do
		if v[1] == Player then
			return true
		end
	end
	return false
end

local function AttemptStart()
	if Choosing and #PossibleTracks == #game.Players:GetPlayers() then
		Choosing = false
		
		local ChosenInfo = PossibleTracks[math.random(#PossibleTracks)]
		ChosenTrack = ChosenInfo[2]
		Repl.TrackChosen:FireAllClients(ChosenTrack, math.random(6, 10) / 100)
		PlayersChosen = {}
		PrepareMap(Storage.Tracks[ChosenTrack])
	end
end

local function ChoosingCourse()
	Choosing = true
	wait(25)
	if Choosing then
		if #PossibleTracks ~= #game.Players:GetPlayers() then
			for i, v in pairs(game.Players:GetPlayers()) do
				print(v, PossibleTracks, HasVoted(v, PossibleTracks))
				if not HasVoted(v, PossibleTracks) then
					local Tracks = Storage.Tracks:GetChildren()
					local Track = Tracks[math.random(#Tracks)].Name
					table.insert(PossibleTracks, {v, Track})
					Repl.AddVote:FireAllClients(v, Track)
				end
			end
		end
		for i, v in pairs(PossibleTracks) do
			print(v[1], v[2])
		end
		if #PossibleTracks == 0 then
			ChosenTrack = Storage.Tracks:GetChildren()[math.random(#Storage.Tracks:GetChildren())].Name
		else
			ChosenTrack = PossibleTracks[math.random(#PossibleTracks)][2]
		end	
		PlayersChosen = {}
		Choosing = false
		Repl.TrackChosen:FireAllClients(ChosenTrack, math.random(6, 10) / 100)
		PrepareMap(Storage.Tracks[ChosenTrack]:Clone())
	end
end

local function PreVoteCountdown()
	EndingGame = false
	AccessPreVote = PreVoteCountdown
	CountdownValue = 15
	for i = 14, 0, -1 do
		print("Countdown: ", DoingCountdown)
		if DoingCountdown and game.Players.NumPlayers > 1 then
			_G.GamePlayers = {}
			wait(1)
			CountdownValue = i
		else
			CountdownValue = nil
			DoingCountdown = false
			break
		end
	end
	if DoingCountdown and CountdownValue then
		wait(5)
		DoingCountdown = false
		Repl.ChooseCourse:FireAllClients()
		GettingPlayers = false
		ChoosingCourse()
	elseif NeedsRestart then
		NeedsRestart = false
	end
end

local function JoinGame(Player)
	if not DoingCountdown and not Choosing then
		if game.Players.NumPlayers <= 1 then
			TryToEndGame()
		elseif not EndingGame and not CanJoin then
			print("aight im gonna watch the game")
			--print(Repl.GetCamera:InvokeClient(Player))
			--.CameraSubject = workspace.SpectateCam
			local CarsToSend = _G.PlayerCars
			Repl.WatchGame:FireClient(Player, CarsToSend, _G.Map)
			if not CarsToSend then
				repeat wait(1) until _G.PlayerCars
				Repl.UpdateCars:FireClient(Player, _G.PlayerCars)
			end
		end
	else
		print("kk gonna wait instead")
		Repl.WaitForVote:FireClient(Player)
	end
end

game.Players.PlayerAdded:Connect(function(Player)
	_G.PlayerData[Player.Name] = DataStore:GetDataStore("v2PLR_" .. Player.UserId)
	local Banned = _G.PlayerData[Player.Name]:GetAsync("Banned")
	if Banned then
		if typeof(Banned) == "table" then
			Player:Kick("You are banned from accessing standard multiplayer servers for reason: " .. Banned[2])
		else
			Player:Kick("You are banned from accessing standard multiplayer servers.")
		end
	end
	local Players = {}
	for i, v in pairs(game.Players:GetPlayers()) do
		table.insert(Players, {v, DataStore:GetDataStore("v2PLR_" .. v.UserId):GetAsync("HasVIP")})
	end
	if not _G.PlayerData[Player.Name]:GetAsync("Accessories") then
		_G.PlayerData[Player.Name]:SetAsync(
			"Accessories",
			{
				Unlocked = {},
				Equipped = {}
			}
		)
	end
	
	Repl.SetControls:FireClient(Player, _G.PlayerData[Player.Name]:GetAsync("MobileControlType"))
	
	repeat wait() until Player.Character
	wait(2)
	
	Repl.AddPlayer:FireAllClients(Players, Player, _G.PlayerData[Player.Name]:GetAsync("CoinUpgrade"))
	if game.Players.NumPlayers >= 2 and not CountdownValue and not DoingCountdown and GettingPlayers then
		DoingCountdown = true
		PreVoteCountdown()
	elseif GameInProgress or Choosing or not CanJoin then
		JoinGame(Player)
	end
end)

game.Players.PlayerRemoving:Connect(function(Player)
	_G.PlayerData[Player.Name] = nil
	local Players = {}
	for i, v in pairs(game.Players:GetPlayers()) do
		if v ~= Player then
			table.insert(Players, {v, DataStore:GetDataStore("v2PLR_" .. v.UserId):GetAsync("HasVIP")})
		end
	end
	if #Players < 2 and DoingCountdown then
		CountdownValue = nil
		DoingCountdown = false
	end
	if GameInProgress then
		pcall(function()
			_G.PlayerCars[Player.Name]:Destroy()
			_G.PlayerCars[Player.Name] = nil
			_G.GamePlayers[Player] = nil
			_G.PlayerData[Player.Name] = nil
		end)
		if game.Players.NumPlayers == 0 or DictLen(_G.GamePlayers) == 0 then
			TryToEndGame()
		end
	end
	for i, v in pairs(CurrentPlayers) do
		if v == Player then
			table.remove(CurrentPlayers, i)
			break
		end
	end
	Repl.RemovePlayer:FireAllClients(Players, Player)
end)

Repl.GiveChosenCourse.OnServerEvent:Connect(function(Player, TrackName)
	if not PlayersChosen[Player] then
		if game.ServerStorage.Tracks:FindFirstChild(TrackName) then
			table.insert(PossibleTracks, {Player, TrackName})
			PlayersChosen[Player] = true
			Repl.AddVote:FireAllClients(Player, TrackName)
			AttemptStart()
--		elseif TrackName then
--			ModeratePlayer(Player) (unstable unstable unstable)
		end
	end
end)

Repl.ItemUsed.OnServerEvent:Connect(ItemUsed)

Repl.SendMessage.OnServerEvent:Connect(ProcessMessage)

function Repl.GetTimeLeft.OnServerInvoke() return CountdownValue end
function Repl.DoingCountdown.OnServerInvoke() return DoingCountdown end
script.GetFirstPlace.OnInvoke = function() return GetPlayerFromPlacement(1) end