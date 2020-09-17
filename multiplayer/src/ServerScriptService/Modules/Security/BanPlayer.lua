local Repl = game.ReplicatedStorage
local DataStore = require(script.Parent.DataStore)

return function(Player)
	DataStore:GetDataStore("v2PLR_" .. Player.UserId):SetAsync("Banned", {"AntiExploit", "Exploiting"})
	for i, v in pairs(game.Players:GetPlayers()) do
		if v ~= Player and not v:IsFriendsWith(Player.UserId) then
			Repl.HidePlayer:FireClient(v, Player)
		end
	end
end

