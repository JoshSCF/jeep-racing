return function(Name)
	local Path = game:FindFirstChild("ServerScriptService")
	for i, v in pairs(Path:WaitForChild("Modules"):GetDescendants()) do
		if v.Name == Name and v:IsA("ModuleScript") then
			return require(v)
		end
	end
end