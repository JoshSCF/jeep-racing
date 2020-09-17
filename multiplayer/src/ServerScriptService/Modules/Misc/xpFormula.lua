local PlacementValues = {
	95, 70, 50, 30, 20, 5,
	-15, -25, -45, -60, -80, -100
}

local module = {
	Calculate = function(Place, PlayerXP, MeanXP, TotalPlayers)
		local ToReturn = PlayerXP
		pcall(function()
			if Place > TotalPlayers then
				Place = Place - 1
			end
			ToReturn = math.ceil(PlacementValues[
				math.ceil((((Place / TotalPlayers) + ((Place - 1) / TotalPlayers)) / 2) * 12)
			]) + PlayerXP
			if ToReturn > 99999 then
				ToReturn = 99999
			elseif ToReturn < 0 then
				ToReturn = 0
			end
		end)
		print(PlayerXP, ToReturn)
		return ToReturn
	end
}

return module
