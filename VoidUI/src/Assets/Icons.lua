-- [[
-- 	Rayfield Enhanced — Icons.lua
-- 	Icon system with caching, Lucide integration, custom .PNG icons from folder
-- 	Supports both PT-BR and English icon names
-- ]]

local Icons = {}
local iconCache = {}
local iconPack = "lucide"

local ICONS_FOLDER = "RayfieldEnhanced/Icons"
local hasFilesystem = type(writefile) == "function" and type(isfile) == "function"
local hasCustomAsset = type(getcustomasset) == "function"

-- ═══════════════════════════════════════════════════════════════
-- 	YOUR CUSTOM ICONS (PT-BR)
-- 	Coloque .png em: src/Assets/Icons/
-- 	Use pelo nome em português nos componentes
-- ═══════════════════════════════════════════════════════════════

local CUSTOM_ICONS = {
	-- PT-BR name -> filename.png
	["18"] = "18.png",
	["28"] = "28.png",
	["abas"] = "abas.png",
	["add_lista"] = "adicionar_lista.png",
	["add_local"] = "adicionar_local.png",
	["baixar"] = "baixar.png",
	["cadeado"] = "cadeado.png",
	["carrinho"] = "carrinho.png",
	["chat"] = "chat.png",
	["compartilhar"] = "compartilhar.png",
	["config"] = "configurar.png",
	["coracao"] = "coração.png",
	["descer"] = "descer.png",
	["direita"] = "direita.png",
	["enviar"] = "enviar.png",
	["esquerda"] = "esquerda.png",
	["fechar"] = "fechar.png",
	["filtro"] = "filtro.png",
	["ideia"] = "ideia.png",
	["lista"] = "lista.png",
	["lixeira"] = "lixeira.png",
	["local"] = "local.png",
	["lupa"] = "lupa.png",
	["mais"] = "mais.png",
	["perfil"] = "perfil.png",
	["salvar_lista"] = "salvar-lista.png",
	["salvar"] = "salvar.png",
	["nuvem"] = "salvar_na_nuvem.png",
	["subir"] = "subir.png",
	["subir_lista"] = "subir_lista.png",
	["tocar"] = "tocar.png",
	["ver"] = "ver.png",
}

-- Also create English aliases for common icons
local ENGLISH_ALIASES = {
	["search"] = "lupa",
	["settings"] = "config",
	["close"] = "fechar",
	["download"] = "baixar",
	["save"] = "salvar",
	["list"] = "lista",
	["filter"] = "filtro",
	["chat"] = "chat",
	["trash"] = "lixeira",
	["lock"] = "cadeado",
	["plus"] = "mais",
	["up"] = "subir",
	["down"] = "descer",
	["left"] = "esquerda",
	["right"] = "direita",
	["send"] = "enviar",
	["share"] = "compartilhar",
	["upload"] = "nuvem",
	["play"] = "tocar",
	["eye"] = "ver",
	["profile"] = "perfil",
	["idea"] = "ideia",
	["cart"] = "carrinho",
	["location"] = "local",
	["save_list"] = "salvar_lista",
	["up_list"] = "subir_lista",
	["add_list"] = "add_lista",
	["add_location"] = "add_local",
	["heart"] = "coracao",
	["tabs"] = "abas",
}

-- Load a custom PNG via getcustomasset()
local function loadCustomIcon(name, filename)
	if not hasFilesystem or not hasCustomAsset then return nil end
	
	local fullPath = ICONS_FOLDER .. "/" .. filename
	local success, result = pcall(function()
		if not isfile(fullPath) then
			local sourcePath = "RayfieldEnhanced/src/Assets/Icons/" .. filename
			if isfile(sourcePath) then
				local content = readfile(sourcePath)
				if content then
					writefile(fullPath, content)
				end
			end
		end
		if isfile(fullPath) then
			return getcustomasset(fullPath)
		end
		return nil
	end)
	return success and result or nil
end

-- Preload all custom icons
for name, filename in pairs(CUSTOM_ICONS) do
	local path = loadCustomIcon(name, filename)
	if path then
		iconCache[name] = path
	end
end

-- Preload English aliases
for eng, pt in pairs(ENGLISH_ALIASES) do
	if iconCache[pt] then
		iconCache[eng] = iconCache[pt]
	end
end

-- ═══════════════════════════════════════════════════════════════
-- 	PUBLIC API
-- ═══════════════════════════════════════════════════════════════

function Icons:Resolve(name)
	if not name or name == "" then return "" end

	-- Cache hit
	if iconCache[name] then return iconCache[name] end

	-- Direct asset URI
	if type(name) == "string" and (name:find("rbxasset://") == 1 or name:find("rbxthumb://") == 1) then
		iconCache[name] = name; return name
	end

	-- Numeric asset ID
	if tonumber(name) then
		local uri = "rbxassetid://" .. name
		iconCache[name] = uri; return uri
	end

	-- Try lowercase
	local lower = name:lower()
	if iconCache[lower] then
		iconCache[name] = iconCache[lower]; return iconCache[lower]
	end

	-- Try English alias mapping to PT-BR
	if ENGLISH_ALIASES[lower] and iconCache[ENGLISH_ALIASES[lower]] then
		local pt = ENGLISH_ALIASES[lower]
		iconCache[name] = iconCache[pt]; return iconCache[pt]
	end

	return ""
end

function Icons:GetAssetId(name)
	local icon = self:Resolve(name)
	if icon == "" then return "" end
	if icon:find("rbxasset://") == 1 then return icon end
	local id = icon:match("rbxassetid://(%d+)")
	return id and tonumber(id) or icon
end

function Icons:GetIconList()
	local list = {}
	for k, v in pairs(CUSTOM_ICONS) do
		table.insert(list, k)
	end
	table.sort(list)
	return list
end

function Icons:GetEnglishList()
	local list = {}
	for k, v in pairs(ENGLISH_ALIASES) do
		table.insert(list, k .. " -> " .. v)
	end
	table.sort(list)
	return list
end

return Icons