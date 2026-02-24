--[[
	vulpy-rig-kit | ShopService
	Busca itens do catalogo Roblox via HTTP proxy (roproxy.com).
	Aplica itens no rig via InsertService:LoadAsset() (funciona em edit mode).

	API: catalog.roproxy.com/v1/search/items/details
	Params: category (numerico), subcategory (numerico), keyword, limit, cursor, sortType
]]

local HttpService = game:GetService("HttpService")
local InsertService = game:GetService("InsertService")
local MarketplaceService = game:GetService("MarketplaceService")

local ShopService = {}

-- ════════════════════════════════════════════════════════════════
-- Cache simples
-- ════════════════════════════════════════════════════════════════
local cache: { [string]: { data: any, timestamp: number } } = {}
local CACHE_TTL = 300

local function getCached(key: string): any?
	local entry = cache[key]
	if entry and (os.clock() - entry.timestamp) < CACHE_TTL then
		return entry.data
	end
	return nil
end

local function setCache(key: string, data: any)
	cache[key] = { data = data, timestamp = os.clock() }
end

-- ════════════════════════════════════════════════════════════════
-- Categorias do catalogo
-- categoryId = ID numerico pra API (category=)
-- subcategoryId = ID numerico pra API (subcategory=)
-- assetTypeName = nome para identificar tipo ao aplicar
-- ════════════════════════════════════════════════════════════════
ShopService.CATEGORIES = {
	{
		key = "All", label = "all",
		categoryId = nil,
		subcategories = {},
	},
	{
		key = "Clothing", label = "clothing",
		categoryId = 3,
		subcategories = {
			{ key = "AllCloth", label = "all", subcategoryId = nil },
			{ key = "Shirt", label = "shirts", subcategoryId = 56 },
			{ key = "Pants", label = "pants", subcategoryId = 57 },
			{ key = "TShirt", label = "tshirts", subcategoryId = 55 },
		},
	},
}

-- ════════════════════════════════════════════════════════════════
-- Busca no catalogo via HTTP
-- ════════════════════════════════════════════════════════════════
function ShopService.buscarCatalogo(
	keyword: string?,
	categoryId: number?,
	subcategoryId: number?,
	limit: number?,
	cursor: string?
): { items: { any }, nextPageCursor: string? }

	local cacheKey = (keyword or "") .. "_" .. tostring(categoryId or 0) .. "_" .. tostring(subcategoryId or 0) .. "_" .. (cursor or "")
	local cached = getCached(cacheKey)
	if cached then return cached end

	local params = {}

	if keyword and keyword ~= "" then
		table.insert(params, "keyword=" .. HttpService:UrlEncode(keyword))
	end
	if categoryId then
		table.insert(params, "category=" .. tostring(categoryId))
	end
	if subcategoryId then
		table.insert(params, "subcategory=" .. tostring(subcategoryId))
	end

	table.insert(params, "limit=" .. tostring(limit or 30))
	table.insert(params, "sortType=0")

	if cursor and cursor ~= "" then
		table.insert(params, "cursor=" .. HttpService:UrlEncode(cursor))
	end

	local url = "https://catalog.roproxy.com/v1/search/items/details?" .. table.concat(params, "&")

	local success, response = pcall(function()
		return HttpService:GetAsync(url)
	end)

	if not success or not response then
		warn("[vulpy-rig-kit] ShopService: HTTP falhou -", response)
		return { items = {}, nextPageCursor = nil }
	end

	local decodeOk, data = pcall(function()
		return HttpService:JSONDecode(response)
	end)

	if not decodeOk or not data or not data.data then
		warn("[vulpy-rig-kit] ShopService: JSON invalido")
		return { items = {}, nextPageCursor = nil }
	end

	local items = {}
	for _, raw in data.data do
		table.insert(items, {
			id = raw.id,
			name = raw.name or "Unknown",
			price = raw.lowestPrice or raw.price,
			assetType = raw.assetType,
			itemType = raw.itemType,
			thumbnail = "rbxthumb://type=Asset&id=" .. tostring(raw.id) .. "&w=150&h=150",
		})
	end

	local result = { items = items, nextPageCursor = data.nextPageCursor }
	setCache(cacheKey, result)
	return result
end

-- ════════════════════════════════════════════════════════════════
-- Busca por ID direto via MarketplaceService
-- ════════════════════════════════════════════════════════════════
function ShopService.buscarPorId(assetId: number): any?
	local cacheKey = "id_" .. tostring(assetId)
	local cached = getCached(cacheKey)
	if cached then return cached end

	local success, info = pcall(function()
		return MarketplaceService:GetProductInfo(assetId, Enum.InfoType.Asset)
	end)

	if not success or not info then return nil end

	local result = {
		id = assetId,
		name = info.Name or "Unknown",
		price = info.PriceInRobux,
		assetType = info.AssetTypeId,
		thumbnail = "rbxthumb://type=Asset&id=" .. tostring(assetId) .. "&w=150&h=150",
	}

	setCache(cacheKey, result)
	return result
end

-- ════════════════════════════════════════════════════════════════
-- Mapa: AccessoryType -> propriedade do HumanoidDescription
-- ════════════════════════════════════════════════════════════════
local ACC_DESC_MAP = {
	[Enum.AccessoryType.Hat] = "HatAccessory",
	[Enum.AccessoryType.Hair] = "HairAccessory",
	[Enum.AccessoryType.Face] = "FaceAccessory",
	[Enum.AccessoryType.Neck] = "NeckAccessory",
	[Enum.AccessoryType.Shoulder] = "ShoulderAccessory",
	[Enum.AccessoryType.Front] = "FrontAccessory",
	[Enum.AccessoryType.Back] = "BackAccessory",
	[Enum.AccessoryType.Waist] = "WaistAccessory",
}

-- Helper: pega ou cria o HumanoidDescription
local function getOrCreateDescription(rig: Model): HumanoidDescription?
	local humanoid = rig:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil end

	local desc = humanoid:FindFirstChildOfClass("HumanoidDescription")
	if not desc then
		local ok, newDesc = pcall(function()
			local d = Instance.new("HumanoidDescription")
			d.Parent = humanoid
			return d
		end)
		if ok then
			desc = newDesc
		end
	end
	return desc
end

-- Helper: sincroniza o HumanoidDescription apos mudancas visuais
local function syncDescription(rig: Model, assetId: number, child: Instance)
	local desc = getOrCreateDescription(rig)
	if not desc then return end

	if child:IsA("Accessory") then
		local prop = ACC_DESC_MAP[child.AccessoryType]
		if not prop then prop = "HatAccessory" end
		pcall(function()
			local current = (desc :: any)[prop] or ""
			if current ~= "" then
				(desc :: any)[prop] = current .. "," .. tostring(assetId)
			else
				(desc :: any)[prop] = tostring(assetId)
			end
		end)

	elseif child:IsA("Shirt") then
		pcall(function() desc.Shirt = assetId end)

	elseif child:IsA("Pants") then
		pcall(function() desc.Pants = assetId end)

	elseif child:IsA("ShirtGraphic") then
		pcall(function() desc.GraphicTShirt = assetId end)

	elseif child:IsA("Decal") then
		pcall(function() desc.Face = assetId end)
	end
end

-- ════════════════════════════════════════════════════════════════
-- Aplica item no rig usando InsertService:LoadAsset()
-- Funciona em edit mode (ApplyDescription NAO funciona visualmente)
-- Tambem atualiza o HumanoidDescription para persistir no Play
-- ════════════════════════════════════════════════════════════════
function ShopService.aplicarItem(rig: Model, assetId: number): boolean
	local humanoid = rig:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		warn("[vulpy-rig-kit] aplicarItem: Humanoid nao encontrado")
		return false
	end

	local loadOk, assetModel = pcall(function()
		return InsertService:LoadAsset(assetId)
	end)

	if not loadOk or not assetModel then
		warn("[vulpy-rig-kit] aplicarItem: LoadAsset falhou para", assetId, "-", assetModel)
		return false
	end

	local applied = false

	local function tagItem(instance: Instance)
		pcall(function()
			instance:SetAttribute("VulpyAssetId", assetId)
		end)
	end

	local function applyChild(child: Instance)
		if child:IsA("Accessory") then
			child.Parent = rig
			tagItem(child)
			syncDescription(rig, assetId, child)
			applied = true

		elseif child:IsA("Shirt") then
			local existing = rig:FindFirstChildOfClass("Shirt")
			if existing then existing:Destroy() end
			child.Parent = rig
			tagItem(child)
			syncDescription(rig, assetId, child)
			applied = true

		elseif child:IsA("Pants") then
			local existing = rig:FindFirstChildOfClass("Pants")
			if existing then existing:Destroy() end
			child.Parent = rig
			tagItem(child)
			syncDescription(rig, assetId, child)
			applied = true

		elseif child:IsA("ShirtGraphic") then
			local existing = rig:FindFirstChildOfClass("ShirtGraphic")
			if existing then existing:Destroy() end
			child.Parent = rig
			tagItem(child)
			syncDescription(rig, assetId, child)
			applied = true

		elseif child:IsA("Decal") then
			local head = rig:FindFirstChild("Head")
			if head then
				local existing = head:FindFirstChild("face") or head:FindFirstChild("Face")
				if existing then existing:Destroy() end
				child.Name = "face"
				child.Parent = head
				tagItem(child)
				syncDescription(rig, assetId, child)
				applied = true
			end

		elseif child:IsA("SpecialMesh") then
			local head = rig:FindFirstChild("Head")
			if head then
				local existing = head:FindFirstChildOfClass("SpecialMesh")
				if existing then existing:Destroy() end
				child.Parent = head
				applied = true
			end
		end
	end

	for _, child in assetModel:GetChildren() do
		if child:IsA("Model") then
			for _, sub in child:GetChildren() do
				applyChild(sub)
			end
		else
			applyChild(child)
		end
	end

	assetModel:Destroy()

	if not applied then
		warn("[vulpy-rig-kit] aplicarItem: Nenhum item reconhecido em", assetId)
	end

	return applied
end

-- ════════════════════════════════════════════════════════════════
-- Limpa tudo do rig (acessorios, roupas, face) mantendo o corpo
-- Tambem limpa o HumanoidDescription
-- ════════════════════════════════════════════════════════════════
-- Partes do corpo que devem ser mantidas (R6 + R15)
local BODY_PARTS = {
	HumanoidRootPart = true,
	Head = true,
	-- R6
	Torso = true,
	["Left Arm"] = true,
	["Right Arm"] = true,
	["Left Leg"] = true,
	["Right Leg"] = true,
	-- R15
	UpperTorso = true,
	LowerTorso = true,
	LeftUpperArm = true,
	LeftLowerArm = true,
	LeftHand = true,
	RightUpperArm = true,
	RightLowerArm = true,
	RightHand = true,
	LeftUpperLeg = true,
	LeftLowerLeg = true,
	LeftFoot = true,
	RightUpperLeg = true,
	RightLowerLeg = true,
	RightFoot = true,
}

function ShopService.limparRig(rig: Model): number
	-- PASSO 1: Salva dados do CORPO e recria o HumanoidDescription do zero
	-- Isso garante que nenhum dado de roupa/acessorio/layered persiste
	local humanoid = rig:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local desc = humanoid:FindFirstChildOfClass("HumanoidDescription")
		if desc then
			-- Salva props do corpo antes de destruir
			local bodyData = {}
			local bodyProps = {
				"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg",
				"HeadColor", "TorsoColor", "LeftArmColor", "RightArmColor", "LeftLegColor", "RightLegColor",
				"HeadScale", "BodyTypeScale", "DepthScale", "HeightScale",
				"ProportionScale", "WidthScale",
			}
			for _, prop in bodyProps do
				pcall(function()
					bodyData[prop] = (desc :: any)[prop]
				end)
			end

			-- Destroi o Description antigo (leva TUDO com ele)
			desc:Destroy()

			-- Cria um novo limpo e restaura APENAS o corpo
			local newDesc = Instance.new("HumanoidDescription")
			for prop, value in bodyData do
				pcall(function()
					(newDesc :: any)[prop] = value
				end)
			end
			newDesc.Parent = humanoid
		end
	end

	-- PASSO 2: Remove TUDO que nao eh corpo nem Humanoid
	local removed = 0

	for _, child in rig:GetChildren() do
		local keep = false

		-- Manter Humanoid e BodyColors
		if child:IsA("Humanoid") or child:IsA("BodyColors") then
			keep = true
		-- Manter partes do corpo (BasePart com nome conhecido)
		elseif child:IsA("BasePart") and BODY_PARTS[child.Name] then
			keep = true
		end

		if not keep then
			child:Destroy()
			removed += 1
		end
	end

	-- PASSO 3: Limpar decals/textures/wraplayers de dentro das partes do corpo
	for _, child in rig:GetDescendants() do
		if child:IsA("Decal") or child:IsA("Texture") or child:IsA("WrapLayer") then
			child:Destroy()
			removed += 1
		end
	end

	return removed
end

return ShopService
