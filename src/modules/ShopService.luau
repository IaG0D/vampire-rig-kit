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
local Players = game:GetService("Players")

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
-- Busca bundle por ID via HTTP (retorna itens individuais do bundle)
-- ════════════════════════════════════════════════════════════════
function ShopService.buscarBundle(bundleId: number): { name: string?, items: { any } }?
	local cacheKey = "bundle_" .. tostring(bundleId)
	local cached = getCached(cacheKey)
	if cached then return cached end

	local url = "https://catalog.roproxy.com/v1/bundles/details?bundleIds=" .. tostring(bundleId)

	local success, response = pcall(function()
		return HttpService:GetAsync(url)
	end)

	if not success or not response then
		warn("[vulpy-rig-kit] buscarBundle: HTTP falhou -", response)
		return nil
	end

	local decodeOk, data = pcall(function()
		return HttpService:JSONDecode(response)
	end)

	if not decodeOk or not data or #data == 0 then
		warn("[vulpy-rig-kit] buscarBundle: JSON invalido")
		return nil
	end

	local bundle = data[1]
	if not bundle or not bundle.items then return nil end

	local items = {}
	for _, raw in bundle.items do
		if raw.id and raw.type == "Asset" then
			-- Tenta pegar info detalhada, mas inclui mesmo se falhar
			local name = raw.name or "Unknown"
			local price = nil
			local assetType = nil
			local ok, info = pcall(function()
				return MarketplaceService:GetProductInfo(raw.id, Enum.InfoType.Asset)
			end)
			if ok and info then
				name = info.Name or name
				price = info.PriceInRobux
				assetType = info.AssetTypeId
			end
			table.insert(items, {
				id = raw.id,
				name = name,
				price = price,
				assetType = assetType,
				thumbnail = "rbxthumb://type=Asset&id=" .. tostring(raw.id) .. "&w=150&h=150",
			})
		end
	end

	local result = { name = bundle.name, items = items }
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
	[Enum.AccessoryType.Shoulder] = "ShouldersAccessory",
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
		local ok, err = pcall(function()
			local current = tostring((desc :: any)[prop] or "")
			if current ~= "" and current ~= "0" then
				(desc :: any)[prop] = current .. "," .. tostring(assetId)
			else
				(desc :: any)[prop] = tostring(assetId)
			end
		end)
		if not ok then
			warn("[vulpy-rig-kit] syncDescription falhou:", prop, err)
		end

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

	-- Verifica se o asset tem body parts (Folders R15/R6)
	local hasBodyParts = assetModel:FindFirstChild("R15ArtistIntent")
		or assetModel:FindFirstChild("R15Fixed")
		or assetModel:FindFirstChild("R6")

	if hasBodyParts then
		-- Body parts: seta no Description + recria o rig inteiro (igual vulpy-avatar-catalog)
		local desc = getOrCreateDescription(rig)
		if desc then
			-- Seta o assetId na propriedade certa do Description
			-- Usa AssetTypeId do GetProductInfo pra saber qual propriedade
			local ASSET_TYPE_MAP = {
				[17] = "Head", [79] = "Head",
				[27] = "Torso",
				[28] = "RightArm", [29] = "LeftArm",
				[30] = "LeftLeg", [31] = "RightLeg",
			}

			local infoOk, info = pcall(function()
				return MarketplaceService:GetProductInfo(assetId, Enum.InfoType.Asset)
			end)
			if infoOk and info and info.AssetTypeId then
				local prop = ASSET_TYPE_MAP[info.AssetTypeId]
				if prop then
					pcall(function() (desc :: any)[prop] = assetId end)
				end
			end

			-- Recria o rig visual a partir do Description atualizado
			local rigCFrame = rig:GetPivot()
			local rigName = rig.Name
			local rigParent = rig.Parent

			local createOk, newModel = pcall(function()
				return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
			end)

			if createOk and newModel then
				-- Mesma logica do RigCreatorService: ancora root, parenta, espera, reaplica

				-- 1. Ancora so o HumanoidRootPart
				local rootPart = newModel:FindFirstChild("HumanoidRootPart")
				if rootPart and rootPart:IsA("BasePart") then
					rootPart.Anchored = true
				end

				-- 2. Parenta temporariamente underground (joints precisam de Parent pra resolver)
				newModel:PivotTo(CFrame.new(0, -500, 0))
				newModel.Parent = rigParent
				task.wait(1)

				-- 3. Reaplica description pra garantir visual
				local newHumanoid = newModel:FindFirstChildOfClass("Humanoid")
				if newHumanoid then
					newHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
					pcall(function()
						newHumanoid:ApplyDescription(desc)
					end)
					task.wait(1)
				end

				-- 4. Ancora tudo e limpa scripts
				for _, part in newModel:GetDescendants() do
					if part:IsA("BasePart") then
						part.Anchored = true
					elseif part:IsA("BaseScript") then
						part:Destroy()
					end
				end

				-- 5. Copia acessorios/roupas do rig antigo pro novo
				-- e sincroniza no Description do novo rig
				local newDesc = getOrCreateDescription(newModel)
				for _, child in rig:GetChildren() do
					if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants")
						or child:IsA("ShirtGraphic") or child:IsA("CharacterMesh") then
						-- Pega o assetId antes de mover
						local childAssetId = nil
						pcall(function()
							childAssetId = child:GetAttribute("VulpyAssetId")
						end)
						child.Parent = newModel
						-- Sincroniza no Description do novo rig
						if childAssetId and newDesc then
							syncDescription(newModel, childAssetId, child)
						end
					end
				end

				-- 6. Posiciona no lugar do rig antigo e remove o antigo
				newModel.Name = rigName
				newModel:PivotTo(rigCFrame)
				rig:Destroy()
				applied = true
			end
		end
	end

	-- Processa filhos diretos (acessorios, roupas, etc. que nao ficam em pastas de body)
	for _, child in assetModel:GetChildren() do
		if child:IsA("Folder") then
			-- Pula folders de body (ja processamos acima)
		elseif child:IsA("Model") then
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
