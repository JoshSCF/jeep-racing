--local DataStore = game:GetService("DataStoreService")
local DataStore = require(script.DataStore)
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local MarketplaceService = game:GetService("MarketplaceService")
local Repl = game.ReplicatedStorage

local FreeItems = require(script.FreeItems)
local FlagData = require(script.FlagData)
local Accessory = require(script.Accessory)
local FlagPrices = require(script.FlagPrices)
local CoinCosts = require(script.CoinCost)
local NotBanned = require(script.BanScript)

local NewData = false
local CanUpdate = false

local Flag = workspace.Car.Flag

local PlrObj

local function AddData(PlayerData)
	PlayerData:SetAsync("HasPlayed", true)
	PlayerData:SetAsync("MultiXP", 2000)
end

local AccessoryDS = {}

local function AddAccessories(Player, Car)
	if AccessoryDS then
		for i, v in pairs({"Flag", "Colour", "Skin", "Accessorie"}) do
			if AccessoryDS.Equipped[v] then
				--Accessory["Add" .. v](AccessoryDS.Equipped[v], Car)
				print("yea adding")
				Repl.UpdateItem:FireAllClients(v, AccessoryDS.Equipped[v])
			end
		end
		if AccessoryDS.Equipped.NumberPlate then
			Accessory.ApplyPlate(AccessoryDS.Equipped.NumberPlate, Car)
			Repl.UpdatePlate:FireAllClients(AccessoryDS.Equipped.NumberPlate)
		end
	end
end

local function CheckExists(PlayerData, Value)
	local Flags = AccessoryDS.Unlocked.Flags
	if Flags then
		for i, v in pairs(Flags) do
			if v == Value then
				return true
			end
		end
	end
	return false
end

local function SetupSurroundings(Player)
	AddAccessories(Player, workspace.Car)
end

local function FlagUnlocked(Accessories, Flag, Type)
	print(Type)
	for i, v in pairs(Accessories.Unlocked[Type]) do
		if v == Flag then
			print("yeet")
			return true
		end
	end
end

Repl.BuyPlate.OnServerEvent:Connect(function(Player, Text)
	local PlayerData = DataStore:GetDataStore("v2PLR_" .. Player.UserId)
	local Result = TextService:FilterStringAsync(Text, Player.UserId)
	local CoinCount = PlayerData:GetAsync("Coins")
	
	if CoinCount >= 49 then
		local Filter = Result:GetNonChatStringForBroadcastAsync()
		if Filter:find("#") then
			Repl.FilteredPlate:FireAllClients(false, "Unfortunately, Roblox have censored this plate!")
		else
			AccessoryDS.Unlocked.NumberPlate = true
			AccessoryDS.Equipped.NumberPlate = Filter
			PlayerData:SetAsync("Coins", CoinCount - 49)
			PlayerData:SetAsync("Accessories", AccessoryDS)
			Repl.FilteredPlate:FireAllClients(true)
		end
	else
		Repl.FilteredPlate:FireAllClients(false, "Unfortunately, you need " .. 49 - CoinCount .. " more coins to buy this!")
	end
end)

Repl.BuyItem.OnServerEvent:Connect(function(Player, Type, Name)
	print(Type, Name)
	if FlagPrices[Type][Name] and AccessoryDS ~= {} then
		local PlayerData = DataStore:GetDataStore("v2PLR_" .. Player.UserId)
		local CoinCount = PlayerData:GetAsync("Coins")
		
		if CoinCount >= FlagPrices[Type][Name] then
			print(FlagPrices[Type][Name])
			PlayerData:SetAsync("Coins", CoinCount - FlagPrices[Type][Name])
			if AccessoryDS.Unlocked[Type .. "s"] then
				table.insert(AccessoryDS.Unlocked[Type .. "s"], Name)
			else
				AccessoryDS.Unlocked[Type .. "s"] = {Name}
			end
			PlayerData:SetAsync("Accessories", AccessoryDS)
			print("UPDATED")
			Repl.ItemPurchased:FireAllClients(Type .. "s", Name, true)
		else
			print("not enough >:(")
			Repl.ItemPurchased:FireAllClients(Type .. "s", Name, false)
		end
	end
end)

Repl.EquipItem.OnServerEvent:Connect(function(Player, ItemType, Name)
	print(ItemType, Name)
	if AccessoryDS.Equipped[ItemType] == Name then
		--Accessory["Remove" .. ItemType](workspace.Car)
		AccessoryDS.Equipped[ItemType] = nil
	elseif FlagUnlocked(AccessoryDS, Name, ItemType.."s") then
		--Accessory["Add" .. ItemType](Name, workspace.Car)
		AccessoryDS.Equipped[ItemType] = Name
	end
end)

--Repl.PurchaseCoins.OnServerEvent:Connect(function(Player, Amount)
----	local ID = CoinCosts[Amount]
----	if ID then
----		
----	end
--end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(Player, AssetID, IsPurchased)
	print(IsPurchased)
end)

MarketplaceService.ProcessReceipt = function(ReceiptInfo)
	local Player = game.Players:GetPlayerByUserId(ReceiptInfo.PlayerId)
	print("processing")
	if (not Player) or ReceiptInfo.CurrencySpent == 0 then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	local PlayerData = DataStore:GetDataStore("v2PLR_" .. Player.UserId)
	local NewAmount = PlayerData:GetAsync("Coins") + CoinCosts[tostring(ReceiptInfo.ProductId)]
	
	PlayerData:SetAsync("Coins", NewAmount)
	
	Repl.AddCoins:FireClient(Player, NewAmount)
	
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

local function SetupData(Player, PlayerData)
	local UnlockedItems = {}
	NewData = true
	if FreeItems[Player.Name] then
		UnlockedItems = {
			Flags = {
				FreeItems[Player.Name]
			}
		}
		Repl.DisplayFlag:FireAllClients(
			FlagData[FreeItems[Player.Name]],
			"Share the code \"" .. string.upper(FreeItems[Player.Name]) .. "\" with your fans and they can unlock this flag too!"
		)
	end
	PlayerData:SetAsync(
		"Accessories",
		{
			Unlocked = UnlockedItems,
			Equipped = {}
		}		
	)
end

game.Players.PlayerAdded:Connect(function(Player)
	if NotBanned(Player) then
	PlrObj = Player
	
	spawn(function()
		repeat wait() until Player.Character
		workspace.Car.DriveSeat:Sit(Player.Character.Humanoid)
	end)
	
	local PlayerData = DataStore:GetDataStore("v2PLR_" .. Player.UserId)
	
	if not PlayerData:GetAsync("Coins") then
		PlayerData:SetAsync("Coins", 0)
	end
	
	if not PlayerData:GetAsync("HasPlayed") then
		--Repl.SendNotification:FireAllClients()
		AddData(PlayerData)
	end
	local Accessories = PlayerData:GetAsync("Accessories")
	if (not Accessories) then
		SetupData(Player, PlayerData)
	elseif not Accessories.Equipped then
		SetupData(Player, PlayerData)
	end
	
	AccessoryDS = PlayerData:GetAsync("Accessories")
	SetupSurroundings(Player)
	print("set")	
	CanUpdate = true
	Repl.UnlockCurrent:FireAllClients(AccessoryDS.Unlocked, AccessoryDS.Equipped, PlayerData:GetAsync("Coins"))
	
	if not CheckExists(PlayerData, "ScriptersCF") then
		local Groups = HttpService:JSONDecode(HttpService:GetAsync("https://api.rprxy.xyz/users/" .. Player.UserId .. "/groups"))
		for i, v in pairs(Groups) do
			if v.Name == "ScriptersCF" then
				if AccessoryDS.Unlocked.Flags then
					table.insert(AccessoryDS.Unlocked.Flags, "ScriptersCF")
				else
					AccessoryDS.Unlocked.Flags = {"ScriptersCF"}
				end
				Repl.DisplayFlag:FireAllClients(
					FlagData.ScriptersCF,
					"Your reward for being a member of the ScriptersCF group on Roblox!"
				)
				return
			end 
		end
	end
	end
end)

game.Players.PlayerRemoving:Connect(function(Player)
	local PlayerData = DataStore:GetDataStore("v2PLR_" .. Player.UserId)
	if AccessoryDS ~= {} and AccessoryDS and CanUpdate then
		--PlayerData:SetAsync("TestAccessories", AccessoryDS)
		PlayerData:SetAsync("Accessories", AccessoryDS)
	end
	wait()
	AccessoryDS = {}
end)

game:BindToClose(function()
	DataStore:GetDataStore("Test"):SetAsync("Testing", true)
end)