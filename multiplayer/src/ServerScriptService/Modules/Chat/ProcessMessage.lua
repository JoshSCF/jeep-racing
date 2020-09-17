local GetModule = require(game.ReplicatedStorage:WaitForChild("MainModule"))
local ChatCommands = GetModule("ChatCommands")
local Chat = game:GetService("Chat")

return function(Player, Message)
	if ChatCommands.Staff[Player.Name] and Message:sub(1, 1) == ";" and #Message > 2 then
		local Command = {}
		for i in Message:sub(2):gmatch("%S+") do
			Command[#Command + 1] = i
		end
		if ChatCommands.Commands[Command[1]] then
			local Args = {}
			for i = 2, #Command do
				Args[#Args + 1] = Command[i]
			end
			game.ReplicatedStorage.DisplayMessage:FireClient(
				Player,
				"SYSTEM",
				ChatCommands.Commands[Command[1]](Args)
			)
		end

		return
	end
	
	if utf8.len(Message) <= 120 then
		for i, v in pairs(game.Players:GetPlayers()) do
			game.ReplicatedStorage.DisplayMessage:FireClient(v, Player.Name, Chat:FilterStringAsync(Message, Player, v))
		end
--		local FilteredMessage = TextService:FilterStringAsync(Message, Player.UserId):GetNonChatStringForBroadcastAsync()
--		Repl.DisplayMessage:FireAllClients(Player.Name, FilteredMessage)
	end
end