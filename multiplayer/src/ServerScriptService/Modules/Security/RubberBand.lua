local ReplicatedStorage = game.ReplicatedStorage
local Module = {}
local MaxSpeeds = {}

local function RubberBand(LastPosition, Car, NewPosition, Prev, Max)
	local Change = (NewPosition[1] - LastPosition[1]).Magnitude
	local LastCFrame = CFrame.new(LastPosition[1].X, LastPosition[2], LastPosition[1].Y)
	local NewCFrame = CFrame.new(NewPosition[1].X, NewPosition[2], NewPosition[1].Y)
	if Change > (Max + Max / 10) then
		if Prev then
			Car:SetPrimaryPartCFrame(LastCFrame:lerp(NewCFrame, (Max + Max / 10) / math.min(Change, Prev)))
			Prev = nil
		else
			ReplicatedStorage.SetSpeed:FireClient(game.Players:GetPlayerFromCharacter(Car.DriveSeat.Occupant.Parent), Max * 2 - Change)
			Prev = Change
		end
	else
		ReplicatedStorage.SetSpeed:FireClient(game.Players:GetPlayerFromCharacter(Car.DriveSeat.Occupant.Parent), Max)
		Prev = nil
	end
	return Prev
end

function Module:Initiate(Car)
	spawn(function()
		local ShouldBand = true
		local LastPosition = {Vector2.new(Car.PrimaryPart.Position.X, Car.PrimaryPart.Position.Z), Car.PrimaryPart.Position.Y}
		local Prev
		MaxSpeeds[Car] = 80
		while wait(1) and Car:FindFirstChild("DriveSeat") do
			pcall(function()
				if not ShouldBand then return end
				local NewPosition = {Vector2.new(Car.PrimaryPart.Position.X, Car.PrimaryPart.Position.Z), Car.PrimaryPart.Position.Y}
				Prev = RubberBand(LastPosition, Car, NewPosition, Prev, MaxSpeeds[Car])
				LastPosition = NewPosition
			end)
		end
		MaxSpeeds[Car] = nil
	end)
end

function Module:UpdateSpeed(Car, Value, Time)
	spawn(function()
		local Original = MaxSpeeds[Car]
		MaxSpeeds[Car] = Value
		wait(Time)
		MaxSpeeds[Car] = Original
	end)
end

return Module