local FlagData = require(script.Parent:WaitForChild("FlagData"))
local ColourValues = require(script.Parent:WaitForChild("ColourValues"))
local SkinData = require(script.Parent:WaitForChild("SkinData"))

local FlagVersion = 1

local function CorrectGIF(Car, Flag)
	for i, v in pairs(Flag.Contents) do
		if Car.Flag.FlagFace.Front.Texture == v then
			return true
		end
	end
end

local function RemoveAccessory(Car)
	for i, v in pairs(Car.Accessories:GetChildren()) do
		v.Transparency = 1
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
				local LocalVersion = FlagVersion + 1
				FlagVersion = LocalVersion
				--print(FlagVersion)
				Car.Flag.FlagFace.Front.Texture = Flag.Contents[#Flag.Contents]
				Car.Flag.FlagFace.Back.Texture = Flag.Contents[#Flag.Contents]
				while CorrectGIF(Car, Flag) and LocalVersion == FlagVersion do
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
	
	RemoveFlag = function(Car)
		Car.Flag.FlagFace.Transparency = 1
		Car.Flag.FlagPole.Transparency = 1
		Car.Flag.FlagFace.Back.Texture = ""
		Car.Flag.FlagFace.Front.Texture = ""
	end,
	
	AddColour = function(ColourName, Car)
		for i, v in pairs(Car:GetChildren()) do
			if ({EngineBlock=1,Union=2,Back=3,BackSeat=4})[v.Name] then
				v.Color = ColourValues[ColourName]
			end
		end
	end,
	
	RemoveColour = function(Car)
		for i, v in pairs(Car:GetChildren()) do
			if ({EngineBlock=1,Union=2,Back=3,BackSeat=4})[v.Name] then
				v.Color = Color3.fromRGB(248, 248, 248)
			end
		end
	end,
	
	ApplyPlate = function(PlateText, Car)
		Car.NumberPlate.Gui.Value.Text = PlateText
	end,
	
	AddSkin = function(SkinName, Car)
		for i, v in pairs(Car:GetChildren()) do
			if ({EngineBlock=1,Union=2,Back=3,BackSeat=4})[v.Name] then
				for x, v in pairs(v:GetChildren()) do
					if v:IsA("Texture") then
						local Skin = SkinData[SkinName]
						v.Texture = Skin.Texture
						v.StudsPerTileU = Skin.Size.X
						v.StudsPerTileV = Skin.Size.Y
					end
				end
			end
		end
	end,
	
	RemoveSkin = function(Car)
		for i, v in pairs(Car:GetChildren()) do
			if ({EngineBlock=1,Union=2,Back=3,BackSeat=4})[v.Name] then
				for x, v in pairs(v:GetChildren()) do
					if v:IsA("Texture") then
						v.Texture = ""
					end
				end
			end
		end
	end,
	
	RemoveAccessorie = RemoveAccessory,
	
	AddAccessorie = function(Accessory, Car)
		RemoveAccessory(Car)
		Car.Accessories[Accessory].Transparency = 0
	end
}

return module
