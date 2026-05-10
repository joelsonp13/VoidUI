-- [[
-- 	Rayfield Enhanced — SearchManager.lua
-- 	Global search system with fuzzy matching, filtering, and animation
-- ]]

local SearchManager = {}

local searchInstances = {}

-- ============================================================
-- 	FUZZY MATCH
-- ============================================================

function SearchManager:FuzzyMatch(text, pattern)
	if not pattern or #pattern == 0 then return true end
	
	text = text:lower()
	pattern = pattern:lower()
	
	local pi = 1
	local score = 0
	
	for ci = 1, #pattern do
		local pc = pattern:sub(ci, ci)
		local matched = false
		
		while pi <= #text do
			local tc = text:sub(pi, pi)
			if tc == pc then
				score = score + 1
				matched = true
				pi = pi + 1
				break
			end
			pi = pi + 1
		end
		
		if not matched then
			return false, 0
		end
	end
	
	return true, score / #pattern
end

-- ============================================================
-- 	SEARCH INSTANCE
-- ============================================================

function SearchManager:Create(config)
	config = config or {}
	
	local search = {
		Id = config.Id or "search_" .. tick(),
		Source = config.Source or {},
		OnResult = config.OnResult or function() end,
		OnClear = config.OnClear or function() end,
		MinChars = config.MinChars or 1,
		MaxResults = config.MaxResults or 50,
		DebounceTime = config.DebounceTime or 0.1,
		_filters = {},
		_lastQuery = "",
		_debounceThread = nil,
	}
	
	searchInstances[search.Id] = search
	return search
end

function SearchManager:Query(searchId, query)
	local search = searchInstances[searchId]
	if not search then return end
	
	query = tostring(query or "")
	
	-- Debounce
	if search._debounceThread then
		task.cancel(search._debounceThread)
	end
	
	search._debounceThread = task.delay(search.DebounceTime, function()
		if #query < search.MinChars then
			search.OnClear()
			return
		end
		
		local results = {}
		local source = search.Source
		
		if type(source) == "function" then
			source = source()
		end
		
		for _, item in ipairs(source) do
			local text = tostring(item.Text or item.Name or item)
			local matched, score = self:FuzzyMatch(text, query)
			if matched then
				table.insert(results, {
					Text = text,
					Score = score,
					Data = item.Data or item,
				})
			end
		end
		
		-- Sort by score
		table.sort(results, function(a, b)
			return a.Score > b.Score
		end)
		
		-- Limit results
		if #results > search.MaxResults then
			for i = #results, search.MaxResults + 1, -1 do
				table.remove(results)
			end
		end
		
		search.OnResult(results, query)
		search._lastQuery = query
	end)
end

function SearchManager:Destroy(searchId)
	searchInstances[searchId] = nil
end

function SearchManager:DestroyAll()
	table.clear(searchInstances)
end

return SearchManager