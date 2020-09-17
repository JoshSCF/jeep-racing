local CreditInfo = require(script.Credits)
local CameraData = require(script.CameraData)
local Accessory = require(script.Accessory)
local CoinCosts = require(script.CoinCost)
local Localise = require(script.Localise)

local Teleport = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local Frame = script.Parent
local Buttons = Frame._Buttons
local LoadingFrame = Frame.Parent.Loading
local Repl = game.ReplicatedStorage
--local Welcome = Frame.Parent.WelcomeFrame
local Unlocked = Frame.Parent.UnlockedFrame
local CreditButton = Frame.Parent.CreditButton
local CreditFrame = Frame.Parent.CreditFrame

local Store = Frame.Parent.Parent.Store

local Profile = Frame.Parent.Parent.Profile
local Pages = Profile.MainFrame

local NumberPlate = Pages.NumberPlate.NewPlate
local Flags = Pages.Flags
local FlagFolders = Flags.Folders
local Colours = Pages.Colours.AllColours
local Skins = Pages.Skins.AllSkins
local Accessories = Pages.Accessories.AllAccs

local PurchasableFlags = {}
local CurrentOutfit = {}

local CanClick = true
local CanBuyCoins = true
local Loading = false
local IsBuying = false
local MouseEntered = false

local function LoadingScreen()
	Frame:TweenPosition(UDim2.new(1, 0, 0, 0))
	wait(1)
	for i = 1, 0, -0.05 do
		LoadingFrame.TextTransparency = i
		wait()
	end
end

local function GenerateCredits()
	CreditFrame.List.Text = CreditFrame.List.Text .. "\n"
	for i, v in pairs(CreditInfo) do
		CreditFrame.List.Text = CreditFrame.List.Text .. "\n"
		CreditFrame.List.Text = CreditFrame.List.Text .. v.Title .. "\n"
		for x, y in pairs(v.List) do
			CreditFrame.List.Text = CreditFrame.List.Text .. y .. "\n"
		end
	end
end

local function PurchaseItem(BuyPlate, Type, Arg, Arg2)
	local Coins = tonumber(Profile.Coins.Value.Text)
	local Price = tonumber(BuyPlate.Parent.Price.Value.Text)
	if BuyPlate.Text == "Buy" and not IsBuying and Coins >= Price then
		IsBuying = true
		BuyPlate.Text = ""
		BuyPlate.Style = "RobloxRoundButton"
		BuyPlate.Load.Visible = true
		Loading = true
		local Rot = 0
		Repl[Arg2 or "BuyItem"]:FireServer(Type, Arg)
		while wait() and Loading do
			BuyPlate.Load.Rotation = Rot
			Rot = Rot + 7.5
		end
		IsBuying = false
	elseif Coins < Price then
		Store:TweenPosition(UDim2.new(0, 16, 0, 16))
		CanClick = false
	end
end

NumberPlate.Changed:Connect(function()
	if #NumberPlate.Text > 8 then
		NumberPlate.Text = NumberPlate.Text:sub(1, 8)
	end
	if NumberPlate.Text:match("%W") then
		NumberPlate.Text = NumberPlate.Text:gsub('%W','')
	end
	NumberPlate.Text = NumberPlate.Text:upper()
	workspace.Car.NumberPlate.Gui.Value.Text = NumberPlate.Text
end)

Buttons.Multiplayer.MouseButton1Click:Connect(function()
	if CanClick and not Unlocked.Visible then
		CanClick = false
		LoadingScreen()
		while wait(0.3) do
			pcall(function()
				Teleport:Teleport(1450793201)
			end)
		end
	end
end)

Buttons.TimeTrials.MouseButton1Click:Connect(function()
	if CanClick and not Unlocked.Visible then
		CanClick = false
		LoadingScreen()
		while wait(0.3) do
			pcall(function()
				Teleport:Teleport(1450912602)
			end)
		end
	end
end)

Buttons._Profile.MouseButton1Click:Connect(function()
	if CanClick and not Unlocked.Visible then
		CanClick = false
		Frame:TweenPosition(UDim2.new(1, 0, 0, 0))
		CreditButton.Visible = false 
		for i = 0, 1.05, 0.05 do
			Frame.Parent.ImageTransparency = i
			wait()
		end
		Frame.Parent.Parent.Profile:TweenPosition(UDim2.new(0, 0, 0, -36))
		Frame.Parent.Credit.Visible = false
		CanClick = true
	end
end)

--Repl.SendNotification.OnClientEvent:Connect(function()
--	Welcome.Visible = true
--	CanClick = false
--end)
--
--Welcome.Frame.OkButton.MouseButton1Click:Connect(function()
--	Welcome.Frame:TweenPosition(UDim2.new(0.5, -200, 1, 0))
--	wait(1)
--	for i = 0.6, 1, 0.05 do
--		Welcome.BackgroundTransparency = i
--		wait()
--	end
--	CanClick = true
--end)

local function GetObject(ItemType, Object)
	for i, v in pairs(Profile.MainFrame[ItemType]:GetDescendants()) do
		if v.Name == Object then
			return v
		end
	end
end

Repl.UpdatePlate.OnClientEvent:Connect(function(Plate)
	NumberPlate.Text = Plate
end)

Repl.ItemPurchased.OnClientEvent:Connect(function(ItemType, Name, Success)
	Loading = false
	local Object = GetObject(ItemType, Name)
	if Success then
		Object.BuyButton.Visible = false
		Object.Price.Visible = false
		Object.Notice.Visible = false
		Object.EquipButton.Visible = true
		local Coins = tonumber(Profile.Coins.Value.Text)
		local Cost = tonumber(Object.Price.Value.Text)
		for i = Coins, Coins - Cost, -math.ceil((Cost) / 15) do 
			Profile.Coins.Value.Text = i
			wait()
		end
		Profile.Coins.Value.Text = Coins - Cost
	end
end)

Repl.UnlockCurrent.OnClientEvent:Connect(function(Unlocked, Equipped, Coins)
	Profile.Coins.Value.Text = Coins
	for x, y in pairs({"Flags", "Colours", "Skins", "Accessories"}) do
		if Unlocked[y] then
			for i, v in pairs(Unlocked[y]) do
				local Object = GetObject(y, v)
				Object.BuyButton.Visible = false
				Object.Price.Visible = false
				Object.Notice.Visible = false
				Object.EquipButton.Visible = true
				Object.Visible = true
--				if Equipped[y] == Object.Name then
--					Object.EquipButton.Text = "Take off"
--				end
			end
		end
	end
end)

CreditButton.MouseButton1Click:Connect(function()
	if not Unlocked.Visible then
		CreditButton.Visible = false
		for i, v in pairs(Buttons:GetChildren()) do
			pcall(function()
				v.Visible = false
			end)
		end
		for i = 1, -0.05, -0.05 do
			CreditFrame.BackgroundTransparency = i
			wait()
		end
		CreditFrame.List:TweenPosition(UDim2.new(0.1, 0, -1, 0), "Out", "Linear", 22)
		wait(22)
		CreditFrame.List.Position = UDim2.new(0.1, 0, 1, 0)
		for i = 0, 1, 0.05 do
			CreditFrame.BackgroundTransparency = i
			wait()
		end
		for i, v in pairs(Buttons:GetChildren()) do
			pcall(function()
				v.Visible = true
			end)
		end
		CreditButton.Visible = true
	end
end)

Unlocked.OK_Button.MouseButton1Click:Connect(function()
	Unlocked.Visible = false
end)

Repl.DisplayFlag.OnClientEvent:Connect(function(Flag, Code)
	Unlocked.FlagImage.RotatedFlag.FlagImage.Image = Flag
	Unlocked._BottomText.Text = Code
	Unlocked.Visible = true
end)

GenerateCredits()

local BuyPlate = Pages.NumberPlate.BuyButton

BuyPlate.MouseButton1Click:Connect(function()
	PurchaseItem(BuyPlate, BuyPlate.Parent.NewPlate.Text, nil, "BuyPlate")
end)

Repl.FilteredPlate.OnClientEvent:Connect(function(PlatePurchased, Error)
	Loading = false
	BuyPlate.Text = "Buy"
	BuyPlate.Style = "RobloxRoundDropdownButton"
	BuyPlate.Load.Visible = false
	if PlatePurchased then
		BuyPlate.Parent.Error.Text = "Success!"
		BuyPlate.Parent.Error.TextColor3 = Color3.new(0, 1, 0)
		local Coins = tonumber(Profile.Coins.Value.Text)
		local Cost = 49
		for i = Coins, Coins - Cost, -math.ceil((Cost) / 15) do 
			Profile.Coins.Value.Text = i
			wait()
		end
		Profile.Coins.Value.Text = Coins - Cost
	else
		BuyPlate.Parent.Error.Text = Error
		BuyPlate.Parent.Error.TextColor3 = Color3.fromRGB(255, 75, 75)
		CanClick = false
		if not Error:find("censor") then
			Store:TweenPosition(UDim2.new(0, 16, 0, 16))
		end
	end
end)

Repl.AddCoins.OnClientEvent:Connect(function(NewAmount)
	CanBuyCoins = false
	for i, v in pairs(Store.Items:GetChildren()) do
		if v:IsA("ImageButton") then
			v.BuyButton.Style = "RobloxRoundButton"
		end
	end
	
	local Coins = tonumber(Profile.Coins.Value.Text)
	
	for i = Coins, NewAmount, math.ceil((NewAmount - Coins) / 15) do 
		Profile.Coins.Value.Text = i
		wait()
	end
	
	print(NewAmount)
	Profile.Coins.Value.Text = NewAmount
	wait(6)
	CanBuyCoins = true
	
	for i, v in pairs(Store.Items:GetChildren()) do
		if v:IsA("ImageButton") then
			v.BuyButton.Style = "RobloxRoundDropdownButton"
		end
	end
end)

repeat wait() print("waiting") until workspace.CurrentCamera

local Cam = workspace.CurrentCamera

Cam.CameraSubject = workspace.Car
Cam.CameraType = Enum.CameraType.Scriptable
Cam.CoordinateFrame = CFrame.new(
	Vector3.new(73, 8.116, -83.64),
	Vector3.new(workspace.Car.PrimaryPart.Position) + Vector3.new(80, 0, 0)
)
Cam.Focus = workspace.Car:GetPrimaryPartCFrame()

Profile.Categories.BackButton.MouseButton1Click:Connect(function()
	CanClick = false
	Frame.Parent.Parent.Profile:TweenPosition(UDim2.new(0, 0, 1, 0))
	for i = 1.05, -0.05, -0.05 do
		Frame.Parent.ImageTransparency = i
		wait()
	end
	Frame:TweenPosition(UDim2.new(0, 0, 0, 0))
	Frame.Parent.Credit.Visible = true
	CanClick = true
end)

for i, v in pairs(Profile.Categories:GetChildren()) do
	if v.Name ~= "BackButton" then
	v.MouseButton1Click:Connect(function()
		for x, y in pairs(Pages:GetChildren()) do
			if y.Visible then
				if y.Name == v.Name then
					return
				end
				y.Visible = false
			end
		end
		for x, y in pairs({"Colour", "Skin", "Flag", "Accessorie"}) do
			if CurrentOutfit[y] then
				Accessory["Add" .. y](CurrentOutfit[y], workspace.Car)
			else
				Accessory["Remove" .. y](workspace.Car)
			end
		end
		Pages[v.Name].Visible = true
		Cam:Interpolate(
			CameraData[v.Name][1],
			CameraData[v.Name][2],
			2
		)
	end)
	end
end

for i, v in pairs(FlagFolders:GetChildren()) do
	if v:IsA("ImageButton") then
		v.MouseButton1Click:Connect(function()
			Flags.BackButton.Visible = true
			Flags[v.Name].Visible = true
			FlagFolders.Visible = false
		end)
	end
end

local FlagTypes = {"AnimatedFlags", "GeneralFlags", "CountryFlags", "YouTubeFlags"}

Flags.BackButton.MouseButton1Click:Connect(function()
	for i, v in pairs(FlagTypes) do
		Flags[v].Visible = false
	end
	FlagFolders.Visible = true
	Flags.BackButton.Visible = false
end)

Store.ExitButton.MouseButton1Click:Connect(function()
	CanClick = true
	Store:TweenPosition(UDim2.new(1, 0, 0, 16))
end)

Profile.Coins.BuyMore.MouseButton1Click:Connect(function()
	CanClick = false
	Store:TweenPosition(UDim2.new(0, 16, 0, 16))
end)

local Updates = {
	Update = function(Folder)
		for i, v in pairs(Folder:GetChildren()) do
			if v:IsA("ImageButton") then
				if v.EquipButton.Text == "Take off" then
					v.EquipButton.Text = "Add"
				end
			end
		end
	end,
	DisplayTakeOff = function(Folder, ItemName)
		if Folder:FindFirstChild(ItemName) then
			Folder[ItemName].EquipButton.Text = "Take off"
		end
	end
}

local FindUpdate = {
	["Flag"] = function(UpdateType, Arg)
		for x, y in pairs(FlagTypes) do
			print(Flags[y], Arg, UpdateType)
			Updates[UpdateType](Flags[y], Arg)
		end
	end,
	["Colour"] = function(UpdateType, Arg)
		Updates[UpdateType](Colours, Arg)
	end,
	["Skin"] = function(UpdateType, Arg)
		Updates[UpdateType](Skins, Arg)
	end,
	["Accessorie"] = function(UpdateType, Arg)
		Updates[UpdateType](Accessories, Arg)
	end
}

local function BuyItem(Item, Type)
	if Item:IsA("ImageButton") then
		
		Item.BuyButton.MouseButton1Click:Connect(function()
			if CanClick then
				PurchaseItem(Item.BuyButton, Type, Item.Name)
			end
		end)
		
		Item.EquipButton.MouseButton1Click:Connect(function()
			if CanClick then
				Repl.EquipItem:FireServer(Type, Item.Name)
				if Item.EquipButton.Text == "Add" then
					FindUpdate[Type]("Update")
					Item.EquipButton.Text = "Take off"
					CurrentOutfit[Type] = Item.Name
					Accessory["Add" .. Type](Item.Name, workspace.Car)
				else
					Item.EquipButton.Text = "Add"
					CurrentOutfit[Type] = nil
					Accessory["Remove" .. Type](workspace.Car)
				end
			end
		end)
		
		Item.MouseEnter:Connect(function()
			if CanClick then
				Accessory["Add" .. Type](Item.Name, workspace.Car)
			end
		end)
--		
--		Item.MouseLeave:Connect(function()
--			if CurrentOutfit[Type] then
--				print(CurrentOutfit[Type])
--				Accessory["Add" .. Type](CurrentOutfit[Type], workspace.Car)
--			else
--				print("no outfit")
--				Accessory["Remove" .. Type](workspace.Car)
--			end
--		end)
		
	end
end

for x, y in pairs(FlagTypes) do
	Flags[y].CanvasSize = UDim2.new(0, 0, 0, Flags[y].UIGridLayout.AbsoluteContentSize.Y)
	for i, v in pairs(Flags[y]:GetChildren()) do
		BuyItem(v, "Flag")
	end
end

Colours.CanvasSize = UDim2.new(0, 0, 0, Colours.UIGridLayout.AbsoluteContentSize.Y)
for i, v in pairs(Colours:GetChildren()) do
	BuyItem(v, "Colour")
end

for i, v in pairs(Skins:GetChildren()) do
	BuyItem(v, "Skin")
end

for i, v in pairs(Accessories:GetChildren()) do
	BuyItem(v, "Accessorie")
end

for i, v in pairs(Store.Items:GetChildren()) do
	if v:IsA("ImageButton") then
		v.BuyButton.MouseButton1Click:Connect(function()
			if CanBuyCoins then
				--CanBuyCoins = false
				MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, CoinCosts[v.Name:sub(3)])
				--Repl.PurchaseCoins:FireServer(v.Name:sub(2))
			end
		end)
	end
end

Repl.UpdateItem.OnClientEvent:Connect(function(Type, Name)
	Accessory["Add" .. Type](Name, workspace.Car)
	FindUpdate[Type]("DisplayTakeOff", Name)
	CurrentOutfit[Type] = Name
end)

workspace.Car.DriveSeat.Changed:Connect(function(Property)
	if Property == "Occupant" then
		workspace.Car.DriveSeat:Sit(game.Players.LocalPlayer.Character.Humanoid)
	end
end)

Localise()

--wait() game.Players.LocalPlayer:Kick()
-- Teleport:Teleport(1450793201)