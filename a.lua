getgenv().namehub = "Light Hub"

local http = game:GetService("HttpService")
local players = game:GetService("Players")
local lp = players.LocalPlayer

local config = {
	keysJsonUrl = "https://raw.githubusercontent.com/qofnodmdkdkdqofnodmdkdkd/qofnodmdkdkdqofnodmdkdkd/refs/heads/main/qofnodmdkdkdqofnodmdkdkd.json",
	linkvertiseUserID = "1370853",
	keyFileName = "light_hub_key.txt"
}

if not game:IsLoaded() then game.Loaded:Wait() end
while not lp do task.wait() lp = players.LocalPlayer end

local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/wzaxk/check/refs/heads/main/uiloader"))()
local main = ui.new()

local keyTab
local lastStatusLabel

local function trim(s)
	if type(s) ~= "string" then return s end
	return s:match("^%s*(.-)%s*$")
end

local function updateStatus(msg)
	if lastStatusLabel then
		lastStatusLabel:Destroy()
		lastStatusLabel = nil
	end
	if keyTab then
		lastStatusLabel = keyTab.create_title({
			name = msg,
			section = "left"
		})
	else
		print("[status]", msg)
	end
end

local function fetchKeys()
	local ok, data = pcall(function()
		return game:HttpGet(config.keysJsonUrl)
	end)
	if not ok then return nil end

	local ok2, keys = pcall(function()
		return http:JSONDecode(data)
	end)
	if not ok2 then return nil end

	return keys
end

local function validateKey(key)
	if not key then return false end
	key = trim(key)

	local keys = fetchKeys()
	if not keys then
		updateStatus("failed to fetch keys")
		return false
	end

	for _, validKey in pairs(keys) do
		if type(validKey) == "string" and trim(validKey) == key then
			if validKey:sub(1,8) == "Premium_" then
				local user = validKey:sub(9)
				if user == lp.Name then
					return true
				else
					updateStatus("not your premium key")
					return false
				end
			end
			return true
		end
	end

	return false
end

local function saveKey(key)
	if writefile then
		writefile(config.keyFileName, key)
	end
end

local function loadMainHub()
	local mainTab = main:create_tab("Main")

	mainTab.create_title({
		name = "welcome to light hub",
		section = "left"
	})

	mainTab.create_button({
		name = "Test Button",
		flag = "testbtn",
		section = "left",
		callback = function()
			print("clicked")
		end
	})

	updateStatus("main hub loaded")
end

local function createKeyTab()
	keyTab = main:create_tab("Key System")

	keyTab.create_input({
		name = "Enter Key",
		flag = "userkey",
		section = "left"
	})

	keyTab.create_button({
		name = "Verify Key",
		flag = "verifybutton",
		section = "left",
		callback = function()
			local key = ui.Flags["userkey"]
			if not key or trim(key) == "" then
				updateStatus("enter a key")
				return
			end

			if validateKey(key) then
				saveKey(trim(key))
				updateStatus("valid key, loading hub...")
				task.delay(0.3, function()
					if keyTab and keyTab.Frame then
						keyTab.Frame:Destroy()
						keyTab = nil
					end
					loadMainHub()
				end)
			else
				updateStatus("wrong key")
			end
		end
	})

	keyTab.create_button({
		name = "Copy Free Key Link",
		flag = "copyfreekey",
		section = "left",
		callback = function()
			local keys = fetchKeys()
			if not keys then
				updateStatus("couldn't get keys")
				return
			end

			local freeKey
			for _, k in pairs(keys) do
				if type(k) == "string" and trim(k):sub(1,5) == "Free_" then
					freeKey = trim(k)
					break
				end
			end

			if not freeKey then
				updateStatus("no free key")
				return
			end

			local url = "https://linkvertise.com/"..config.linkvertiseUserID.."/"..http:UrlEncode(freeKey)
			if setclipboard then
				setclipboard(url)
				updateStatus("link copied")
			else
				updateStatus("clipboard not supported:\n"..url)
			end
		end
	})

	updateStatus("enter your key and verify")
end

task.spawn(function()
	local savedKey
	if isfile and isfile(config.keyFileName) then
		savedKey = trim(readfile(config.keyFileName))
	end

	if savedKey and savedKey ~= "" and validateKey(savedKey) then
		loadMainHub()
	else
		createKeyTab()
		if savedKey and savedKey ~= "" then
			updateStatus("saved key wrong, enter new one")
		else
			updateStatus("enter your key")
		end
	end
end)
