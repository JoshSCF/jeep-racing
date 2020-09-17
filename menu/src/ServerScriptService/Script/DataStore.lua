local Module = {}
local Functions = {}
local DataStore = game:GetService("DataStoreService")

local function TempData(Key)
	if Key == "Accessories" then
		return {
			Equipped = {},
			Unlocked = {},
			Temp = true
		}
	elseif Key == "HasPlayed" then
		return true
	elseif Key == "Coins" then
		return -2000000
	elseif Key == "MultiXP" then
		return -2000000
	end
	return
end

local function DummyStore()
	local Functions = {}
	
	function Functions:GetAsync(Key)
		return TempData(Key)
	end
	
	function Functions:SetAsync()
		return
	end
	
	function Functions:UpdateAsync()
		return
	end
	
	function Functions:CheckAsync()
		return false
	end
	
	function Functions:RevertAsync()
		return "fail"
	end
	
	return Functions
end

local function GenerateData(DS, Temp)
	local Functions = {}
	
	function Functions:GetAsync(Key)
		if Temp then
			return TempData(Key)
		end
		
		local Success, Content = pcall(function()
			return DS:GetAsync(Key)
		end)
		if Success then
			return Content
		else
			return TempData(Key)
		end
	end
	
	function Functions:SetAsync(Key, Value)
		if Temp then
			return
		end
		
		if typeof(Value) == "table" then
			if Value.Temp then
				print"yeet"
				return
			end
		end
		
		if (Key == "Coins" or Key == "MultiXP") and Value < 0 then
			return
		end
		
		local Success, Content = pcall(function()
			return DS:SetAsync(Key, Value)
		end)
		
		if Success then
			return true
		else
			warn("Store attempt failed! Retrying in 6.5s")
			spawn(function()
				wait(6.5)
				Functions:SetAsync(Key, Value)
			end)
		end
	end
	
	function Functions:UpdateAsync(Key, Func)
		local Success, Content = pcall(function()
			return DS:UpdateAsync(Key, Func)
		end)
		
		if not Success then
			warn("Update attempt failed! Retrying in 6.5s")
			spawn(function()
				wait(6.5)
				return Functions:UpdateAsync(Key, Func)
			end)
		end
	end
	
	function Functions:CheckAsync()
		local Success, Content = pcall(function()
			DS:SetAsync("Test", true)
		end)
		
		return Success
	end
	
	function Functions:RevertAsync()
		
	end
	
	return Functions
end

function Module:GetDataStore(Key, Attempts)
	local Attempts = Attempts or 1
	local Success, DS = pcall(function()
		return DataStore:GetDataStore(Key)
	end)
	
	if Attempts == 5 then
		warn("Couldn't get datastore!")
		return GenerateData(DummyStore(), true)
	end
	
	if Success then
		return GenerateData(DS)
	else
		return Module:GetDataStore(Key, Attempts + 1)
	end
end

return Module