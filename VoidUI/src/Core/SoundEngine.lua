-- [[
-- 	Rayfield Enhanced — SoundEngine.lua
-- 	Sound system for UI interactions with caching, volume, mute
-- ]]

local SoundEngine = {}

local soundCache = {}
local soundPool = {}
local muted = false
local volume = 0.5

local SOUND_IDS = {
	Click = "rbxassetid://9120388167",
	Toggle = "rbxassetid://9120388167",
	Notification = "rbxassetid://9120388167",
	Dropdown = "rbxassetid://9120388167",
	Error = "rbxassetid://9120388167",
	Success = "rbxassetid://9120388167",
	Hover = "rbxassetid://9120388167",
}

function SoundEngine:SetSoundID(name, assetId)
	SOUND_IDS[name] = assetId
	soundCache[name] = nil
end

function SoundEngine:Play(name, volumeOverride)
	if muted then return end

	local soundId = SOUND_IDS[name] or SOUND_IDS.Click
	local vol = volumeOverride or volume

	-- Pooling
	local sound = table.remove(soundPool)
	if not sound then
		sound = Instance.new("Sound")
		sound.Parent = gethui and gethui() or CoreGui
	end

	sound.SoundId = soundId
	sound.Volume = vol
	sound:Play()

	task.delay(0.5, function()
		sound:Stop()
		table.insert(soundPool, sound)
	end)
end

function SoundEngine:SetVolume(v)
	volume = math.clamp(v, 0, 1)
end

function SoundEngine:GetVolume()
	return volume
end

function SoundEngine:Mute()
	muted = true
end

function SoundEngine:Unmute()
	muted = false
end

function SoundEngine:IsMuted()
	return muted
end

function SoundEngine:ToggleMute()
	muted = not muted
	return muted
end

function SoundEngine:Preload()
	for name, id in pairs(SOUND_IDS) do
		local sound = Instance.new("Sound")
		sound.SoundId = id
		sound.Volume = 0
		sound.Parent = gethui and gethui() or CoreGui
		sound:Play()
		task.delay(0.1, function()
			sound:Stop()
			sound:Destroy()
		end)
	end
end

return SoundEngine