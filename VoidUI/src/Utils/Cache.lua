-- [[
-- 	Rayfield Enhanced — Cache.lua
-- 	Smart caching system for elements, icons, and GUI objects
-- ]]

local Cache = {}

local elementCache = {}
local iconCache = {}
local objectCache = {}
local cacheStats = { Hits = 0, Misses = 0 }

-- ============================================================
-- 	ELEMENT CACHE
-- ============================================================

function Cache:GetElement(cacheKey, factory)
	if elementCache[cacheKey] then
		cacheStats.Hits = cacheStats.Hits + 1
		return elementCache[cacheKey]
	end
	
	cacheStats.Misses = cacheStats.Misses + 1
	local element = factory()
	if element then
		elementCache[cacheKey] = element
	end
	return element
end

function Cache:SetElement(cacheKey, element)
	elementCache[cacheKey] = element
end

function Cache:RemoveElement(cacheKey)
	local element = elementCache[cacheKey]
	elementCache[cacheKey] = nil
	return element
end

function Cache:ClearElements()
	table.clear(elementCache)
end

-- ============================================================
-- 	ICON CACHE
-- ============================================================

function Cache:GetIcon(iconName, iconResolver)
	if iconCache[iconName] then
		return iconCache[iconName]
	end
	
	if iconResolver then
		local result = iconResolver(iconName)
		iconCache[iconName] = result
		return result
	end
	return nil
end

function Cache:PreloadIcons(iconNames, iconResolver)
	for _, name in ipairs(iconNames) do
		if not iconCache[name] and iconResolver then
			iconCache[name] = iconResolver(name)
		end
	end
end

function Cache:ClearIcons()
	table.clear(iconCache)
end

-- ============================================================
-- 	GENERAL OBJECT CACHE (with TTL)
-- ============================================================

function Cache:Set(name, value, ttl)
	objectCache[name] = {
		Value = value,
		Expires = ttl and (tick() + ttl) or nil,
	}
end

function Cache:Get(name)
	local entry = objectCache[name]
	if not entry then return nil end
	
	if entry.Expires and tick() > entry.Expires then
		objectCache[name] = nil
		return nil
	end
	
	return entry.Value
end

function Cache:Remove(name)
	objectCache[name] = nil
end

function Cache:Clear()
	table.clear(objectCache)
	table.clear(iconCache)
	table.clear(elementCache)
end

-- ============================================================
-- 	STATS
-- ============================================================

function Cache:GetStats()
	return {
		Hits = cacheStats.Hits,
		Misses = cacheStats.Misses,
		CacheSize = #elementCache + #iconCache + #objectCache,
		Elements = #elementCache,
		Icons = #iconCache,
		Objects = #objectCache,
	}
end

function Cache:ResetStats()
	cacheStats.Hits = 0
	cacheStats.Misses = 0
end

return Cache