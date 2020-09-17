local Repl = game.ReplicatedStorage
local Ban = require(script.Parent.BanPlayer)
local Remotes = {
	"BanPlayer",
	"VoteKick",
	"KickPlayer",
	"ExecuteCode"
}

return function()
	for i, v in pairs(Remotes) do
		Repl:FindFirstChild(v).OnServerEvent:Connect(function(Player)
			Ban(Player)
		end)
	end
end