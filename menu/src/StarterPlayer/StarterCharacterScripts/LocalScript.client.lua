local Player = script.Parent.Humanoid

Player.JumpPower = 0

Player.HealthChanged:Connect(function()
	Player.Health = 100
end)