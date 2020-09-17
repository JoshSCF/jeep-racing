local IsPlaying = false

local module = {
	["Crazy Circuit"] = {
		Start = function(Track)
			IsPlaying = true
			game.Lighting.TimeOfDay = "14:00:00"
--			for i, v in pairs(Track.Decoration.Stands:GetChildren()) do
--				for _, Player in pairs(v.Players:GetChildren()) do
--					wait()
--					local Cheer = Player.Humanoid:LoadAnimation(script.Cheer)
--					spawn(function()
--						while wait(1) and IsPlaying do
--							Cheer:Play()
--						end
--					end)
--				end
--			end
		end,
		Finish = function()
			IsPlaying = false
		end
	},
	["Night Track"] = {
		Start = function(Track)
			IsPlaying = true
			game.Lighting.TimeOfDay = "04:00:00"
		end,
		Finish = function()
			IsPlaying = false
		end
	}
}

return module
