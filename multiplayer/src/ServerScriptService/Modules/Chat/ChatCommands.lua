local TeleportService = game:GetService("TeleportService")
local GetModule = require(game.ReplicatedStorage:WaitForChild("MainModule"))
local DataStore = GetModule("DataStore")

local function GetPlayers(Key)
	local Players = {}
	if Key == "all" then
		return game.Players:GetPlayers()
	end
	for i, v in pairs(game.Players:GetPlayers()) do
		if v.Name:lower():sub(1, #Key) == Key:lower() then
			Players[#Players + 1] = v
		end
	end
	return Players
end

return {
	Staff = {
		["JoshRBX"] = true,
		["Player1"] = true
	},
	Commands = {
		["kick"] = function(Args)
			local KickCount = 0
			if Args[1] then
				local Reason = Args[2] or "Unspecified"
				for i, v in pairs(GetPlayers(Args[1])) do
					v:Kick(Reason)
					KickCount = KickCount + 1
				end
			end
			return KickCount > 0 and ("Kicked " .. KickCount .. " players.") or "No players were kicked."
		end,
		
		["ban"] = function(Args)
			local BanCount = 0
			if Args[1] and Args[2] then
				local Reason = Args[2] or "Unspecified"
				for i, v in pairs(GetPlayers(Args[1])) do
					DataStore:GetDataStore("v2PLR_" .. v.UserId):SetAsync("Banned", {"Mod", Reason})
					v:Kick(Reason)
					BanCount = BanCount + 1
				end
			end
			return BanCount > 0 and ("Banned " .. BanCount .. " players.") or "No players were banned, ensure you provide a reason."
		end,
		
		["addcoins"] = function(Args)
			if Args[1] and tonumber(Args[2]) then
				local Count = 0
				for i, v in pairs(GetPlayers(Args[1])) do
					DataStore:GetDataStore("v2PLR_" .. v.UserId):UpdateAsync("Coins", function(Old)
						return Old + tonumber(Args[2])
					end)
					Count = Count + 1
				end
				return Count > 0 and ("Updated " .. Count .. " players' coin counts by " .. Args[2] .. ".") or "No players were awarded coins."
			end
		end,
		
		["setcoins"] = function(Args)
			if Args[1] and tonumber(Args[2]) then
				local Count = 0
				for i, v in pairs(GetPlayers(Args[1])) do
					DataStore:GetDataStore("v2PLR_" .. v.UserId):SetAsync("Coins", tonumber(Args[2]))
					Count = Count + 1
				end
				return Count > 0 and ("Updated " .. Count .. " players' coin counts by " .. Args[2] .. ".") or "No players were awarded coins."
			end
		end,
		
		["getcoins"] = function(Args)
			if Args[1] then
				for i, v in pairs(GetPlayers(Args[1])) do
					return v.Name .. " has " .. DataStore:GetDataStore("v2PLR_" .. v.UserId):GetAsync("Coins") .. " coins"
				end
			end
		end,
		
		["closeserver"] = function()
			for i, v in pairs(game.Players:GetPlayers()) do
				TeleportService:Teleport(v, 1450793201)
			end
			
			game.Players.PlayerAdded:Connect(function(Player)
				TeleportService:Teleport(Player, 1450793201)
			end)
		end
		
	}
}