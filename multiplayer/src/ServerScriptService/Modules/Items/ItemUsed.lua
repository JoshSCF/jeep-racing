local GetModule = require(game.ReplicatedStorage:WaitForChild("MainModule"))
local Items = GetModule("Items")

return function(Player, Item)
	-- there is a bug here somewhere
	print(_G.GamePlayers[Player].CurrentItem, Item)
	if _G.GamePlayers[Player].CurrentItem == Item then
		script.Parent.Parent.Parent.Main.SendPrevItem:Fire(Player, Item)
		spawn(function()
			Items[Item].Run(Player, Item, _G.Map, _G.PlayerCars[Player.Name], GetPlayerFromPlacement(1), _G.PlayerCars)
		end)
	else
		warn(Player, Item, _G.GamePlayers[Player].CurrentItem)
		--ModeratePlayer(Player, "Attempting to use items that you have not found in an item box.")
	end
	_G.GamePlayers[Player].CurrentItem = nil
end