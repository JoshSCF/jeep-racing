game:GetService("LogService").MessageOut:Connect(function(Message, Type)
	if Type == Enum.MessageType.MessageError then
		game.ReplicatedStorage.ReportError:FireServer(Message, debug.traceback())
	end
end)