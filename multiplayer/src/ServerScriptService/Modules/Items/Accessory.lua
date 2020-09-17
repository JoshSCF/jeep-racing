local FlagData = {
	["Alex"] = "rbxassetid://2097535552",
	["Corl"] = "rbxassetid://2097537824",
	["DanTDM"] = "rbxassetid://2097540209",
	["Denis"] = "rbxassetid://2097543360",
	["Flamingo"] = "rbxassetid://2097545277",
	["InquisitorMaster"] = "rbxassetid://2097548175",
	["ItsFunneh"] = "rbxassetid://2097552527",
	["Poke"] = "rbxassetid://2097557689",
	["Sketch"] = "rbxassetid://2097560479",
	["Sub"] = "rbxassetid://2097561989",
	["Thinknoodles"] = "rbxassetid://2097563140",
	["Tofuu"] = "rbxassetid://2097564499",
	["ZephPlayz"] = "rbxassetid://2097565888",
	["Josh"] = "rbxassetid://2097937772",
	["ScriptersCF"] = "rbxassetid://2098188827",
	["NyanCat"] = {Update=0.07,Contents={"rbxassetid://2659720720","rbxassetid://2660834871","rbxassetid://2660837326","rbxassetid://2660840189","rbxassetid://2660841411","rbxassetid://2660852188","rbxassetid://2660853499","rbxassetid://2660859498","rbxassetid://2660869343","rbxassetid://2660872621","rbxassetid://2660873738","rbxassetid://2660875447"}},
	["DancingBanana"] = "rbxassetid://2659723859",
	["Twitter"] = "rbxassetid://2661003835"
}

local ColourValues = {
	["BlueLight"] = Color3.fromRGB(3, 167, 242),
	["Red"] = Color3.fromRGB(255, 0, 0),
	["Orange"] = Color3.fromRGB(255, 81, 0),
	["GreyLight"] = Color3.fromRGB(167, 167, 167),
	["GreyDark"] = Color3.fromRGB(86, 86, 86),
	["Blue"] = Color3.fromRGB(0, 25, 255),
	["Purple"] = Color3.fromRGB(140, 0, 255),
	["Yellow"] = Color3.fromRGB(255, 255, 0),
	["Black"] = Color3.fromRGB(8, 8, 8),
	["Green"] = Color3.fromRGB(0, 255, 0),
	["GreenDark"] = Color3.fromRGB(0, 116, 0),
	["BlueGreen"] = Color3.fromRGB(0, 170, 127),
	["Gold"] = Color3.fromRGB(236, 202, 10),
	["YellowLight"] = Color3.fromRGB(255, 255, 127),
	["Brown"] = Color3.fromRGB(60, 0, 0)
}

local function CorrectGIF(Car, Flag)
	for i, v in pairs(Flag.Contents) do
		if Car.Flag.FlagFace.Front.Texture == v then
			return true
		end
	end
end

local module = {
	AddFlag = function(FlagName, Car)
		Car.Flag.FlagFace.Transparency = 0
		Car.Flag.FlagPole.Transparency = 0
		local Flag = FlagData[FlagName]
		if typeof(Flag) == "string" then
			Car.Flag.FlagFace.Front.Texture = Flag
			Car.Flag.FlagFace.Back.Texture = Flag
		else
			spawn(function()
				Car.Flag.FlagFace.Front.Texture = Flag.Contents[#Flag.Contents]
				Car.Flag.FlagFace.Back.Texture = Flag.Contents[#Flag.Contents]
				while CorrectGIF(Car, Flag) do
					for i, v in pairs(Flag.Contents) do
						wait(Flag.Update)
						if CorrectGIF(Car, Flag) then
							Car.Flag.FlagFace.Front.Texture = v
							Car.Flag.FlagFace.Back.Texture = v
						else
							break
						end
					end
				end
			end)
		end
	end,
	
	AddColour = function(ColourName, Car)
		for i, v in pairs(Car:GetChildren()) do
			if ({EngineBlock=1,Union=2,Back=3,BackSeat=4})[v.Name] then
				v.Color = ColourValues[ColourName]
			end
		end
	end,
	
	ApplyPlate = function(PlateText, Car)
		Car.NumberPlate.Gui.Value.Text = PlateText
	end
}

return module
