-- [[
-- 	Rayfield Enhanced — ConfigManager.lua
-- 	Advanced configuration system with profiles, import/export
-- ]]

local HttpService = game:GetService("HttpService")

local ConfigManager = {}
ConfigManager.__index = ConfigManager

local RAYFIELD_FOLDER = "RayfieldEnhanced"
local CONFIG_FOLDER = RAYFIELD_FOLDER .. "/Configs"
local EXTENSION = ".json"

-- ============================================================
-- 	CONFIG MANAGER
-- ============================================================

local ConfigInstance = {
	_flags = {},
	_profiles = {},
	_currentProfile = "Default",
	_autoSaveEnabled = false,
	_autoSaveInterval = 30,
	_autoSaveThread = nil,
	_listeners = {},
	_loaded = false,
}

function ConfigInstance:RegisterFlag(name, value)
	self._flags[name] = value
end

function ConfigInstance:GetFlag(name)
	return self._flags[name]
end

function ConfigInstance:SetFlag(name, value)
	self._flags[name] = value
	if self._autoSaveEnabled then
		Performance.BatchUpdate("config_save", function()
			self:Save()
		end)
	end
	return value
end

function ConfigInstance:Save(profileName)
	profileName = profileName or self._currentProfile
	local data = {}
	for name, value in pairs(self._flags) do
		if typeof(value) == "Color3" then
			data[name] = {R = value.R * 255, G = value.G * 255, B = value.B * 255}
		elseif typeof(value) == "UDim2" then
			data[name] = {
				XS = value.X.Scale, XO = value.X.Offset,
				YS = value.Y.Scale, YO = value.Y.Offset,
			}
		else
			data[name] = value
		end
	end

	local success, encoded = pcall(function()
		return HttpService:JSONEncode(data)
	end)

	if success then
		local ok = pcall(function()
			ensureFolder(RAYFIELD_FOLDER)
			ensureFolder(CONFIG_FOLDER)
			writefile(CONFIG_FOLDER .. "/" .. profileName .. EXTENSION, encoded)
		end)
		if ok then
			for _, cb in ipairs(self._listeners) do
				pcall(cb, "saved", profileName)
			end
		end
	end
end

function ConfigInstance:Load(profileName)
	profileName = profileName or self._currentProfile

	local fileContent = pcall(function()
		return readfile(CONFIG_FOLDER .. "/" .. profileName .. EXTENSION)
	end)

	local success, content = pcall(function()
		if fileContent then return fileContent end
	end)

	if not success or not content then return false end

	local decodeSuccess, data = pcall(function()
		return HttpService:JSONDecode(content)
	end)

	if not decodeSuccess or not data then return false end

	for name, value in pairs(data) do
		if type(value) == "table" and value.R and value.G and value.B then
			self._flags[name] = Color3.fromRGB(value.R, value.G, value.B)
		elseif type(value) == "table" and value.XS then
			self._flags[name] = UDim2.new(value.XS, value.XO, value.YS, value.YO)
		else
			self._flags[name] = value
		end
	end

	self._loaded = true
	for _, cb in ipairs(self._listeners) do
		pcall(cb, "loaded", profileName)
	end

	return true
end

function ConfigInstance:SetProfile(name)
	self._currentProfile = name
end

function ConfigInstance:GetProfiles()
	local profiles = {}
	local ok = pcall(function()
		local folder = CONFIG_FOLDER
		if isfolder and isfolder(folder) then
			local files = listfiles(folder)
			for _, file in ipairs(files) do
				local name = file:match("([^/\\]+)" .. EXTENSION:gsub("%.", "%%."))
				if name then
					table.insert(profiles, name)
				end
			end
		end
	end)
	return profiles
end

function ConfigInstance:DeleteProfile(name)
	local ok = pcall(function()
		delfile(CONFIG_FOLDER .. "/" .. name .. EXTENSION)
	end)
	return ok
end

function ConfigInstance:ExportConfig()
	local data = {}
	for name, value in pairs(self._flags) do
		if typeof(value) == "Color3" then
			data[name] = {R = value.R * 255, G = value.G * 255, B = value.B * 255}
		elseif typeof(value) == "UDim2" then
			data[name] = {XS = value.X.Scale, XO = value.X.Offset, YS = value.Y.Scale, YO = value.Y.Offset}
		else
			data[name] = value
		end
	end
	return HttpService:JSONEncode(data)
end

function ConfigInstance:ImportConfig(jsonString)
	local success, data = pcall(function()
		return HttpService:JSONDecode(jsonString)
	end)
	if not success then return false end
	for name, value in pairs(data) do
		if type(value) == "table" and value.R then
			self._flags[name] = Color3.fromRGB(value.R, value.G, value.B)
		else
			self._flags[name] = value
		end
	end
	self:Save()
	return true
end

function ConfigInstance:EnableAutoSave(interval)
	self._autoSaveEnabled = true
	self._autoSaveInterval = interval or 30
	if self._autoSaveThread then
		task.cancel(self._autoSaveThread)
	end
	self._autoSaveThread = task.spawn(function()
		while self._autoSaveEnabled do
			task.wait(self._autoSaveInterval)
			self:Save()
		end
	end)
end

function ConfigInstance:DisableAutoSave()
	self._autoSaveEnabled = false
	if self._autoSaveThread then
		task.cancel(self._autoSaveThread)
		self._autoSaveThread = nil
	end
end

function ConfigInstance:OnConfigEvent(callback)
	table.insert(self._listeners, callback)
end

function ConfigInstance:Reset()
	table.clear(self._flags)
	self:Save()
end

-- Helper: ensure folder exists
local function ensureFolder(path)
	if isfolder and not isfolder(path) then
		makefolder(path)
	end
end

-- Create default folders
pcall(function()
	ensureFolder(RAYFIELD_FOLDER)
	ensureFolder(CONFIG_FOLDER)
end)

return ConfigInstance