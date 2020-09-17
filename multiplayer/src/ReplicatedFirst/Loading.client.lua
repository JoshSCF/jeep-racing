game.ReplicatedFirst:RemoveDefaultLoadingScreen()

local Loading = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("HUD").BlackScreen.Loading

for i = 1, 500 do
	wait()
	Loading.Rotation = Loading.Rotation + 5
end