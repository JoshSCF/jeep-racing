local Banned = {
	["example-player"] = {
		Reason = "Hacking",
		UnbanDate = "Thursday 14th March 2019, 00:00 GMT"
	}
}

return function(Player)
	local Info = Banned[Player.Name]
	if Info then
		Player:Kick("You are banned from Jeep Racing for reason: " .. Info.Reason .. "\nYou will be unbanned: " .. Info.UnbanDate)
		return false
	end
	return true
end