local Placement = script.Parent.Placement.Images
local Countdown = script.Parent.Countdown.Images
local Lap = script.Parent.Lap.Images
local Finish = script.Parent.Finish.Finish
local MainScreen = script.Parent.MainScreen
local MobileControls = script.Parent.Parent.MobileControls
local Items = script.Parent.ItemHolder.Item
local Coins = script.Parent.Coins.CoinCount
local Sounds = script.Parent.Parent.Sounds
local Textures = script.Parent.Parent.Textures
local ChatUI = script.Parent.ChatUI
local ChatButton = script.Parent.Parent.TopPrevention.ChatButton
local BlackScreen = script.Parent.Parent.BlackScreen
local Minimap = script.Parent.Minimap
local CountdownEvent = script.Parent.Parent.Parent:WaitForChild("RaceCountdown")

local MSPlacement = MainScreen.Placement
local Waiting = MainScreen.Waiting
local Courses = MainScreen.Courses
local Controls = MainScreen.Controls
local WaitingForVotes = MainScreen.WaitingForVotes
local LeftButtons = MainScreen.LeftButtons
local Repl = game.ReplicatedStorage
--local VoteTimer = WaitingForVotes.Timer._Timer.Timer.Frame.TimerText
local TrackNameLabel = WaitingForVotes.TrackChosen.Track.Frame.Track.TrackName
local TrackList = WaitingForVotes.Choices._Tracks
local Dragger = MobileControls.Joystick.Dragger
local DragBackdrop = MobileControls.Joystick.DragBackdrop
local AButton = MobileControls.Buttons.RightSide.ForwardButton
local BButton = MobileControls.Buttons.LeftSide.ReverseButton
local Messages = ChatUI.Messages
local MessageBox = ChatUI.TextBoxRegion.MessageBox
local EmojiButton = MessageBox.EmojiButton
local EmojiMenu = ChatUI.EmojiMenu
local LoadItems = Items.Getting:GetChildren()
local SpectateCam = workspace.SpectateCam
local Camera

local MostRecentPoint = Vector3.new(0.25, 0, 0.25, 0)
local EmojiCount = #EmojiMenu.EmojiList:GetChildren() - 1
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local ChatService = game:GetService("Chat")
local GuiService = game:GetService("GuiService")
local SocialService = game:GetService("SocialService")
local Heartbeat = game:GetService("RunService").Heartbeat
local CurrentItem = nil
local CurrentTrack = nil
local OldXPData = nil
local HoldingItem = nil
local Car = nil
local Controller = "PC"

local DoingCountdown = false
local DoingLocalCountdown = false
local GettingPlayers = true
local GameStarted = false
local GameFinished = false
local LocalFinished = false
local CanChoose = true
local Spectating = false
local EmojiEditable = true
local CanChat = false
local GameEnded = true
local HasCoinUpgrade = false
local HoldingDown = true
local Chosen = false

local LocalItemData = require(script.LocalItemData)
local Localise = require(script.Localise)
local TrackScripts = require(script.TrackScripts)

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

local PlayerCars = {}
local CurrentMap = nil
local NextTrack = 0

ContentProvider:PreloadAsync(Placement:GetChildren())
ContentProvider:PreloadAsync(Lap:GetChildren())
ContentProvider:PreloadAsync(LoadItems)
--ContentProvider:PreloadAsync(Textures:GetChildren())
ContentProvider:PreloadAsync(script.LocalItemData:GetChildren())
ContentProvider:PreloadAsync(Sounds:GetChildren())

local function DistBetweenPoints(P1, P2)
	return math.abs(
		math.sqrt(
			(P1.X - P2.X) ^ 2 + (P1.Y - P2.Y) ^ 2
		)
	)
end

local function ChangePlace(Current, New, Folder)
	for i = 0, 180, 45 do
		Current.Rotation = i
		Current.ImageTransparency = i / 180
		Current.Size = UDim2.new(1 - i / 180, 0, 1 - i / 180, 0)
		wait()
	end
	for i = 180, 360, 45 do
		New.Rotation = i
		New.ImageTransparency = 1 - ((i - 180) / 180)
		New.Size = UDim2.new((i - 180) / 180, 0, (i - 180) / 180, 0)
		wait()
	end
	if Folder then
		for i, v in pairs(Folder:GetChildren()) do
			if v ~= New then
				v.ImageTransparency = 1
			end
		end
	end
end

local function ToggleVisibility(Object, WaitBetween)
	local function P2()
		if WaitBetween then
			wait(WaitBetween)
		end
		for x = 0, 1.08, .08 do
			Object.ImageTransparency = x
			Heartbeat:Wait()
		end
	end
	for x = 1, -0.08, -.08 do
		Object.ImageTransparency = x
		Heartbeat:Wait()
	end
	if Object.Name == "GO" then
		spawn(P2)
	else
		P2()
	end
end

local function GetPlayerFrame(i)
	if i < 10 then
		return Waiting.Players["Player" .. i]
	else
		return Waiting.Players["_Player" .. i]
	end
end

local function WaitForVote()
	DoingLocalCountdown = false
	GettingPlayers = false
	Waiting:TweenPosition(UDim2.new(1, 0, 0, 0))
	for i = 1, 0, -0.05 do
		MainScreen.Loading.TextTransparency = i
		wait()
	end
end

local function StartCountdown()
	local TimeLeft = Repl.GetTimeLeft:InvokeServer()
	while not TimeLeft do
		wait(1)
		TimeLeft = Repl.GetTimeLeft:InvokeServer()
	end
	for i = TimeLeft, 0, -1 do
		if DoingCountdown and DoingLocalCountdown then
			Waiting.Countdown.Text = "The voting will begin in " .. i .. " seconds."
			wait(1)
		else
			break
		end
	end
	if Repl.GetTimeLeft:InvokeServer() == 0 then
		WaitForVote()
	end
end

local function StopCountdown()
	Waiting.Countdown.Text = "Waiting for players..."
end

local function AddBadge(PlayerFrame, v)
	if Developers[v[1].Name] then
		PlayerFrame.DevBadge.Visible = true
	elseif Helpers[v[1].Name] then
		PlayerFrame.HelperBadge.Visible = true
	elseif v[2] == true then
		PlayerFrame.VIPBadge.Visible = true
	else
		PlayerFrame.DevBadge.Visible = false
		PlayerFrame.VIPBadge.Visible = false
		PlayerFrame.HelperBadge.Visible = false
	end
end

local function UpdateBoard(Players)
	DoingCountdown = Repl.DoingCountdown:InvokeServer()
	for i, v in pairs(Players) do
		local PlayerFrame = GetPlayerFrame(i)
		AddBadge(PlayerFrame, v)
		PlayerFrame.Frame.Username.Text = v[1].Name
		local ID = v[1].UserId
		if ID < 1 then
			ID = 1
		end
		PlayerFrame.Frame.Character.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. ID .. "&width=420&height=420&format=png"
		PlayerFrame.Frame.Character.Visible = true
		PlayerFrame.Frame.Add.Visible = false
	end
	for i = #Players + 1, 12 do
		local PlayerFrame = GetPlayerFrame(i)
		PlayerFrame.VIPBadge.Visible = false
		PlayerFrame.DevBadge.Visible = false
		PlayerFrame.HelperBadge.Visible = false
		PlayerFrame.Frame.Character.Image = ""
		PlayerFrame.Frame.Character.Visible = false
		PlayerFrame.Frame.Add.Visible = true
		PlayerFrame.Frame.Username.Text = "Invite friends"
	end
	if #Players > 1 and DoingCountdown and not DoingLocalCountdown then
		DoingLocalCountdown = true
		StartCountdown()
	elseif #Players <= 1 and not DoingCountdown and DoingLocalCountdown then
		DoingLocalCountdown = false
		StopCountdown()
	end
end

local function PickedTrack(MyPickedTrack)
	if MyPickedTrack then
		Repl.GiveChosenCourse:FireServer(MyPickedTrack)
	end
	Courses:TweenPosition(UDim2.new(1, 0, 0, 0))
	if CanChoose then
		wait(1)
		WaitingForVotes.Choices:TweenPosition(UDim2.new(0, 0, 0, 0))
	end
end

local function CountdownCourse()
--	for i = 20, 0, -1 do
--		VoteTimer.Text = i
--		wait(1)
--	end
	Chosen = false
	spawn(function()
		while not Chosen do
			for i, v in pairs(WaitingForVotes.Choices._Tracks:GetChildren()) do
				if v:IsA("Frame") then
					v.Frame.Loading.Wheel.Rotation = v.Frame.Loading.Wheel.Rotation + 5
				end
			end
			wait()
		end
	end)
	--wait(20)
	--Chosen = true
--	CanChoose = false
--	Courses:TweenPosition(UDim2.new(1, 0, 0, 0))
--	WaitingForVotes.Choices:TweenPosition(UDim2.new(1, 0, 0, 0))
--	wait(1)
--	WaitingForVotes.TrackChosen:TweenPosition(UDim2.new(0, 0, 0, 0))
end

local function LocalFinish()
	for i = 1, -0.05, -0.05 do
		wait()
		Finish.ImageTransparency = i
	end
	if CanChat then
		ChatButton.Visible = true
	end
	if CurrentTrack then
		Sounds[CurrentTrack]:Stop()
		Sounds[CurrentTrack].PlaybackSpeed = 1
	end
	LocalFinished = true
	Placement.Parent:TweenPosition(UDim2.new(2, 0, 0, 26))
	Lap.Parent:TweenPosition(UDim2.new(-1, 0, 0, 0))
	Coins.Parent:TweenPosition(UDim2.new(-1, 0, 0.15, 0))
	script.Parent.ItemHolder:TweenPosition(UDim2.new(0, 0, -1, 0))
	Minimap:TweenPosition(UDim2.new(2, 0, 0.9, 0))
end

local function TryAddControls()
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		MobileControls.Visible = true
		Minimap.Visible = false
	end
end

local function ResetStuff()
	GameEnded = false
	Chosen = true
	NextTrack = 0
	Lap["2"].ImageTransparency = 1
	Lap["3"].ImageTransparency = 1
	Lap["1"].ImageTransparency = 0
	Countdown["1"].Visible = true
	Countdown["2"].Visible = true
	Countdown["3"].Visible = true
	Finish.ImageTransparency = 1
	for i, v in pairs(MSPlacement.Places:GetChildren()) do
		v.Position = UDim2.new(1.5, 0, v.Position.Y.Scale, 0)
	end
	for i, v in pairs(Placement:GetChildren()) do
		v.ImageTransparency = v.Name == "1" and 0 or 1
		v.Rotation = 0
		v.Size = UDim2.new(1, 0, 1, 0)
	end
	for i, v in pairs(Minimap:GetChildren()) do
		v.Visible = false
	end
	Spectating = false
	workspace.LocalItems:ClearAllChildren()
	--Sounds.Waiting:Play()
	--print"playing1"
end

local function StartLBCountdown()
	for i = 5, 0, -1 do
		MSPlacement.Timer.Timer.TimerText.Text = i
		wait(1)
	end
	MSPlacement:TweenPosition(UDim2.new(1.1, 0, 0, 0))
	for i = 1, 0, -0.05 do
		MainScreen.Loading.TextTransparency = i
		wait()
	end
end

local function GetPlayer(AllPlayers, PlayerName)
	for i, v in pairs(AllPlayers) do
		if v.Name == PlayerName then
			return v
		end
	end
end
--
local function DisplayLeaderboard(AllPlayers, GamePlayers)
	StopCountdown()
	CanChoose = true
	Sounds.Waiting:Play()
	UserInputService.MouseIconEnabled = true
	GameFinished = true
	local LocalPlacement = {}
	for i, v in pairs(GamePlayers) do
		LocalPlacement[v.Place] = i
		if v.Name == game.Players.LocalPlayer.Name then
			ChangePlace(Placement[tostring(v.Place)], Placement["1"])
		end
	end
	for i, v in pairs(LocalPlacement) do
		local Place = MSPlacement.Places["Place" .. i]
		Place.Username.Text = v
		Place.XP_Count.Text = OldXPData[v] > 0 and OldXPData[v] or "????"
		local ID = GetPlayer(AllPlayers, v).UserId
		if ID < 0 then
			ID = 1
		end
		Place.Character.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. ID .. "&width=420&height=420&format=png"
	end	
	for i, v in pairs(LocalPlacement) do
		local Place = MSPlacement.Places["Place" .. i]
		Place:TweenPosition(UDim2.new(
			0,
			0,
			Place.Position.Y.Scale,
			0
		), "Out", "Quad", 0.3)
		wait(0.08)
	end
	StartLBCountdown()
end

local function AttemptGuiFix()
	MainScreen.Size = UDim2.new(1, 0, 1, 37)
	wait()
	MainScreen.Size = UDim2.new(1, 0, 1, 36)
end

local function ConsoleButtonY()
	if GettingPlayers then
		Controls.Controller.Visible = true
		Controls.Visible = true
		Controls.Exit.Button.Visible = false
		Controls.Exit.Controller.Visible = true
	end
end

local function KeyboardE()
	if CurrentItem and CurrentItem ~= "LOAD" then
		local Item = CurrentItem
		Repl.ItemUsed:FireServer(Item)
		Items[Item].ImageTransparency = 1
		HoldingItem = Item
		CurrentItem = nil
		LocalItemData[Item](script.Parent.Parent.Parent.LocalCarScript.Car.Value, game.Players.LocalPlayer)
	end
end

local function ConsoleButtonB()
	if Controls.Visible then
		Controls.Controller.Visible = false
		Controls.Visible = false
		Controls.Exit.Button.Visible = true
		Controls.Exit.Controller.Visible = false
	else
		KeyboardE()
	end
end

local function Drop()
	if LocalItemData.Drop[HoldingItem] and not Controls.Visible then
		Repl.ItemDropped:FireServer(HoldingItem)
		LocalItemData.Drop[HoldingItem](script.Parent.Parent.Parent.LocalCarScript.Car.Value, game.Players.LocalPlayer)
	end
	HoldingItem = nil
end

for i, v in pairs({AButton, BButton}) do
	v.InputBegan:Connect(function()
		v.ImageTransparency = 0.4
	end)
	
	v.InputEnded:Connect(function()
		v.ImageTransparency = 0
	end)
end

Items.ItemClicked.MouseButton1Down:Connect(KeyboardE)
Items.ItemClicked.MouseButton1Up:Connect(Drop)

UserInputService.InputBegan:Connect(function(Input)
	if Input.KeyCode ~= Enum.KeyCode.Unknown then
		if Input.KeyCode == Enum.KeyCode.ButtonY then
			ConsoleButtonY()
		elseif Input.KeyCode == Enum.KeyCode.ButtonB then
			ConsoleButtonB()
		elseif Input.KeyCode == Enum.KeyCode.E then
			KeyboardE()
		elseif Input.KeyCode == Enum.KeyCode.Slash and not MessageBox:IsFocused() and CanChat and ChatButton.Visible then
			ChatUI.Visible = true
			ChatButton.NewMessage.Visible = false
			EmojiMenu.EmojiList.CanvasSize = UDim2.new(0, 0, 0, (EmojiCount / math.floor(EmojiMenu.EmojiList.AbsoluteSize.X / 38)) * 34)
			MessageBox:CaptureFocus()
			wait()
			if MessageBox.Text:sub(1,1) == "/" then
				MessageBox.Text = ""
			elseif MessageBox.Text:sub(#MessageBox.Text) == "/" then
				MessageBox.Text = MessageBox.Text:sub(1, #MessageBox.Text - 1)
			end
		end
	end
end)

Repl.SetControls.OnClientEvent:Connect(function(Type)
	if UserInputService.GyroscopeEnabled then
		if Type then
			if Type == "Joystick" then
				MobileControls.Joystick.Visible = true
				MobileControls.JoystickButtons.Visible = true
			else
				MobileControls.Buttons.Visible = true
			end
		else
			MobileControls.Buttons.Visible = true
		end
	else
		MobileControls.Buttons.Visible = true
	end
end)

UserInputService.InputEnded:Connect(function(Input)
	if Input.KeyCode ~= Enum.KeyCode.Unknown then
		if Input.KeyCode == Enum.KeyCode.E or Input.KeyCode == Enum.KeyCode.ButtonB then
			Drop()
		end
	end
end)

UserInputService.TouchStarted:Connect(function(Touch)
	if Touch.Position.X >= Dragger.AbsolutePosition.X and Touch.Position.X <= Dragger.AbsolutePosition.X + Dragger.AbsoluteSize.X and Touch.Position.Y >= Dragger.AbsolutePosition.Y and Touch.Position.Y <= Dragger.AbsolutePosition.Y + Dragger.AbsoluteSize.Y then
		HoldingDown = Touch
	end
end)

UserInputService.TouchMoved:Connect(function(Touch)
	if HoldingDown == Touch then
		local OrangeCentre = Vector2.new(
			DragBackdrop.AbsoluteSize.X / 2,
			DragBackdrop.AbsoluteSize.Y / 2
		)
		local NewPosition = Vector2.new(
			Touch.Position.X - MobileControls.Joystick.AbsolutePosition.X,
			Touch.Position.Y - MobileControls.Joystick.AbsolutePosition.Y
		)
		Dragger.Position = UDim2.new(0, NewPosition.X, 0, NewPosition.Y)
		local Hypo = (NewPosition - OrangeCentre).magnitude
		local Direction = (NewPosition - OrangeCentre).unit
		if Hypo >= 50 then
			local Excess = Hypo - 50
			OrangeCentre = OrangeCentre + Direction * (Excess)
			DragBackdrop.Position = UDim2.new(
				0,
				OrangeCentre.X,
				0,
				OrangeCentre.Y
			)
		end
	end
end)

UserInputService.TouchEnded:Connect(function(Touch)
	if Touch == HoldingDown then
		HoldingDown = false
		Dragger.Position = UDim2.new(0.5, 0, 0.5, 0)
		DragBackdrop.Position = UDim2.new(0.5, 0, 0.5, 0)
	end
--	AButton.ImageTransparency = 0
--	BButton.ImageTransparency = 0
end)

LeftButtons.Buttons.Controls.Button.MouseButton1Click:Connect(function()
	if GettingPlayers then
		Controls.Visible = true
		if Controller == "Mobile" then
			Controls.Mobile.Visible = true
		else
			Controls.Keyboard.Visible = true
		end
	end
end)

Controls.Exit.Button.MouseButton1Click:Connect(function()
	Controls.Visible = false
	Controls.Keyboard.Visible = false
	Controls.Mobile.Visible = false
end)

--Dragger.MouseButton1Up:Connect(function()
--	Dragger.Position = UDim2.new(0.25, 0, 0.25, 0)
--end)

--Dragger:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
--	local BackCentre = Vector2.new(
--		DragBackdrop.AbsolutePosition.X + DragBackdrop.AbsoluteSize.X / 2,
--		DragBackdrop.AbsolutePosition.Y + DragBackdrop.AbsoluteSize.Y / 2
--	)
--	local DraggerCentre = Vector2.new(
--		Dragger.AbsolutePosition.X + Dragger.AbsoluteSize.X / 2,
--		Dragger.AbsolutePosition.Y + Dragger.AbsoluteSize.Y / 2
--	)
--	--if DistBetweenPoints(DraggerCentre, BackCentre) > (DragBackdrop.AbsoluteSize.X * 0.7) / 2 then
--		--Dragger.Position = MostRecentPoint
--	--end
--	MostRecentPoint = Dragger.Position
--end)

--EmojiButton.MouseEnter:Connect(function()
--	EmojiButton:TweenSizeAndPosition(UDim2.new(0.9, 0, 0.9, 0), UDim2.new(1, -30.5, 0, 1.5), "Out", "Quad", 0.1, true)
--end)
--
--EmojiButton.MouseLeave:Connect(function()
--	EmojiButton:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(1, -32, 0, 0), "Out", "Quad", 0.1, true)
--end)

--EmojiMenu.EmojiList.Changed:Connect(function()
--	if EmojiMenu.EmojiList.CanvasSize ~= UDim2.new(0, 0, 0, (EmojiCount / math.floor(EmojiMenu.EmojiList.AbsoluteSize.X / 38)) * 34) then
--		EmojiMenu.EmojiList.CanvasSize = UDim2.new(0, 0, 0, (EmojiCount / math.floor(EmojiMenu.EmojiList.AbsoluteSize.X / 38)) * 34)
--	end
--end)

EmojiMenu.SearchBox.Changed:Connect(function()
	if EmojiEditable then
		EmojiEditable = false
		EmojiCount = 0
		for i, v in pairs(EmojiMenu.EmojiList:GetChildren()) do
			if v.Name ~= "_UIGridLayout" then
				if v.Name:lower():find(EmojiMenu.SearchBox.Text:lower()) then
					EmojiCount = EmojiCount + 1
					if not v.Visible then
						v.Visible = true
					end
				else
					v.Visible = false
				end
			end
		end
		EmojiMenu.EmojiList.CanvasSize = UDim2.new(0, 0, 0, (EmojiCount / math.floor(EmojiMenu.EmojiList.AbsoluteSize.X / 38)) * 34)
		EmojiEditable = true
	end
end)

MessageBox.FocusLost:Connect(function(EnterPressed)
	if EnterPressed and #MessageBox.Text > 0 then
		Repl.SendMessage:FireServer(MessageBox.Text)
		MessageBox.Text = ""
		--ChatUI.Visible = false
	end
end)

EmojiMenu.SearchBox.FocusLost:Connect(function(EnterPressed)
	if EnterPressed and #EmojiMenu.SearchBox.Text > 0 then
		local Possible = {}
		for i, v in pairs(EmojiMenu.EmojiList:GetChildren()) do
			if v.Name ~= "_UIGridLayout" then
				if v.Visible then
					table.insert(Possible, v.Name)
				end
			end
		end
		if #Possible > 0 then
			table.sort(Possible, function(x, y)
				return x < y
			end)
			MessageBox.Text = MessageBox.Text .. EmojiMenu.EmojiList[Possible[1]].Text
			EmojiMenu.Visible = false
			MessageBox:CaptureFocus()
		end
	end
end)

MessageBox.Changed:Connect(function()
	if utf8.len(MessageBox.Text) > 120 then
		MessageBox.Text = MessageBox.Text:sub(1, 120)
	end
end)

for i, v in pairs(EmojiMenu.EmojiList:GetChildren()) do
	if v.Name ~= "_UIGridLayout" then
		v.MouseButton1Click:Connect(function()
			MessageBox.Text = MessageBox.Text .. v.Text
			EmojiMenu.Visible = false
			MessageBox:CaptureFocus()
		end)
	end
end

EmojiButton.MouseButton1Click:Connect(function()
	if EmojiMenu.Visible then
		EmojiMenu.Visible = false
	else
		EmojiMenu.Visible = true
		EmojiMenu.SearchBox:CaptureFocus()
	end
end)

Repl.DisplayMessage.OnClientEvent:Connect(function(Sender, Message)
	if not ChatUI.Visible then
		ChatButton.NewMessage.Visible = true
	end
	
	Messages.Message1.Content.Text = Messages.Message2.Content.Text
	Messages.Message1.Sender.Text = Messages.Message2.Sender.Text
	Messages.Message2.Content.Text = Messages.Message3.Content.Text
	Messages.Message2.Sender.Text = Messages.Message3.Sender.Text
	Messages.Message3.Content.Text = Messages.Message4.Content.Text
	Messages.Message3.Sender.Text = Messages.Message4.Sender.Text
	Messages.Message4.Content.Text = Messages.Message5.Content.Text
	Messages.Message4.Sender.Text = Messages.Message5.Sender.Text
	Messages.Message5.Content.Text = Messages.Message6.Content.Text
	Messages.Message5.Sender.Text = Messages.Message6.Sender.Text
	Messages.Message6.Content.Text = Messages.Message7.Content.Text
	Messages.Message6.Sender.Text = Messages.Message7.Sender.Text
	
	Messages.Message7.Sender.TextTransparency = 1
	Messages.Message7.Content.TextTransparency = 1
	
	Messages.Message7.Sender.Text = Sender
	Messages.Message7.Content.Text = Message
	
	for i = 1, -0.05, -0.1 do
		Messages.Message7.Sender.TextTransparency = i
		Messages.Message7.Content.TextTransparency = i
		wait()
	end
end)

ChatButton.MouseButton1Click:Connect(function()
	if CanChat then
		ChatUI.Visible = not ChatUI.Visible
		ChatButton.NewMessage.Visible = false
		EmojiMenu.SearchBox.Text = ""
		EmojiMenu.EmojiList.CanvasSize = UDim2.new(0, 0, 0, (EmojiCount / math.floor(EmojiMenu.EmojiList.AbsoluteSize.X / 38)) * 34)
		EmojiMenu.Visible = false
	end
end)

Repl.xpData.OnClientEvent:Connect(function(PlayersXP, PlayersNewXP)
	print(PlayersNewXP)
	OldXPData = PlayersXP
	wait(5.75)
	for i, v in pairs(MSPlacement.Places:GetChildren()) do
		if v.Username.Text then
			local OldXP = PlayersXP[v.Username.Text]
			local NewXP = PlayersNewXP[v.Username.Text]
			spawn(function()
				wait(1)
				pcall(function()
					if OldXP > 0 then
						for i = OldXP, NewXP, math.ceil((NewXP - OldXP) / 15) do
							v.XP_Count.Text = i
							wait()
						end
					else
						NewXP = "????"
					end
				end)
				if NewXP then
					v.XP_Count.Text = NewXP
				end
			end)
		end
	end
end)

Repl.GiveCoins.OnClientEvent:Connect(function() -- moved to localcarscript for optimisation
	Coins.Text = tonumber(Coins.Text) + 1
	Sounds.Coin:Play()
end)

Repl.RestartGame.OnClientEvent:Connect(function(Players)
	GettingPlayers = true
	for i = 0, 1.05, 0.05 do
		MainScreen.Loading.TextTransparency = i
		wait()
	end
	MainScreen.Waiting:TweenPosition(UDim2.new(0, 0, 0, 0))
	UpdateBoard(Players)
	--UpdateBoard(Repl.GetPlayers:InvokeServer())
end)

Repl.PlayerFinished.OnClientEvent:Connect(function(Player, Finishers)
	if Player == game.Players.LocalPlayer.Name then
		LocalFinish()
	end
end)

TrackNameLabel:GetPropertyChangedSignal("Text"):Connect(function()
	if TrackNameLabel.Text ~= "..." then
		wait(2)
		WaitingForVotes.TrackChosen:TweenPosition(UDim2.new(1, 0, 0, 0))
		for i = 1, 0, -0.05 do
			MainScreen.Loading.TextTransparency = i
			wait()
		end
	end
	wait(3)
	MainScreen:TweenPosition(UDim2.new(1.1, 0, 0, -36))
	TrackNameLabel.Text = "..."
	CanChoose = true
	TryAddControls()
	ResetStuff()
end)

local function StartAnimations(Track)
	while Track and Heartbeat:Wait() do
		for i, v in pairs(Track.ItemBoxes:GetChildren()) do
			v.Orientation = v.Orientation + Vector3.new(0, 3, 0)
		end
		for i, v in pairs(Track.Coins:GetChildren()) do
			v.Orientation = v.Orientation + Vector3.new(0, 3, 0)
		end
	end
end

local function TrackSelected(Selector)
	ResetStuff()
	for x = 1, 3 do
		for i = 1, 0.4, -0.1 do
			Selector.BackgroundTransparency = i
			wait()
		end
		for i = 0.5, 1.1, 0.1 do
			Selector.BackgroundTransparency = i
			wait()
		end
	end
	spawn(function()
		for i = 1, 500 do
			wait()
			BlackScreen.Loading.Rotation = BlackScreen.Loading.Rotation + 5
		end
	end)
	local EndScreen = false
	for i = 1, -0.05, -0.05 do
		if EndScreen then return end
		wait()
		BlackScreen.BackgroundTransparency = i
		BlackScreen.Loading.ImageTransparency = i
	end
	local Places = workspace:WaitForChild(CurrentTrack):WaitForChild("StartPoint"):WaitForChild("Places")
--	workspace.CurrentCamera.CFrame = CFrame.new(
--		Places:WaitForChild("Place2").PrimaryPart.Position + Vector3.new(0, 30, 120),
--		Places:WaitForChild("Place5").PrimaryPart.Position
--	)
	if TrackScripts[CurrentTrack] then
		spawn(function()
			TrackScripts[CurrentTrack].Start(workspace[CurrentTrack])
		end)
	end
	spawn(function()
		StartAnimations(workspace[CurrentTrack])
	end)
	Repl.ReadyToRace:FireServer()
	EndScreen = true
	MainScreen.Position = UDim2.new(1.1, 0, 0, -36)
	WaitingForVotes.Choices.Position = UDim2.new(1, 0, 0, 0)
	if BlackScreen.BackgroundTransparency <= 0 then
		for i = 0, 1.05, 0.05 do
			wait()
			BlackScreen.BackgroundTransparency = i
		end
	end
	--TryAddControls()
	--ResetStuff()
end

Repl.StartIntro.OnClientEvent:Connect(function()
	for i = 0, 1.05, 0.05 do
		wait()
		--BlackScreen.BackgroundTransparency = i
		BlackScreen.Loading.ImageTransparency = i
	end
	print("IntroStarting")
	TryAddControls()
end)

Repl.TrackChosen.OnClientEvent:Connect(function(TrackInfo, Increment)
	--TrackNameLabel.Text = TrackName
	Courses:TweenPosition(UDim2.new(1, 0, 0, 0))
	CurrentTrack = TrackInfo
	local Count = 0.05
	while Count <= 0.7 do
		local Found = false
		for i, v in pairs(TrackList:GetChildren()) do
			if v:IsA("Frame") then
				Count = Count + Increment
				if Count <= 0.7 then
					local Selector = v.Frame.TrackImage.Selector
					Selector.BackgroundTransparency = 0.5
					if Found then
						wait(Count)
					else
						Found = true
					end
					Selector.BackgroundTransparency = 1
				else
					break
				end
			end
		end
	end
	for i, v in pairs(TrackList:GetChildren()) do
		if v:IsA("Frame") then
			local Selector = v.Frame.TrackImage.Selector
			print(v.Frame.TrackName.Text, TrackInfo)
			if v.Frame.TrackName.Text == TrackInfo then
				TrackSelected(Selector)
				break
			else
				Selector.BackgroundTransparency = 0.5
				wait(0.7)
				Selector.BackgroundTransparency = 1
			end
		end
	end
end)

Repl.ChooseCourse.OnClientEvent:Connect(function()
	for i, v in pairs(WaitingForVotes.Choices._Tracks:GetChildren()) do
		if v:IsA("Frame") and v.Name ~= "_Template" then
			v:Destroy()
		end
	end
	for i = 1, #game.Players:GetPlayers() do
		local Choice = WaitingForVotes.Choices._Tracks._Template:Clone()
		Choice.Visible = true
		Choice.Name = (i >= 10 and "_Choice" or "Choice") .. i
		Choice.Parent = WaitingForVotes.Choices._Tracks
	end
	for i = 1, 3 do
		Lap[tostring(i)].Size = UDim2.new(1, 0, 1, 0)
		Lap[tostring(i)].Rotation = 0
	end
	for i = 0, 1.05, 0.05 do
		MainScreen.Loading.TextTransparency = i
		wait()
	end
	Courses:TweenPosition(UDim2.new(0, 0, 0, 0))
	for i, v in pairs(Courses._CourseList:GetChildren()) do
		if v:IsA("Frame") then
			local MyPickedTrack = v.Name
			v.Frame.TrackButton.MouseButton1Click:Connect(function()
				if CanChoose then
					PickedTrack(MyPickedTrack)
					CanChoose = false
				end
			end)
		end
	end
	CountdownCourse()
end)

Repl.AddVote.OnClientEvent:Connect(function(Player, TrackName)
	print("adding card")
	NextTrack = NextTrack + 1
	local Card = WaitingForVotes.Choices._Tracks[(NextTrack >= 10 and "_Choice" or "Choice") .. NextTrack]
	Card.Frame.TrackImage.Visible = true
	Card.Frame.Loading.Visible = false
	Card.Frame.TrackName.Text = TrackName
	Card.UserImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Player.UserId .. "&width=420&height=420&format=png"
end)

local function CheckIfSpectating()
	if Spectating then
		for i, v in pairs(Placement:GetChildren()) do
			v.ImageTransparency = v.Name == "1" and 0 or 1
			v.Rotation = 0
			v.Size = UDim2.new(1, 0, 1, 0)
		end
		for i, v in pairs(Minimap:GetChildren()) do
			v.Visible = false
		end
		Lap.Parent.Position = UDim2.new(-1, 0, 0, 0)
		script.Parent.ItemHolder.Position = UDim2.new(0, 0, -1, 0)
		Coins.Parent.Position = UDim2.new(-1, 0, 0.15, 0)
		Minimap.Position = UDim2.new(2, 0, 0.9, 0)
		Placement.Parent.Position = UDim2.new(2, 0, 0, -26)
	end
end

Repl.StartCountdown.OnClientEvent:Connect(function()
	if CurrentTrack and not Spectating then
		spawn(function()
			if BlackScreen.BackgroundTransparency <= 0 then
				for i = 0, 1.05, 0.05 do
					BlackScreen.BackgroundTransparency = i
					wait()
				end
			end
		end)
		CountdownEvent = script.Parent.Parent.Parent:WaitForChild("RaceCountdown")
		ChatButton.Visible = false
		ChatUI.Visible = false
		LocalFinished = false
		--UserInputService.MouseIconEnabled = false CHANGELATER
		Sounds.Waiting:Stop()
		print"stopping"
		Placement.Parent:TweenPosition(UDim2.new(0.65, -10, 0, -26))
		Lap.Parent:TweenPosition(UDim2.new(0, 36, 0, 0))
		script.Parent.ItemHolder:TweenPosition(UDim2.new(0, 0, 0, -20))
		Coins.Parent:TweenPosition(UDim2.new(0, 36, 0.15, 0))
		Minimap:TweenPosition(UDim2.new(0.95, 0, 0.9, 0))
		CountdownEvent:Fire(true)
		for i = 3, 1, -1 do
			if Countdown[tostring(i)].Visible then
				Sounds.MainCountdown:Play()
				ToggleVisibility(Countdown[tostring(i)], 0.7)
				if i == 1 then
					CountdownEvent:Fire(false)
				end
			else
				CheckIfSpectating()
				break
			end
		end
		--Sounds.MainCountdownGo:Play()
		--ToggleVisibility(Countdown.GO, 0.5)
		--Sounds[CurrentTrack]:Play()
	end
	--[[for i = 2, 12 do
		wait(2)
		ChangePlace(Placement[tostring(i - 1)], Placement[tostring(i)])
	end]]
	--Spectating = false
end)

Repl.StartRace.OnClientEvent:Connect(function()
	if CurrentTrack and not Spectating then
		Countdown["1"].Visible = false
		Countdown["2"].Visible = false
		Countdown["3"].Visible = false
		Sounds.MainCountdownGo:Play()
		Countdown["1"].ImageTransparency = 1
		Countdown["2"].ImageTransparency = 1
		Countdown["3"].ImageTransparency = 1
		ToggleVisibility(Countdown.GO, 0.7)
		Countdown["1"].Visible = true
		Countdown["2"].Visible = true
		Countdown["3"].Visible = true
		Sounds[CurrentTrack]:Play()
		Car = script.Parent.Parent.Parent.LocalCarScript.Car.Value
		Car.PrimaryPart.Anchored = false
		CountdownEvent:Fire(false)
	end
end)

Repl.AddPlayer.OnClientEvent:Connect(function(Players, Player, CoinUpgrade)
	HasCoinUpgrade = CoinUpgrade
	if CoinUpgrade and Player == game.Players.LocalPlayer then
		Coins.HasCoinUpgrade.Value = true
	end
	if GettingPlayers then
		spawn(function()
			UpdateBoard(Players)
		end)
	elseif not GameStarted and Player == game.Players.LocalPlayer then
		spawn(PickedTrack)
	end
	if Player == game.Players.LocalPlayer then
		--wait(1)
		--AttemptGuiFix()
		Sounds.Waiting:Play()
		print"playing2"
		for i = 0, 1.05, 0.05 do
			BlackScreen.BackgroundTransparency = i
			BlackScreen.Loading.ImageTransparency = i
			wait()
		end
	end
end)

Repl.RemovePlayer.OnClientEvent:Connect(function(Players, Player)
	if GettingPlayers then
		UpdateBoard(Players)
		--UpdateBoard(Repl.GetPlayers:InvokeServer())
	end
end)

Repl.ChangeLap.OnClientEvent:Connect(function(CurrLap)
	if CurrLap == 2 then
		ChangePlace(Lap[CurrLap - 1], Lap[CurrLap])
	elseif CurrLap == 3 then
		ChangePlace(Lap[CurrLap - 1], Lap[CurrLap])
		Sounds[CurrentTrack]:Stop()
		Sounds[CurrentTrack].PlaybackSpeed = 1.2
		Sounds[CurrentTrack]:Play()
	end
end)

Repl.ChangePlace.OnClientEvent:Connect(function(Previous, New)
	ChangePlace(Placement:WaitForChild(tostring(Previous)), Placement:WaitForChild(tostring(New)), Placement)
--	if Placement.Parent.Position ~= UDim2.new(0.65, -10, 0, -26) and not LocalFinished then
--		Placement.Parent:TweenPosition(UDim2.new(0.65, -10, 0, -26))
--		Lap.Parent:TweenPosition(UDim2.new(0, 36, 0, 0))
--		script.Parent.ItemHolder:TweenPosition(UDim2.new(0, 0, 0, -20))
--		Coins.Parent:TweenPosition(UDim2.new(0, 36, 0.15, 0))
--	end
end)

Repl.GameEnded.OnClientEvent:Connect(function(AllPlayers, GamePlayers)
	NextTrack = 0
	PlayerCars = {}
	GameEnded = true
	if Sounds.Spectating.IsPlaying then
		Sounds.Spectating:Stop()
	end
	if not LocalFinished then
		LocalFinish()
		wait(1.33)
	else
		wait(2)
	end
	MainScreen:TweenPosition(UDim2.new(0, 0, 0, -36))
	Coins.Text = "0"
	Coins.TextColor3 = Color3.fromRGB(252, 181, 0)
	pcall(function()
		Items[CurrentItem].ImageTransparency = 1
	end)
	CurrentItem = nil
	wait(1.5)
	script.Parent.LiveUI.Visible = false
	for i = 0, 1.05, 0.05 do
		MainScreen.Loading.TextTransparency = i
		wait()
	end
	MSPlacement:TweenPosition(UDim2.new(0, 0, 0, 0))
	wait(1)
	DisplayLeaderboard(AllPlayers, GamePlayers)
end)

Repl.GiveCarInformation.OnClientEvent:Connect(function(Cars, Point1, Point2, Map)
	if Controller == "Mobile" then
		return
	end
	--Players = Cars
	CurrentMap = Map
	Minimap:FindFirstChild(Map.Parent.Name).Players:ClearAllChildren()
	Minimap:FindFirstChild(Map.Parent.Name).Visible = true
	for i, v in pairs(Cars) do
		pcall(function()
			local NewPlayer = Minimap:FindFirstChild(Map.Parent.Name).PlayerTemplate:Clone()
			NewPlayer.Name = i
			NewPlayer.Visible = true
			local ID = game.Players[i].UserId
			if ID < 1 then
				ID = 1
			end
			NewPlayer.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. ID .. "&width=420&height=420&format=png"
			if i == game.Players.LocalPlayer.Name then
				NewPlayer.ImageTransparency = 0.1
				NewPlayer.ZIndex = 2
			end
			local ScaleFactorX = Point2.X - Point1.X
			local ScaleFactorY = Point2.Z - Point1.Z
			NewPlayer.Parent = Minimap:FindFirstChild(Map.Parent.Name).Players
			spawn(function()
				wait(3)
				while game:GetService("RunService").Heartbeat:wait() do
					if not v.DriveSeat.Occupant then
						if not game.Players:FindFirstChild(i) then
							break
						end
					end
					NewPlayer.Position = UDim2.new(
						(v.PrimaryPart.Position.X - Point1.X) / ScaleFactorX,
						0,
						(v.PrimaryPart.Position.Z - Point1.Z) / ScaleFactorY,
						0
					)
				end
				NewPlayer:Destroy()
			end)
		end)
	end
end)

Repl.GiveItem.OnClientEvent:Connect(function(Item)
	if not CurrentItem then
		CurrentItem = "LOAD"
		for i = 40, 20, -1 do
			local Rand = math.random(#LoadItems)
			local Chosen = LoadItems[Rand]
			table.remove(LoadItems, Rand)
			Chosen:TweenPosition(UDim2.new(0.05, 0, -1.00, 0), "Out", "Linear", 300 / (i * 100), true)
			wait(300 / (i * 200))
			spawn(function()
				wait( 300 / (i * 200))
				Chosen.Position = UDim2.new(0.05, 0, 1, 0)
				table.insert(LoadItems, Chosen)
			end)
		end
		for i = 1, 0, -0.1 do
			Items[Item].ImageTransparency = i
			wait()
		end
		CurrentItem = Item
	end
end)

Repl.WaitForVote.OnClientEvent:Connect(function()
	Waiting.Position = UDim2.new(1, 0, 0, 0)
	MainScreen.Position = UDim2.new(1.1, 0, 0, 0)
	print"playing3"
	Sounds.Waiting:Play()
end)

local function WatchGame(Map)
	TrackScripts[Map.Name].Start(Map)
	while not GameEnded do
		pcall(function()
			local ChosenCar
			for i, v in pairs(PlayerCars) do
				ChosenCar = v
				break
			end
			Camera.CameraSubject = ChosenCar.PrimaryPart
			--ChosenCar 
--			local NewPos = ChosenCar.PrimaryPart.Position + Vector3.new(0, 10, 0)
--			SpectateCam.CFrame = CFrame.new(ChosenCar.PrimaryPart.Position + Vector3.new(0, 10, 0))
--			for i = 1, 30 do
--				wait()
--				Camera.Focus = CFrame.new(ChosenCar.PrimaryPart.Position)
--				--SpectateCam.CFrame = CFrame.new(NewPos, ChosenCar.PrimaryPart.Position)
--			end
		end)
		wait(1)
	end
	Sounds.Spectating:Stop()
end

Repl.UpdateCars.OnClientEvent:Connect(function(Cars)
	PlayerCars = Cars
end)

Repl.WatchGame.OnClientEvent:Connect(function(Cars, Map, Finished)
	PlayerCars = Cars
	if not Finished then
		Spectating = true
		Countdown["1"].Visible = false
		Countdown["2"].Visible = false
		Countdown["3"].Visible = false
		if Sounds.Waiting.IsPlaying then
			Sounds.Waiting:Stop()
		end
		Sounds.Spectating:Play()
		GameEnded = false
		Waiting.Position = UDim2.new(1, 0, 0, 0)
		MainScreen.Position = UDim2.new(1.1, 0, 0, -36)
		script.Parent.LiveUI.Visible = true
		for i = 0, 1, 0.05 do
			BlackScreen.BackgroundTransparency = i
			wait()
		end
	else
		wait(2)
		if not GameEnded then
			for i = 1, 0, -0.03 do
				wait()
				BlackScreen.BackgroundTransparency = i
			end
			spawn(function()
				wait(0.5)
				for i = 0, 1, 0.03 do
					wait()
					BlackScreen.BackgroundTransparency = i
				end
			end)
		end
	end
	repeat wait() until workspace.CurrentCamera
	Camera = workspace.CurrentCamera
	spawn(function()
		WatchGame(Map)
	end)
end)

Repl.Respawning.OnClientEvent:Connect(function()
	for i = 1, -0.05, -0.05 do
		BlackScreen.BackgroundTransparency = i
		wait()
	end
	wait(1)
	for i = 0, 1.05, 0.05 do
		BlackScreen.BackgroundTransparency = i
		wait()
	end
end)

for i, v in pairs(Waiting.Players:GetChildren()) do
	if v:IsA("Frame") then
		v.Frame.Add.MouseButton1Click:Connect(function()
			SocialService:PromptGameInvite(game.Players.LocalPlayer)
		end)
	end
end

wait()
if UserInputService.GamepadEnabled then
	UserInputService.MouseIconEnabled = false
	Controller = "XBOX"
	LeftButtons.Buttons.Visible = false
	LeftButtons.Controller.Visible = true
	Items.Key.Controller.Visible = true
elseif UserInputService.KeyboardEnabled then
	Controller = "PC"
	Items.Key.Keyboard.Visible = true
elseif UserInputService.TouchEnabled then
	Controller = "Mobile"
	EmojiButton.Visible = false
	MessageBox.Size = UDim2.new(1, 0, 1, 0)
end

if ChatUI.AbsoluteSize.X < 280 then
	ChatUI.Size = UDim2.new(0.5, 0, 0.5, 0)
end

CanChat = ChatService:CanUserChatAsync(game.Players.LocalPlayer.UserId)

if CanChat then
	ChatButton.Visible = true
end

workspace.CurrentCamera.FieldOfView = 80
--workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

-- https://www.roblox.com/headshot-thumbnail/image?userId=27646631&width=420&height=420&format=png
Localise()
print("hi how are you")