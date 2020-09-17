local Raven = require(script.Raven)
local Client = Raven:Client("https://xxxxxxxxxxxxxxx@sentry.io/xxxxxxxxxxxxxxxx")

local EventLevels = {
	["Enum.MessageType.MessageError"] = Raven.EventLevel.Error,
	["Enum.MessageType.MessageInfo"] = Raven.EventLevel.Info,
	["Enum.MessageType.MessageWarning"] = Raven.EventLevel.Warning
}

game:GetService("LogService").MessageOut:Connect(function(Message, Type)
	local ErrorType = EventLevels[tostring(Type)]
	if Type == Enum.MessageType.MessageError then
		Client:SendException(ErrorType, Message, debug.traceback())
	end
end)

Client:ConnectRemoteEvent(game.ReplicatedStorage.ReportError)