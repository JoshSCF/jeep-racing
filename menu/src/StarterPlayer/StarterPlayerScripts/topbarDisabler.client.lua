wait()
pcall(function()
	local starterGui = game:GetService('StarterGui')
	local userInputService = game:GetService('UserInputService')
	userInputService.ModalEnabled = true
	starterGui:SetCore("TopbarEnabled", false)
	starterGui:SetCore("ResetButtonCallback", false)
end)